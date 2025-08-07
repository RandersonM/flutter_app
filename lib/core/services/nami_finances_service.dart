import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:opfan/core/models/nami_finances_model.dart';

class NamiFinancesService {
  static const String _boxName = 'nami_finances';
  Box<NamiFinancesModel>? _box;

  Future<Box<NamiFinancesModel>> get _getBox async {
    if (_box == null || !_box!.isOpen) {
      _box = await Hive.openBox<NamiFinancesModel>(_boxName);
    }
    return _box!;
  }

  Future<NamiFinancesModel?> getFinancesForMonth(DateTime month) async {
    final monthKey = _getMonthKey(month);
    
    try {
      final box = await _getBox;
      return box.get(monthKey);
    } catch (e) {
      debugPrint('Erro ao buscar finanças para o mês: $e');
      return null;
    }
  }

  Future<NamiFinancesModel?> getCurrentMonthFinances() async {
    final now = DateTime.now();
    return getFinancesForMonth(now);
  }

  Future<void> saveFinances(NamiFinancesModel finances) async {
    final monthKey = finances.monthKey;
    
    try {
      final box = await _getBox;
      await box.put(monthKey, finances);
    } catch (e) {
      throw Exception('Erro ao salvar finanças: $e');
    }
  }

  Future<bool> canEditFinances(DateTime month) async {
    final now = DateTime.now();
    return month.year == now.year && month.month == now.month;
  }

  Future<void> deleteFinances(String id) async {
    try {
      final box = await _getBox;
      final key = box.keys.firstWhere(
        (key) => box.get(key)?.id == id,
        orElse: () => null,
      );
      
      if (key != null) {
        await box.delete(key);
      }
    } catch (e) {
      throw Exception('Erro ao deletar finanças: $e');
    }
  }

  Future<List<NamiFinancesModel>> getAllFinances() async {
    try {
      final box = await _getBox;
      final finances = box.values.toList();
      finances.sort((a, b) => b.month.compareTo(a.month));
      return finances;
    } catch (e) {
      throw Exception('Erro ao buscar todas as finanças: $e');
    }
  }

  Future<List<NamiFinancesModel>> getFinancesForYear(int year) async {
    try {
      final box = await _getBox;
      final finances = box.values
          .where((finances) => finances.month.year == year)
          .toList();
      finances.sort((a, b) => b.month.compareTo(a.month));
      return finances;
    } catch (e) {
      throw Exception('Erro ao buscar finanças do ano: $e');
    }
  }

  Future<List<NamiFinancesModel>> getLastMonthsFinances(int months) async {
    try {
      final box = await _getBox;
      final allFinances = box.values.toList();
      allFinances.sort((a, b) => b.month.compareTo(a.month));
      
      final now = DateTime.now();
      final cutoffDate = DateTime(now.year, now.month - months + 1, 1);
      
      return allFinances
          .where((finances) => finances.month.isAfter(cutoffDate) || finances.month.isAtSameMomentAs(cutoffDate))
          .toList();
    } catch (e) {
      throw Exception('Erro ao buscar finanças dos últimos meses: $e');
    }
  }

  String _getMonthKey(DateTime month) {
    return '${month.year}-${month.month.toString().padLeft(2, '0')}';
  }
}
