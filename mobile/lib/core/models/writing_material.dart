class WritingMaterial {
  final int id;
  final String content;
  final String? guidelineImage;
  final String? imagePath;
  final int level;

  WritingMaterial({
    required this.id,
    required this.content,
    this.guidelineImage,
    this.imagePath,
    required this.level,
  });

  factory WritingMaterial.fromJson(Map<String, dynamic> json) {
    return WritingMaterial(
      id: int.parse(json['id'].toString()),
      content: json['content'],
      guidelineImage: json['guideline_image'],
      imagePath: json['image_path'],
      level: int.parse(json['level'].toString()),
    );
  }
}
