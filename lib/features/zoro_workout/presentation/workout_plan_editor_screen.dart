import 'package:opfan/shared/widgets/atoms/app_icon.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:opfan/features/zoro_workout/data/models/workout_plan_model.dart';
import 'package:opfan/features/zoro_workout/bloc/zoro_workout_bloc.dart';
import 'package:opfan/features/zoro_workout/bloc/zoro_workout_event.dart';
import 'package:opfan/features/zoro_workout/bloc/zoro_workout_state.dart';
import 'package:opfan/l10n/app_localizations.dart';
import 'package:opfan/shared/widgets/atoms/app_button.dart';

/// Full-screen editor for creating/editing a user's workout plan.
/// Supports multiple named splits (A, B, C…), each with a list of exercises.
class WorkoutPlanEditorScreen extends StatefulWidget {
  /// Pass existing plan to enter edit mode. null = create mode.
  final WorkoutPlanModel? existingPlan;

  const WorkoutPlanEditorScreen({super.key, this.existingPlan});

  @override
  State<WorkoutPlanEditorScreen> createState() =>
      _WorkoutPlanEditorScreenState();
}

class _WorkoutPlanEditorScreenState extends State<WorkoutPlanEditorScreen> {
  late List<_SplitDraft> _splits;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    if (widget.existingPlan != null && widget.existingPlan!.isNotEmpty) {
      _splits = widget.existingPlan!.splits.map((s) {
        return _SplitDraft(
          name: s.name,
          exercises: s.exercises
              .map((e) => _ExerciseDraft(name: e.name, volume: e.volume))
              .toList(),
        );
      }).toList();
    } else {
      _splits = [
        _SplitDraft(name: 'Treino A', exercises: [_ExerciseDraft()])
      ];
    }
  }

  void _addSplit() {
    setState(() {
      final letter = String.fromCharCode('A'.codeUnitAt(0) + _splits.length);
      _splits.add(
          _SplitDraft(name: 'Treino $letter', exercises: [_ExerciseDraft()]));
    });
  }

  void _removeSplit(int index) {
    if (_splits.length <= 1) return;
    setState(() => _splits.removeAt(index));
  }

  Future<void> _save() async {
    // Validate
    for (final split in _splits) {
      if (split.nameController.text.trim().isEmpty) {
        _showError('Dê um nome para cada split de treino.');
        return;
      }
      for (final ex in split.exercises) {
        if (ex.nameController.text.trim().isEmpty) {
          _showError('Preencha o nome de todos os exercícios.');
          return;
        }
        if (ex.volumeController.text.trim().isEmpty) {
          _showError('Preencha o volume de todos os exercícios (ex: 3x15).');
          return;
        }
      }
    }

    setState(() => _saving = true);

    final plan = WorkoutPlanModel(
      splits: _splits.map((s) {
        return WorkoutSplitModel(
          name: s.nameController.text.trim(),
          exercises: s.exercises.map((e) {
            return WorkoutExerciseModel(
              name: e.nameController.text.trim(),
              volume: e.volumeController.text.trim(),
            );
          }).toList(),
        );
      }).toList(),
    );

    context.read<ZoroWorkoutBloc>().add(SaveWorkoutPlan(workoutPlan: plan));
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg), behavior: SnackBarBehavior.floating));
  }

  @override
  void dispose() {
    for (final s in _splits) {
      s.nameController.dispose();
      for (final e in s.exercises) {
        e.nameController.dispose();
        e.volumeController.dispose();
      }
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    final isEdit = widget.existingPlan != null;

    return BlocListener<ZoroWorkoutBloc, ZoroWorkoutState>(
      listener: (context, state) {
        if (_saving) {
          if (state is ZoroWorkoutLoaded) {
            setState(() => _saving = false);
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(AppLocalizations.of(context)!.workoutPlanSaved),
                backgroundColor: Colors.green,
                behavior: SnackBarBehavior.floating,
              ),
            );
          } else if (state is ZoroWorkoutError) {
            setState(() => _saving = false);
            _showError(state.message);
          }
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title:
              Text(isEdit ? 'Editar Plano de Treino' : 'Criar Plano de Treino'),
          centerTitle: true,
          actions: [
            if (_saving)
              const Padding(
                padding: EdgeInsets.only(right: 16),
                child: Center(
                    child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2))),
              )
            else
              AppButton(
                onPressed: _save,
                variant: AppButtonVariant.text,
                label: AppLocalizations.of(context)!.saveLabel,
              ),
          ],
        ),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
          children: [
            // Instrução
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  AppIcon(PhosphorIconsRegular.info,
                      color: primary, size: 18),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Crie splits (A, B, C…) com exercícios. O app vai rodiziar automaticamente conforme seus dias de treino.',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Lista de splits
            ...List.generate(_splits.length, (splitIndex) {
              final split = _splits[splitIndex];
              return _SplitCard(
                split: split,
                splitIndex: splitIndex,
                totalSplits: _splits.length,
                primaryColor: primary,
                onRemove: () => _removeSplit(splitIndex),
                onAddExercise: () =>
                    setState(() => split.exercises.add(_ExerciseDraft())),
                onRemoveExercise: (exIndex) {
                  if (split.exercises.length <= 1) return;
                  setState(() => split.exercises.removeAt(exIndex));
                },
                onChanged: () => setState(() {}),
              );
            }),

            // Botão adicionar split
            const SizedBox(height: 16),
            AppButton(
              onPressed: _splits.length < 6 ? _addSplit : null,
              variant: AppButtonVariant.outline,
              icon: const AppIcon(PhosphorIconsRegular.plus),
              label: AppLocalizations.of(context)!.addSplit,
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: _saving ? null : _save,
          backgroundColor: primary,
          foregroundColor: Colors.white,
          icon: _saving
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: Colors.white))
              : const AppIcon(PhosphorIconsRegular.check),
          label: Text(_saving ? 'Salvando…' : 'Salvar Plano'),
        ),
      ),
    );
  }
}

