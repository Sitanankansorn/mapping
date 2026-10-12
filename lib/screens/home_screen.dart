import 'package:flutter/material.dart';
import '../state/user_profile_provider.dart';
import '../widgets/widgets.dart';

class HomeScreen extends StatefulWidget {
  final VoidCallback? onOpenMap;

  const HomeScreen({super.key, this.onOpenMap});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final cs = Theme.of(context).colorScheme;
    final mq = MediaQuery.of(context);
    final crossCount = mq.size.width > 600 ? 4 : 2;
    final notifier = UserProfileScope.of(context);
    final profile = notifier.profile;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Thailand Mapping 🇹🇭'),
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
          IconButton(
            icon: const Icon(Icons.notifications_none_rounded),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Thailand alerts: All transit lines normal'),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              );
            },
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async =>
            await Future.delayed(const Duration(milliseconds: 600)),
        child: ListView(
          padding: const EdgeInsets.only(bottom: 28),
          children: [
            // ── Greeting Banner ───────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 6, 16, 10),
              child: _GreetingBanner(
                profile: profile,
                colorScheme: cs,
                onOpenMap: widget.onOpenMap,
              ),
            ),

            // ── Live Bangkok City Pulse Widget ────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: cs.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: cs.outlineVariant.withValues(alpha: 0.18),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildPulseItem(
                      icon: Icons.wb_sunny_rounded,
                      color: const Color(0xFFF59E0B),
                      title: '31°C Sunny',
                      subtitle: 'Bangkok, TH',
                    ),
                    Container(
                      width: 1,
                      height: 32,
                      color: cs.outlineVariant.withValues(alpha: 0.3),
                    ),
                    _buildPulseItem(
                      icon: Icons.directions_subway_rounded,
                      color: const Color(0xFF10B981),
                      title: 'BTS & MRT',
                      subtitle: 'Normal Service',
                    ),
                    Container(
                      width: 1,
                      height: 32,
                      color: cs.outlineVariant.withValues(alpha: 0.3),
                    ),
                    _buildPulseItem(
                      icon: Icons.traffic_rounded,
                      color: const Color(0xFF3B82F6),
                      title: 'City Traffic',
                      subtitle: 'Flowing Good',
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // ── Quick Stats Grid ──────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: GridView.count(
                crossAxisCount: crossCount,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 1.45,
                children: [
                  _StatTile(
                    icon: Icons.map_rounded,
                    label: 'Bangkok Spots',
                    value: '12',
                    color: cs.primary,
                  ),
                  _StatTile(
                    icon: Icons.bookmark_rounded,
                    label: 'Saved Spots',
                    value: '${profile.savedPlaceIds.length}',
                    color: const Color(0xFFF59E0B),
                  ),
                  _StatTile(
                    icon: Icons.alt_route_rounded,
                    label: 'Transit Lines',
                    value: '8',
                    color: const Color(0xFF10B981),
                  ),
                  _StatTile(
                    icon: Icons.workspace_premium_rounded,
                    label: 'Explorer Level',
                    value: 'Lv. 4',
                    color: const Color(0xFF8B5CF6),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ── Recent Activity Section ───────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Recent Explorations',
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.w700),
                  ),
                  TextButton(
                    onPressed: () {},
                    child: const Text('See all'),
                  ),
                ],
              ),
            ),

            ..._activityItems.map(
              (item) => GlassCard(
                margin:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
                padding: const EdgeInsets.all(16),
                onTap: () {},
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: item.color.withValues(alpha: 0.16),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(item.icon, color: item.color, size: 24),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.title,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            item.subtitle,
                            style: TextStyle(
                              color: cs.onSurfaceVariant,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      item.time,
                      style: TextStyle(
                        color: cs.onSurfaceVariant,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPulseItem({
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
  }) {
    return Column(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(height: 4),
        Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
        ),
        Text(
          subtitle,
          style: const TextStyle(fontSize: 10, color: Colors.grey),
        ),
      ],
    );
  }
}

class _GreetingBanner extends StatelessWidget {
  final dynamic profile;
  final ColorScheme colorScheme;
  final VoidCallback? onOpenMap;

  const _GreetingBanner({
    required this.profile,
    required this.colorScheme,
    this.onOpenMap,
  });

  @override
  Widget build(BuildContext context) {
    final avatar = profile.currentAvatar;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          colors: [
            colorScheme.primary.withValues(alpha: 0.35),
            colorScheme.tertiary.withValues(alpha: 0.22),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(
          color: colorScheme.primary.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: avatar.gradientColors,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Center(
                  child: Text(
                    avatar.emoji,
                    style: const TextStyle(fontSize: 26),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _greeting,
                      style: TextStyle(
                        color: colorScheme.onSurfaceVariant,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      profile.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            'Ready to explore Bangkok? Discover temples, street food & transit in real-time.',
            style: TextStyle(
              color: colorScheme.onSurface.withValues(alpha: 0.85),
              fontSize: 13,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 14),
          ElevatedButton.icon(
            onPressed: onOpenMap,
            icon: const Icon(Icons.map_rounded, size: 18),
            label: const Text('Open Bangkok Live Map'),
            style: ElevatedButton.styleFrom(
              backgroundColor: colorScheme.primary,
              foregroundColor: colorScheme.onPrimary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              minimumSize: const Size(double.infinity, 44),
            ),
          ),
        ],
      ),
    );
  }

  String get _greeting {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Sawatdee / Good morning,';
    if (hour < 17) return 'Good afternoon,';
    return 'Good evening,';
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLow,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: cs.outlineVariant.withValues(alpha: 0.15),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              color: cs.onSurfaceVariant,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}

class _ActivityItem {
  const _ActivityItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.time,
    required this.color,
  });
  final IconData icon;
  final String title;
  final String subtitle;
  final String time;
  final Color color;
}

const _activityItems = [
  _ActivityItem(
    icon: Icons.temple_buddhist_rounded,
    title: 'Visited Wat Arun',
    subtitle: 'Chao Phraya Riverside · Temple of Dawn',
    time: '1h ago',
    color: Color(0xFFF59E0B),
  ),
  _ActivityItem(
    icon: Icons.restaurant_rounded,
    title: 'Street Food Checked-in',
    subtitle: 'Yaowarat Chinatown · Night Market',
    time: '4h ago',
    color: Color(0xFFEF4444),
  ),
  _ActivityItem(
    icon: Icons.shopping_bag_rounded,
    title: 'Saved ICONSIAM Spot',
    subtitle: 'Indoor Floating Market & Fountain',
    time: 'Yesterday',
    color: Color(0xFF8B5CF6),
  ),
  _ActivityItem(
    icon: Icons.directions_transit_rounded,
    title: 'BTS Skytrain Route Completed',
    subtitle: 'Siam Interchange to Sala Daeng',
    time: '2d ago',
    color: Color(0xFF10B981),
  ),
];
