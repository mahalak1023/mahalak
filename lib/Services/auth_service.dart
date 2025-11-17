import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  // Only initialize GoogleSignIn for mobile platforms
  final GoogleSignIn? _googleSignIn = kIsWeb
      ? null
      : GoogleSignIn(scopes: ['email', 'profile']);

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Auth state changes stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Sign in with Google
  Future<UserCredential?> signInWithGoogle() async {
    try {
      if (kIsWeb) {
        print('🌐 WEB: Initiating Google sign-in redirect...');
        // Web platform: Use redirect (more reliable, no popup blockers)
        GoogleAuthProvider googleProvider = GoogleAuthProvider();
        googleProvider.addScope('email');
        googleProvider.addScope('profile');

        await _auth.signInWithRedirect(googleProvider);
        print('🌐 WEB: Redirect initiated successfully');
        // After redirect, user will return to app and we handle result in main.dart
        return null;
      } else {
        print('📱 MOBILE: Initiating native Google sign-in...');
        // Mobile platforms: Native Google Sign-In
        final GoogleSignInAccount? googleUser = await _googleSignIn?.signIn();

        if (googleUser == null) {
          print('ℹ️ MOBILE: User canceled Google sign-in');
          // User canceled the sign-in
          return null;
        }

        print('📱 MOBILE: Google user selected: ${googleUser.email}');
        final GoogleSignInAuthentication googleAuth =
            await googleUser.authentication;

        final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        final userCredential = await _auth.signInWithCredential(credential);
        print('✅ MOBILE: Sign-in successful: ${userCredential.user?.email}');
        return userCredential;
      }
    } catch (e, stackTrace) {
      print('❌ ERROR: Google sign-in failed');
      print('Error: $e');
      print('Stack trace: $stackTrace');
      rethrow;
    }
  }

  // Get redirect result (for web after OAuth redirect)
  Future<UserCredential?> getRedirectResult() async {
    try {
      print('🔍 Checking for OAuth redirect result...');
      final result = await _auth.getRedirectResult();

      if (result.user != null) {
        print('✅ Found redirect result: ${result.user?.email}');
      } else {
        print('ℹ️ No redirect result (normal page load)');
      }

      return result;
    } catch (e, stackTrace) {
      print('❌ ERROR: Failed to get redirect result');
      print('Error: $e');
      print('Stack trace: $stackTrace');
      return null;
    }
  }

  // Sign in with Apple
  Future<UserCredential?> signInWithApple() async {
    try {
      if (kIsWeb) {
        print('🌐 WEB: Initiating Apple sign-in redirect...');
        // Web platform: Use redirect
        final appleProvider = OAuthProvider('apple.com');
        appleProvider.addScope('email');
        appleProvider.addScope('name');

        await _auth.signInWithRedirect(appleProvider);
        print('🌐 WEB: Apple redirect initiated successfully');
        return null;
      } else {
        print('📱 MOBILE: Initiating native Apple sign-in...');
        // Mobile platforms
        final appleCredential = await SignInWithApple.getAppleIDCredential(
          scopes: [
            AppleIDAuthorizationScopes.email,
            AppleIDAuthorizationScopes.fullName,
          ],
        );

        final oauthCredential = OAuthProvider('apple.com').credential(
          idToken: appleCredential.identityToken,
          accessToken: appleCredential.authorizationCode,
        );

        final userCredential = await _auth.signInWithCredential(
          oauthCredential,
        );
        print(
          '✅ MOBILE: Apple sign-in successful: ${userCredential.user?.email}',
        );
        return userCredential;
      }
    } catch (e, stackTrace) {
      print('❌ ERROR: Apple sign-in failed');
      print('Error: $e');
      print('Stack trace: $stackTrace');
      rethrow;
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      final futures = [_auth.signOut()];
      if (_googleSignIn != null) {
        futures.add(_googleSignIn.signOut());
      }
      await Future.wait(futures);
    } catch (e) {
      print('Error signing out: $e');
      rethrow;
    }
  }

  // Delete account
  Future<void> deleteAccount() async {
    try {
      await _auth.currentUser?.delete();
    } catch (e) {
      print('Error deleting account: $e');
      rethrow;
    }
  }
}
