class DiaryEntry {
  int? id;
  final int? cardColor; // Optional field for card color
  int userId;
  String title;
  String content;
  String mood; // e.g., 'Happy', 'Sad', 'Neutral', 'Excited'
  DateTime entryDate;
  String? imagePath; // Path to the image file
  String? imageCaption;

  DiaryEntry({
    this.id,
    required this.userId,
    required this.title,
    required this.content,
    required this.mood,
    required this.entryDate,
    this.imagePath,
    this.imageCaption,
    this.cardColor, // Initialize cardColor if needed
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'title': title,
      'content': content,
      'mood': mood,
      'entryDate': entryDate.toIso8601String(), // Store as ISO 8601 string
      'imagePath': imagePath,
      'imageCaption': imageCaption,
      'cardColor': cardColor,
    };
  }

  factory DiaryEntry.fromMap(Map<String, dynamic> map) {
    return DiaryEntry(
      id: map['id'],
      userId: map['userId'],
      title: map['title'],
      content: map['content'],
      mood: map['mood'],
      entryDate: DateTime.parse(map['entryDate']),
      imagePath: map['imagePath'],
      imageCaption: map['imageCaption'],
      cardColor: map['cardColor'],
    );
  }
}