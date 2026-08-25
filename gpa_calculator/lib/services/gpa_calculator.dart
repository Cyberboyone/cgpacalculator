import '../models/course.dart';
import '../models/grading_scale.dart';
import '../models/semester.dart';

class GpaResult {
  final double gpa; // 0 if no valid courses
  final double totalCredits;
  final double qualityPoints;

  const GpaResult({
    required this.gpa,
    required this.totalCredits,
    required this.qualityPoints,
  });

  static const zero = GpaResult(gpa: 0, totalCredits: 0, qualityPoints: 0);
}

class GpaCalculator {
  /// Resolves the point value (out of scale.maxScale) for a single course.
  static double? pointsForCourse(Course course, GradingScale scale) {
    if (scale.isPercentage) {
      return course.scorePercent;
    }
    if (course.gradeLabel == null) return null;
    final level = scale.levels.where((l) => l.label == course.gradeLabel);
    if (level.isEmpty) return null;
    return level.first.points;
  }

  /// Weighted GPA for a single semester under the given scale.
  static GpaResult semesterGpa(Semester semester, GradingScale scale) {
    double totalCredits = 0;
    double qualityPoints = 0;
    for (final course in semester.courses) {
      final points = pointsForCourse(course, scale);
      if (points == null || course.creditUnits <= 0) continue;
      totalCredits += course.creditUnits;
      qualityPoints += points * course.creditUnits;
    }
    if (totalCredits == 0) return GpaResult.zero;
    return GpaResult(
      gpa: qualityPoints / totalCredits,
      totalCredits: totalCredits,
      qualityPoints: qualityPoints,
    );
  }

  /// Weighted CGPA across all semesters under the given scale.
  static GpaResult cumulativeGpa(
      List<Semester> semesters, GradingScale scale) {
    double totalCredits = 0;
    double qualityPoints = 0;
    for (final semester in semesters) {
      final result = semesterGpa(semester, scale);
      totalCredits += result.totalCredits;
      qualityPoints += result.qualityPoints;
    }
    if (totalCredits == 0) return GpaResult.zero;
    return GpaResult(
      gpa: qualityPoints / totalCredits,
      totalCredits: totalCredits,
      qualityPoints: qualityPoints,
    );
  }
}
