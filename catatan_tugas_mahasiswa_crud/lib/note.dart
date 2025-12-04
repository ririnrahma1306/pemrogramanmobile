// lib/note.dart
class Note {
  String title;
  String content;
  DateTime createdDate;
  String category; // Kuliah, Organisasi, Pribadi, Lain-lain

  Note({
    required this.title,
    required this.content,
    required this.createdDate,
    required this.category,
  });

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'content': content,
      'createdDate': createdDate.toIso8601String(),
      'category': category,
    };
  }

  factory Note.fromMap(Map<String, dynamic> map) {
    return Note(
      title: map['title'] ?? '',
      content: map['content'] ?? '',
      createdDate: DateTime.parse(map['createdDate'] ?? DateTime.now().toIso8601String()),
      category: map['category'] ?? 'Lain-lain',
    );
  }
}