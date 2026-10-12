import 'package:flutter/material.dart';
import '../models/bangkok_places.dart';
import '../state/user_profile_provider.dart';
import '../widgets/widgets.dart';

class ExploreScreen extends StatefulWidget {
  final ValueChanged<BangkokPlace>? onPlaceSelected;

  const ExploreScreen({super.key, this.onPlaceSelected});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  final _searchCtrl = TextEditingController();
  String _selectedCategory = 'All';

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  List<BangkokPlace> get _filteredPlaces {
    final q = _searchCtrl.text.trim().toLowerCase();
    return kBangkokPlaces.where((p) {
      final matchCat =
          _selectedCategory == 'All' || p.category == _selectedCategory;
      final matchQuery = q.isEmpty ||
          p.name.toLowerCase().contains(q) ||
          p.thaiName.toLowerCase().contains(q) ||
          p.province.toLowerCase().contains(q) ||
          p.district.toLowerCase().contains(q);
      return matchCat && matchQuery;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final cs = Theme.of(context).colorScheme;
    final notifier = UserProfileScope.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Discover Thailand 🇹🇭'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            tooltip: notifier.profile.isDarkMode ? 'Light Mode' : 'Night Mode',
            icon: Icon(
              notifier.profile.isDarkMode
                  ? Icons.light_mode_rounded
                  : Icons.dark_mode_rounded,
            ),
            onPressed: () => notifier.toggleThemeMode(),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 28),
        children: [
          // ── Search bar ─────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
            child: TextField(
              controller: _searchCtrl,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                hintText: 'Search temples, beaches, night markets, BTS…',
                prefixIcon: const Icon(Icons.search_rounded),
                suffixIcon: _searchCtrl.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.close_rounded),
                        onPressed: () {
                          _searchCtrl.clear();
                          setState(() {});
                        },
                      )
                    : null,
              ),
            ),
          ),

          // ── Category chips ─────────────────────────────────────
          SizedBox(
            height: 40,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                'All',
                'Temples',
                'Shopping',
                'Street Food',
                'Parks',
                'Culture'
              ].map((cat) {
                final isSelected = _selectedCategory == cat;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(cat),
                    selected: isSelected,
                    onSelected: (_) => setState(() => _selectedCategory = cat),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          const SizedBox(height: 18),

          // ── Curated Thailand Itineraries Carousel ──────────────
          if (_searchCtrl.text.isEmpty && _selectedCategory == 'All') ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Featured Thailand Itineraries',
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.w700),
                  ),
                  Text(
                    'Curated',
                    style: TextStyle(
                      color: cs.primary,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 140,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: const [
                  _ItineraryCard(
                    title: 'Bangkok Historic River & Temples',
                    subtitle: 'Grand Palace • Wat Arun • Wat Pho',
                    badge: 'Bangkok Tour',
                    color: Color(0xFFF59E0B),
                    icon: Icons.temple_buddhist_rounded,
                  ),
                  _ItineraryCard(
                    title: 'Phuket & Phi Phi Island Cruise',
                    subtitle: 'Maya Bay • Pileh Lagoon • Coral Reefs',
                    badge: 'Island Escape',
                    color: Color(0xFF06B6D4),
                    icon: Icons.sailing_rounded,
                  ),
                  _ItineraryCard(
                    title: 'Chiang Mai Mist & Ancient Temples',
                    subtitle: 'Doi Suthep • Doi Inthanon • Tha Phae',
                    badge: 'Northern Trail',
                    color: Color(0xFF10B981),
                    icon: Icons.landscape_rounded,
                  ),
                  _ItineraryCard(
                    title: 'Chinatown Midnight Food Safari',
                    subtitle: 'Yaowarat Stalls • Michelin Seafood',
                    badge: 'Night Market',
                    color: Color(0xFFEF4444),
                    icon: Icons.nightlife_rounded,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],

          // ── Thailand Landmarks List ────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _searchCtrl.text.isEmpty
                      ? 'All Places in Thailand'
                      : 'Search Results (${_filteredPlaces.length})',
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.w700),
                ),
                Text(
                  '${_filteredPlaces.length} spots',
                  style: TextStyle(color: cs.onSurfaceVariant, fontSize: 13),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),

          if (_filteredPlaces.isEmpty)
            Padding(
              padding: const EdgeInsets.all(40),
              child: Center(
                child: Column(
                  children: [
                    Icon(Icons.search_off_rounded,
                        size: 56,
                        color: cs.onSurfaceVariant.withValues(alpha: 0.4)),
                    const SizedBox(height: 12),
                    Text(
                      'No matching destinations found in Thailand',
                      style: TextStyle(color: cs.onSurfaceVariant, fontSize: 16),
                    ),
                  ],
                ),
              ),
            )
          else
            ..._filteredPlaces.map((place) {
              final isSaved = notifier.isPlaceSaved(place.id);
              return GlassCard(
                margin:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                padding: const EdgeInsets.all(16),
                onTap: () {
                  if (widget.onPlaceSelected != null) {
                    widget.onPlaceSelected!(place);
                  }
                },
                child: Row(
                  children: [
                    PlaceImage(
                      place: place,
                      width: 52,
                      height: 52,
                      borderRadius: BorderRadius.circular(16),
                      showBadge: true,
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            place.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${place.thaiName} • ${place.province}',
                            style: TextStyle(
                              color: cs.onSurfaceVariant,
                              fontSize: 12,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              const Icon(Icons.star_rounded,
                                  size: 15, color: Color(0xFFF59E0B)),
                              const SizedBox(width: 3),
                              Text(
                                '${place.rating}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: cs.surfaceContainerHigh,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  place.region,
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: cs.onSurfaceVariant,
                                  ),
                                ),
                              ),
                              const Spacer(),
                              Text(
                                place.price,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: cs.primary,
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
                        color: isSaved
                            ? const Color(0xFFF59E0B)
                            : cs.onSurfaceVariant,
                      ),
                      onPressed: () => notifier.toggleSavePlace(place.id),
                    ),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }
}

class _ItineraryCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String badge;
  final Color color;
  final IconData icon;

  const _ItineraryCard({
    required this.title,
    required this.subtitle,
    required this.badge,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      width: 260,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLow,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  badge,
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.bold,
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ),
          const Spacer(),
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 3),
          Text(
            subtitle,
            style: TextStyle(
              color: cs.onSurfaceVariant,
              fontSize: 12,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
