/// Intent detection and classification models for AI Whisperer
///
/// This module provides the foundation for understanding user intent
/// from voice input, enabling personalized prompt enhancement.

import 'package:json_annotation/json_annotation.dart';

part 'intent.g.dart';

/// Types of user intent detected from voice input
enum IntentType {
  /// Software development, debugging, code review
  @JsonValue('coding')
  coding,

  /// Content creation, copywriting, documentation
  @JsonValue('writing')
  writing,

  /// Business documents, presentations, reports
  @JsonValue('business')
  business,

  /// Learning, teaching, educational content
  @JsonValue('education')
  education,

  /// Campaigns, ads, social media, branding
  @JsonValue('marketing')
  marketing,

  /// General inquiries and other categories
  @JsonValue('general')
  general,
}

/// Tone detected in user's voice input
enum Tone {
  /// Professional, corporate language
  @JsonValue('formal')
  formal,

  /// Conversational, friendly language
  @JsonValue('casual')
  casual,

  /// Time-sensitive, direct language
  @JsonValue('urgent')
  urgent,

  /// Imaginative, expressive language
  @JsonValue('creative')
  creative,

  /// Precise, detailed technical language
  @JsonValue('technical')
  technical,
}

/// Expected output format for the prompt
enum OutputType {
  /// Code snippet or script
  @JsonValue('code')
  code,

  /// Detailed explanation or description
  @JsonValue('explanation')
  explanation,

  /// Step-by-step guide or tutorial
  @JsonValue('steps')
  steps,

  /// Concise summary or overview
  @JsonValue('summary')
  summary,

  /// Bulleted or numbered list
  @JsonValue('list')
  list,

  /// Structured document
  @JsonValue('document')
  document,
}

/// Result of intent analysis on user input
@JsonSerializable()
class IntentAnalysis {
  /// Primary intent type detected
  final IntentType intentType;

  /// Tone of the communication
  final Tone tone;

  /// Expected output format
  final OutputType outputType;

  /// Confidence score (0.0 - 1.0)
  final double confidence;

  /// Additional metadata about the analysis
  final Map<String, dynamic> metadata;

  /// Detected keywords that influenced classification
  final List<String> keywords;

  /// When this analysis was performed
  final DateTime analyzedAt;

  IntentAnalysis({
    required this.intentType,
    required this.tone,
    required this.outputType,
    required this.confidence,
    this.metadata = const {},
    this.keywords = const [],
    DateTime? analyzedAt,
  }) : analyzedAt = analyzedAt ?? DateTime.now();

  /// Create from JSON
  factory IntentAnalysis.fromJson(Map<String, dynamic> json) =>
      _$IntentAnalysisFromJson(json);

  /// Convert to JSON
  Map<String, dynamic> toJson() => _$IntentAnalysisToJson(this);

  /// Create a copy with updated fields
  IntentAnalysis copyWith({
    IntentType? intentType,
    Tone? tone,
    OutputType? outputType,
    double? confidence,
    Map<String, dynamic>? metadata,
    List<String>? keywords,
    DateTime? analyzedAt,
  }) {
    return IntentAnalysis(
      intentType: intentType ?? this.intentType,
      tone: tone ?? this.tone,
      outputType: outputType ?? this.outputType,
      confidence: confidence ?? this.confidence,
      metadata: metadata ?? this.metadata,
      keywords: keywords ?? this.keywords,
      analyzedAt: analyzedAt ?? this.analyzedAt,
    );
  }

  /// Get human-readable description of the intent
  String get description {
    final buffer = StringBuffer();

    switch (intentType) {
      case IntentType.coding:
        buffer.write('Software Development');
        break;
      case IntentType.writing:
        buffer.write('Content Writing');
        break;
      case IntentType.business:
        buffer.write('Business Communication');
        break;
      case IntentType.education:
        buffer.write('Educational Content');
        break;
      case IntentType.marketing:
        buffer.write('Marketing & Campaigns');
        break;
      case IntentType.general:
        buffer.write('General Inquiry');
        break;
    }

    buffer.write(' • ${tone.name.capitalize()}');
    buffer.write(' • ${outputType.name.capitalize()}');

    return buffer.toString();
  }

  @override
  String toString() => 'IntentAnalysis($description, confidence: ${(confidence * 100).toStringAsFixed(0)}%)';
}

/// Extension for string capitalization
extension StringCapitalization on String {
  String capitalize() {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }
}
