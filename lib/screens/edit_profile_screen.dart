import 'package:flutter/material.dart';
import '../models/user_profile.dart';
import '../state/user_profile_provider.dart';
import '../widgets/widgets.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameCtrl;
  late final TextEditingController _userCtrl;
  late final TextEditingController _bioCtrl;
  late final TextEditingController _emailCtrl;
  late final TextEditingController _phoneCtrl;
  late final TextEditingController _cityCtrl;

  late int _selectedAvatarId;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    // Controllers will be initialized in didChangeDependencies to read current profile
  }

  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      final p = UserProfileScope.of(context).profile;
      _nameCtrl = TextEditingController(text: p.name);
      _userCtrl = TextEditingController(text: p.username);
      _bioCtrl = TextEditingController(text: p.bio);
      _emailCtrl = TextEditingController(text: p.email);
      _phoneCtrl = TextEditingController(text: p.phone);
      _cityCtrl = TextEditingController(text: p.homeCity);
      _selectedAvatarId = p.avatarId;
      _initialized = true;
    }
  }

  @override
  void dispose() {
    if (_initialized) {
      _nameCtrl.dispose();
      _userCtrl.dispose();
      _bioCtrl.dispose();
      _emailCtrl.dispose();
      _phoneCtrl.dispose();
      _cityCtrl.dispose();
    }
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _saving = true);
    await Future.delayed(const Duration(milliseconds: 600));

    if (!mounted) return;
    final notifier = UserProfileScope.of(context);
    notifier.updateProfile(
      name: _nameCtrl.text.trim(),
      username: _userCtrl.text.trim(),
      bio: _bioCtrl.text.trim(),
      email: _emailCtrl.text.trim(),
      phone: _phoneCtrl.text.trim(),
      homeCity: _cityCtrl.text.trim(),
      avatarId: _selectedAvatarId,
    );

    setState(() => _saving = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
            SizedBox(width: 10),
            Text('Profile updated successfully!'),
          ],
        ),
        backgroundColor: const Color(0xFF10B981),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final selectedPreset = kAvatarPresets[_selectedAvatarId];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        actions: [
          TextButton(
            onPressed: _saving ? null : _save,
            child: _saving
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text(
                    'Save',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          children: [
            // ── Live Avatar Preview ──────────────────────────────────
            Center(
              child: Stack(
                children: [
                  Container(
                    width: 104,
                    height: 104,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: selectedPreset.gradientColors,
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: selectedPreset.gradientColors.first
                              .withValues(alpha: 0.4),
                          blurRadius: 18,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        selectedPreset.emoji,
                        style: const TextStyle(fontSize: 48),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(7),
                      decoration: BoxDecoration(
                        color: cs.primary,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: cs.surface,
                          width: 2.5,
                        ),
                      ),
                      child: Icon(
                        Icons.camera_alt_rounded,
                        size: 16,
                        color: cs.onPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Center(
              child: Text(
                'Select Avatar Persona',
                style: TextStyle(
                  color: cs.onSurfaceVariant,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 12),

            // ── Avatar Presets Carousel / Grid ────────────────────────
            SizedBox(
              height: 74,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: kAvatarPresets.length,
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (ctx, idx) {
                  final preset = kAvatarPresets[idx];
                  final isSelected = _selectedAvatarId == preset.id;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedAvatarId = preset.id),
                    child: Column(
                      children: [
                        Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              colors: preset.gradientColors,
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            border: Border.all(
                              color: isSelected
                                  ? Colors.white
                                  : Colors.transparent,
                              width: isSelected ? 3 : 0,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              preset.emoji,
                              style: const TextStyle(fontSize: 24),
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          preset.label.split(' ').first,
                          style: TextStyle(
                            fontSize: 11,
                            color: isSelected
                                ? cs.primary
                                : cs.onSurfaceVariant,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 24),

            // ── Profile Fields ───────────────────────────────────────
            AppTextField(
              controller: _nameCtrl,
              label: 'Full Name',
              hint: 'Sarawut Tan',
              prefixIcon: Icons.badge_outlined,
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Name cannot be empty';
                return null;
              },
            ),
            const SizedBox(height: 16),

            AppTextField(
              controller: _userCtrl,
              label: 'Username',
              hint: '@bangkok_explorer',
              prefixIcon: Icons.alternate_email_rounded,
              validator: (v) {
                if (v == null || v.trim().isEmpty) {
                  return 'Username cannot be empty';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            AppTextField(
              controller: _bioCtrl,
              label: 'Bio & Explorer Status',
              hint: 'Tell Bangkok explorers about yourself…',
              prefixIcon: Icons.edit_note_rounded,
              maxLines: 3,
            ),
            const SizedBox(height: 16),

            AppTextField(
              controller: _cityCtrl,
              label: 'City & Country',
              hint: 'Bangkok, Thailand 🇹🇭',
              prefixIcon: Icons.location_city_rounded,
            ),
            const SizedBox(height: 16),

            AppTextField(
              controller: _emailCtrl,
              label: 'Email Address',
              hint: 'sarawut.t@bangkokmap.th',
              prefixIcon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Email is required';
                if (!v.contains('@')) return 'Enter a valid email';
                return null;
              },
            ),
            const SizedBox(height: 16),

            AppTextField(
              controller: _phoneCtrl,
              label: 'Phone Number',
              hint: '+66 81 892 3456',
              prefixIcon: Icons.phone_android_rounded,
              keyboardType: TextInputType.phone,
            ),

            const SizedBox(height: 32),
            PrimaryButton(
              label: 'Save Profile Changes',
              isLoading: _saving,
              onPressed: _save,
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
