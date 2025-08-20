import 'package:flutter/material.dart';
import 'package:opfan/core/models/goal_model.dart';
import 'package:opfan/utils/theme.dart';

class UpdateProgressDialog extends StatefulWidget {
  final GoalModel goal;
  final int increment;

  const UpdateProgressDialog({
    super.key,
    required this.goal,
    required this.increment,
  });

  @override
  State<UpdateProgressDialog> createState() => _UpdateProgressDialogState();
}

class _UpdateProgressDialogState extends State<UpdateProgressDialog> {
  final _notesController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final newProgress = (widget.goal.progress + widget.increment).clamp(0.0, 100.0);
    final isIncrement = widget.increment > 0;

    return AlertDialog(
      title: Text(
        isIncrement ? 'Aumentar Progresso' : 'Diminuir Progresso',
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.bold,
        ),
      ),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Objetivo: ${widget.goal.title}',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Text(
                  'Progresso atual: ',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                Text(
                  '${widget.goal.progress.toStringAsFixed(1)}%',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.purple[350],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Text(
                  'Novo progresso: ',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                Text(
                  '${newProgress.toStringAsFixed(1)}%',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isIncrement ? Colors.green : Colors.orange,
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  isIncrement ? Icons.arrow_upward : Icons.arrow_downward,
                  size: 16,
                  color: isIncrement ? Colors.green : Colors.orange,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Atualizações sobre o plano:',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _notesController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: isIncrement 
                  ? 'O que você fez para progredir? (ex: estudou 2 horas, completou exercícios...)'
                  : 'Por que o progresso diminuiu? (ex: atraso, dificuldade encontrada...)',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppColors.purple[350]!),
                ),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Por favor, descreva o que aconteceu';
                }
                return null;
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              Navigator.of(context).pop({
                'progress': newProgress,
                'notes': _notesController.text.trim(),
              });
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.purple[350],
            foregroundColor: Colors.white,
          ),
          child: Text(isIncrement ? 'Aumentar' : 'Diminuir'),
        ),
      ],
    );
  }
}
