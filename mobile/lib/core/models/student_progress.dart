class StudentProgress {
  final int id;
  final int studentId;
  final String? fullName;
  final String module;
  final int materialId;
  final int score;
  final String completedAt;

  StudentProgress({
    required this.id,
    required this.studentId,
    this.fullName,
    required this.module,
    required this.materialId,
    required this.score,
    required this.completedAt,
  });

  factory StudentProgress.fromJson(Map<String, dynamic> json) {
    return StudentProgress(
      id: int.tryParse(json['id'].toString()) ?? 0,
      studentId: int.tryParse(json['student_id'].toString()) ?? 0,
      fullName: json['full_name'],
      module: json['module'] ?? "",
      materialId: int.tryParse(json['material_id'].toString()) ?? 0,
      score: int.tryParse(json['score'].toString()) ?? 0,
      completedAt: json['completed_at'] ?? "",
    );
  }
}
