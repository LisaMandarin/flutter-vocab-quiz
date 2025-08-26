import 'package:cloud_firestore/cloud_firestore.dart';

class VocabItem {
  final String word;
  final String definition;

  VocabItem({required this.word, required this.definition});

  factory VocabItem.fromMap(Map<String, dynamic> map) {
    return VocabItem(
      word: map['word'] as String? ?? '',
      definition: map['definition'] as String? ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {'word': word, 'definition': definition};
  }
}

class VocabList {
  final Timestamp createdAt;
  final Timestamp updatedAt;
  final String ownerId;
  final String title;
  final String username;
  final bool isFavorite;
  final bool isPublic;
  final List<VocabItem> list;

  VocabList({
    required this.createdAt,
    required this.updatedAt,
    required this.ownerId,
    required this.title,
    required this.username,
    required this.isFavorite,
    required this.isPublic,
    required this.list,
  });

  factory VocabList.fromMap(Map<String, dynamic> map) {
    return VocabList(
      createdAt: map['createdAt'] as Timestamp? ?? Timestamp.now(),
      updatedAt: map['updatedAt'] as Timestamp? ?? Timestamp.now(),
      ownerId: map['ownerId'] as String? ?? '',
      title: map['title'] as String? ?? '',
      username: map['username'] as String? ?? '',
      isFavorite: map['isFavorite'] as bool? ?? false,
      isPublic: map['isPublic'] as bool? ?? false,
      list: (map['list'] as List<dynamic>? ?? [])
          .map((item) => VocabItem.fromMap(item as Map<String, dynamic>))
          .toList(),
    );
  }
}

class StoredPublicWordlist {
  final Timestamp storedAt;
  final String storedBy;
  final String storedUsername;
  final String wordlistId;
  final String wordlistOwnerId;
  final String wordlistOwnerName;
  final String wordlistTitle;

  StoredPublicWordlist({
    required this.storedAt,
    required this.storedBy,
    required this.storedUsername,
    required this.wordlistId,
    required this.wordlistOwnerId,
    required this.wordlistOwnerName,
    required this.wordlistTitle,
  });

  factory StoredPublicWordlist.fromMap(Map<String, dynamic> map) {
    return StoredPublicWordlist(
      storedAt: map['storedAt'] as Timestamp? ?? Timestamp.now(),
      storedBy: map['storedBy'] as String? ?? "",
      storedUsername: map['storedUsername'] as String? ?? "",
      wordlistId: map['wordlistId'] as String? ?? "",
      wordlistOwnerId: map['wordlistOwnerId'] as String? ?? "",
      wordlistOwnerName: map['wordlistOwnerName'] as String? ?? "",
      wordlistTitle: map['wordlistTitle'] as String? ?? "",
    );
  }
}
