import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:vocab_quiz/data/classes.dart';

ValueNotifier<FirestoreServices> firestore = ValueNotifier(FirestoreServices());

// Service class for handling Firestore database operations
// Manages user data and vocabulary word lists with Firebase integration
class FirestoreServices {
  final db = FirebaseFirestore.instance;

  // get the currently authenticated user
  User? get user => FirebaseAuth.instance.currentUser;

  Future<void> createUserRecordIfNotExists() async {
    if (user == null) return;

    // get the user record after user registration to initialize their profile
    final docRef = db.collection('users').doc(user?.uid);
    final doc = await docRef.get();

    // create a user record in Firestore if it doesn't already exist
    if (!doc.exists) {
      await docRef.set({
        'email': user?.email,
        'createdAt': FieldValue.serverTimestamp(),
      });
    }
  }

  Future<void> addUsername(String username) async {
    if (user == null) return;

    // add a username to an existing user record
    final docRef = db.collection('users').doc(user?.uid);
    await docRef.set({'username': username}, SetOptions(merge: true));

    // update Firebase Auth display name
    await user?.updateDisplayName(username);
  }

  Future<void> updateUsername(String username) async {
    if (user == null) return;

    // update the username for the current user
    final docRef = db.collection('users').doc(user?.uid);
    await docRef.update({'username': username});

    // update Firebase Auth display name
    await user?.updateDisplayName(username);
  }

  Future<Map<String, dynamic>?> getUserDoc() async {
    // retrieve the current user data from users collection on Firestore
    final docRef = db.collection('users').doc(user?.uid);
    final DocumentSnapshot doc = await docRef.get();

    // Returns null if user document doesn't exist
    if (!doc.exists) return null;
    final data = doc.data() as Map<String, dynamic>;
    return data;
  }

  // create a new vocabulary word list in word_lists collection on Firestore
  Future<void> addWordList(
    TextEditingController title,
    List<Map<String, String>> list,
    bool isPublic,
    bool isFavorite,
  ) async {
    final docRef = db.collection('word_lists').doc();
    await docRef.set({
      "ownerId": user?.uid,
      "username": user?.displayName ?? "Unknown",
      "createdAt": FieldValue.serverTimestamp(),
      "updatedAt": FieldValue.serverTimestamp(),
      "title": title.text.trim(),
      "list": list,
      "isPublic": isPublic,
      "isFavorite": isFavorite,
    });
  }

  // update a new vocabulary word list in word_lists collection on Firestore
  Future<void> updateWordList(
    String id,
    String title,
    List<VocabItem> list,
    bool isPublic,
    bool isFavorite,
  ) async {
    final docRef = db.collection('word_lists').doc(id);
    await docRef.update({
      "title": title,
      "username": user?.displayName ?? "Unknown",
      "list": list.map((item) => item.toMap()).toList(),
      "updatedAt": FieldValue.serverTimestamp(),
      "isPublic": isPublic,
      "isFavorite": isFavorite,
    });
  }

  // retrieve all vocabulary word lists owned by the current user
  // return lists ordered by creation date (newest first)
  Future<List<QueryDocumentSnapshot>> getMyWordLists() async {
    if (user == null) return [];
    final querySnapshot = await db
        .collection('word_lists')
        .where('ownerId', isEqualTo: user?.uid)
        .orderBy('createdAt', descending: true)
        .get();
    return querySnapshot.docs;
  }

  // retrieves the 4 most recent vocabulary word lists for the current user
  // Used for displaying recent lists on the home screen
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

  // retrieve a specific vocabulary word list by ID
  // return null if the list doesn't exist or ID is empty
  Future<DocumentSnapshot?> getWordList(String id) async {
    if (id.isEmpty) return null;
    final docRef = db.collection('word_lists').doc(id);
    final DocumentSnapshot doc = await docRef.get();
    return doc.exists ? doc : null;
  }

  // deletes a vocabulary word list from Firestore
  Future<void> deleteWordList(String id) async {
    await db.collection('word_lists').doc(id).delete();
  }

  Future<List<QueryDocumentSnapshot>> getWordListsByPublic() async {
    if (user == null) return [];
    final querySnapshot = await db
        .collection("word_lists")
        .where("ownerId", isEqualTo: user?.uid)
        .where("isPublic", isEqualTo: true)
        .orderBy("createdAt", descending: true)
        .get();
    return querySnapshot.docs;
  }

  Future<List<QueryDocumentSnapshot>> getWordListsByFavorite() async {
    if (user == null) return [];
    final querySnapshot = await db
        .collection("word_lists")
        .where("ownerId", isEqualTo: user?.uid)
        .where("isFavorite", isEqualTo: true)
        .orderBy("createdAt", descending: true)
        .get();
    return querySnapshot.docs;
  }

  // get public word lists
  Future<List<QueryDocumentSnapshot>> getPublicWordLists() async {
    final querySnapshot = await db
        .collection("word_lists")
        .where("isPublic", isEqualTo: true)
        .orderBy("updatedAt", descending: true)
        .get();
    return querySnapshot.docs;
  }

  // get the latest 4 public word lists
  Future<List<QueryDocumentSnapshot>> getLatestPublicWordLists() async {
    final querySnapshot = await db
        .collection("word_lists")
        .where("isPublic", isEqualTo: true)
        .orderBy("updatedAt", descending: true)
        .limit(3)
        .get();
    return querySnapshot.docs;
  }

  // id is the combination of user ID and word list ID
  Future<void> storePublicWordlist(
    String wordlistId,
    String wordlistTitle,
    String wordlistOwnerId,
    String wordlistOwnerName,
    String userId,
    String userName,
  ) async {
    if (user == null) return;
    final savedId = "${user!.uid}_$wordlistId";
    final docRef = db.collection("stored_public_wordlists").doc(savedId);
    await docRef.set({
      "wordlistId": wordlistId,
      "wordlistTitle": wordlistTitle,
      "wordlistOwnerId": wordlistOwnerId,
      "wordlistOwnerName": wordlistOwnerName,
      "storedBy": userId,
      "storedUsername": userName,
      "storedAt": FieldValue.serverTimestamp(),
    });
  }

  // id is the combination of user ID and word list ID
  Future<void> deleteStoredPublicWordlist(String id) async {
    if (user == null) return;
    final docRef = db.collection("stored_public_wordlists").doc(id);
    await docRef.delete();
  }

  Future<List<QueryDocumentSnapshot>> getStoredPublicWordlistsByUser(
    String userId,
  ) async {
    if (user == null) return Future.value([]);
    final querySnapshot = await db
        .collection("stored_public_wordlists")
        .where("storedBy", isEqualTo: userId)
        .get();
    return querySnapshot.docs;
  }
}
