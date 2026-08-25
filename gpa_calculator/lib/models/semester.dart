import 'course.dart';

class Semester {
  final String id;
  String name;
  List<Course> courses;

  Semester({
    required this.id,
    required this.name,
    List<Course>? courses,
  }) : courses = courses ?? [];

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'courses': courses.map((c) => c.toJson()).toList(),
      };

  factory Semester.fromJson(Map<String, dynamic> json) => Semester(
        id: json['id'] as String,
        name: json['name'] as String,
        courses: (json['courses'] as List<dynamic>)
            .map((c) => Course.fromJson(c as Map<String, dynamic>))
            .toList(),
      );
}
