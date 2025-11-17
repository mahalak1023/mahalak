import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn? _googleSignIn =
      kIsWeb ? null : GoogleSignIn(scopes: ['email', 'profile']);

  bool _isSigningInWithGoogle = false;

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Auth state changes stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Sign in with Google
  Future<UserCredential?> signInWithGoogle() async {
    if (_isSigningInWithGoogle) {
      // Prevent multiple simultaneous sign-in attempts
      return null;
    }

    _isSigningInWithGoogle = true;

    try {
      UserCredential? userCredential;

      if (kIsWeb) {
        // Web platform: Use signInWithPopup for a simpler flow that
        // returns a UserCredential directly.
        final GoogleAuthProvider googleProvider = GoogleAuthProvider();
        googleProvider.addScope('email');
        googleProvider.addScope('profile');
        userCredential = await _auth.signInWithPopup(googleProvider);
      } else {
        // Mobile platforms: Use the native Google Sign-In flow.
        final GoogleSignInAccount? googleUser = await _googleSignIn?.signIn();

        if (googleUser == null) {
          // User canceled the sign-in process.
          return null;
        }

        final GoogleSignInAuthentication googleAuth =
            await googleUser.authentication;

        final OAuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        userCredential = await _auth.signInWithCredential(credential);
      }

      if (userCredential?.user != null) {
        print('✅ Google sign-in successful: ${userCredential!.user!.email}');
      }

      return userCredential;
    } on FirebaseAuthException catch (e) {
      // Handle specific Firebase errors
      print('❌ ERROR: Firebase Google sign-in failed. Code: ${e.code}');
      throw Exception('Google sign-in failed: ${e.message}');
    } catch (e, stackTrace) {
      // Handle other errors (network, etc.)
      print('❌ ERROR: An unexpected error occurred during Google sign-in.');
      print('Error: $e');
      print('Stack trace: $stackTrace');
      throw Exception('Google sign-in failed: An unexpected error occurred.');
    } finally {
      // Ensure the flag is always reset
      _isSigningInWithGoogle = false;
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
      // Do not rethrow to avoid JS interop issues on web; return null
      // so the UI can handle the error gracefully.
      return null;
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
      // Don't rethrow to avoid surfacing framework-level JS interop
      // issues when called from web UI callbacks.
      return Future.value();
    }
  }

  // Delete account
  Future<void> deleteAccount() async {
    try {
      await _auth.currentUser?.delete();
    } catch (e) {
      print('Error deleting account: $e');
      // Swallow the exception here and let caller decide next steps.
      return Future.value();
    }
  }

  // Create user with email & password
  Future<UserCredential?> createUserWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Optionally send email verification
      await userCredential.user?.sendEmailVerification();

      print('✅ Email signup successful: ${userCredential.user?.email}');
      return userCredential;
    } catch (e, stackTrace) {
      print('❌ ERROR: Email signup failed');
      print('Error: $e');
      print('Stack trace: $stackTrace');
      return null;
    }
  }

  // Sign in with email & password
  Future<UserCredential?> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      print('✅ Email sign-in successful: ${userCredential.user?.email}');
      return userCredential;
    } catch (e, stackTrace) {
      print('❌ ERROR: Email sign-in failed');
      print('Error: $e');
      print('Stack trace: $stackTrace');
      return null;
    }
  }
}
