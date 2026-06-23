import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:opfan/core/models/goal_model.dart';
import 'package:opfan/features/robin_knowledge/data/repository/planner_repository_interface.dart';
import 'package:opfan/core/services/firestore_service.dart';

class PlannerRepository implements PlannerRepositoryInterface {
  final FirestoreService _firestoreService;
  static const String _collection = 'planner';

  PlannerRepository({required FirestoreService firestoreService})
      : _firestoreService = firestoreService;

  @override
  Future<List<GoalModel>> getGoals() async {
    try {
      final documents = await _firestoreService.getUserDocuments(
        collection: _collection,
      );

      final goals = documents.map((doc) => _documentToGoalModel(doc)).toList();
      goals.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      
      return goals;
    } catch (e) {
      throw Exception('Failed to get goals: $e');
    }
  }

  @override
  Future<GoalModel?> getGoalById(String id) async {
    try {
      final document = await _firestoreService.getDocument(
        collection: _collection,
        documentId: id,
      );

      if (document == null) return null;
      return _documentToGoalModel({'id': id, ...document});
    } catch (e) {
      throw Exception('Failed to get goal by id: $e');
    }
  }

  @override
  Future<String> createGoal(GoalModel goal) async {
    try {
      final goalData = _goalModelToDocument(goal);
      return await _firestoreService.createUserDocument(
        collection: _collection,
        data: goalData,
      );
    } catch (e) {
      throw Exception('Failed to create goal: $e');
    }
  }

  @override
  Future<void> updateGoal(GoalModel goal) async {
    try {
      final goalData = _goalModelToDocument(goal);
      await _firestoreService.updateUserDocument(
        collection: _collection,
        documentId: goal.id,
        data: goalData,
      );
    } catch (e) {
      throw Exception('Failed to update goal: $e');
    }
  }

  @override
  Future<void> deleteGoal(String id) async {
    try {
      await _firestoreService.deleteDocument(
        collection: _collection,
        documentId: id,
      );
    } catch (e) {
      throw Exception('Failed to delete goal: $e');
    }
  }

  @override
  Future<void> updateGoalProgress(String id, double progress, {String? notes}) async {
    try {
      final goal = await getGoalById(id);
      if (goal == null) {
        throw Exception('Goal not found');
      }

      String updatedNotes = goal.notes ?? '';
      if (notes != null && notes.isNotEmpty) {
        final now = DateTime.now();
        final dateFormat = '${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year} ${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
        final newNote = '[$dateFormat] ${progress.toStringAsFixed(1)}%: $notes';
        
        if (updatedNotes.isNotEmpty) {
          updatedNotes += '\n\n$newNote';
        } else {
          updatedNotes = newNote;
        }
      }

      await _firestoreService.updateUserDocument(
        collection: _collection,
        documentId: id,
        data: {
          'progress': progress,
          'notes': updatedNotes,
          'status': progress == 0.0 
            ? GoalStatus.notStarted.name 
            : progress >= 100.0 
              ? GoalStatus.completed.name 
              : GoalStatus.inProgress.name,
        },
      );
    } catch (e) {
      throw Exception('Failed to update goal progress: $e');
    }
  }

  @override
  Stream<List<GoalModel>> streamGoals() {
    try {
      return _firestoreService.streamUserDocuments(
        collection: _collection,
      ).map((documents) {
        final goals = documents
            .map((doc) => _documentToGoalModel(doc))
            .toList();
        goals.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        return goals;
      });
    } catch (e) {
      throw Exception('Failed to stream goals: $e');
    }
  }

  Map<String, dynamic> _goalModelToDocument(GoalModel goal) {
    return {
      'title': goal.title,
      'description': goal.description,
      'deadline': Timestamp.fromDate(goal.deadline),
      'createdAt': Timestamp.fromDate(goal.createdAt),
      'category': goal.category.name,
      'status': goal.progress == 0.0 ? GoalStatus.notStarted.name : GoalStatus.inProgress.name,
      'progress': goal.progress,
      'tags': goal.tags,
      'notes': goal.notes,
    };
  }

  GoalModel _documentToGoalModel(Map<String, dynamic> document) {
    return GoalModel(
      id: document['id'] as String,
      title: document['title'] as String,
      description: document['description'] as String,
      deadline: _parseDateTime(document['deadline']),
      createdAt: _parseDateTime(document['createdAt']),
      category: GoalCategory.values.firstWhere(
        (e) => e.name == document['category'],
        orElse: () => GoalCategory.other,
      ),
      status: GoalStatus.values.firstWhere(
        (e) => e.name == document['status'],
        orElse: () => GoalStatus.notStarted,
      ),
      progress: (document['progress'] as num?)?.toDouble() ?? 0.0,
      tags: List<String>.from(document['tags'] ?? []),
      notes: document['notes']?.toString(),
    );
  }

  DateTime _parseDateTime(dynamic value) {
    if (value is String) {
      return DateTime.parse(value);
    } else if (value is DateTime) {
      return value;
    } else if (value is Timestamp) {
      return value.toDate();
    }
    throw Exception('Invalid date format: $value');
  }
}
