import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../models/course.dart';
import '../models/grading_scale.dart';
import '../models/semester.dart';
import '../services/gpa_calculator.dart';
import '../services/storage_service.dart';

const _uuid = Uuid();

class AppState extends ChangeNotifier {
  final StorageService _storage = StorageService();

  List<Semester> semesters = [];
  List<GradingScale> customScales = [];
  String activeScaleId = GradingScale.preset4Point().id;
  bool loaded = false;

  List<GradingScale> get allScales => [
        ...GradingScale.builtInPresets(),
        ...customScales,
      ];

  GradingScale get activeScale => allScales.firstWhere(
        (s) => s.id == activeScaleId,
        orElse: () => GradingScale.preset4Point(),
      );

  GpaResult get cgpa => GpaCalculator.cumulativeGpa(semesters, activeScale);

  Future<void> load() async {
    semesters = await _storage.loadSemesters();
    customScales = await _storage.loadCustomScales();
    activeScaleId = await _storage.loadActiveScaleId();
    loaded = true;
    notifyListeners();
  }

  Future<void> _persistSemesters() async {
    await _storage.saveSemesters(semesters);
  }

  GpaResult semesterGpa(Semester s) =>
      GpaCalculator.semesterGpa(s, activeScale);

  Future<void> addSemester(String name) async {
    semesters.add(Semester(id: _uuid.v4(), name: name));
    notifyListeners();
    await _persistSemesters();
  }

  Future<void> renameSemester(String semesterId, String newName) async {
    final s = semesters.firstWhere((s) => s.id == semesterId);
    s.name = newName;
    notifyListeners();
    await _persistSemesters();
  }

  Future<void> deleteSemester(String semesterId) async {
    semesters.removeWhere((s) => s.id == semesterId);
    notifyListeners();
    await _persistSemesters();
  }

  Future<void> addCourse(String semesterId, Course course) async {
    final s = semesters.firstWhere((s) => s.id == semesterId);
    s.courses.add(course);
    notifyListeners();
    await _persistSemesters();
  }

  Future<void> updateCourse(String semesterId, Course updated) async {
    final s = semesters.firstWhere((s) => s.id == semesterId);
    final idx = s.courses.indexWhere((c) => c.id == updated.id);
    if (idx != -1) s.courses[idx] = updated;
    notifyListeners();
    await _persistSemesters();
  }

  Future<void> deleteCourse(String semesterId, String courseId) async {
    final s = semesters.firstWhere((s) => s.id == semesterId);
    s.courses.removeWhere((c) => c.id == courseId);
    notifyListeners();
    await _persistSemesters();
  }

  Future<void> setActiveScale(String scaleId) async {
    activeScaleId = scaleId;
    notifyListeners();
    await _storage.saveActiveScaleId(scaleId);
  }

  Future<void> addCustomScale(GradingScale scale) async {
    customScales.add(scale);
    notifyListeners();
    await _storage.saveCustomScales(customScales);
  }

  Future<void> deleteCustomScale(String scaleId) async {
    customScales.removeWhere((s) => s.id == scaleId);
    if (activeScaleId == scaleId) {
      await setActiveScale(GradingScale.preset4Point().id);
    }
    notifyListeners();
    await _storage.saveCustomScales(customScales);
  }
}
