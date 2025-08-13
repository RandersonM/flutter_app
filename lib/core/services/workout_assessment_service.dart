import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:opfan/core/models/workout_assessment_model.dart';

class WorkoutAssessmentService {
  static final WorkoutAssessmentService _instance =
      WorkoutAssessmentService._internal();
  factory WorkoutAssessmentService() => _instance;
  WorkoutAssessmentService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String get _currentMonthYear {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}';
  }

  Future<WorkoutAssessmentModel> saveWorkoutAssessment({
    required String gender,
    required int age,
    required double height,
    required double weight,
    required double waist,
    double? bmi,
    double? waistToHeightRatio,
    double? bodyFatPercentage,
    double? healthScore,
    int? workoutDaysGoal,
    List<int>? workoutDays,
    String? activityLevel,
    String? goal,
  }) async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) {
        throw Exception('Usuário não autenticado');
      }

      final currentMonthYear = _currentMonthYear;

      final existingDoc = await _firestore
          .collection('workout_assessments')
          .where('user_id', isEqualTo: userId)
          .where('month_year', isEqualTo: currentMonthYear)
          .limit(1)
          .get();

      final now = DateTime.now();
      WorkoutAssessmentModel assessment;

      if (existingDoc.docs.isNotEmpty) {
        final docId = existingDoc.docs.first.id;
        final existingData = existingDoc.docs.first.data();
        
        // Safe data extraction with null checks
        final existingBmi = existingData['bmi'];
        final existingWaistToHeightRatio =
            existingData['waist_to_height_ratio'];
        final existingBodyFatPercentage = existingData['body_fat_percentage'];
        final existingHealthScore = existingData['health_score'];
        final existingWorkoutDaysGoal = existingData['workout_days_goal'];
        final existingActivityLevel = existingData['activity_level'];
        final existingGoal = existingData['goal'];
        final existingCreatedAt = existingData['created_at'];

        assessment = WorkoutAssessmentModel(
          id: docId,
          userId: userId,
          monthYear: currentMonthYear,
          gender: gender,
          age: age,
          height: height,
          weight: weight,
          waist: waist,
          bmi: bmi ?? (existingBmi is double ? existingBmi : null),
          waistToHeightRatio: waistToHeightRatio ??
              (existingWaistToHeightRatio is double
                  ? existingWaistToHeightRatio
                  : null),
          bodyFatPercentage: bodyFatPercentage ??
              (existingBodyFatPercentage is double
                  ? existingBodyFatPercentage
                  : null),
          healthScore: healthScore ??
              (existingHealthScore is double ? existingHealthScore : null),
          workoutDaysGoal: workoutDaysGoal ??
              (existingWorkoutDaysGoal is int ? existingWorkoutDaysGoal : null),
          workoutDays: workoutDays,
          activityLevel: activityLevel ??
              (existingActivityLevel is String ? existingActivityLevel : null),
          goal: goal ?? (existingGoal is String ? existingGoal : null),
          createdAt:
              existingCreatedAt is Timestamp ? existingCreatedAt.toDate() : now,
          updatedAt: now,
        );

        final data = assessment.toJson();
        data['created_at'] = Timestamp.fromDate(assessment.createdAt);
        data['updated_at'] = Timestamp.fromDate(assessment.updatedAt);

        await _firestore
            .collection('workout_assessments')
            .doc(docId)
            .update(data);
      } else {
        assessment = WorkoutAssessmentModel(
          userId: userId,
          monthYear: currentMonthYear,
          gender: gender,
          age: age,
          height: height,
          weight: weight,
          waist: waist,
          bmi: bmi,
          waistToHeightRatio: waistToHeightRatio,
          bodyFatPercentage: bodyFatPercentage,
          healthScore: healthScore,
          workoutDaysGoal: workoutDaysGoal,
          activityLevel: activityLevel,
          goal: goal,
          createdAt: now,
          updatedAt: now,
        );

        final data = assessment.toJson();
        data['created_at'] = Timestamp.fromDate(assessment.createdAt);
        data['updated_at'] = Timestamp.fromDate(assessment.updatedAt);

        final docRef =
            await _firestore.collection('workout_assessments').add(data);

        assessment = assessment.copyWith(id: docRef.id);
      }
      return assessment;
    } catch (e, stackTrace) {
      debugPrint(
          'WorkoutAssessmentService: Error in saveWorkoutAssessment: $e');
      debugPrint('WorkoutAssessmentService: Stack trace: $stackTrace');
      rethrow;
    }
  }

  Future<WorkoutAssessmentModel?> getCurrentUserAssessment() async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) {
        return null;
      }

      final currentMonthYear = _currentMonthYear;

      final doc = await _firestore
          .collection('workout_assessments')
          .where('user_id', isEqualTo: userId)
          .where('month_year', isEqualTo: currentMonthYear)
          .limit(1)
          .get();

      if (doc.docs.isEmpty) {
        return null;
      }

      final data = doc.docs.first.data();
      data['id'] = doc.docs.first.id;
      
      if (data['created_at'] is Timestamp) {
        data['created_at'] =
            (data['created_at'] as Timestamp).toDate().toIso8601String();
      }
      if (data['updated_at'] is Timestamp) {
        data['updated_at'] =
            (data['updated_at'] as Timestamp).toDate().toIso8601String();
      }

      return WorkoutAssessmentModel.fromJson(data);
    } catch (e) {
      debugPrint('WorkoutAssessmentService: Erro ao buscar avaliação: $e');
      return null;
    }
  }

  Future<WorkoutAssessmentModel?> getLatestUserAssessment() async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) {
        return null;
      }

      final docs = await _firestore
          .collection('workout_assessments')
          .where('user_id', isEqualTo: userId)
          .get();

      if (docs.docs.isEmpty) {
        return null;
      }

      final sortedDocs = docs.docs.toList()
        ..sort((a, b) => (b.data()['month_year'] as String)
            .compareTo(a.data()['month_year'] as String));

      final data = sortedDocs.first.data();
      data['id'] = sortedDocs.first.id;

      if (data['created_at'] is Timestamp) {
        data['created_at'] =
            (data['created_at'] as Timestamp).toDate().toIso8601String();
      }
      if (data['updated_at'] is Timestamp) {
        data['updated_at'] =
            (data['updated_at'] as Timestamp).toDate().toIso8601String();
      }

      return WorkoutAssessmentModel.fromJson(data);
    } catch (e) {
      debugPrint(
          'WorkoutAssessmentService: Erro ao buscar avaliação mais recente: $e');
      return null;
    }
  }

  Future<bool> hasCurrentMonthAssessment() async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) {
        return false;
      }

      final currentMonthYear = _currentMonthYear;

      final doc = await _firestore
          .collection('workout_assessments')
          .where('user_id', isEqualTo: userId)
          .where('month_year', isEqualTo: currentMonthYear)
          .limit(1)
          .get();

      return doc.docs.isNotEmpty;
    } catch (e) {
      debugPrint(
          'WorkoutAssessmentService: Erro ao verificar avaliação do mês atual: $e');
      return false;
    }
  }

  Future<bool> hasAssessment() async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) {
        return false;
      }

      final doc = await _firestore
          .collection('workout_assessments')
          .where('user_id', isEqualTo: userId)
          .limit(1)
          .get();

      return doc.docs.isNotEmpty;
    } catch (e) {
      debugPrint('WorkoutAssessmentService: Erro ao verificar avaliação: $e');
      return false;
    }
  }

  Future<List<WorkoutAssessmentModel>> getUserAssessmentHistory() async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) {
        return [];
      }

      final docs = await _firestore
          .collection('workout_assessments')
          .where('user_id', isEqualTo: userId)
          .get();

      final sortedDocs = docs.docs.toList()
        ..sort((a, b) => (b.data()['month_year'] as String)
            .compareTo(a.data()['month_year'] as String));

      return sortedDocs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        
        if (data['created_at'] is Timestamp) {
          data['created_at'] =
              (data['created_at'] as Timestamp).toDate().toIso8601String();
        }
        if (data['updated_at'] is Timestamp) {
          data['updated_at'] =
              (data['updated_at'] as Timestamp).toDate().toIso8601String();
        }
        
        return WorkoutAssessmentModel.fromJson(data);
      }).toList();
    } catch (e) {
      debugPrint('WorkoutAssessmentService: Erro ao buscar histórico: $e');
      return [];
    }
  }

  Future<void> deleteCurrentMonthAssessment() async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) {
        throw Exception('Usuário não autenticado');
      }

      final currentMonthYear = _currentMonthYear;

      final doc = await _firestore
          .collection('workout_assessments')
          .where('user_id', isEqualTo: userId)
          .where('month_year', isEqualTo: currentMonthYear)
          .limit(1)
          .get();

      if (doc.docs.isNotEmpty) {
        await doc.docs.first.reference.delete();
      }
    } catch (e) {
      debugPrint('WorkoutAssessmentService: Erro ao deletar avaliação: $e');
      rethrow;
    }
  }

  Future<void> deleteAllUserAssessments() async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) {
        throw Exception('Usuário não autenticado');
      }

      final docs = await _firestore
          .collection('workout_assessments')
          .where('user_id', isEqualTo: userId)
          .get();

      for (final doc in docs.docs) {
        await doc.reference.delete();
      }

    } catch (e) {
      debugPrint(
          'WorkoutAssessmentService: Erro ao deletar todas as avaliações: $e');
      rethrow;
    }
  }

  Future<void> updateWorkoutDays(List<int> workoutDays) async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) {
        throw Exception('Usuário não autenticado');
      }

      final currentMonthYear = _currentMonthYear;
      final doc = await _firestore
          .collection('workout_assessments')
          .where('user_id', isEqualTo: userId)
          .where('month_year', isEqualTo: currentMonthYear)
          .limit(1)
          .get();

      if (doc.docs.isEmpty) {
        throw Exception('Nenhuma avaliação encontrada para o mês atual');
      }

      final docId = doc.docs.first.id;
      await _firestore
          .collection('workout_assessments').doc(docId).update({
        'workout_days': workoutDays,
        'updated_at': Timestamp.fromDate(DateTime.now()),
      });
    } catch (e) {
      debugPrint(
          'WorkoutAssessmentService: Erro ao atualizar dias de treino: $e');
      rethrow;
    }
  }

  Future<WorkoutAssessmentModel> updateNutritionData({
    required String gender,
    required int age,
    required double height,
    required double weight,
    required double waist,
    String? activityLevel,
    String? goal,
  }) async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) {
        throw Exception('Usuário não autenticado');
      }

      final currentMonthYear = _currentMonthYear;

      final existingDoc = await _firestore
          .collection('workout_assessments')
          .where('user_id', isEqualTo: userId)
          .where('month_year', isEqualTo: currentMonthYear)
          .limit(1)
          .get();

      final now = DateTime.now();
      WorkoutAssessmentModel assessment;

      if (existingDoc.docs.isNotEmpty) {
        final docId = existingDoc.docs.first.id;
        final existingData = existingDoc.docs.first.data();

        // Safe data extraction with null checks
        final existingBmi = existingData['bmi'];
        final existingWaistToHeightRatio =
            existingData['waist_to_height_ratio'];
        final existingBodyFatPercentage = existingData['body_fat_percentage'];
        final existingHealthScore = existingData['health_score'];
        final existingWorkoutDays = existingData['workout_days'];
        final existingWorkoutDaysGoal = existingData['workout_days_goal'];
        final existingCreatedAt = existingData['created_at'];

        assessment = WorkoutAssessmentModel(
          id: docId,
          userId: userId,
          monthYear: currentMonthYear,
          gender: gender,
          age: age,
          height: height,
          weight: weight,
          waist: waist,
          bmi: existingBmi is double ? existingBmi : null,
          waistToHeightRatio: existingWaistToHeightRatio is double
              ? existingWaistToHeightRatio
              : null,
          bodyFatPercentage: existingBodyFatPercentage is double
              ? existingBodyFatPercentage
              : null,
          healthScore:
              existingHealthScore is double ? existingHealthScore : null,
          workoutDays: existingWorkoutDays is List
              ? List<int>.from(existingWorkoutDays)
              : null,
          workoutDaysGoal:
              existingWorkoutDaysGoal is int ? existingWorkoutDaysGoal : null,
          activityLevel: activityLevel,
          goal: goal,
          createdAt:
              existingCreatedAt is Timestamp ? existingCreatedAt.toDate() : now,
          updatedAt: now,
        );

        final data = assessment.toJson();
        data['created_at'] = Timestamp.fromDate(assessment.createdAt);
        data['updated_at'] = Timestamp.fromDate(assessment.updatedAt);

        await _firestore
            .collection('workout_assessments')
            .doc(docId)
            .update(data);
      } else {
        assessment = WorkoutAssessmentModel(
          userId: userId,
          monthYear: currentMonthYear,
          gender: gender,
          age: age,
          height: height,
          weight: weight,
          waist: waist,
          bmi: null,
          waistToHeightRatio: null,
          bodyFatPercentage: null,
          healthScore: null,
          workoutDaysGoal: null,
          activityLevel: activityLevel,
          goal: goal,
          createdAt: now,
          updatedAt: now,
        );

        final data = assessment.toJson();
        data['created_at'] = Timestamp.fromDate(assessment.createdAt);
        data['updated_at'] = Timestamp.fromDate(assessment.updatedAt);

        final docRef =
            await _firestore.collection('workout_assessments').add(data);

        assessment = assessment.copyWith(id: docRef.id);
      }
      return assessment;
    } catch (e, stackTrace) {
      debugPrint('WorkoutAssessmentService: Error in updateNutritionData: $e');
      debugPrint('WorkoutAssessmentService: Stack trace: $stackTrace');
      rethrow;
    }
  }
}
