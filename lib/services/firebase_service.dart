import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../firebase_options.dart';
import '../models/user_profile.dart';

class FirebaseService {
  FirebaseService._();
  static final FirebaseService instance = FirebaseService._();

  bool _initialized = false;
  String? _initError;

  bool get isInitialized => _initialized;
  String? get initError => _initError;
  String get ownerEmail => DefaultFirebaseOptions.ownerEmail;

  FirebaseAuth? get auth {
    if (!_initialized) return null;
    try {
      return FirebaseAuth.instance;
    } catch (_) {
      return null;
    }
  }

  FirebaseFirestore? get firestore {
    if (!_initialized) return null;
    try {
      return FirebaseFirestore.instance;
    } catch (_) {
      return null;
    }
  }

  User? get currentUser => auth?.currentUser;

  /// Initializes Firebase safely with DefaultFirebaseOptions
  Future<bool> initialize() async {
    if (_initialized) return true;

    try {
      if (Firebase.apps.isNotEmpty) {
        _initialized = true;
        debugPrint('🔥 Firebase already initialized.');
        return true;
      }

      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      _initialized = true;
      debugPrint('🔥 Firebase successfully initialized for $ownerEmail');
      return true;
    } catch (e) {
      _initError = e.toString();
      debugPrint('⚠️ Firebase init notice: $e (App will continue with safe local fallback)');
      return false;
    }
  }

  /// Sign in with Firebase Authentication
  Future<UserCredential?> signIn({
    required String email,
    required String password,
  }) async {
    final authInstance = auth;
    if (authInstance == null) {
      debugPrint('Firebase Auth not available. Using local authentication.');
      return null;
    }

    try {
      final credential = await authInstance.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      return credential;
    } on FirebaseAuthException catch (e) {
      debugPrint('Firebase Auth error: ${e.code} - ${e.message}');
      rethrow;
    }
  }

  /// Register new user with Firebase Authentication and create Firestore profile document
  Future<UserCredential?> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final authInstance = auth;
    if (authInstance == null) {
      debugPrint('Firebase Auth not available. Registered locally.');
      return null;
    }

    try {
      final credential = await authInstance.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      // Update user display name in Firebase Auth
      await credential.user?.updateDisplayName(name.trim());

      // Create initial Firestore user document
      final db = firestore;
      if (db != null && credential.user != null) {
        await db.collection('users').doc(credential.user!.uid).set({
          'name': name.trim(),
          'email': email.trim(),
          'username': '@${email.split('@').first}',
          'createdAt': FieldValue.serverTimestamp(),
          'savedPlaceIds': [
            'grand_palace',
            'wat_arun',
            'siam_paragon',
          ],
        }, SetOptions(merge: true));
      }

      return credential;
    } on FirebaseAuthException catch (e) {
      debugPrint('Firebase Registration error: ${e.code} - ${e.message}');
      rethrow;
    }
  }

  /// Send password reset link to user's email
  Future<void> sendPasswordReset(String email) async {
    final authInstance = auth;
    if (authInstance == null) return;
    await authInstance.sendPasswordResetEmail(email: email.trim());
  }

  /// Sign out
  Future<void> signOut() async {
    await auth?.signOut();
  }

  /// Sync saved places to Cloud Firestore in the user document
  Future<void> syncSavedPlaces(Set<String> savedPlaceIds) async {
    final db = firestore;
    final user = currentUser;
    if (db == null || user == null) return;

    try {
      await db.collection('users').doc(user.uid).set({
        'savedPlaceIds': savedPlaceIds.toList(),
        'lastSync': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      debugPrint('🔥 Cloud Firestore: Synced ${savedPlaceIds.length} saved places.');
    } catch (e) {
      debugPrint('Firestore sync notice: $e');
    }
  }

  /// Fetch saved places from Cloud Firestore
  Future<Set<String>?> fetchSavedPlaces() async {
    final db = firestore;
    final user = currentUser;
    if (db == null || user == null) return null;

    try {
      final doc = await db.collection('users').doc(user.uid).get();
      if (doc.exists && doc.data() != null) {
        final list = doc.data()!['savedPlaceIds'];
        if (list is List) {
          return Set<String>.from(list.map((e) => e.toString()));
        }
      }
    } catch (e) {
      debugPrint('Firestore fetch error: $e');
    }
    return null;
  }

  /// Sync user profile data to Cloud Firestore
  Future<void> syncUserProfile(UserProfile profile) async {
    final db = firestore;
    final user = currentUser;
    if (db == null || user == null) return;

    try {
      await db.collection('users').doc(user.uid).set({
        'name': profile.name,
        'username': profile.username,
        'email': profile.email,
        'phone': profile.phone,
        'bio': profile.bio,
        'homeCity': profile.homeCity,
        'isDarkMode': profile.isDarkMode,
        'mapStyle': profile.mapStyle,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      debugPrint('🔥 Cloud Firestore: Synced user profile for ${profile.email}');
    } catch (e) {
      debugPrint('Firestore profile sync error: $e');
    }
  }
}
