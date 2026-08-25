import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/grading_scale.dart';
import '../models/semester.dart';

/// Handles all local (offline) persistence. No network calls are made here.
class StorageService {
  static const _kSemesters = 'semesters';
  static const _kActiveScaleId = 'active_scale_id';
  static const _kCustomScales = 'custom_scales';

  Future<List<Semester>> loadSemesters() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_kSemesters);
    if (raw == null || raw.isEmpty) return [];
    final list = jsonDecode(raw) as List<dynamic>;
    return list
        .map((e) => Semester.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> saveSemesters(List<Semester> semesters) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = jsonEncode(semesters.map((s) => s.toJson()).toList());
    await prefs.setString(_kSemesters, raw);
  }

  Future<List<GradingScale>> loadCustomScales() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_kCustomScales);
    if (raw == null || raw.isEmpty) return [];
    final list = jsonDecode(raw) as List<dynamic>;
    return list
        .map((e) => GradingScale.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> saveCustomScales(List<GradingScale> scales) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = jsonEncode(scales.map((s) => s.toJson()).toList());
    await prefs.setString(_kCustomScales, raw);
  }

  Future<String> loadActiveScaleId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_kActiveScaleId) ?? GradingScale.preset4Point().id;
  }

  Future<void> saveActiveScaleId(String id) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kActiveScaleId, id);
  }
}
