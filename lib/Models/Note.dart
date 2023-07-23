class Note {
  int ?id;
  String title;
  String content;

  Note({
     this.id,
    required this.title,
    required this.content,
  });

  // Method to convert a Note object to a Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'content': content,
    };
  }

  // Static method to create a Note object from a Map
  static Note fromMap(Map<String, dynamic> map) {
    return Note(
      id: map['id'],
      title: map['title'],
      content: map['content'],
    );
  }
}
