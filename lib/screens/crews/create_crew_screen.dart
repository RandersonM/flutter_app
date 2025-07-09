import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:opfan/screens/crews/blocs/index.dart';
import 'package:opfan/utils/theme.dart';
import 'package:opfan/utils/decorations/gradient.dart';
import 'package:opfan/core/auth/blocs/index.dart';
import 'package:opfan/core/services/crew_image_service.dart';

class CreateCrewScreen extends StatefulWidget {
  const CreateCrewScreen({super.key});

  @override
  State<CreateCrewScreen> createState() => _CreateCrewScreenState();
}

class _CreateCrewScreenState extends State<CreateCrewScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _jollyRogerPromptController = TextEditingController();
  final _boatPromptController = TextEditingController();
  final List<String> _tags = [];
  
  final CrewImageService _crewImageService = CrewImageService();
  String? _generatedJollyRogerUrl;
  String? _generatedBoatUrl;
  bool _isGeneratingJollyRoger = false;
  bool _isGeneratingBoat = false;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _jollyRogerPromptController.dispose();
    _boatPromptController.dispose();
    super.dispose();
  }

  void _addTag(String tag) {
    if (tag.isNotEmpty && !_tags.contains(tag)) {
      setState(() {
        _tags.add(tag);
      });
    }
  }

  void _removeTag(String tag) {
    setState(() {
      _tags.remove(tag);
    });
  }

  void _showAddTagDialog() {
    final tagController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Adicionar Tag'),
        content: TextField(
          controller: tagController,
          decoration: const InputDecoration(
            labelText: 'Nome da tag',
            hintText: 'Ex: Piratas, Aventureiros, etc.',
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              _addTag(tagController.text.trim());
              Navigator.pop(context);
            },
            child: const Text('Adicionar'),
          ),
        ],
      ),
    );
  }

  Future<void> _generateJollyRoger() async {
    if (_jollyRogerPromptController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Digite um prompt para gerar a bandeira pirata'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _isGeneratingJollyRoger = true;
    });

    try {
      final imageUrl = await _crewImageService.generateJollyRogerImage(
        crewName: _nameController.text.isNotEmpty
            ? _nameController.text
            : 'Tripulação',
        prompt: _jollyRogerPromptController.text.trim(),
        tags: _tags,
        description: _descriptionController.text.isNotEmpty
            ? _descriptionController.text
            : null,
      );

      setState(() {
        _generatedJollyRogerUrl = imageUrl;
        _isGeneratingJollyRoger = false;
      });

      if (imageUrl != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Bandeira pirata gerada com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isGeneratingJollyRoger = false;
      });
      if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao gerar bandeira: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  Future<void> _generateBoat() async {
    if (_boatPromptController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Digite um prompt para gerar o barco'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _isGeneratingBoat = true;
    });

    try {
      final imageUrl = await _crewImageService.generateBoatImage(
        crewName: _nameController.text.isNotEmpty
            ? _nameController.text
            : 'Tripulação',
        prompt: _boatPromptController.text.trim(),
        tags: _tags,
        description: _descriptionController.text.isNotEmpty
            ? _descriptionController.text
            : null,
      );

      setState(() {
        _generatedBoatUrl = imageUrl;
        _isGeneratingBoat = false;
      });

      if (imageUrl != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Barco gerado com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isGeneratingBoat = false;
      });
      if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao gerar barco: $e'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.read<AuthBloc>().state;
    final userId = authState is AuthAuthenticated ? authState.user.uid : null;

    return BlocProvider(
      create: (context) => CreateCrewBloc(userId: userId),
      child: Builder(
        builder: (context) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Criar Tripulação'),
              backgroundColor: Colors.transparent,
              elevation: 0,
            ),
            body: BlocListener<CreateCrewBloc, CreateCrewState>(
              listener: (context, state) {
                if (state is CreateCrewSuccess) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Tripulação criada com sucesso!'),
                      backgroundColor: Colors.green,
                    ),
                  );
                  Navigator.pop(context, {'action': 'created', 'crewId': state.crewId});
                } else if (state is CreateCrewFailure) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Erro: ${state.error}'),
                      backgroundColor: Theme.of(context).colorScheme.error,
                    ),
                  );
                }
              },
              child: Container(
                decoration: backgroundGradient(),
                child: SafeArea(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16.0),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Container(
                            height: 120,
                            decoration: BoxDecoration(
                              color: AppColors.purple[200]!,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: AppColors.purple[600]!,
                              ),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.sailing,
                                  size: 48,
                                  color: Colors.white.withValues(alpha: 0.8),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Nova Tripulação',
                                  style: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.8),
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          
                          const SizedBox(height: 24),
                          
                          TextFormField(
                            controller: _nameController,
                            decoration: InputDecoration(
                              labelText: 'Nome da Tripulação *',
                              hintText: 'Ex: Mugiwaras Custom',
                              prefixIcon: const Icon(Icons.flag),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              filled: true,
                              fillColor: Colors.white.withValues(alpha: 0.1),
                            ),
                            style: TextStyle(color: AppColors.purple[600]!),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Nome é obrigatório';
                              }
                              if (value.trim().length < 3) {
                                return 'Nome deve ter pelo menos 3 caracteres';
                              }
                              return null;
                            },
                          ),
                          
                          const SizedBox(height: 16),
                          
                          TextFormField(
                            controller: _descriptionController,
                            maxLines: 3,
                            decoration: InputDecoration(
                              labelText: 'Descrição',
                              hintText: 'Conte um pouco sobre sua tripulação...',
                              prefixIcon: const Icon(Icons.description),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              filled: true,
                              fillColor: Colors.white.withValues(alpha: 0.1),
                            ),
                            style: TextStyle(color: AppColors.purple[600]!),
                          ),
                          
                          const SizedBox(height: 16),
                          
                          // Seção de Tags
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppColors.purple[200]!,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: AppColors.purple[600]!,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text(
                                      'Tags',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    IconButton(
                                      onPressed: _showAddTagDialog,
                                      icon: const Icon(
                                        Icons.add_circle_outline,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                                if (_tags.isEmpty)
                                  const Padding(
                                    padding: EdgeInsets.only(top: 8),
                                    child: Text(
                                      'Nenhuma tag adicionada',
                                      style: TextStyle(
                                        color: Colors.white54,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                if (_tags.isNotEmpty) ...[
                                  const SizedBox(height: 8),
                                  Wrap(
                                    spacing: 8,
                                    runSpacing: 8,
                                    children: _tags.map((tag) {
                                      return Chip(
                                        label: Text(tag, style: const TextStyle(color: Colors.white)),
                                        backgroundColor: AppColors.purple[500],
                                        deleteIcon: const Icon(
                                          Icons.close,
                                          color: Colors.white,
                                          size: 18,
                                        ),
                                        onDeleted: () => _removeTag(tag),
                                      );
                                    }).toList(),
                                  ),
                                ],
                              ],
                            ),
                          ),
                          
                          const SizedBox(height: 24),
                          
                          // Seção de Geração de Jolly Roger
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppColors.purple[200]!,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: AppColors.purple[600]!,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Row(
                                  children: [
                                    Icon(
                                      Icons.flag,
                                      color: Colors.white,
                                    ),
                                    SizedBox(width: 8),
                                    Text(
                                      'Bandeira Pirata (Jolly Roger)',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                TextFormField(
                                  controller: _jollyRogerPromptController,
                                  decoration: InputDecoration(
                                    labelText: 'Prompt para IA',
                                    hintText:
                                        'Ex: caveira com espadas cruzadas, bandeira negra',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    filled: true,
                                    fillColor:
                                        Colors.white.withValues(alpha: 0.1),
                                  ),
                                  style:
                                      TextStyle(color: AppColors.purple[600]!),
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  children: [
                                    Expanded(
                                      child: ElevatedButton.icon(
                                        onPressed: _isGeneratingJollyRoger
                                            ? null
                                            : _generateJollyRoger,
                                        icon: _isGeneratingJollyRoger
                                            ? const SizedBox(
                                                width: 16,
                                                height: 16,
                                                child:
                                                    CircularProgressIndicator(
                                                  strokeWidth: 2,
                                                  valueColor:
                                                      AlwaysStoppedAnimation<
                                                          Color>(Colors.white),
                                                ),
                                              )
                                            : const Icon(Icons.auto_awesome),
                                        label: Text(_isGeneratingJollyRoger
                                            ? 'Gerando...'
                                            : 'Gerar Bandeira'),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor:
                                              AppColors.purple[500],
                                          foregroundColor: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                if (_generatedJollyRogerUrl != null) ...[
                                  const SizedBox(height: 12),
                                  Container(
                                    height: 120,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                          color: AppColors.purple[600]!),
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: Image.network(
                                        _generatedJollyRogerUrl!,
                                        fit: BoxFit.cover,
                                        errorBuilder:
                                            (context, error, stackTrace) {
                                          return Container(
                                            color: Colors.grey[300],
                                            child: const Icon(Icons.error),
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),

                          const SizedBox(height: 16),

                          // Seção de Geração de Barco
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppColors.purple[200]!,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: AppColors.purple[600]!,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Row(
                                  children: [
                                    Icon(
                                      Icons.directions_boat,
                                      color: Colors.white,
                                    ),
                                    SizedBox(width: 8),
                                    Text(
                                      'Barco da Tripulação',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                TextFormField(
                                  controller: _boatPromptController,
                                  decoration: InputDecoration(
                                    labelText: 'Prompt para IA',
                                    hintText:
                                        'Ex: navio pirata de madeira com velas pretas',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    filled: true,
                                    fillColor:
                                        Colors.white.withValues(alpha: 0.1),
                                  ),
                                  style:
                                      TextStyle(color: AppColors.purple[600]!),
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  children: [
                                    Expanded(
                                      child: ElevatedButton.icon(
                                        onPressed: _isGeneratingBoat
                                            ? null
                                            : _generateBoat,
                                        icon: _isGeneratingBoat
                                            ? const SizedBox(
                                                width: 16,
                                                height: 16,
                                                child:
                                                    CircularProgressIndicator(
                                                  strokeWidth: 2,
                                                  valueColor:
                                                      AlwaysStoppedAnimation<
                                                          Color>(Colors.white),
                                                ),
                                              )
                                            : const Icon(Icons.auto_awesome),
                                        label: Text(_isGeneratingBoat
                                            ? 'Gerando...'
                                            : 'Gerar Barco'),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor:
                                              AppColors.purple[500],
                                          foregroundColor: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                if (_generatedBoatUrl != null) ...[
                                  const SizedBox(height: 12),
                                  Container(
                                    height: 120,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                          color: AppColors.purple[600]!),
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: Image.network(
                                        _generatedBoatUrl!,
                                        fit: BoxFit.cover,
                                        errorBuilder:
                                            (context, error, stackTrace) {
                                          return Container(
                                            color: Colors.grey[300],
                                            child: const Icon(Icons.error),
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),

                          const SizedBox(height: 24),
                          
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppColors.purple[200]!.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: AppColors.purple[600]!,
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.info_outline,
                                  color: AppColors.purple[600]!,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    'Use prompts descritivos para gerar imagens únicas da sua tripulação. '
                                    'As imagens geradas serão salvas automaticamente.',
                                    style: TextStyle(
                                      color: AppColors.purple[400]!,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          
                          const SizedBox(height: 32),
                          
                          BlocBuilder<CreateCrewBloc, CreateCrewState>(
                            builder: (context, state) {
                              return ElevatedButton(
                                onPressed: state is CreateCrewLoading 
                                    ? null 
                                    : () {
                                        if (_formKey.currentState!.validate()) {
                                          context.read<CreateCrewBloc>().add(
                                                CreateCrewSubmitted(
                                                  name: _nameController.text,
                                                  description: _descriptionController.text.isEmpty 
                                                      ? null 
                                                      : _descriptionController.text,
                                                  jollyRogerUrl:
                                                      _generatedJollyRogerUrl,
                                                  boatImageUrl:
                                                      _generatedBoatUrl,
                                                  tags: _tags,
                                                ),
                                              );
                                        }
                                      },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.purple[500],
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: state is CreateCrewLoading
                                    ? const SizedBox(
                                        height: 20,
                                        width: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor: AlwaysStoppedAnimation<Color>(
                                            Colors.white,
                                          ),
                                        ),
                                      )
                                    : const Text(
                                        'Criar Tripulação',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
