import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../models/bangkok_places.dart';
import '../services/routing_service.dart';
import '../services/geocoding_service.dart';
import '../state/user_profile_provider.dart';
import '../widgets/widgets.dart';

enum TravelMode { car, transit, motorbike, walk }

class MapScreen extends StatefulWidget {
  final BangkokPlace? initialSelectedPlace;

  const MapScreen({super.key, this.initialSelectedPlace});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> with TickerProviderStateMixin {
  final MapController _mapController = MapController();
  final TextEditingController _searchCtrl = TextEditingController();

  static const LatLng _bangkokCenter = LatLng(13.7465, 100.5349);
  static const LatLng _userSimulatedLocation =
      LatLng(13.7367, 100.5331); // Pathum Wan / Central Bangkok

  String _selectedRegion = 'All';
  BangkokPlace? _selectedPlace;
  bool _showRoute = false;
  TravelMode _travelMode = TravelMode.car;

  // Real road route data
  List<LatLng> _routePoints = [];
  double _routeDistanceKm = 0.0;
  double _routeDurationMins = 0.0;
  List<String> _routeTurnSteps = [];
  bool _isLoadingRoute = false;

  // Search & Geocoding suggestions
  List<BangkokPlace> _liveSuggestions = [];
  bool _isSearching = false;
  Timer? _searchDebounce;

  late final AnimationController _pulseCtrl;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();

    // Defer _selectPlace until after the FlutterMap widget is first rendered,
    // otherwise MapController throws "rendered at least once" error.
    if (widget.initialSelectedPlace != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _selectPlace(widget.initialSelectedPlace!);
      });
    }
  }

  @override
  void dispose() {
    _mapController.dispose();
    _searchCtrl.dispose();
    _pulseCtrl.dispose();
    _searchDebounce?.cancel();
    super.dispose();
  }

  void _animatedMapMove(LatLng destLocation, double destZoom) {
    final latTween = Tween<double>(
      begin: _mapController.camera.center.latitude,
      end: destLocation.latitude,
    );
    final lngTween = Tween<double>(
      begin: _mapController.camera.center.longitude,
      end: destLocation.longitude,
    );
    final zoomTween = Tween<double>(
      begin: _mapController.camera.zoom,
      end: destZoom,
    );

    final controller = AnimationController(
      duration: const Duration(milliseconds: 650),
      vsync: this,
    );
    final animation =
        CurvedAnimation(parent: controller, curve: Curves.easeInOutCubic);

    controller.addListener(() {
      _mapController.move(
        LatLng(latTween.evaluate(animation), lngTween.evaluate(animation)),
        zoomTween.evaluate(animation),
      );
    });

    animation.addStatusListener((status) {
      if (status == AnimationStatus.completed ||
          status == AnimationStatus.dismissed) {
        controller.dispose();
      }
    });

    controller.forward();
  }

  /// Calculates real road directions following actual streets, bridges, and highways.
  Future<void> _fetchRealRoadRoute(BangkokPlace place) async {
    setState(() {
      _isLoadingRoute = true;
      _showRoute = true;
    });

    final result = await RoutingService.getDirections(
      origin: _userSimulatedLocation,
      destination: place.location,
    );

    if (!mounted) return;
    setState(() {
      _routePoints = result.points;
      _routeDistanceKm = result.distanceKm;
      _routeDurationMins = result.durationMinutes;
      _routeTurnSteps = result.turnSteps;
      _isLoadingRoute = false;
    });
  }

  void _onSearchChanged(String query) {
    _searchDebounce?.cancel();
    if (query.trim().isEmpty) {
      setState(() {
        _liveSuggestions = [];
        _isSearching = false;
      });
      return;
    }

    setState(() => _isSearching = true);
    _searchDebounce = Timer(const Duration(milliseconds: 350), () async {
      final results =
          await GeocodingService.searchEverywhereInThailand(query);
      if (!mounted) return;
      setState(() {
        _liveSuggestions = results;
        _isSearching = false;
      });
    });
  }

  void _selectPlace(BangkokPlace place) {
    setState(() {
      _selectedPlace = place;
      _liveSuggestions = [];
      _searchCtrl.text = place.name;
    });

    _fetchRealRoadRoute(place);

    const distCalc = Distance();
    final km = distCalc.as(
        LengthUnit.Kilometer, _userSimulatedLocation, place.location);
    final zoomLevel = km > 120 ? 8.0 : (km > 25 ? 11.0 : 14.5);

    _animatedMapMove(place.location, zoomLevel);
  }

  String _formatDuration(double baseMinutes, TravelMode mode) {
    double mins = baseMinutes;
    switch (mode) {
      case TravelMode.car:
        break;
      case TravelMode.transit:
        mins = baseMinutes * 1.15;
        break;
      case TravelMode.motorbike:
        mins = baseMinutes * 0.75; // Lane filtering
        break;
      case TravelMode.walk:
        mins = _routeDistanceKm * 12.5; // ~4.8 km/h
        break;
    }

    final total = mins.round();
    if (total < 60) return '$total min';
    final h = total ~/ 60;
    final m = total % 60;
    return '${h}h ${m}m';
  }

  /// Free real-world tile URLs — no API key required.
  /// Light: OpenStreetMap standard tiles (Thai labels, looks like picture 2)
  /// Dark : OpenStreetMap with dark overlay (free, no signup)
  String _getTileUrl(bool isDark) {
    if (isDark) {
      // OpenStreetMap dark variant — free, no API key, dark background
      return 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png';
    }
    // OpenStreetMap standard — free, no API key, Thai labels, looks like Google Maps
    return 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png';
  }

  List<BangkokPlace> get _visiblePlaces {
    final query = _searchCtrl.text.trim().toLowerCase();
    final all = [...kBangkokPlaces, ...GeocodingService.kSoiAndVillagePlaces];

    return all.where((p) {
      final matchRegion =
          _selectedRegion == 'All' || p.region == _selectedRegion;
      final matchQuery = query.isEmpty ||
          p.name.toLowerCase().contains(query) ||
          p.thaiName.toLowerCase().contains(query) ||
          p.province.toLowerCase().contains(query) ||
          p.district.toLowerCase().contains(query);
      return matchRegion && matchQuery;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final userNotifier = UserProfileScope.of(context);
    final isDarkMode = userNotifier.profile.isDarkMode;
    final isSaved =
        _selectedPlace != null && userNotifier.isPlaceSaved(_selectedPlace!.id);

    return Scaffold(
      body: Stack(
        children: [
          // ── Flutter Map (Day & Dark Mode) ──────────────────────
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _bangkokCenter,
              initialZoom: 13.5,
              minZoom: 5.5,
              maxZoom: 18.0,
              interactionOptions: const InteractionOptions(
                flags: InteractiveFlag.all,
              ),
              onTap: (_, __) {
                if (_liveSuggestions.isNotEmpty) {
                  setState(() => _liveSuggestions = []);
                }
              },
            ),
            children: [
              TileLayer(
                urlTemplate: _getTileUrl(isDarkMode),
                // OpenStreetMap standard sub-domains for faster parallel tile loading
                subdomains: const ['a', 'b', 'c'],
                userAgentPackageName: 'com.example.mapping_v1',
                maxZoom: 19,
              ),

              // ── REAL ROAD ROUTE POLYLINES (Following Actual Streets) ──
              if (_showRoute && _routePoints.isNotEmpty)
                PolylineLayer(
                  polylines: [
                    // Outer neon aura glow in Dark Mode
                    Polyline(
                      points: _routePoints,
                      strokeWidth: isDarkMode ? 10.0 : 7.0,
                      color: isDarkMode
                          ? const Color(0xFF00E5FF).withValues(alpha: 0.35)
                          : cs.primary.withValues(alpha: 0.25),
                    ),
                    // High-contrast primary road path
                    Polyline(
                      points: _routePoints,
                      strokeWidth: 4.8,
                      color: isDarkMode
                          ? const Color(0xFF00E5FF)
                          : const Color(0xFF2563EB),
                      pattern: const StrokePattern.solid(),
                    ),
                  ],
                ),

              // ── Markers Layer ──────────────────────────────────
              MarkerLayer(
                markers: [
                  // User Location (Pulsing Radar Marker)
                  Marker(
                    point: _userSimulatedLocation,
                    width: 60,
                    height: 60,
                    child: AnimatedBuilder(
                      animation: _pulseCtrl,
                      builder: (ctx, _) {
                        final val = _pulseCtrl.value;
                        return Stack(
                          alignment: Alignment.center,
                          children: [
                            Container(
                              width: 32 + (val * 24),
                              height: 32 + (val * 24),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: (isDarkMode
                                        ? const Color(0xFF00E5FF)
                                        : const Color(0xFF3B82F6))
                                    .withValues(alpha: (1.0 - val) * 0.45),
                              ),
                            ),
                            Container(
                              width: 22,
                              height: 22,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: isDarkMode
                                    ? const Color(0xFF00E5FF)
                                    : const Color(0xFF2563EB),
                                border: Border.all(
                                  color: Colors.white,
                                  width: 3.5,
                                ),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Colors.black45,
                                    blurRadius: 6,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),

                  // Destination and Location Markers
                  ..._visiblePlaces.map((place) {
                    final isCurrentSelected = _selectedPlace?.id == place.id;
                    return Marker(
                      point: place.location,
                      width: isCurrentSelected ? 56 : 46,
                      height: isCurrentSelected ? 56 : 46,
                      child: GestureDetector(
                        onTap: () => _selectPlace(place),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          decoration: BoxDecoration(
                            color: isCurrentSelected
                                ? (isDarkMode
                                    ? const Color(0xFF00E5FF)
                                    : place.color)
                                : cs.surfaceContainerHigh,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isCurrentSelected
                                  ? Colors.white
                                  : place.color,
                              width: isCurrentSelected ? 3 : 2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: (isDarkMode && isCurrentSelected
                                        ? const Color(0xFF00E5FF)
                                        : place.color)
                                    .withValues(
                                  alpha: isCurrentSelected ? 0.75 : 0.35,
                                ),
                                blurRadius: isCurrentSelected ? 18 : 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Center(
                            child: Icon(
                              place.icon,
                              color: isCurrentSelected
                                  ? (isDarkMode ? Colors.black : Colors.white)
                                  : place.color,
                              size: isCurrentSelected ? 26 : 22,
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ],
          ),

          // ── Top Search Bar (Everywhere in Thailand: Sois, Villages) ──
          SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: isDarkMode
                        ? const Color(0xFF1E1B24).withValues(alpha: 0.95)
                        : Colors.white.withValues(alpha: 0.96),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: isDarkMode
                          ? const Color(0xFF00E5FF).withValues(alpha: 0.3)
                          : cs.outlineVariant.withValues(alpha: 0.3),
                      width: isDarkMode ? 1.5 : 1.0,
                    ),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 16,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      const SizedBox(width: 14),
                      Icon(
                        Icons.search_rounded,
                        color: isDarkMode
                            ? const Color(0xFF00E5FF)
                            : cs.primary,
                        size: 24,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextField(
                          controller: _searchCtrl,
                          onChanged: _onSearchChanged,
                          decoration: InputDecoration(
                            hintText:
                                'Search any Soi, Village, Town, or Landmark…',
                            hintStyle: TextStyle(
                              color: cs.onSurfaceVariant.withValues(alpha: 0.7),
                              fontSize: 13,
                            ),
                            border: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            contentPadding:
                                const EdgeInsets.symmetric(vertical: 14),
                            filled: false,
                          ),
                        ),
                      ),
                      if (_isSearching)
                        const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      if (_searchCtrl.text.isNotEmpty)
                        IconButton(
                          icon: const Icon(Icons.close_rounded, size: 20),
                          onPressed: () {
                            _searchCtrl.clear();
                            setState(() => _liveSuggestions = []);
                          },
                        ),
                      // Dedicated Map Dark Mode Toggle
                      Container(
                        margin: const EdgeInsets.only(right: 8),
                        decoration: BoxDecoration(
                          color: isDarkMode
                              ? const Color(0xFF00E5FF).withValues(alpha: 0.2)
                              : cs.surfaceContainerHigh,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: IconButton(
                          tooltip: isDarkMode
                              ? 'Switch Map to Daylight'
                              : 'Switch Map to Dark Mode',
                          icon: Icon(
                            isDarkMode
                                ? Icons.dark_mode_rounded
                                : Icons.light_mode_rounded,
                            color: isDarkMode
                                ? const Color(0xFF00E5FF)
                                : const Color(0xFFF59E0B),
                            size: 20,
                          ),
                          onPressed: () => userNotifier.toggleThemeMode(),
                        ),
                      ),
                    ],
                  ),
                ),

                // Live Suggestions List (Sois, Villages, Towns everywhere)
                if (_liveSuggestions.isNotEmpty)
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    constraints: const BoxConstraints(maxHeight: 280),
                    decoration: BoxDecoration(
                      color: isDarkMode
                          ? const Color(0xFF1E1B24).withValues(alpha: 0.98)
                          : Colors.white.withValues(alpha: 0.98),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: isDarkMode
                            ? const Color(0xFF00E5FF).withValues(alpha: 0.3)
                            : cs.outlineVariant.withValues(alpha: 0.3),
                      ),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black45,
                          blurRadius: 20,
                          offset: Offset(0, 8),
                        ),
                      ],
                    ),
                    child: ListView.separated(
                      shrinkWrap: true,
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      itemCount: _liveSuggestions.length,
                      separatorBuilder: (_, __) => Divider(
                        height: 1,
                        indent: 56,
                        color: cs.outlineVariant.withValues(alpha: 0.2),
                      ),
                      itemBuilder: (ctx, i) {
                        final p = _liveSuggestions[i];
                        const distCalc = Distance();
                        final km = distCalc.as(LengthUnit.Kilometer,
                            _userSimulatedLocation, p.location);

                        return ListTile(
                          leading: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: p.color.withValues(alpha: 0.16),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(p.icon, color: p.color, size: 20),
                          ),
                          title: Text(
                            p.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          subtitle: Text(
                            '${p.thaiName} • ${p.province}',
                            style: TextStyle(
                              fontSize: 12,
                              color: cs.onSurfaceVariant,
                            ),
                          ),
                          trailing: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                '${km.toStringAsFixed(0)} km',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: isDarkMode
                                      ? const Color(0xFF00E5FF)
                                      : cs.primary,
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                p.district,
                                style: TextStyle(
                                  fontSize: 10,
                                  color: cs.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                          onTap: () => _selectPlace(p),
                        );
                      },
                    ),
                  ),

                // Region Filter Chips (All, Bangkok, North, South, East, Central, Isan)
                SizedBox(
                  height: 38,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    children: [
                      _buildRegionChip('All', 'All Thailand 🇹🇭', cs, isDarkMode),
                      _buildRegionChip('Bangkok', 'Bangkok City', cs, isDarkMode),
                      _buildRegionChip('North', 'Chiang Mai & North', cs, isDarkMode),
                      _buildRegionChip('South', 'Phuket & Islands', cs, isDarkMode),
                      _buildRegionChip('East', 'Pattaya & East', cs, isDarkMode),
                      _buildRegionChip('Central', 'Ayutthaya & Central', cs, isDarkMode),
                      _buildRegionChip('Isan', 'Northeast (Isan)', cs, isDarkMode),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ── Floating Action Buttons (Right Side) ─────────────────
          Positioned(
            right: 16,
            bottom: _selectedPlace != null ? 365 : 28,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Map Dark Mode Quick Button
                _buildMapFab(
                  icon: isDarkMode
                      ? Icons.dark_mode_rounded
                      : Icons.light_mode_rounded,
                  tooltip: isDarkMode ? 'Dark Mode Active' : 'Light Mode Active',
                  color: isDarkMode
                      ? const Color(0xFF00E5FF)
                      : const Color(0xFFF59E0B),
                  onTap: () => userNotifier.toggleThemeMode(),
                  cs: cs,
                  isDarkMode: isDarkMode,
                ),
                const SizedBox(height: 10),

                // Center to Bangkok Location
                _buildMapFab(
                  icon: Icons.my_location_rounded,
                  tooltip: 'My Location (Bangkok)',
                  onTap: () {
                    _animatedMapMove(_userSimulatedLocation, 14.5);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text(
                          'Centered to your location in Bangkok, Thailand 🇹🇭',
                        ),
                        duration: const Duration(seconds: 1),
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    );
                  },
                  cs: cs,
                  isDarkMode: isDarkMode,
                ),
                const SizedBox(height: 10),

                // Zoom In
                _buildMapFab(
                  icon: Icons.add_rounded,
                  tooltip: 'Zoom In',
                  onTap: () {
                    final z = _mapController.camera.zoom + 1;
                    _mapController.move(_mapController.camera.center, z);
                  },
                  cs: cs,
                  isDarkMode: isDarkMode,
                ),
                const SizedBox(height: 10),

                // Zoom Out
                _buildMapFab(
                  icon: Icons.remove_rounded,
                  tooltip: 'Zoom Out',
                  onTap: () {
                    final z = _mapController.camera.zoom - 1;
                    _mapController.move(_mapController.camera.center, z);
                  },
                  cs: cs,
                  isDarkMode: isDarkMode,
                ),
              ],
            ),
          ),

          // ── Turn-by-Turn Guidance Banner ─────────────────────────
          if (_showRoute && _selectedPlace != null && _routeTurnSteps.isNotEmpty)
            Positioned(
              left: 16,
              right: 16,
              top: 154,
              child: _buildNavigationBanner(cs, isDarkMode),
            ),

          // ── Bottom Destination Card with Real Road Distance & Directions ──
          if (_selectedPlace != null)
            Positioned(
              left: 16,
              right: 16,
              bottom: 16,
              child: _buildPlaceCard(
                _selectedPlace!,
                isSaved,
                userNotifier,
                cs,
                isDarkMode,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildRegionChip(
      String key, String label, ColorScheme cs, bool isDarkMode) {
    final isSelected = _selectedRegion == key;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: () {
          setState(() => _selectedRegion = key);
          if (key == 'North') {
            _animatedMapMove(const LatLng(18.7883, 98.9853), 9.0);
          } else if (key == 'South') {
            _animatedMapMove(const LatLng(7.8804, 98.3923), 8.5);
          } else if (key == 'East') {
            _animatedMapMove(const LatLng(12.9276, 100.8771), 10.0);
          } else if (key == 'Central') {
            _animatedMapMove(const LatLng(14.3532, 100.5684), 10.0);
          } else if (key == 'Bangkok') {
            _animatedMapMove(_bangkokCenter, 13.5);
          }
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: isSelected
                ? (isDarkMode ? const Color(0xFF00E5FF) : cs.primary)
                : (isDarkMode
                    ? const Color(0xFF1E1B24).withValues(alpha: 0.9)
                    : Colors.white.withValues(alpha: 0.9)),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected
                  ? Colors.transparent
                  : cs.outlineVariant.withValues(alpha: 0.25),
            ),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected
                    ? (isDarkMode ? Colors.black : Colors.white)
                    : cs.onSurface,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMapFab({
    required IconData icon,
    required String tooltip,
    required VoidCallback onTap,
    required ColorScheme cs,
    required bool isDarkMode,
    Color? color,
  }) {
    return Material(
      color: isDarkMode
          ? const Color(0xFF1E1B24).withValues(alpha: 0.92)
          : Colors.white.withValues(alpha: 0.94),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(
          color: isDarkMode
              ? const Color(0xFF00E5FF).withValues(alpha: 0.3)
              : cs.outlineVariant.withValues(alpha: 0.25),
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          width: 46,
          height: 46,
          alignment: Alignment.center,
          child: Icon(icon, size: 22, color: color ?? cs.onSurface),
        ),
      ),
    );
  }

  Widget _buildNavigationBanner(ColorScheme cs, bool isDarkMode) {
    final step = _routeTurnSteps.isNotEmpty
        ? _routeTurnSteps.first
        : 'Follow real road directions toward destination';

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDarkMode
              ? [const Color(0xFF0F172A), const Color(0xFF1E1B4B)]
              : [cs.primary, cs.tertiary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        border: isDarkMode
            ? Border.all(color: const Color(0xFF00E5FF).withValues(alpha: 0.4))
            : null,
        boxShadow: const [
          BoxShadow(
            color: Colors.black38,
            blurRadius: 14,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isDarkMode
                  ? const Color(0xFF00E5FF).withValues(alpha: 0.2)
                  : Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.turn_right_rounded,
              color: isDarkMode ? const Color(0xFF00E5FF) : Colors.white,
              size: 26,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  step,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _isLoadingRoute
                      ? 'Calculating real road directions…'
                      : 'Real Road Route • ${_routeDistanceKm.toStringAsFixed(1)} km via Highways & Streets',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.85),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close_rounded, color: Colors.white),
            onPressed: () => setState(() => _showRoute = false),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceCard(
    BangkokPlace place,
    bool isSaved,
    UserProfileNotifier userNotifier,
    ColorScheme cs,
    bool isDarkMode,
  ) {
    final distText = _routeDistanceKm > 0
        ? '${_routeDistanceKm.toStringAsFixed(1)} km'
        : 'Calculating…';
    final durationText = _routeDurationMins > 0
        ? _formatDuration(_routeDurationMins, _travelMode)
        : 'Calculating…';

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDarkMode
            ? const Color(0xFF1E1B24).withValues(alpha: 0.98)
            : Colors.white.withValues(alpha: 0.97),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDarkMode
              ? const Color(0xFF00E5FF).withValues(alpha: 0.35)
              : cs.outlineVariant.withValues(alpha: 0.25),
        ),
        boxShadow: const [
          BoxShadow(
            color: Colors.black45,
            blurRadius: 24,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row with Building Image & Info
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Real Building / Place Picture
              GestureDetector(
                onTap: () => _showPlaceDetailModal(context, place),
                child: Tooltip(
                  message: 'Tap to view ${place.name} building & details',
                  child: Hero(
                    tag: 'place_card_img_${place.id}',
                    child: PlaceImage(
                      place: place,
                      width: 60,
                      height: 60,
                      borderRadius: BorderRadius.circular(16),
                      showBadge: true,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      place.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${place.thaiName} • ${place.province}',
                      style: TextStyle(
                        fontSize: 12,
                        color: cs.onSurfaceVariant,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    // Category & Rating pill
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: place.color.withValues(alpha: 0.16),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            place.category,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: place.color,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF59E0B)
                                .withValues(alpha: 0.16),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.star_rounded,
                                  size: 12, color: Color(0xFFF59E0B)),
                              const SizedBox(width: 2),
                              Text(
                                '${place.rating}',
                                style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFFF59E0B),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: Icon(
                  isSaved
                      ? Icons.bookmark_rounded
                      : Icons.bookmark_border_rounded,
                  color:
                      isSaved ? const Color(0xFFF59E0B) : cs.onSurfaceVariant,
                ),
                onPressed: () {
                  userNotifier.toggleSavePlace(place.id);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        isSaved
                            ? 'Removed from saved places'
                            : 'Saved to favorites!',
                      ),
                      duration: const Duration(seconds: 1),
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  );
                },
              ),
              // ── X Close Button ──────────────────────────────────
              GestureDetector(
                onTap: () => setState(() {
                  _selectedPlace = null;
                  _showRoute = false;
                  _routePoints = [];
                  _routeDistanceKm = 0.0;
                  _routeDurationMins = 0.0;
                  _routeTurnSteps = [];
                  _searchCtrl.clear();
                  _liveSuggestions = [];
                }),
                child: Container(
                  width: 32,
                  height: 32,
                  margin: const EdgeInsets.only(right: 4),
                  decoration: BoxDecoration(
                    color: isDarkMode
                        ? Colors.white.withValues(alpha: 0.08)
                        : cs.surfaceContainerHigh,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.close_rounded,
                    size: 18,
                    color: isDarkMode
                        ? Colors.white.withValues(alpha: 0.7)
                        : cs.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),

          // ── "Why Visit" Recommendation Highlight Box ──────────
          GestureDetector(
            onTap: () => _showPlaceDetailModal(context, place),
            child: Container(
              margin: const EdgeInsets.only(top: 10, bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: isDarkMode
                    ? const Color(0xFF262230)
                    : const Color(0xFFFFFBEB),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: const Color(0xFFF59E0B).withValues(alpha: 0.35),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF59E0B).withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.auto_awesome_rounded,
                      size: 14,
                      color: Color(0xFFF59E0B),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Why we recommend visiting:',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFF59E0B),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          place.description,
                          style: TextStyle(
                            fontSize: 11,
                            height: 1.25,
                            color: isDarkMode
                                ? Colors.white.withValues(alpha: 0.9)
                                : const Color(0xFF78350F),
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(
                    Icons.chevron_right_rounded,
                    size: 16,
                    color: Color(0xFFF59E0B),
                  ),
                ],
              ),
            ),
          ),

          // Travel Mode Selector (Drive, Transit, Bike, Walk)
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: isDarkMode
                  ? const Color(0xFF2A2633)
                  : cs.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                _buildModeBtn(TravelMode.car, Icons.directions_car_rounded,
                    'Drive', isDarkMode),
                _buildModeBtn(TravelMode.transit,
                    Icons.directions_transit_rounded, 'Transit', isDarkMode),
                _buildModeBtn(TravelMode.motorbike, Icons.two_wheeler_rounded,
                    'Bike', isDarkMode),
                _buildModeBtn(TravelMode.walk, Icons.directions_walk_rounded,
                    'Walk', isDarkMode),
              ],
            ),
          ),
          const SizedBox(height: 10),

          // Real Road Distance & Travel Duration Badges
          Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: isDarkMode
                      ? const Color(0xFF00E5FF).withValues(alpha: 0.18)
                      : cs.primaryContainer.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.route_rounded,
                      size: 16,
                      color: isDarkMode
                          ? const Color(0xFF00E5FF)
                          : cs.primary,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      distText,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        color: isDarkMode
                            ? const Color(0xFF00E5FF)
                            : cs.primary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.timer_outlined,
                        size: 16, color: Color(0xFF10B981)),
                    const SizedBox(width: 6),
                    Text(
                      durationText,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        color: Color(0xFF10B981),
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFF59E0B).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.star_rounded,
                        color: Color(0xFFF59E0B), size: 16),
                    const SizedBox(width: 4),
                    Text(
                      '${place.rating}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        color: Color(0xFFF59E0B),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // Action Buttons: Real Direction Path & Turn-by-Turn Steps
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    setState(() => _showRoute = true);
                    _fetchRealRoadRoute(place);
                    _animatedMapMove(place.location, 13.0);
                  },
                  icon: const Icon(Icons.navigation_rounded, size: 18),
                  label: Text(_showRoute ? 'Road Route Active' : 'Show Road Route'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isDarkMode
                        ? const Color(0xFF00E5FF)
                        : cs.primary,
                    foregroundColor:
                        isDarkMode ? Colors.black : Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    minimumSize: const Size(0, 46),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              OutlinedButton.icon(
                onPressed: () => _showPlaceDetailModal(context, place),
                icon: const Icon(Icons.turn_slight_right_rounded, size: 18),
                label: const Text('Directions'),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(0, 46),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  side: BorderSide(
                    color: isDarkMode
                        ? const Color(0xFF00E5FF).withValues(alpha: 0.4)
                        : cs.outlineVariant.withValues(alpha: 0.3),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildModeBtn(
      TravelMode mode, IconData icon, String label, bool isDarkMode) {
    final cs = Theme.of(context).colorScheme;
    final isSelected = _travelMode == mode;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _travelMode = mode),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected
                ? (isDarkMode ? const Color(0xFF00E5FF) : cs.primary)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 16,
                color: isSelected
                    ? (isDarkMode ? Colors.black : Colors.white)
                    : cs.onSurfaceVariant,
              ),
              const SizedBox(width: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  color: isSelected
                      ? (isDarkMode ? Colors.black : Colors.white)
                      : cs.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showPlaceDetailModal(BuildContext context, BangkokPlace place) {
    final cs = Theme.of(context).colorScheme;
    final userNotifier = UserProfileScope.of(context);
    final isDarkMode = userNotifier.profile.isDarkMode;

    final turns = _routeTurnSteps.isNotEmpty
        ? _routeTurnSteps
        : place.navigationSteps;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDarkMode
          ? const Color(0xFF1E1B24)
          : cs.surfaceContainerHigh,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) {
        return DraggableScrollableSheet(
          initialChildSize: 0.72,
          maxChildSize: 0.94,
          minChildSize: 0.45,
          expand: false,
          builder: (_, controller) {
            return ListView(
              controller: controller,
              padding: const EdgeInsets.all(24),
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 5,
                    decoration: BoxDecoration(
                      color: cs.outlineVariant.withValues(alpha: 0.4),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // ── Hero Picture of the Place / Building ──────────
                Stack(
                  children: [
                    PlaceImage(
                      place: place,
                      width: double.infinity,
                      height: 200,
                      borderRadius: BorderRadius.circular(22),
                    ),
                    // Gradient overlay at bottom of photo
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(22),
                          gradient: LinearGradient(
                            colors: [
                              Colors.transparent,
                              Colors.black.withValues(alpha: 0.78),
                            ],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                        ),
                      ),
                    ),
                    // Top badges over photo
                    Positioned(
                      top: 12,
                      left: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.65),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.white24),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(place.icon, size: 14, color: Colors.white),
                            const SizedBox(width: 6),
                            Text(
                              place.category,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      top: 12,
                      right: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.65),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.white24),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.star_rounded,
                                size: 16, color: Color(0xFFF59E0B)),
                            const SizedBox(width: 4),
                            Text(
                              '${place.rating} (${place.reviewCount})',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    // Bottom caption over photo
                    Positioned(
                      bottom: 14,
                      left: 16,
                      right: 16,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            place.name,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              shadows: [
                                Shadow(color: Colors.black87, blurRadius: 4),
                              ],
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${place.thaiName} • ${place.province}',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.88),
                              fontSize: 13,
                              shadows: const [
                                Shadow(color: Colors.black87, blurRadius: 4),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),

                // ── "Why You Need To Visit" Section ──────────────
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDarkMode
                        ? const Color(0xFF262230)
                        : const Color(0xFFFFFBEB),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: const Color(0xFFF59E0B).withValues(alpha: 0.35),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.auto_awesome_rounded,
                            color: Color(0xFFF59E0B),
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Why You Need To Visit',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: isDarkMode
                                  ? const Color(0xFFF59E0B)
                                  : const Color(0xFFB45309),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        place.description,
                        style: TextStyle(
                          fontSize: 14,
                          height: 1.5,
                          color: isDarkMode
                              ? Colors.white.withValues(alpha: 0.95)
                              : const Color(0xFF78350F),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: place.highlights.map((h) {
                          return Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF59E0B)
                                  .withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.check_circle_rounded,
                                    size: 13, color: Color(0xFFF59E0B)),
                                const SizedBox(width: 6),
                                Text(
                                  h,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: isDarkMode
                                        ? Colors.white
                                        : const Color(0xFF92400E),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),

                // Destination Info Grid: Open Hours, Price, Transit
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isDarkMode
                              ? const Color(0xFF2A2633)
                              : cs.surfaceContainerHigh,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.access_time_rounded,
                                    size: 15, color: cs.primary),
                                const SizedBox(width: 6),
                                Text(
                                  'Hours',
                                  style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: cs.onSurfaceVariant),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              place.openHours,
                              style: const TextStyle(
                                  fontSize: 12, fontWeight: FontWeight.bold),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isDarkMode
                              ? const Color(0xFF2A2633)
                              : cs.surfaceContainerHigh,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.payments_rounded,
                                    size: 15, color: Color(0xFF10B981)),
                                const SizedBox(width: 6),
                                Text(
                                  'Price',
                                  style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: cs.onSurfaceVariant),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              place.price,
                              style: const TextStyle(
                                  fontSize: 12, fontWeight: FontWeight.bold),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),

                // Real Road Turn-by-Turn Steps
                Text(
                  'Real Road Directions & Route Turns',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: cs.onSurface,
                  ),
                ),
                const SizedBox(height: 12),
                ...turns.asMap().entries.map((entry) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 26,
                          height: 26,
                          decoration: BoxDecoration(
                            color: isDarkMode
                                ? const Color(0xFF00E5FF).withValues(alpha: 0.2)
                                : cs.primaryContainer,
                            shape: BoxShape.circle,
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            '${entry.key + 1}',
                            style: TextStyle(
                              color: isDarkMode
                                  ? const Color(0xFF00E5FF)
                                  : cs.primary,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            entry.value,
                            style: const TextStyle(fontSize: 13, height: 1.4),
                          ),
                        ),
                      ],
                    ),
                  );
                }),

                const SizedBox(height: 16),
                Text(
                  'About Destination',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: cs.onSurface,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  place.description,
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.5,
                    color: cs.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Key Highlights',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: cs.onSurface,
                  ),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: place.highlights.map((h) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 7),
                      decoration: BoxDecoration(
                        color: isDarkMode
                            ? const Color(0xFF2A2633)
                            : cs.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: cs.outlineVariant.withValues(alpha: 0.2),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.check_circle_rounded,
                              size: 14,
                              color: isDarkMode
                                  ? const Color(0xFF00E5FF)
                                  : cs.primary),
                          const SizedBox(width: 6),
                          Text(h, style: const TextStyle(fontSize: 12)),
                        ],
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 20),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.access_time_rounded),
                  title: const Text('Open Hours'),
                  subtitle: Text(place.openHours),
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.directions_transit_rounded),
                  title: const Text('Transit Connection'),
                  subtitle: Text(place.transitInfo),
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.attach_money_rounded),
                  title: const Text('Admission / Price'),
                  subtitle: Text(place.price),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
