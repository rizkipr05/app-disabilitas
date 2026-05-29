class MathMaterial {
  final int id;
  final int operand1;
  final int operand2;
  final String? explanation;
  final String? imagePath;
  final int level;

  MathMaterial({
    required this.id,
    required this.operand1,
    required this.operand2,
    this.explanation,
    this.imagePath,
    required this.level,
  });

  factory MathMaterial.fromJson(Map<String, dynamic> json) {
    return MathMaterial(
      id: int.parse(json['id'].toString()),
      operand1: int.parse(json['operand1'].toString()),
      operand2: int.parse(json['operand2'].toString()),
      explanation: json['explanation'],
      imagePath: json['image_path'],
      level: int.parse(json['level'].toString()),
    );
  }
}
