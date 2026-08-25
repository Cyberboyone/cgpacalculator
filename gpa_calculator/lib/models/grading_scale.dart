/// A single grade level, e.g. "A" -> 4.0 points.
class GradeLevel {
  final String label;
  final double points;

  const GradeLevel({required this.label, required this.points});

  Map<String, dynamic> toJson() => {'label': label, 'points': points};

  factory GradeLevel.fromJson(Map<String, dynamic> json) => GradeLevel(
        label: json['label'] as String,
        points: (json['points'] as num).toDouble(),
      );
}

/// The type of scale a course's grade is entered as.
enum ScaleKind { letter, percentage }

/// A grading scale: either a set of letter-grade levels (4.0, 5.0, custom)
/// or a raw percentage scale (0-100, weighted average).
class GradingScale {
  final String id;
  final String name;
  final ScaleKind kind;
  final List<GradeLevel> levels; // empty for percentage kind
  final double maxScale; // e.g. 4.0, 5.0, or 100 for percentage

  const GradingScale({
    required this.id,
    required this.name,
    required this.kind,
    required this.levels,
    required this.maxScale,
  });

  bool get isPercentage => kind == ScaleKind.percentage;

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'kind': kind.name,
        'levels': levels.map((l) => l.toJson()).toList(),
        'maxScale': maxScale,
      };

  factory GradingScale.fromJson(Map<String, dynamic> json) => GradingScale(
        id: json['id'] as String,
        name: json['name'] as String,
        kind: ScaleKind.values.firstWhere((k) => k.name == json['kind']),
        levels: (json['levels'] as List<dynamic>)
            .map((l) => GradeLevel.fromJson(l as Map<String, dynamic>))
            .toList(),
        maxScale: (json['maxScale'] as num).toDouble(),
      );

  static GradingScale preset4Point() => const GradingScale(
        id: 'preset-4.0',
        name: '4.0 Scale (US)',
        kind: ScaleKind.letter,
        maxScale: 4.0,
        levels: [
          GradeLevel(label: 'A', points: 4.0),
          GradeLevel(label: 'A-', points: 3.7),
          GradeLevel(label: 'B+', points: 3.3),
          GradeLevel(label: 'B', points: 3.0),
          GradeLevel(label: 'B-', points: 2.7),
          GradeLevel(label: 'C+', points: 2.3),
          GradeLevel(label: 'C', points: 2.0),
          GradeLevel(label: 'C-', points: 1.7),
          GradeLevel(label: 'D+', points: 1.3),
          GradeLevel(label: 'D', points: 1.0),
          GradeLevel(label: 'F', points: 0.0),
        ],
      );

  static GradingScale preset5Point() => const GradingScale(
        id: 'preset-5.0',
        name: '5.0 Scale (Nigerian)',
        kind: ScaleKind.letter,
        maxScale: 5.0,
        levels: [
          GradeLevel(label: 'A', points: 5.0),
          GradeLevel(label: 'B', points: 4.0),
          GradeLevel(label: 'C', points: 3.0),
          GradeLevel(label: 'D', points: 2.0),
          GradeLevel(label: 'E', points: 1.0),
          GradeLevel(label: 'F', points: 0.0),
        ],
      );

  static GradingScale presetPercentage() => const GradingScale(
        id: 'preset-percentage',
        name: 'Percentage (0-100)',
        kind: ScaleKind.percentage,
        maxScale: 100.0,
        levels: [],
      );

  static List<GradingScale> builtInPresets() =>
      [preset4Point(), preset5Point(), presetPercentage()];
}