// ─── Internal Draft Models ────────────────────────────────────────────────────

class _SplitDraft {
  final TextEditingController nameController;
  final List<_ExerciseDraft> exercises;

  _SplitDraft({required String name, required this.exercises})
      : nameController = TextEditingController(text: name);
}

class _ExerciseDraft {
  final TextEditingController nameController;
  final TextEditingController volumeController;

  _ExerciseDraft({String name = '', String volume = ''})
      : nameController = TextEditingController(text: name),
        volumeController = TextEditingController(text: volume);
}

// ─── Split Card Widget ────────────────────────────────────────────────────────

class _SplitCard extends StatelessWidget {
  final _SplitDraft split;
  final int splitIndex;
  final int totalSplits;
  final Color primaryColor;
  final VoidCallback onRemove;
  final VoidCallback onAddExercise;
  final void Function(int) onRemoveExercise;
  final VoidCallback onChanged;

  const _SplitCard({
    required this.split,
    required this.splitIndex,
    required this.totalSplits,
    required this.primaryColor,
    required this.onRemove,
    required this.onAddExercise,
    required this.onRemoveExercise,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: primaryColor.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header do split
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: primaryColor.withValues(alpha: 0.08),
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: primaryColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    String.fromCharCode('A'.codeUnitAt(0) + splitIndex),
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: split.nameController,
                    onChanged: (_) => onChanged(),
                    style: Theme.of(context)
                        .textTheme
                        .titleSmall
                        ?.copyWith(fontWeight: FontWeight.bold),
                    decoration: InputDecoration(
                      hintText: AppLocalizations.of(context)!.splitNameHint,
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ),
                if (totalSplits > 1)
                  IconButton(
                    onPressed: onRemove,
                    icon: AppIcon(PhosphorIconsRegular.trash,
                        color: Theme.of(context).colorScheme.error, size: 20),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
              ],
            ),
          ),

          // Lista de exercícios
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                ...List.generate(split.exercises.length, (exIndex) {
                  final ex = split.exercises[exIndex];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Row(
                      children: [
                        // Número
                        Container(
                          width: 26,
                          height: 26,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: primaryColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            '${exIndex + 1}',
                            style: TextStyle(
                                color: primaryColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 12),
                          ),
                        ),
                        const SizedBox(width: 10),
                        // Nome do exercício
                        Expanded(
                          flex: 3,
                          child: TextField(
                            controller: ex.nameController,
                            onChanged: (_) => onChanged(),
                            decoration: InputDecoration(
                              hintText:
                                  AppLocalizations.of(context)!.exerciseHint,
                              hintStyle: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurface
                                          .withValues(alpha: 0.4)),
                              isDense: true,
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 10),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurface
                                        .withValues(alpha: 0.2)),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurface
                                        .withValues(alpha: 0.2)),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Volume
                        Expanded(
                          flex: 2,
                          child: TextField(
                            controller: ex.volumeController,
                            onChanged: (_) => onChanged(),
                            decoration: InputDecoration(
                              hintText:
                                  AppLocalizations.of(context)!.setsRepsHint,
                              hintStyle: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurface
                                          .withValues(alpha: 0.4)),
                              isDense: true,
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 10),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurface
                                        .withValues(alpha: 0.2)),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurface
                                        .withValues(alpha: 0.2)),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        // Remover exercício
                        if (split.exercises.length > 1)
                          GestureDetector(
                            onTap: () => onRemoveExercise(exIndex),
                            child: AppIcon(PhosphorIconsRegular.x,
                                size: 18,
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurface
                                    .withValues(alpha: 0.3)),
                          )
                        else
                          const SizedBox(width: 18),
                      ],
                    ),
                  );
                }),

                // Botão adicionar exercício
                GestureDetector(
                  onTap: onAddExercise,
                  child: Row(
                    children: [
                      AppIcon(PhosphorIconsRegular.plusCircle,
                          size: 18, color: primaryColor.withValues(alpha: 0.7)),
                      const SizedBox(width: 6),
                      Text(
                        'Adicionar exercício',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: primaryColor.withValues(alpha: 0.8),
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
