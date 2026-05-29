class ReadingMaterial {
  final int id;
  final String type; // word, 2_words, sentence
  final String content;
  final String? audioPath;
  final String? imagePath;
  final int level;

  ReadingMaterial({
    required this.id,
    required this.type,
    required this.content,
    this.audioPath,
    this.imagePath,
    required this.level,
  });

  factory ReadingMaterial.fromJson(Map<String, dynamic> json) {
    return ReadingMaterial(
      id: int.parse(json['id'].toString()),
      type: json['type'],
      content: json['content'],
      audioPath: json['audio_path'],
      imagePath: json['image_path'],
      level: int.parse(json['level'].toString()),
    );
  }
}
