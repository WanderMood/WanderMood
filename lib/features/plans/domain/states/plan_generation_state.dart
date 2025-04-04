import 'package:freezed_annotation/freezed_annotation.dart';
import '../models/plan.dart';

part 'plan_generation_state.freezed.dart';

@freezed
class PlanGenerationState with _$PlanGenerationState {
  const factory PlanGenerationState.initial() = _Initial;
  
  const factory PlanGenerationState.loading({
    required String message,
    required double progress,
  }) = _Loading;
  
  const factory PlanGenerationState.searchingPlaces({
    required String message,
    required double progress,
  }) = _SearchingPlaces;
  
  const factory PlanGenerationState.analyzingMood({
    required String message,
    required double progress,
  }) = _AnalyzingMood;
  
  const factory PlanGenerationState.generatingDescription({
    required String message,
    required double progress,
  }) = _GeneratingDescription;
  
  const factory PlanGenerationState.success({
    required Plan plan,
  }) = _Success;
  
  const factory PlanGenerationState.error({
    required String message,
  }) = _Error;
} 