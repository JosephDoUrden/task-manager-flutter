import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../models/user_model.dart';
import 'package:flutter/material.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  // Auth state changes stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Get user data from Firestore
  Future<UserModel> getUserData(String uid) async {
    try {
      debugPrint('Fetching user data for uid: $uid');
      final doc = await _firestore.collection('users').doc(uid).get();

      if (!doc.exists) {
        debugPrint('User document does not exist, creating new user data');
        final user = _auth.currentUser;
        if (user == null) throw 'No authenticated user found';

        final userModel = UserModel(
          uid: uid,
          email: user.email ?? '',
          displayName: user.displayName,
          photoUrl: user.photoURL,
          createdAt: DateTime.now(),
          lastLoginAt: DateTime.now(),
        );

        await _firestore.collection('users').doc(uid).set(userModel.toMap());
        return userModel;
      }

      debugPrint('User document found, converting to UserModel');
      return UserModel.fromFirestore(doc);
    } catch (e) {
      debugPrint('Error in getUserData: $e');
      throw _handleAuthError(e);
    }
  }

  // Sign in with email and password
  Future<UserModel> signInWithEmailAndPassword(String email, String password) async {
    try {
      debugPrint('Attempting to sign in with email: $email');
      final UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = result.user!;
      await _updateUserLastLogin(user.uid);
      return await getUserData(user.uid);
    } catch (e) {
      debugPrint('Error in signInWithEmailAndPassword: $e');
      throw _handleAuthError(e);
    }
  }

  // Register with email and password
  Future<UserModel> registerWithEmailAndPassword(String email, String password, String? displayName) async {
    try {
      debugPrint('Attempting to register new user with email: $email');
      final UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = result.user!;
      if (displayName != null) {
        await user.updateDisplayName(displayName);
      }

      final userModel = UserModel(
        uid: user.uid,
        email: email,
        displayName: displayName,
        createdAt: DateTime.now(),
        lastLoginAt: DateTime.now(),
      );

      debugPrint('Creating user document in Firestore');
      await _firestore.collection('users').doc(user.uid).set(userModel.toMap());
      return userModel;
    } catch (e) {
      debugPrint('Error in registerWithEmailAndPassword: $e');
      throw _handleAuthError(e);
    }
  }

  // Sign in with Google
  Future<UserModel> signInWithGoogle() async {
    try {
      debugPrint('Initiating Google sign in process');
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) throw 'Google sign in aborted';

      debugPrint('Getting Google auth credentials');
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      debugPrint('Signing in to Firebase with Google credential');
      final UserCredential result = await _auth.signInWithCredential(credential);
      final user = result.user!;

      // Check if user exists in Firestore
      debugPrint('Checking if user exists in Firestore');
      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      if (!userDoc.exists) {
        debugPrint('Creating new user document for Google sign in');
        final userModel = UserModel(
          uid: user.uid,
          email: user.email!,
          displayName: user.displayName,
          photoUrl: user.photoURL,
          createdAt: DateTime.now(),
          lastLoginAt: DateTime.now(),
        );
        await _firestore.collection('users').doc(user.uid).set(userModel.toMap());
        return userModel;
      }

      await _updateUserLastLogin(user.uid);
      return await getUserData(user.uid);
    } catch (e) {
      debugPrint('Error in signInWithGoogle: $e');
      throw _handleAuthError(e);
    }
  }

  // Update last login
  Future<void> _updateUserLastLogin(String uid) async {
    try {
      debugPrint('Updating last login time for user: $uid');
      await _firestore.collection('users').doc(uid).update({
        'lastLoginAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('Error updating last login: $e');
      // Don't throw here as this is not critical
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      debugPrint('Signing out user');
      await Future.wait([
        _auth.signOut(),
        _googleSignIn.signOut(),
      ]);
    } catch (e) {
      debugPrint('Error in signOut: $e');
      throw _handleAuthError(e);
    }
  }

  // Reset password
  Future<void> resetPassword(String email) async {
    try {
      debugPrint('Sending password reset email to: $email');
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      debugPrint('Error in resetPassword: $e');
      throw _handleAuthError(e);
    }
  }

  // Update user profile
  Future<UserModel> updateProfile({String? displayName, String? photoUrl}) async {
    try {
      debugPrint('Updating user profile');
      final user = _auth.currentUser;
      if (user == null) throw 'No user logged in';

      if (displayName != null) {
        await user.updateDisplayName(displayName);
      }
      if (photoUrl != null) {
        await user.updatePhotoURL(photoUrl);
      }

      await _firestore.collection('users').doc(user.uid).update({
        if (displayName != null) 'displayName': displayName,
        if (photoUrl != null) 'photoUrl': photoUrl,
        'lastLoginAt': FieldValue.serverTimestamp(),
      });

      return await getUserData(user.uid);
    } catch (e) {
      debugPrint('Error in updateProfile: $e');
      throw _handleAuthError(e);
    }
  }

  // Handle authentication errors
  String _handleAuthError(dynamic e) {
    if (e is FirebaseAuthException) {
      switch (e.code) {
        case 'user-not-found':
          return 'No user found with this email.';
        case 'wrong-password':
          return 'Wrong password provided.';
        case 'email-already-in-use':
          return 'Email is already in use.';
        case 'invalid-email':
          return 'Invalid email address.';
        case 'weak-password':
          return 'Password is too weak.';
        case 'operation-not-allowed':
          return 'Operation not allowed.';
        case 'user-disabled':
          return 'User has been disabled.';
        default:
          return 'An error occurred: ${e.message}';
      }
    }
    return e.toString();
  }
}
