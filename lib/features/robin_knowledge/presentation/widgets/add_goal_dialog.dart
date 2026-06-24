import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:opfan/core/models/goal_model.dart';
import 'package:opfan/features/robin_knowledge/bloc/robin_knowledge_bloc.dart';
import 'package:opfan/shared/utils/theme.dart';
import 'package:opfan/shared/widgets/atoms/custom_dropdown.dart';
import 'package:opfan/shared/widgets/atoms/custom_text_field.dart';
import 'package:opfan/l10n/app_localizations.dart';


class AddGoalDialog extends StatefulWidget {
  final RobinKnowledgeBloc robinKnowledgeBloc;
  
  const AddGoalDialog({
    super.key,
    required this.robinKnowledgeBloc,
  });

  @override
  State<AddGoalDialog> createState() => _AddGoalDialogState();
}

class _AddGoalDialogState extends State<AddGoalDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _notesController = TextEditingController();
  final _tagsController = TextEditingController();

  DateTime _selectedDeadline = DateTime.now().add(const Duration(days: 7));
  GoalCategory _selectedCategory = GoalCategory.study;
  double _progress = 0.0;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _notesController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(context),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildTitleField(),
                      const SizedBox(height: 16),
                      _buildDescriptionField(),
                      const SizedBox(height: 16),
                      _buildCategoryField(),
                      const SizedBox(height: 16),
                      _buildDeadlineField(),
                      const SizedBox(height: 16),
                      _buildProgressField(),
                      const SizedBox(height: 16),
                      _buildTagsField(),
                      const SizedBox(height: 16),
                      _buildNotesField(),
                    ],
                  ),
                ),
              ),
            ),
            _buildActions(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(12),
          topRight: Radius.circular(12),
        ),
      ),
      child: Row(
        children: [
          Icon(
            FontAwesomeIcons.bookAtlas,
            color: AppColors.purple[350],
          ),
          const SizedBox(width: 12),
          Text(
            AppLocalizations.of(context)!.newGoal,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.purple[350],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTitleField() {
    return CustomTextField(
      controller: _titleController,
      label: '${AppLocalizations.of(context)!.title} *',
      hint: AppLocalizations.of(context)!.enterGoalTitle,
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return AppLocalizations.of(context)!.titleRequired;
        }
        return null;
      },
    );
  }

  Widget _buildDescriptionField() {
    return CustomTextField(
      controller: _descriptionController,
      label: AppLocalizations.of(context)!.description,
      hint: AppLocalizations.of(context)!.enterGoalDescription,
      maxLines: 3,
    );
  }

  Widget _buildCategoryField() {
    return CustomDropdown<GoalCategory>(
      value: _selectedCategory,
      label: AppLocalizations.of(context)!.category,
      items: GoalCategory.values.toList(),
      itemToString: (category) => _getCategoryName(context, category),
      itemBuilder: (category) => Row(
        children: [
          Icon(_getCategoryIcon(category), size: 16),
          const SizedBox(width: 8),
          Text(_getCategoryName(context, category)),
        ],
      ),
      onChanged: (value) {
        if (value != null) {
          setState(() {
            _selectedCategory = value;
          });
        }
      },
    );
  }

  Widget _buildDeadlineField() {
    return InkWell(
      onTap: () => _selectDeadline(context),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: AppLocalizations.of(context)!.deadline,
          border: const OutlineInputBorder(),
          suffixIcon: const Icon(Icons.calendar_today),
        ),
        child: Text(
          DateFormat('dd/MM/yyyy').format(_selectedDeadline),
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ),
    );
  }

  Widget _buildProgressField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context)!.initialProgress(_progress.toInt()),
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Slider(
          value: _progress,
          min: 0,
          max: 100,
          activeColor: AppColors.purple[350],
          thumbColor: AppColors.purple[350],
          divisions: 20,
          label: '${_progress.toInt()}%',
          onChanged: (value) {
            setState(() {
              _progress = value;
            });
          },
        ),
      ],
    );
  }

  Widget _buildTagsField() {
    return CustomTextField(
      controller: _tagsController,
      label: AppLocalizations.of(context)!.tags,
      hint: AppLocalizations.of(context)!.enterTagsCommaSeparated,
    );
  }

  Widget _buildNotesField() {
    return CustomTextField(
      controller: _notesController,
      label: AppLocalizations.of(context)!.notes,
      hint: AppLocalizations.of(context)!.enterAdditionalNotes,
      maxLines: 3,
    );
  }

  Widget _buildActions(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.purple[350],
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(12),
          bottomRight: Radius.circular(12),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: OutlinedButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.onSurface,
            ),
            child: Text(AppLocalizations.of(context)!.cancelAction),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: _saveGoal,
            child: Text(AppLocalizations.of(context)!.saveAction),
          ),
        ],
      ),
    );
  }

  Future<void> _selectDeadline(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDeadline,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 3)),
    );
    if (picked != null && picked != _selectedDeadline) {
      setState(() {
        _selectedDeadline = picked;
      });
    }
  }

  void _saveGoal() {
    if (_formKey.currentState!.validate()) {
      final tags = _tagsController.text
          .split(',')
          .map((tag) => tag.trim())
          .where((tag) => tag.isNotEmpty)
          .toList();

      final goal = GoalModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        deadline: _selectedDeadline,
        createdAt: DateTime.now(),
        category: _selectedCategory,
        progress: _progress,
        tags: tags,
        notes: _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
      );

      widget.robinKnowledgeBloc.add(AddGoal(goal));
      Navigator.pop(context);
    }
  }

  IconData _getCategoryIcon(GoalCategory category) {
    switch (category) {
      case GoalCategory.study:
        return FontAwesomeIcons.book;
      case GoalCategory.work:
        return FontAwesomeIcons.briefcase;
      case GoalCategory.personal:
        return FontAwesomeIcons.user;
      case GoalCategory.health:
        return FontAwesomeIcons.heart;
      case GoalCategory.finance:
        return FontAwesomeIcons.coins;
      case GoalCategory.other:
        return FontAwesomeIcons.star;
    }
  }

  String _getCategoryName(BuildContext context, GoalCategory category) {
    switch (category) {
      case GoalCategory.study:
        return AppLocalizations.of(context)!.study;
      case GoalCategory.work:
        return AppLocalizations.of(context)!.work;
      case GoalCategory.personal:
        return AppLocalizations.of(context)!.personal;
      case GoalCategory.health:
        return AppLocalizations.of(context)!.health;
      case GoalCategory.finance:
        return AppLocalizations.of(context)!.finance;
      case GoalCategory.other:
        return AppLocalizations.of(context)!.other;
    }
  }
}
