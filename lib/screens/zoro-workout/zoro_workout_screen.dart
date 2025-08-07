import 'package:flutter/material.dart';
import 'package:opfan/l10n/app_localizations.dart';
import 'package:opfan/utils/constants.dart';
import 'package:opfan/widgets/molecules/default_app_bar.dart';
import 'package:opfan/widgets/organisms/bottom_navigation.dart';

class WorkoutScreen extends StatefulWidget {
  const WorkoutScreen({super.key});

  @override
  State<WorkoutScreen> createState() => _WorkoutScreenState();
}

class _WorkoutScreenState extends State<WorkoutScreen> {
  final _formKey = GlobalKey<FormState>();
  final _heightController = TextEditingController();
  final _weightController = TextEditingController();
  final _scrollController = ScrollController();
  String? _selectedGender;
  double? _bmi;
  String? _bmiCategory;
  List<String> _recommendedExercises = [];

  @override
  void dispose() {
    _heightController.dispose();
    _weightController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _calculateBMI() {
    if (_formKey.currentState!.validate()) {
      final height = double.parse(_heightController.text) / 100;
      final weight = double.parse(_weightController.text);
      final bmi = weight / (height * height);
      
      setState(() {
        _bmi = bmi;
        _bmiCategory = _getBMICategory(bmi);
        _recommendedExercises = _getRecommendedExercises(bmi, _selectedGender);
      });
      
      Future.delayed(const Duration(milliseconds: 100), () {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 800),
            curve: Curves.easeInOut,
          );
        }
      });
    }
  }

  String _getBMICategory(double bmi) {
    if (bmi < 18.5) return 'Abaixo do peso';
    if (bmi < 25) return 'Peso normal';
    if (bmi < 30) return 'Sobrepeso';
    if (bmi < 35) return 'Obesidade grau 1';
    if (bmi < 40) return 'Obesidade grau 2';
    return 'Obesidade grau 3';
  }

  List<String> _getRecommendedExercises(double bmi, String? gender) {
    List<String> exercises = [];
    
    if (bmi < 18.5) {
      exercises = [
        'Treino de força 3x por semana',
        'Exercícios com peso corporal',
        'Flexões e agachamentos',
        'Alongamentos diários',
        'Consumir mais proteínas'
      ];
    } else if (bmi < 25) {
      exercises = [
        'Corrida 30 minutos',
        'Treino funcional',
        'Natação 2x por semana',
        'Yoga para flexibilidade',
        'Ciclismo ao ar livre'
      ];
    } else {
      exercises = [
        'Caminhada 45 minutos',
        'Hidroginástica',
        'Pilates para iniciantes',
        'Alongamentos suaves',
        'Exercícios de respiração'
      ];
    }

    if (gender == 'Masculino') {
      exercises.addAll([
        'Treino de peito e costas',
        'Exercícios de pernas',
        'Treino de ombros'
      ]);
    } else if (gender == 'Feminino') {
      exercises.addAll([
        'Treino de glúteos',
        'Exercícios de core',
        'Treino de pernas'
      ]);
    }

    return exercises;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: DefaultAppBar(
        title: Text(AppLocalizations.of(context)!.workout),
      ),
      bottomNavigationBar: const BottomNavigation(BottomNavigationPages.workout),
      body: SingleChildScrollView(
        controller: _scrollController,
        padding: const EdgeInsets.symmetric(horizontal: Constants.margin),
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
              ),
              width: double.infinity,
              height: 250,
              clipBehavior: Clip.antiAlias,
              child: Image.asset(
                'assets/logo/zoro-workout.gif',
                fit: BoxFit.fill,
              ),
            ),
            const SizedBox(height: 20),
            Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Calculadora de IMC',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  DropdownButtonFormField<String>(
                    value: _selectedGender,
                    decoration: const InputDecoration(
                      labelText: 'Sexo',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'Masculino', child: Text('Masculino')),
                      DropdownMenuItem(value: 'Feminino', child: Text('Feminino')),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _selectedGender = value;
                      });
                    },
                    validator: (value) {
                      if (value == null) return 'Selecione o sexo';
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  
                  TextFormField(
                    controller: _heightController,
                    decoration: const InputDecoration(
                      labelText: 'Altura (cm)',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Digite sua altura';
                      }
                      if (double.tryParse(value) == null) {
                        return 'Digite um número válido';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  
                  TextFormField(
                    controller: _weightController,
                    decoration: const InputDecoration(
                      labelText: 'Peso (kg)',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Digite seu peso';
                      }
                      if (double.tryParse(value) == null) {
                        return 'Digite um número válido';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _calculateBMI,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text('Calcular IMC'),
                    ),
                  ),
                ],
              ),
            ),
            
            if (_bmi != null) ...[
              const SizedBox(height: 30),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Resultado do IMC',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Seu IMC: ${_bmi!.toStringAsFixed(1)}',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    Text(
                      'Categoria: $_bmiCategory',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 20),
              Text(
                'Exercícios Recomendados',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              ...(_recommendedExercises.map((exercise) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Icon(Icons.fitness_center, color: Colors.green.shade600),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        exercise,
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ),
                  ],
                ),
              ))),
            ],
          ],
        ),
      ),
    );
  }
}