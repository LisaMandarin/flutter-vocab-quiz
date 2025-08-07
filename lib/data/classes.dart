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
}

class VocabList {
  final Timestamp createdAt;
  final String ownerId;
  final String title;
  final String username;
  final List<VocabItem> list;

  VocabList({
    required this.createdAt,
    required this.ownerId,
    required this.title,
    required this.username,
    required this.list,
  });

  factory VocabList.fromMap(Map<String, dynamic> map) {
    return VocabList(
      createdAt: map['createdAt'] as Timestamp? ?? Timestamp.now(),
      ownerId: map['ownerId'] as String? ?? '',
      title: map['title'] as String? ?? '',
      username: map['username'] as String? ?? '',
      list: (map['list'] as List<dynamic>? ?? [])
          .map((item) => VocabItem.fromMap(item as Map<String, dynamic>))
          .toList(),
    );
  }
}
