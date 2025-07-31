import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

ValueNotifier<FirestoreServices> firestore = ValueNotifier(FirestoreServices());

class FirestoreServices {
  final db = FirebaseFirestore.instance;
  User? get user => FirebaseAuth.instance.currentUser;

  Future<void> createUserRecordIfNotExists() async {
    if (user == null) return;

    final docRef = db.collection('users').doc(user?.uid);
    final doc = await docRef.get();

    if (!doc.exists) {
      await docRef.set({
        'email': user?.email,
        'createdAt': FieldValue.serverTimestamp(),
      });
    }
  }

  Future<void> addUsername(String username) async {
    if (user == null) return;
    final docRef = db.collection('users').doc(user?.uid);
    await docRef.set({'username': username}, SetOptions(merge: true));
  }

  Future<void> updateUsername(String username) async {
    if (user == null) return;
    final docRef = db.collection('users').doc(user?.uid);
    await docRef.update({'username': username});
  }

  Future<Map<String, dynamic>?> getUserDoc() async {
    final docRef = db.collection('users').doc(user?.uid);
    final DocumentSnapshot doc = await docRef.get();
    final data = doc.data() as Map<String, dynamic>;
    return data;
  }
}
