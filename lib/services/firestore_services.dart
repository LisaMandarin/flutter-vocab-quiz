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
    if (!doc.exists) return null;
    final data = doc.data() as Map<String, dynamic>;
    return data;
  }

  Future<void> addWordList(
    TextEditingController title,
    List<Map<String, String>> wordList,
  ) async {
    final docRef = db.collection('word_lists').doc();
    await docRef.set({
      "ownerId": user?.uid,
      "username": user?.displayName ?? "Unknown",
      "createdAt": FieldValue.serverTimestamp(),
      "title": title.text.trim(),
      "wordList": wordList,
    });
  }

  Future<void> updateWordList(
    String id,
    List<Map<String, String>> wordList,
  ) async {
    final docRef = db.collection('word_lists').doc(id);
    await docRef.update({
      "wordList": wordList,
      "updatedAt": FieldValue.serverTimestamp(),
    });
  }

  Future<List<QueryDocumentSnapshot>> getMyWordLists() async {
    if (user == null) return [];
    final querySnapshot = await db
        .collection('word_lists')
        .where('ownerId', isEqualTo: user?.uid)
        .orderBy('createdAt', descending: true)
        .get();
    return querySnapshot.docs;
  }

  Future<List<QueryDocumentSnapshot>> getMyTop4Lists() async {
    if (user == null) return [];
    final querySnapshot = await db
        .collection('word_lists')
        .where('ownerId', isEqualTo: user?.uid)
        .orderBy('createdAt', descending: true)
        .limit(4)
        .get();
    return querySnapshot.docs;
  }

  Future<DocumentSnapshot?> getWordList(String id) async {
    if (id.isEmpty) return null;
    final docRef = db.collection('word_lists').doc(id);
    final DocumentSnapshot doc = await docRef.get();
    return doc.exists ? doc : null;
  }

  Future<void> deleteWordList(String id) async {
    await db.collection('word_lists').doc(id).delete();
  }
}
