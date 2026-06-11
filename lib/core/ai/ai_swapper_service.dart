import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../database/app_database.dart';

class SwapperRecommendation {
  final Exercise exercise;
  final double matchScore;
  final String translationNote;

  SwapperRecommendation(this.exercise, this.matchScore, this.translationNote);
}

class AiSwapperService {
  final AppDatabase _db;

  AiSwapperService(this._db);

  Future<List<SwapperRecommendation>> getAlternatives(Exercise currentExercise, {int limit = 4}) async {
    final candidates = await (_db.select(_db.exercises)
          ..where((tbl) => tbl.target.equals(currentExercise.target))
          ..where((tbl) => tbl.equipment.isNotValue(currentExercise.equipment)))
        .get();

    if (candidates.isEmpty) return [];

    List<SwapperRecommendation> rankedList = [];

    for (var candidate in candidates) {
      double score = 0.5;

      final currentTokens = currentExercise.name.toLowerCase().split(' ');
      final candidateTokens = candidate.name.toLowerCase().split(' ');
      
      int sharedTokens = 0;
      for (var token in currentTokens) {
        if (token.length > 3 && candidateTokens.contains(token)) {
          sharedTokens++;
        }
      }
      
      score += (sharedTokens * 0.15);
      if (score > 1.0) score = 1.0;

      String note = _generateTranslationNote(currentExercise.equipment, candidate.equipment);

      rankedList.add(SwapperRecommendation(candidate, score, note));
    }

    rankedList.sort((a, b) => b.matchScore.compareTo(a.matchScore));

    return rankedList.take(limit).toList();
  }

  double calculateNewTargetWeight(double oldWeight, String oldEquip, String newEquip) {
    if (oldWeight <= 0) return 0.0;

    final oldEq = oldEquip.toLowerCase();
    final newEq = newEquip.toLowerCase();

    if (oldEq.contains('barbell') && newEq.contains('dumbbell')) {
      return _roundToNearest((oldWeight * 0.85) / 2);
    }
    
    if (oldEq.contains('dumbbell') && newEq.contains('barbell')) {
      return _roundToNearest((oldWeight * 2) * 1.15);
    }

    if ((oldEq.contains('barbell') || oldEq.contains('dumbbell')) && 
        (newEq.contains('machine') || newEq.contains('cable'))) {
      return _roundToNearest(oldWeight * 1.10);
    }

    if ((oldEq.contains('machine') || oldEq.contains('cable')) && 
        (newEq.contains('barbell') || newEq.contains('dumbbell'))) {
      return _roundToNearest(oldWeight * 0.85);
    }

    return _roundToNearest(oldWeight);
  }

  String _generateTranslationNote(String oldEq, String newEq) {
    final oldClean = oldEq.toLowerCase();
    final newClean = newEq.toLowerCase();

    if (oldClean.contains('barbell') && newClean.contains('dumbbell')) return "Calculated for individual arm load.";
    if (oldClean.contains('machine') && newClean.contains('dumbbell')) return "Weight reduced to account for required stabilization.";
    if (oldClean.contains('dumbbell') && newClean.contains('barbell')) return "Combined total load calculation.";
    return "1:1 Mechanical Load Transfer.";
  }

  double _roundToNearest(double value) {
    return (value * 4).round() / 4.0;
  }
}

final aiSwapperProvider = Provider<AiSwapperService>((ref) {
  return AiSwapperService(ref.watch(databaseProvider));
});
