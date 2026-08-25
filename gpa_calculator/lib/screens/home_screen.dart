import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/app_state.dart';
import '../widgets/banner_ad_widget.dart';
import 'semester_detail_screen.dart';
import 'scale_settings_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  Future<void> _addSemester(BuildContext context) async {
    final controller = TextEditingController(
      text: 'Semester ${context.read<AppState>().semesters.length + 1}',
    );
    final name = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('New semester'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(labelText: 'Semester name'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, controller.text.trim()),
            child: const Text('Add'),
          ),
        ],
      ),
    );
    if (name != null && name.isNotEmpty && context.mounted) {
      await context.read<AppState>().addSemester(name);
    }
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();

    if (!app.loaded) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final cgpa = app.cgpa;

    return Scaffold(
      appBar: AppBar(
        title: const Text('GPA Calculator'),
        actions: [
          IconButton(
            icon: const Icon(Icons.tune),
            tooltip: 'Grading scale',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ScaleSettingsScreen()),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(child: _CgpaCard(cgpa: cgpa.gpa, scaleName: app.activeScale.name, scaleMax: app.activeScale.maxScale, totalCredits: cgpa.totalCredits)),
                if (app.semesters.isEmpty)
                  const SliverFillRemaining(
                    hasScrollBody: false,
                    child: _EmptyState(),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                    sliver: SliverList.separated(
                      itemCount: app.semesters.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        final semester = app.semesters[index];
                        final result = app.semesterGpa(semester);
                        return _SemesterTile(
                          name: semester.name,
                          gpa: result.gpa,
                          credits: result.totalCredits,
                          courseCount: semester.courses.length,
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  SemesterDetailScreen(semesterId: semester.id),
                            ),
                          ),
                          onDelete: () => _confirmDelete(context, semester.id, semester.name),
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),
          const BannerAdWidget(),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _addSemester(context),
        icon: const Icon(Icons.add),
        label: const Text('Semester'),
      ),
    );
  }

  Future<void> _confirmDelete(
      BuildContext context, String id, String name) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete semester?'),
        content: Text('This removes "$name" and all its courses.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      await context.read<AppState>().deleteSemester(id);
    }
  }
}

class _CgpaCard extends StatelessWidget {
  final double cgpa;
  final String scaleName;
  final double scaleMax;
  final double totalCredits;

  const _CgpaCard({
    required this.cgpa,
    required this.scaleName,
    required this.scaleMax,
    required this.totalCredits,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [theme.colorScheme.primary, theme.colorScheme.primaryContainer],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('CGPA', style: theme.textTheme.titleMedium?.copyWith(color: Colors.white70)),
          const SizedBox(height: 6),
          Text(
            scaleMax == 100 ? '${cgpa.toStringAsFixed(1)}%' : cgpa.toStringAsFixed(2),
            style: theme.textTheme.displayMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            '$scaleName · ${totalCredits.toStringAsFixed(0)} credit units',
            style: theme.textTheme.bodyMedium?.copyWith(color: Colors.white70),
          ),
        ],
      ),
    );
  }
}

class _SemesterTile extends StatelessWidget {
  final String name;
  final double gpa;
  final double credits;
  final int courseCount;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _SemesterTile({
    required this.name,
    required this.gpa,
    required this.credits,
    required this.courseCount,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        title: Text(name, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text('$courseCount course${courseCount == 1 ? '' : 's'} · ${credits.toStringAsFixed(0)} credits'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(gpa.toStringAsFixed(2), style: Theme.of(context).textTheme.titleLarge),
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: onDelete,
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.school_outlined, size: 56, color: Colors.grey.shade400),
            const SizedBox(height: 12),
            Text(
              'No semesters yet',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 4),
            Text(
              'Tap "Semester" below to add your first one.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade600),
            ),
          ],
        ),
      ),
    );
  }
}
