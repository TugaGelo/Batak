import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ExerciseVector {
  final String id;
  final String name;
  final String primaryMuscle;
  final List<double> vector;

  ExerciseVector({
    required this.id,
    required this.name,
    required this.primaryMuscle,
    required this.vector,
  });

  factory ExerciseVector.fromJson(Map<String, dynamic> json) {
    return ExerciseVector(
      id: json['id'],
      name: json['name'],
      primaryMuscle: json['primary_muscle'],
      vector: List<double>.from(json['vector'].map((x) => x.toDouble())),
    );
  }
}

class SwapperRecommendation {
  final ExerciseVector exercise;
  final double matchScore;

  SwapperRecommendation(this.exercise, this.matchScore);
}

class AiSwapperService {
  List<ExerciseVector> _exerciseMatrix = [];

  Future<void> initialize() async {
    try {
      final String jsonString = await rootBundle.loadString('assets/data/exercises_vectors.json');
      final List<dynamic> rawData = json.decode(jsonString);
      _exerciseMatrix = rawData.map((data) => ExerciseVector.fromJson(data)).toList();
      print("✅ [AI ENGINE] Biomechanical Matrix Loaded: ${_exerciseMatrix.length} exercises.");
    } catch (e) {
      print("❌ [AI ENGINE] Failed to load matrix: $e");
    }
  }

  double _calculateSimilarity(List<double> vectorA, List<double> vectorB) {
    double dotProduct = 0.0;
    double normA = 0.0;
    double normB = 0.0;

    for (int i = 0; i < vectorA.length; i++) {
      dotProduct += vectorA[i] * vectorB[i];
      normA += vectorA[i] * vectorA[i];
      normB += vectorB[i] * vectorB[i];
    }

    if (normA == 0 || normB == 0) return 0.0;
    return dotProduct / (math.sqrt(normA) * math.sqrt(normB));
  }

  List<SwapperRecommendation> getAlternatives(String targetExerciseId, {int limit = 3}) {
    if (_exerciseMatrix.isEmpty) return [];

    final targetExercise = _exerciseMatrix.firstWhere(
      (ex) => ex.id == targetExerciseId,
      orElse: () => _exerciseMatrix.first,
    );

    List<SwapperRecommendation> recommendations = [];

    for (var exercise in _exerciseMatrix) {
      if (exercise.id == targetExerciseId) continue;

      if (exercise.primaryMuscle != targetExercise.primaryMuscle) continue;

      double score = _calculateSimilarity(targetExercise.vector, exercise.vector);
      recommendations.add(SwapperRecommendation(exercise, score));
    }

    recommendations.sort((a, b) => b.matchScore.compareTo(a.matchScore));

    return recommendations.take(limit).toList();
  }
}

final aiSwapperProvider = Provider<AiSwapperService>((ref) {
  return AiSwapperService();
});
