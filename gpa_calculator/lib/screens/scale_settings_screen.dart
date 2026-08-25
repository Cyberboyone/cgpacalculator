import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../models/grading_scale.dart';
import '../services/app_state.dart';

const _uuid = Uuid();

class ScaleSettingsScreen extends StatelessWidget {
  const ScaleSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();

    return Scaffold(
      appBar: AppBar(title: const Text('Grading scale')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('Presets', style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 8),
          ...GradingScale.builtInPresets().map(
            (scale) => _ScaleTile(
              scale: scale,
              selected: app.activeScaleId == scale.id,
              onTap: () => context.read<AppState>().setActiveScale(scale.id),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Your custom scales', style: Theme.of(context).textTheme.titleSmall),
              TextButton.icon(
                icon: const Icon(Icons.add, size: 18),
                label: const Text('New'),
                onPressed: () => _openCustomScaleBuilder(context),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (app.customScales.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                'No custom scales yet. Create one if your school uses a different grading system.',
                style: TextStyle(color: Colors.grey.shade600),
              ),
            )
          else
            ...app.customScales.map(
              (scale) => _ScaleTile(
                scale: scale,
                selected: app.activeScaleId == scale.id,
                onTap: () => context.read<AppState>().setActiveScale(scale.id),
                onDelete: () => context.read<AppState>().deleteCustomScale(scale.id),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _openCustomScaleBuilder(BuildContext context) async {
    final nameController = TextEditingController();
    final List<Map<String, TextEditingController>> rows = [
      {'label': TextEditingController(text: 'A'), 'points': TextEditingController(text: '4.0')},
      {'label': TextEditingController(text: 'B'), 'points': TextEditingController(text: '3.0')},
    ];

    final saved = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          title: const Text('New custom scale'),
          content: SizedBox(
            width: double.maxFinite,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(labelText: 'Scale name (e.g. "My University")'),
                  ),
                  const SizedBox(height: 12),
                  ...rows.asMap().entries.map((entry) {
                    final i = entry.key;
                    final row = entry.value;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: row['label'],
                              decoration: const InputDecoration(labelText: 'Grade'),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextField(
                              controller: row['points'],
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              decoration: const InputDecoration(labelText: 'Points'),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.remove_circle_outline),
                            onPressed: rows.length <= 1
                                ? null
                                : () => setState(() => rows.removeAt(i)),
                          ),
                        ],
                      ),
                    );
                  }),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton.icon(
                      icon: const Icon(Icons.add),
                      label: const Text('Add grade level'),
                      onPressed: () => setState(() => rows.add({
                            'label': TextEditingController(),
                            'points': TextEditingController(),
                          })),
                    ),
                  ),
                ],
              ),
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
    final levels = <GradeLevel>[];
    for (final row in rows) {
      final label = row['label']!.text.trim();
      final points = double.tryParse(row['points']!.text.trim());
      if (label.isEmpty || points == null) continue;
      levels.add(GradeLevel(label: label, points: points));
    }

    if (name.isEmpty || levels.isEmpty) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Enter a name and at least one valid grade level.')),
        );
      }
      return;
    }

    final maxScale = levels.map((l) => l.points).reduce((a, b) => a > b ? a : b);
    final scale = GradingScale(
      id: _uuid.v4(),
      name: name,
      kind: ScaleKind.letter,
      levels: levels,
      maxScale: maxScale,
    );

    if (context.mounted) {
      await context.read<AppState>().addCustomScale(scale);
      await context.read<AppState>().setActiveScale(scale.id);
    }
  }
}

class _ScaleTile extends StatelessWidget {
  final GradingScale scale;
  final bool selected;
  final VoidCallback onTap;
  final VoidCallback? onDelete;

  const _ScaleTile({
    required this.scale,
    required this.selected,
    required this.onTap,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      color: selected ? Theme.of(context).colorScheme.primaryContainer : null,
      child: ListTile(
        onTap: onTap,
        leading: Icon(selected ? Icons.check_circle : Icons.circle_outlined),
        title: Text(scale.name),
        subtitle: Text(
          scale.isPercentage
              ? 'Weighted percentage average'
              : scale.levels.map((l) => '${l.label}=${l.points}').join('  '),
        ),
        trailing: onDelete != null
            ? IconButton(icon: const Icon(Icons.delete_outline), onPressed: onDelete)
            : null,
      ),
    );
  }
}
