import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../models/course.dart';
import '../services/app_state.dart';
import '../widgets/banner_ad_widget.dart';

const _uuid = Uuid();

class SemesterDetailScreen extends StatelessWidget {
  final String semesterId;
  const SemesterDetailScreen({super.key, required this.semesterId});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final semester = app.semesters.firstWhere((s) => s.id == semesterId);
    final scale = app.activeScale;
    final result = app.semesterGpa(semester);

    return Scaffold(
      appBar: AppBar(title: Text(semester.name)),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Semester GPA', style: Theme.of(context).textTheme.titleMedium),
                Text(
                  scale.maxScale == 100
                      ? '${result.gpa.toStringAsFixed(1)}%'
                      : result.gpa.toStringAsFixed(2),
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          Expanded(
            child: semester.courses.isEmpty
                ? Center(
                    child: Text('No courses yet. Tap + to add one.',
                        style: TextStyle(color: Colors.grey.shade600)),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: semester.courses.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final course = semester.courses[index];
                      return Card(
                        margin: EdgeInsets.zero,
                        child: ListTile(
                          title: Text(course.name),
                          subtitle: Text(
                            '${course.creditUnits.toStringAsFixed(0)} credit units · '
                            '${scale.isPercentage ? "${course.scorePercent?.toStringAsFixed(1) ?? "-"}%" : course.gradeLabel ?? "-"}',
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit_outlined),
                                onPressed: () => _openCourseDialog(context, existing: course),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete_outline),
                                onPressed: () => context
                                    .read<AppState>()
                                    .deleteCourse(semesterId, course.id),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
          const BannerAdWidget(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openCourseDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<void> _openCourseDialog(BuildContext context, {Course? existing}) async {
    final app = context.read<AppState>();
    final scale = app.activeScale;
    final nameController = TextEditingController(text: existing?.name ?? '');
    final creditController = TextEditingController(
      text: existing?.creditUnits.toStringAsFixed(0) ?? '',
    );
    final scoreController = TextEditingController(
      text: existing?.scorePercent?.toString() ?? '',
    );
    String? selectedGrade = existing?.gradeLabel ?? (scale.levels.isNotEmpty ? scale.levels.first.label : null);

    final saved = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          title: Text(existing == null ? 'Add course' : 'Edit course'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  autofocus: true,
                  decoration: const InputDecoration(labelText: 'Course name'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: creditController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(labelText: 'Credit units'),
                ),
                const SizedBox(height: 12),
                if (scale.isPercentage)
                  TextField(
                    controller: scoreController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(labelText: 'Score (0-100)'),
                  )
                else
                  DropdownButtonFormField<String>(
                    value: selectedGrade,
                    decoration: const InputDecoration(labelText: 'Grade'),
                    items: scale.levels
                        .map((l) => DropdownMenuItem(
                              value: l.label,
                              child: Text('${l.label} (${l.points})'),
                            ))
                        .toList(),
                    onChanged: (v) => setState(() => selectedGrade = v),
                  ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
            FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Save')),
          ],
        ),
      ),
    );

    if (saved != true) return;

    final name = nameController.text.trim();
    final credits = double.tryParse(creditController.text.trim());
    if (name.isEmpty || credits == null || credits <= 0) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Enter a valid course name and credit units.')),
        );
      }
      return;
    }

    double? scorePercent;
    if (scale.isPercentage) {
      scorePercent = double.tryParse(scoreController.text.trim());
      if (scorePercent == null || scorePercent < 0 || scorePercent > 100) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Enter a score between 0 and 100.')),
          );
        }
        return;
      }
    }

    final course = Course(
      id: existing?.id ?? _uuid.v4(),
      name: name,
      creditUnits: credits,
      gradeLabel: scale.isPercentage ? null : selectedGrade,
      scorePercent: scorePercent,
    );

    if (existing == null) {
      await app.addCourse(semesterId, course);
    } else {
      await app.updateCourse(semesterId, course);
    }
  }
}
