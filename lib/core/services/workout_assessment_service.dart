import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../models/workout_assessment_model.dart';

class WorkoutAssessmentService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;


  String get _collection => 'workout_assessments';

  String? get _currentUserId => _auth.currentUser?.uid;

  String get _currentMonthYear {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}';
  }

  Future<WorkoutAssessment?> getCurrentMonthAssessment() async {
    if (_currentUserId == null) return null;

    try {
      final doc = await _firestore
          .collection(_collection)
          .where('userId', isEqualTo: _currentUserId)
          .where('monthYear', isEqualTo: _currentMonthYear)
          .limit(1)
          .get();

      if (doc.docs.isNotEmpty) {
        return WorkoutAssessment.fromFirestore(doc.docs.first);
      }
      return null;
    } catch (e) {
      debugPrint('Erro ao buscar assessment atual: $e');
      return null;
    }
  }

  Future<void> saveAssessment(WorkoutAssessment assessment) async {
    if (_currentUserId == null) throw Exception('Usuário não autenticado');

    try {
      if (assessment.id != null) {
        await _firestore
            .collection(_collection)
            .doc(assessment.id)
            .update(assessment.toFirestore());
      } else {
        await _firestore
            .collection(_collection)
            .add(assessment.toFirestore());
      }
    } catch (e) {
      debugPrint('Erro ao salvar assessment: $e');
      rethrow;
    }
  }

  Future<List<WorkoutAssessment>> getAssessmentHistory() async {
    if (_currentUserId == null) return [];

    try {
      final query = await _firestore
          .collection(_collection)
          .where('userId', isEqualTo: _currentUserId)
          .get();

      final assessments = query.docs
          .map((doc) => WorkoutAssessment.fromFirestore(doc))
          .toList();
      
      assessments.sort((a, b) => b.monthYear.compareTo(a.monthYear));
      
      return assessments;
    } catch (e) {
      debugPrint('Erro ao buscar histórico: $e');
      return [];
    }
  }

  Future<WorkoutAssessment?> checkAndCreateNewMonth() async {
    if (_currentUserId == null) return null;

    try {
      final currentAssessment = await getCurrentMonthAssessment();
      
      if (currentAssessment != null) {
        final now = DateTime.now();
        final currentMonthYear = '${now.year}-${now.month.toString().padLeft(2, '0')}';
        
        if (currentAssessment.monthYear != currentMonthYear) {
          await _lockPreviousMonth(currentAssessment);
          return await _createNewMonthAssessment(currentAssessment);
        }
        
        return currentAssessment;
      } else {
        return await _createNewMonthAssessment(null);
      }
    } catch (e) {
      debugPrint('Erro ao verificar/criar novo mês: $e');
      return null;
    }
  }

  Future<void> _lockPreviousMonth(WorkoutAssessment assessment) async {
    try {
      await _firestore
          .collection(_collection)
          .doc(assessment.id)
          .update({
        'lockedAt': Timestamp.now(),
        'isCurrentMonth': false,
      });
    } catch (e) {
      debugPrint('Erro ao bloquear mês anterior: $e');
    }
  }

  Future<WorkoutAssessment> _createNewMonthAssessment(WorkoutAssessment? previousAssessment) async {
    final now = DateTime.now();
    final monthYear = '${now.year}-${now.month.toString().padLeft(2, '0')}';

    final healthResults = previousAssessment?.healthResults ?? {};
    final workoutDaysGoal = previousAssessment?.workoutDaysGoal ?? 0;

    final newAssessment = WorkoutAssessment(
      userId: _currentUserId!,
      monthYear: monthYear,
      createdAt: now,
      healthResults: healthResults,
      workoutDaysGoal: workoutDaysGoal,
      workoutDays: [],
      isCurrentMonth: true,
    );

    final docRef = await _firestore
        .collection(_collection)
        .add(newAssessment.toFirestore());

    return newAssessment.copyWith(id: docRef.id);
  }

  Future<void> updateWorkoutDays(List<int> workoutDays) async {
    final assessment = await getCurrentMonthAssessment();
    if (assessment == null || !assessment.canEdit) return;

    try {
      await _firestore
          .collection(_collection)
          .doc(assessment.id)
          .update({
        'workoutDays': workoutDays,
      });
    } catch (e) {
      debugPrint('Erro ao atualizar dias de exercício: $e');
    }
  }

  Future<void> updateHealthResults(Map<String, dynamic> healthResults) async {
    final assessment = await getCurrentMonthAssessment();
    if (assessment == null || !assessment.canEdit) return;

    try {
      await _firestore
          .collection(_collection)
          .doc(assessment.id)
          .update({
        'healthResults': healthResults,
      });
    } catch (e) {
      debugPrint('Erro ao atualizar resultados de saúde: $e');
    }
  }

  Future<void> updateWorkoutDaysGoal(int workoutDaysGoal) async {
    final assessment = await getCurrentMonthAssessment();
    if (assessment == null || !assessment.canEdit) return;

    try {
      await _firestore
          .collection(_collection)
          .doc(assessment.id)
          .update({
        'workoutDaysGoal': workoutDaysGoal,
      });
    } catch (e) {
      debugPrint('Erro ao atualizar meta de dias: $e');
    }
  }

  Future<void> deleteAssessment(String assessmentId) async {
    try {
      await _firestore
          .collection(_collection)
          .doc(assessmentId)
          .delete();
    } catch (e) {
      debugPrint('Erro ao deletar assessment: $e');
    }
  }
}
