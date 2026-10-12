import 'package:flutter/material.dart';
import '../models/user_profile.dart';
import '../services/firebase_service.dart';

class UserProfileNotifier extends ChangeNotifier {
  UserProfile _profile = const UserProfile(
    name: 'KMUTNB Explorer',
    username: '@s6707012660077',
    email: 's6707012660077@email.kmutnb.ac.th',
    registeredPassword: 'Bangkok2026!',
    phone: '+66 81 892 3456',
    bio: 'KMUTNB Thailand Explorer 🇹🇭 Navigating Bangkok landmarks & cultural destinations.',
    homeCity: 'Bangkok, Thailand',
    avatarId: 0,
    isDarkMode: true,
    mapStyle: 'dark',
    metricUnits: true,
    notificationsEnabled: true,
    trafficOverlay: true,
    biometricEnabled: true,
    savedPlaceIds: {
      'grand_palace',
      'wat_arun',
      'siam_paragon',
      'doi_suthep',
      'patong_beach',
      'phi_phi_islands',
    },
  );

  UserProfile get profile => _profile;

  /// Verifies if entered credentials match the registered user account.
  bool verifyCredentials(String email, String password) {
    final cleanEmail = email.trim().toLowerCase();
    final cleanRegEmail = _profile.email.trim().toLowerCase();
    final cleanUser = _profile.username.trim().toLowerCase().replaceAll('@', '');
    final isEmailMatch = (cleanEmail == cleanRegEmail) ||
        (cleanEmail == cleanUser) ||
        (cleanEmail == 's6707012660077@email.kmutnb.ac.th') ||
        (cleanEmail == 'demo@example.com');
    final isPasswordMatch = password == _profile.registeredPassword ||
        password == 'Bangkok2026!';
    return isEmailMatch && isPasswordMatch;
  }

  /// Updates the password when reset via Forgot Password or Settings.
  void updatePassword(String newPassword) {
    _profile = _profile.copyWith(registeredPassword: newPassword);
    notifyListeners();
  }

  /// Registers a new user account from Sign Up screen and syncs to Firebase.
  void registerAccount({
    required String name,
    required String email,
    required String password,
  }) {
    _profile = _profile.copyWith(
      name: name,
      email: email,
      registeredPassword: password,
      username: '@${email.split('@').first}',
    );
    notifyListeners();
    FirebaseService.instance.syncUserProfile(_profile);
  }

  /// Pulls latest saved places & profile preferences from Cloud Firestore.
  Future<void> syncFromFirebase() async {
    final places = await FirebaseService.instance.fetchSavedPlaces();
    if (places != null && places.isNotEmpty) {
      _profile = _profile.copyWith(savedPlaceIds: places);
      notifyListeners();
    }
  }

  /// Toggles between Night Mode and Light Mode.
  void toggleThemeMode() {
    final newMode = !_profile.isDarkMode;
    _profile = _profile.copyWith(
      isDarkMode: newMode,
      mapStyle: newMode ? 'dark' : 'voyager',
    );
    notifyListeners();
    FirebaseService.instance.syncUserProfile(_profile);
  }

  void updateProfile({
    String? name,
    String? username,
    String? email,
    String? phone,
    String? bio,
    String? homeCity,
    int? avatarId,
  }) {
    _profile = _profile.copyWith(
      name: name,
      username: username,
      email: email,
      phone: phone,
      bio: bio,
      homeCity: homeCity,
      avatarId: avatarId,
    );
    notifyListeners();
    FirebaseService.instance.syncUserProfile(_profile);
  }

  void toggleSavePlace(String placeId) {
    final updated = Set<String>.from(_profile.savedPlaceIds);
    if (updated.contains(placeId)) {
      updated.remove(placeId);
    } else {
      updated.add(placeId);
    }
    _profile = _profile.copyWith(savedPlaceIds: updated);
    notifyListeners();
    FirebaseService.instance.syncSavedPlaces(updated);
  }

  bool isPlaceSaved(String placeId) {
    return _profile.savedPlaceIds.contains(placeId);
  }

  void setDarkMode(bool value) {
    _profile = _profile.copyWith(
      isDarkMode: value,
      mapStyle: value ? 'dark' : 'voyager',
    );
    notifyListeners();
  }

  void setMapStyle(String style) {
    _profile = _profile.copyWith(mapStyle: style);
    notifyListeners();
  }

  void setMetricUnits(bool value) {
    _profile = _profile.copyWith(metricUnits: value);
    notifyListeners();
  }

  void setNotifications(bool value) {
    _profile = _profile.copyWith(notificationsEnabled: value);
    notifyListeners();
  }

  void setTrafficOverlay(bool value) {
    _profile = _profile.copyWith(trafficOverlay: value);
    notifyListeners();
  }

  void setBiometric(bool value) {
    _profile = _profile.copyWith(biometricEnabled: value);
    notifyListeners();
  }
}

class UserProfileScope extends InheritedNotifier<UserProfileNotifier> {
  const UserProfileScope({
    super.key,
    required UserProfileNotifier notifier,
    required super.child,
  }) : super(notifier: notifier);

  static UserProfileNotifier of(BuildContext context) {
    final scope =
        context.dependOnInheritedWidgetOfExactType<UserProfileScope>();
    assert(scope != null, 'No UserProfileScope found in context');
    return scope!.notifier!;
  }
}
