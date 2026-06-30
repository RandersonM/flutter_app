import 'package:opfan/shared/widgets/atoms/app_icon.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:flutter/material.dart';
import 'package:opfan/l10n/app_localizations.dart';
import 'package:opfan/features/devil_fruit/data/models/devil_fruit.dart';

class DevilFruitSearchDropdown extends StatefulWidget {
  final String label;
  final DevilFruit? value;
  final List<DevilFruit> items;
  final void Function(DevilFruit?) onChanged;
  final String? Function(DevilFruit?)? validator;
  final bool enabled;

  const DevilFruitSearchDropdown({
    super.key,
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
    this.validator,
    this.enabled = true,
  });

  @override
  State<DevilFruitSearchDropdown> createState() =>
      _DevilFruitSearchDropdownState();
}

class _DevilFruitSearchDropdownState extends State<DevilFruitSearchDropdown> {
  final TextEditingController _searchController = TextEditingController();
  List<DevilFruit> _filteredItems = [];

  @override
  void initState() {
    super.initState();
    _filteredItems = widget.items;
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void didUpdateWidget(DevilFruitSearchDropdown oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.items != widget.items) {
      _filteredItems = widget.items;
    }
  }

  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredItems = widget.items;
      } else {
        _filteredItems = widget.items.where((fruit) {
          return fruit.romanName.toLowerCase().contains(query) ||
              fruit.name.toLowerCase().contains(query) ||
              fruit.type.toLowerCase().contains(query);
        }).toList();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: FormField<DevilFruit>(
        validator: widget.validator,
        builder: (FormFieldState<DevilFruit> field) {
          return InputDecorator(
            decoration: InputDecoration(
              labelText: widget.label,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              filled: true,
              errorText: field.errorText,
            ),
            child: GestureDetector(
              onTap: widget.enabled ? _showDevilFruitDialog : null,
              child: Row(
                children: [
                  Expanded(
                    child: widget.value != null
                        ? _buildSelectedDevilFruitItem(widget.value!)
                        : Text(
                            AppLocalizations.of(context)!
                                .selectDevilFruitPlaceholder,
                          ),
                  ),
                  const AppIcon(PhosphorIconsRegular.caretDown),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _showDevilFruitDialog() {
    _searchController.clear();
    _filteredItems = widget.items;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setDialogState) {
            return AlertDialog(
              title: Text(AppLocalizations.of(context)!.selectDevilFruit),
              content: SizedBox(
                width: double.maxFinite,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Campo de busca
                    TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText:
                            AppLocalizations.of(context)!.searchDevilFruit,
                        prefixIcon: const AppIcon(
                            PhosphorIconsRegular.magnifyingGlass),
                        suffixIcon: _searchController.text.isNotEmpty
                            ? IconButton(
                                icon: const AppIcon(PhosphorIconsRegular.x),
                                onPressed: () {
                                  _searchController.clear();
                                  setDialogState(() {
                                    _filteredItems = widget.items;
                                  });
                                },
                              )
                            : null,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onChanged: (value) {
                        setDialogState(() {
                          _onSearchChanged();
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    // Lista de itens
                    Flexible(
                      child: Container(
                        constraints: const BoxConstraints(maxHeight: 300),
                        child: _filteredItems.isEmpty
                            ? Center(
                                child: Text(AppLocalizations.of(context)!
                                    .noDevilFruitFound),
                              )
                            : ListView.builder(
                                shrinkWrap: true,
                                itemCount: _filteredItems.length,
                                itemBuilder: (context, index) {
                                  final fruit = _filteredItems[index];
                                  return ListTile(
                                    leading: Container(
                                      width: 32,
                                      height: 32,
                                      decoration: BoxDecoration(
                                        color: _getTypeColor(fruit.type),
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      child: Icon(
                                        _getTypeIcon(fruit.type),
                                        color: Colors.white,
                                        size: 18,
                                      ),
                                    ),
                                    title: Text(
                                      fruit.romanName.isNotEmpty
                                          ? fruit.romanName
                                          : fruit.name,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                    subtitle: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 6,
                                            vertical: 2,
                                          ),
                                          decoration: BoxDecoration(
                                            color: _getTypeColor(fruit.type)
                                                .withValues(alpha: 0.1),
                                            borderRadius:
                                                BorderRadius.circular(4),
                                          ),
                                          child: Text(
                                            fruit.type,
                                            style: TextStyle(
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                              color: _getTypeColor(fruit.type),
                                            ),
                                          ),
                                        ),
                                        if (fruit.name != fruit.romanName &&
                                            fruit.romanName.isNotEmpty)
                                          Text(
                                            fruit.name,
                                            style: TextStyle(
                                              fontSize: 11,
                                              color: Colors.grey[600],
                                              fontStyle: FontStyle.italic,
                                            ),
                                          ),
                                      ],
                                    ),
                                    onTap: () {
                                      widget.onChanged(fruit);
                                      Navigator.of(context).pop();
                                    },
                                  );
                                },
                              ),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(AppLocalizations.of(context)!.cancel),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildSelectedDevilFruitItem(DevilFruit fruit) {
    return Row(
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: _getTypeColor(fruit.type),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            _getTypeIcon(fruit.type),
            color: Colors.white,
            size: 14,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            fruit.romanName.isNotEmpty ? fruit.romanName : fruit.name,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ),
      ],
    );
  }

  Color _getTypeColor(String type) {
    switch (type.toLowerCase()) {
      case 'logia':
        return const Color(0xFF667eea);
      case 'paramecia':
        return const Color(0xFF11998e);
      case 'zoan':
        return const Color(0xFFf093fb);
      default:
        return const Color(0xFF667eea);
    }
  }

  IconData _getTypeIcon(String type) {
    switch (type.toLowerCase()) {
      case 'logia':
        return PhosphorIconsRegular.drop;
      case 'paramecia':
        return PhosphorIconsRegular.magicWand;
      case 'zoan':
        return PhosphorIconsRegular.pawPrint;
      default:
        return PhosphorIconsRegular.question;
    }
  }
}
