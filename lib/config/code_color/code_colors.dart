import 'package:flutter/material.dart';
// import 'package:flutter/scheduler.dart';

@immutable
class CodeColor extends ThemeExtension<CodeColor> {
  const CodeColor({
    required this.functionNameColor,
    required this.dataTypeColor,
    required this.argumentColor,
    required this.operatorColor,
    required this.conditionColor,
    required this.argumentOfConditionExpressionColor,
    required this.parenthesisOfConditionExpressionColor,
    required this.trueFalseExpressionColor,
    required this.parenthesisOfFunctionColor,
  });

  final Color? functionNameColor;
  final Color? dataTypeColor;
  final Color? argumentColor;
  final Color? operatorColor;
  final Color? conditionColor;
  final Color? argumentOfConditionExpressionColor;
  final Color? parenthesisOfConditionExpressionColor;
  final Color? trueFalseExpressionColor;
  final Color? parenthesisOfFunctionColor;

  @override
  CodeColor copyWith({
    Color? functionNameColor,
    Color? dataTypeColor,
    Color? argumentColor,
    Color? operatorColor,
    Color? conditionColor,
    Color? argumentOfConditionExpressionColor,
    Color? parenthesisOfConditionExpressionColor,
    Color? trueFalseExpressionColor,
    Color? parenthesisOfFunctionColor,
  }) {
    return CodeColor(
      functionNameColor: functionNameColor ?? this.functionNameColor,
      dataTypeColor: dataTypeColor ?? this.dataTypeColor,
      argumentColor: argumentColor ?? this.argumentColor,
      operatorColor: operatorColor ?? this.operatorColor,
      conditionColor: conditionColor ?? this.conditionColor,
      argumentOfConditionExpressionColor: argumentOfConditionExpressionColor ??
          this.argumentOfConditionExpressionColor,
      parenthesisOfConditionExpressionColor:
          parenthesisOfConditionExpressionColor ??
              this.parenthesisOfConditionExpressionColor,
      trueFalseExpressionColor:
          trueFalseExpressionColor ?? this.trueFalseExpressionColor,
      parenthesisOfFunctionColor:
          parenthesisOfFunctionColor ?? this.parenthesisOfFunctionColor,
    );
  }

  // Optional
  @override
  String toString() =>
      'CodeColors(functionNameColor: $functionNameColor, dataTypeColor: $dataTypeColor)';

  @override
  CodeColor lerp(ThemeExtension<CodeColor>? other, double t) {
    if (other is! CodeColor) {
      return this;
    }
    return CodeColor(
      functionNameColor:
          Color.lerp(functionNameColor, other.functionNameColor, t),
      dataTypeColor: Color.lerp(dataTypeColor, other.dataTypeColor, t),
      argumentColor: Color.lerp(argumentColor, other.argumentColor, t),
      operatorColor: Color.lerp(operatorColor, other.operatorColor, t),
      conditionColor: Color.lerp(conditionColor, other.conditionColor, t),
      argumentOfConditionExpressionColor: Color.lerp(
          argumentOfConditionExpressionColor,
          other.argumentOfConditionExpressionColor,
          t),
      parenthesisOfConditionExpressionColor: Color.lerp(
          parenthesisOfConditionExpressionColor,
          other.parenthesisOfConditionExpressionColor,
          t),
      trueFalseExpressionColor: Color.lerp(
          trueFalseExpressionColor, other.trueFalseExpressionColor, t),
      parenthesisOfFunctionColor: Color.lerp(
          parenthesisOfFunctionColor, other.parenthesisOfFunctionColor, t),
    );
  }
}
