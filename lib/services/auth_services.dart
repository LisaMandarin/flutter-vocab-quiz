import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

ValueNotifier<AuthServices> authService = ValueNotifier(AuthServices());

class AuthServices {
  // initialize firebase authentication service
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;

  // fetch current user
  User? get currentUser => firebaseAuth.currentUser;

  // watch authentication change
  Stream<User?> get authStateChange => firebaseAuth.authStateChanges();

  // log in with email and password
  Future<UserCredential> signIn({
    required String email,
    required String password,
  }) async {
    return await firebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  // register with email and password
  Future<UserCredential> createAccount({
    required String email,
    required String password,
  }) async {
    return await firebaseAuth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  // log out
  Future<void> signOut() async {
    return await firebaseAuth.signOut();
  }

  // reset password and send reset link to user's email
  Future<void> resetPassword({required String email}) async {
    return await firebaseAuth.sendPasswordResetEmail(email: email);
  }

  // change user's authentication username
  Future<void> updateUsername({required String displayName}) async {
    return await firebaseAuth.currentUser?.updateDisplayName(displayName);
  }

  // change password through current password
  Future<void> resetPasswordFromCurrentPassword({
    required String email,
    required String password,
    required String newPassword,
  }) async {
    AuthCredential credential = EmailAuthProvider.credential(
      email: email,
      password: password,
    );
    await currentUser?.reauthenticateWithCredential(credential);
    await currentUser?.updatePassword(newPassword);
  }
}
