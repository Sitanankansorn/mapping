import 'package:flutter/material.dart';

/// Available avatar styles for user profile customization.
class AvatarPreset {
  final int id;
  final String label;
  final String emoji;
  final List<Color> gradientColors;

  const AvatarPreset({
    required this.id,
    required this.label,
    required this.emoji,
    required this.gradientColors,
  });
}

const List<AvatarPreset> kAvatarPresets = [
  AvatarPreset(
    id: 0,
    label: 'Bangkok Explorer',
    emoji: '🧭',
    gradientColors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
  ),
  AvatarPreset(
    id: 1,
    label: 'Street Foodie',
    emoji: '🍜',
    gradientColors: [Color(0xFFF59E0B), Color(0xFFEF4444)],
  ),
  AvatarPreset(
    id: 2,
    label: 'Temple Wanderer',
    emoji: '🛕',
    gradientColors: [Color(0xFF10B981), Color(0xFF059669)],
  ),
  AvatarPreset(
    id: 3,
    label: 'Night Nomad',
    emoji: '🌃',
    gradientColors: [Color(0xFFEC4899), Color(0xFF8B5CF6)],
  ),
  AvatarPreset(
    id: 4,
    label: 'River Cruiser',
    emoji: '🚤',
    gradientColors: [Color(0xFF06B6D4), Color(0xFF3B82F6)],
  ),
  AvatarPreset(
    id: 5,
    label: 'Photo Traveler',
    emoji: '📸',
    gradientColors: [Color(0xFFF97316), Color(0xFFEAB308)],
  ),
];

/// Data model representing the user's profile, credentials and preferences.
class UserProfile {
  final String name;
  final String username;
  final String email;
  final String registeredPassword;
  final String phone;
  final String bio;
  final String homeCity;
  final int avatarId;
  final bool isDarkMode;
  final String mapStyle; // 'dark', 'voyager', 'streets'
  final bool metricUnits;
  final bool notificationsEnabled;
  final bool trafficOverlay;
  final bool biometricEnabled;
  final Set<String> savedPlaceIds;

  const UserProfile({
    required this.name,
    required this.username,
    required this.email,
    this.registeredPassword = 'Bangkok2026!',
    required this.phone,
    required this.bio,
    required this.homeCity,
    required this.avatarId,
    this.isDarkMode = true,
    this.mapStyle = 'dark',
    this.metricUnits = true,
    this.notificationsEnabled = true,
    this.trafficOverlay = true,
    this.biometricEnabled = true,
    this.savedPlaceIds = const {
      'grand_palace',
      'wat_arun',
      'siam_paragon',
      'doi_suthep',
      'patong_beach',
      'phi_phi_islands',
    },
  });

  String get initials {
    final parts = name.trim().split(' ');
    if (parts.isEmpty) return 'U';
    if (parts.length == 1) return parts[0].substring(0, 1).toUpperCase();
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }

  AvatarPreset get currentAvatar {
    if (avatarId >= 0 && avatarId < kAvatarPresets.length) {
      return kAvatarPresets[avatarId];
    }
    return kAvatarPresets[0];
  }

  UserProfile copyWith({
    String? name,
    String? username,
    String? email,
    String? registeredPassword,
    String? phone,
    String? bio,
    String? homeCity,
    int? avatarId,
    bool? isDarkMode,
    String? mapStyle,
    bool? metricUnits,
    bool? notificationsEnabled,
    bool? trafficOverlay,
    bool? biometricEnabled,
    Set<String>? savedPlaceIds,
  }) {
    return UserProfile(
      name: name ?? this.name,
      username: username ?? this.username,
      email: email ?? this.email,
      registeredPassword: registeredPassword ?? this.registeredPassword,
      phone: phone ?? this.phone,
      bio: bio ?? this.bio,
      homeCity: homeCity ?? this.homeCity,
      avatarId: avatarId ?? this.avatarId,
      isDarkMode: isDarkMode ?? this.isDarkMode,
      mapStyle: mapStyle ?? this.mapStyle,
      metricUnits: metricUnits ?? this.metricUnits,
      notificationsEnabled:
          notificationsEnabled ?? this.notificationsEnabled,
      trafficOverlay: trafficOverlay ?? this.trafficOverlay,
      biometricEnabled: biometricEnabled ?? this.biometricEnabled,
      savedPlaceIds: savedPlaceIds ?? this.savedPlaceIds,
    );
  }
}
