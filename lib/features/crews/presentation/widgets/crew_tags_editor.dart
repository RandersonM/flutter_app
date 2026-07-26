import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:opfan/l10n/app_localizations.dart';
import 'package:opfan/shared/widgets/atoms/app_icon.dart';

import 'crew_form_card.dart';

/// Tag list with an add-dialog and removable chips.
///
/// Stateless by design: the owning form holds the tag list, so create (starts
/// empty) and edit (starts populated from the crew) share one widget.
class CrewTagsEditor extends StatelessWidget {
  const CrewTagsEditor({
    super.key,
    required this.tags,
    required this.onAdd,
    required this.onRemove,
  });

  final List<String> tags;
  final ValueChanged<String> onAdd;
  final ValueChanged<String> onRemove;

  Future<void> _showAddTagDialog(BuildContext context) async {
    final loc = AppLocalizations.of(context)!;
    final tagController = TextEditingController();

    final tag = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(loc.addTag),
        content: TextField(
          controller: tagController,
          decoration: InputDecoration(
            labelText: loc.tagName,
            hintText: loc.tagNameHint,
          ),
          autofocus: true,
          onSubmitted: (value) => Navigator.pop(dialogContext, value.trim()),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(loc.cancel),
          ),
          ElevatedButton(
            onPressed: () =>
                Navigator.pop(dialogContext, tagController.text.trim()),
            child: Text(loc.add),
          ),
        ],
      ),
    );

    // Dispose only after the dialog closed — the TextField still reads it while
    // the route is animating out.
    tagController.dispose();

    if (tag != null && tag.isNotEmpty) onAdd(tag);
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return CrewFormCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CrewFormSectionTitle(
            icon: const AppIcon(PhosphorIconsRegular.tag),
            label: loc.tagsLabel,
            trailing: IconButton(
              onPressed: () => _showAddTagDialog(context),
              icon: const AppIcon(PhosphorIconsRegular.plusCircle),
            ),
          ),
          if (tags.isEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                loc.noTagsAdded,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(fontSize: 14),
              ),
            )
          else ...[
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: tags
                  .map(
                    (tag) => Chip(
                      label: Text(tag),
                      deleteIcon: const AppIcon(
                        PhosphorIconsRegular.x,
                        size: 18,
                      ),
                      onDeleted: () => onRemove(tag),
                    ),
                  )
                  .toList(),
            ),
          ],
        ],
      ),
    );
  }
}
