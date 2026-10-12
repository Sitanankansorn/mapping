import 'package:flutter/material.dart';
import '../state/user_profile_provider.dart';
import '../widgets/widgets.dart';
import 'edit_profile_screen.dart';
import 'forgot_password_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final notifier = UserProfileScope.of(context);
    final profile = notifier.profile;
    final avatar = profile.currentAvatar;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 12),
        children: [
          // ── Profile Quick Card ──────────────────────────────────
          GlassCard(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
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
                      style: const TextStyle(fontSize: 28),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        profile.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        profile.username,
                        style: TextStyle(
                          fontSize: 13,
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        profile.email,
                        style: TextStyle(
                          fontSize: 12,
                          color: cs.onSurfaceVariant.withValues(alpha: 0.8),
                        ),
                      ),
                    ],
                  ),
                ),
                FilledButton.tonal(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const EditProfileScreen(),
                      ),
                    );
                  },
                  child: const Text('Edit'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // ── FIREBASE CLOUD CONNECTION ──────────────────────────
          _buildSectionHeader('FIREBASE CLOUD CONNECTION', cs),
          GlassCard(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF59E0B).withValues(alpha: 0.18),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.local_fire_department_rounded,
                        color: Color(0xFFF59E0B),
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Firebase Cloud Connected',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            's6707012660077@email.kmutnb.ac.th',
                            style: TextStyle(
                              fontSize: 12,
                              color: cs.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color:
                            const Color(0xFF10B981).withValues(alpha: 0.16),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'Active',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF10B981),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  'Saved landmarks, route history, and user settings sync directly to your Firebase Firestore project.',
                  style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant),
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: () async {
                    await notifier.syncFromFirebase();
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text(
                              '🔥 Synced successfully with Firebase Cloud!'),
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                      );
                    }
                  },
                  icon: const Icon(Icons.sync_rounded, size: 16),
                  label: const Text('Sync with Firebase Now'),
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // ── MAP & NAVIGATION (BANGKOK) ──────────────────────────
          _buildSectionHeader('BANGKOK MAP & NAVIGATION', cs),
          GlassCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.palette_outlined),
                  title: const Text('Map Theme Style'),
                  subtitle: Text(
                    profile.mapStyle == 'dark'
                        ? 'Carto Dark Matter'
                        : profile.mapStyle == 'voyager'
                            ? 'Carto Voyager'
                            : 'OpenStreetMap Classic',
                    style: TextStyle(color: cs.primary, fontSize: 13),
                  ),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () => _showMapStyleDialog(context, notifier),
                ),
                _buildDivider(cs),
                SwitchListTile.adaptive(
                  secondary: const Icon(Icons.straighten_rounded),
                  title: const Text('Metric Units (Kilometers)'),
                  subtitle: Text(
                    profile.metricUnits ? 'km & meters' : 'miles & feet',
                    style: TextStyle(color: cs.onSurfaceVariant, fontSize: 12),
                  ),
                  value: profile.metricUnits,
                  onChanged: (val) => notifier.setMetricUnits(val),
                ),
                _buildDivider(cs),
                SwitchListTile.adaptive(
                  secondary: const Icon(Icons.traffic_rounded),
                  title: const Text('Bangkok Live Traffic Alert'),
                  subtitle: const Text(
                    'Real-time transit and traffic congestion status',
                    style: TextStyle(fontSize: 12),
                  ),
                  value: profile.trafficOverlay,
                  onChanged: (val) => notifier.setTrafficOverlay(val),
                ),
                _buildDivider(cs),
                ListTile(
                  leading: const Icon(Icons.download_for_offline_outlined),
                  title: const Text('Offline Bangkok Map Cache'),
                  subtitle: const Text('48.2 MB cached • Tap to clear'),
                  trailing: const Icon(Icons.delete_outline_rounded, size: 20),
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('Bangkok map cache cleared!'),
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // ── ACCOUNT & SECURITY ──────────────────────────────────
          _buildSectionHeader('ACCOUNT & SECURITY', cs),
          GlassCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.person_outline_rounded),
                  title: const Text('Edit Profile & Persona'),
                  subtitle: const Text('Change name, avatar, bio and city'),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const EditProfileScreen(),
                      ),
                    );
                  },
                ),
                _buildDivider(cs),
                ListTile(
                  leading: const Icon(Icons.lock_reset_rounded),
                  title: const Text('Change / Reset Password'),
                  subtitle: const Text('Update security password'),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const ForgotPasswordScreen(),
                      ),
                    );
                  },
                ),
                _buildDivider(cs),
                SwitchListTile.adaptive(
                  secondary: const Icon(Icons.fingerprint_rounded),
                  title: const Text('Biometric Authentication'),
                  subtitle: const Text(
                    'Face ID / Fingerprint lock for Bangkok Mapping',
                    style: TextStyle(fontSize: 12),
                  ),
                  value: profile.biometricEnabled,
                  onChanged: (val) => notifier.setBiometric(val),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // ── PREFERENCES & NOTIFICATIONS ─────────────────────────
          _buildSectionHeader('PREFERENCES', cs),
          GlassCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                SwitchListTile.adaptive(
                  secondary: Icon(profile.isDarkMode
                      ? Icons.dark_mode_rounded
                      : Icons.light_mode_rounded),
                  title: Text(profile.isDarkMode
                      ? 'Night Mode Active'
                      : 'Light Mode Active'),
                  subtitle: Text(profile.isDarkMode
                      ? 'Dark aesthetic & night city map'
                      : 'Crisp daylight aesthetic & bright map'),
                  value: profile.isDarkMode,
                  onChanged: (val) => notifier.setDarkMode(val),
                ),
                _buildDivider(cs),
                SwitchListTile.adaptive(
                  secondary: const Icon(Icons.notifications_none_rounded),
                  title: const Text('Push Notifications'),
                  subtitle: const Text('Alerts on saved places and events'),
                  value: profile.notificationsEnabled,
                  onChanged: (val) => notifier.setNotifications(val),
                ),
                _buildDivider(cs),
                ListTile(
                  leading: const Icon(Icons.translate_rounded),
                  title: const Text('Language'),
                  subtitle: const Text('English (US) / ภาษาไทย'),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('Language is set to English & Thai'),
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // ── ABOUT & LOGOUT ──────────────────────────────────────
          _buildSectionHeader('ABOUT & SUPPORT', cs),
          GlassCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.support_agent_rounded),
                  title: const Text('Help Center & Support'),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () {},
                ),
                _buildDivider(cs),
                ListTile(
                  leading: const Icon(Icons.privacy_tip_outlined),
                  title: const Text('Privacy Policy'),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () {},
                ),
                _buildDivider(cs),
                ListTile(
                  leading: const Icon(Icons.info_outline_rounded),
                  title: const Text('Bangkok Mapping App Version'),
                  trailing: Text(
                    'v2.4.0 (Bangkok Pro)',
                    style: TextStyle(color: cs.onSurfaceVariant, fontSize: 12),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: OutlinedButton.icon(
              onPressed: () => _confirmSignOut(context),
              style: OutlinedButton.styleFrom(
                foregroundColor: cs.error,
                side: BorderSide(color: cs.error.withValues(alpha: 0.4)),
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              icon: const Icon(Icons.logout_rounded),
              label: const Text('Log Out'),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, ColorScheme cs) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
      child: Text(
        title,
        style: TextStyle(
          color: cs.onSurfaceVariant,
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildDivider(ColorScheme cs) {
    return Divider(
      height: 1,
      indent: 56,
      color: cs.outlineVariant.withValues(alpha: 0.2),
    );
  }

  void _showMapStyleDialog(BuildContext context, UserProfileNotifier notifier) {
    final cs = Theme.of(context).colorScheme;
    final currentStyle = notifier.profile.mapStyle;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: cs.surfaceContainerHigh,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Choose Map Theme'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.dark_mode_rounded),
              title: const Text('Carto Dark Matter (Dark)'),
              trailing: currentStyle == 'dark'
                  ? Icon(Icons.check_circle_rounded, color: cs.primary)
                  : null,
              onTap: () {
                notifier.setMapStyle('dark');
                Navigator.pop(ctx);
              },
            ),
            ListTile(
              leading: const Icon(Icons.map_rounded),
              title: const Text('Carto Voyager (Detailed)'),
              trailing: currentStyle == 'voyager'
                  ? Icon(Icons.check_circle_rounded, color: cs.primary)
                  : null,
              onTap: () {
                notifier.setMapStyle('voyager');
                Navigator.pop(ctx);
              },
            ),
            ListTile(
              leading: const Icon(Icons.public_rounded),
              title: const Text('OpenStreetMap Standard'),
              trailing: currentStyle == 'streets'
                  ? Icon(Icons.check_circle_rounded, color: cs.primary)
                  : null,
              onTap: () {
                notifier.setMapStyle('streets');
                Navigator.pop(ctx);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _confirmSignOut(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: cs.surfaceContainerHigh,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Log Out'),
        content: const Text(
          'Are you sure you want to log out of Bangkok Mapping?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pushNamedAndRemoveUntil(
                context,
                '/login',
                (route) => false,
              );
            },
            style: TextButton.styleFrom(foregroundColor: cs.error),
            child: const Text('Log Out'),
          ),
        ],
      ),
    );
  }
}
