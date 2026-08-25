class Course {
  final String id;
  String name;
  double creditUnits;
  // For letter-grade scales: the grade label (e.g. "A", "B+").
  // For percentage scales: null (use scorePercent instead).
  String? gradeLabel;
  // For percentage scales: raw score 0-100.
  // For letter-grade scales: null.
  double? scorePercent;

  Course({
    required this.id,
    required this.name,
    required this.creditUnits,
    this.gradeLabel,
    this.scorePercent,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'creditUnits': creditUnits,
        'gradeLabel': gradeLabel,
        'scorePercent': scorePercent,
      };

  factory Course.fromJson(Map<String, dynamic> json) => Course(
        id: json['id'] as String,
        name: json['name'] as String,
        creditUnits: (json['creditUnits'] as num).toDouble(),
        gradeLabel: json['gradeLabel'] as String?,
        scorePercent: (json['scorePercent'] as num?)?.toDouble(),
      );
}
