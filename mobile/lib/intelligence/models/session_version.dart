/// Session versioning and prompt evolution tracking models
///
/// This module enables tracking of prompt iterations, comparisons
/// between versions, and session memory features.

import 'package:json_annotation/json_annotation.dart';
import 'package:uuid/uuid.dart';
import 'intent.dart';
import 'enhancement.dart';

part 'session_version.g.dart';

/// Type of change in a text diff
enum ChangeType {
  @JsonValue('addition')
  addition,

  @JsonValue('deletion')
  deletion,

  @JsonValue('modification')
  modification,

  @JsonValue('unchanged')
  unchanged,
}

/// A single text change in a version diff
@JsonSerializable()
class TextChange {
  /// Type of change
  final ChangeType type;

  /// The text content
  final String text;

  /// Position in original text
  final int startIndex;

  /// Length of the change
  final int length;

  TextChange({
    required this.type,
    required this.text,
    required this.startIndex,
    required this.length,
  });

  /// Create from JSON
  factory TextChange.fromJson(Map<String, dynamic> json) =>
      _$TextChangeFromJson(json);

  /// Convert to JSON
  Map<String, dynamic> toJson() => _$TextChangeToJson(this);

  /// Check if this is an addition
  bool get isAddition => type == ChangeType.addition;

  /// Check if this is a deletion
  bool get isDeletion => type == ChangeType.deletion;

  /// Check if this is a modification
  bool get isModification => type == ChangeType.modification;
}

/// A version of a prompt in a session
@JsonSerializable()
class PromptVersion {
  /// Unique identifier for this version
  final String id;

  /// Version number (1, 2, 3, ...)
  final int versionNumber;

  /// The prompt text
  final String text;

  /// Intent analysis for this version
  final IntentAnalysis? intent;

  /// Enhancement variants generated for this version
  final List<PromptVariant>? variants;

  /// ID of the selected variant (if any)
  final String? selectedVariantId;

  /// When this version was created
  final DateTime createdAt;

  /// Refinement command that led to this version (if any)
  final String? refinementCommand;

  /// Token count estimate
  final int estimatedTokens;

  /// Metadata about this version
  final Map<String, dynamic> metadata;

  PromptVersion({
    String? id,
    required this.versionNumber,
    required this.text,
    this.intent,
    this.variants,
    this.selectedVariantId,
    DateTime? createdAt,
    this.refinementCommand,
    this.estimatedTokens = 0,
    this.metadata = const {},
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now();

  /// Create from JSON
  factory PromptVersion.fromJson(Map<String, dynamic> json) =>
      _$PromptVersionFromJson(json);

  /// Convert to JSON
  Map<String, dynamic> toJson() => _$PromptVersionToJson(this);

  /// Get selected variant
  PromptVariant? get selectedVariant {
    if (selectedVariantId == null || variants == null) return null;
    try {
      return variants!.firstWhere((v) => v.id == selectedVariantId);
    } catch (_) {
      return null;
    }
  }

  /// Create a copy with updated fields
  PromptVersion copyWith({
    String? id,
    int? versionNumber,
    String? text,
    IntentAnalysis? intent,
    List<PromptVariant>? variants,
    String? selectedVariantId,
    DateTime? createdAt,
    String? refinementCommand,
    int? estimatedTokens,
    Map<String, dynamic>? metadata,
  }) {
    return PromptVersion(
      id: id ?? this.id,
      versionNumber: versionNumber ?? this.versionNumber,
      text: text ?? this.text,
      intent: intent ?? this.intent,
      variants: variants ?? this.variants,
      selectedVariantId: selectedVariantId ?? this.selectedVariantId,
      createdAt: createdAt ?? this.createdAt,
      refinementCommand: refinementCommand ?? this.refinementCommand,
      estimatedTokens: estimatedTokens ?? this.estimatedTokens,
      metadata: metadata ?? this.metadata,
    );
  }

  @override
  String toString() => 'PromptVersion(v$versionNumber, ${text.length} chars)';
}

/// Difference between two prompt versions
@JsonSerializable()
class VersionDiff {
  /// Source version
  final PromptVersion from;

  /// Target version
  final PromptVersion to;

  /// List of changes between versions
  final List<TextChange> changes;

  /// Human-readable summary of changes
  final String summary;

  /// Percentage of text changed (0-100)
  final double changePercentage;

  /// When this diff was computed
  final DateTime computedAt;

  VersionDiff({
    required this.from,
    required this.to,
    required this.changes,
    required this.summary,
    required this.changePercentage,
    DateTime? computedAt,
  }) : computedAt = computedAt ?? DateTime.now();

  /// Create from JSON
  factory VersionDiff.fromJson(Map<String, dynamic> json) =>
      _$VersionDiffFromJson(json);

  /// Convert to JSON
  Map<String, dynamic> toJson() => _$VersionDiffToJson(this);

  /// Count additions
  int get additionCount =>
      changes.where((c) => c.type == ChangeType.addition).length;

  /// Count deletions
  int get deletionCount =>
      changes.where((c) => c.type == ChangeType.deletion).length;

  /// Count modifications
  int get modificationCount =>
      changes.where((c) => c.type == ChangeType.modification).length;

  /// Get total character difference
  int get characterDifference => to.text.length - from.text.length;

  @override
  String toString() => 'VersionDiff(v${from.versionNumber} → v${to.versionNumber}, $changePercentage% changed)';
}

/// Memory and history for a session
@JsonSerializable()
class SessionMemory {
  /// Session ID
  final String sessionId;

  /// Template slug used
  final String templateSlug;

  /// All versions in chronological order
  final List<PromptVersion> versions;

  /// User preferences learned during session
  final Map<String, dynamic> userPreferences;

  /// Tags associated with this session
  final List<String> tags;

  /// When this session was created
  final DateTime createdAt;

  /// When this session was last updated
  final DateTime updatedAt;

  /// Whether this session is marked as favorite
  bool isFavorite;

  SessionMemory({
    required this.sessionId,
    required this.templateSlug,
    this.versions = const [],
    this.userPreferences = const {},
    this.tags = const [],
    DateTime? createdAt,
    DateTime? updatedAt,
    this.isFavorite = false,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  /// Create from JSON
  factory SessionMemory.fromJson(Map<String, dynamic> json) =>
      _$SessionMemoryFromJson(json);

  /// Convert to JSON
  Map<String, dynamic> toJson() => _$SessionMemoryToJson(this);

  /// Get current (latest) version
  PromptVersion get current => versions.last;

  /// Get first (original) version
  PromptVersion get original => versions.first;

  /// Check if session has multiple versions
  bool get hasMultipleVersions => versions.length > 1;

  /// Get version count
  int get versionCount => versions.length;

  /// Get a specific version by number
  PromptVersion? getVersion(int versionNumber) {
    try {
      return versions.firstWhere((v) => v.versionNumber == versionNumber);
    } catch (_) {
      return null;
    }
  }

  /// Add a new version
  void addVersion(PromptVersion version) {
    versions.add(version);
  }

  /// Compute diffs between all versions
  List<VersionDiff> computeHistory() {
    final diffs = <VersionDiff>[];

    for (int i = 0; i < versions.length - 1; i++) {
      final from = versions[i];
      final to = versions[i + 1];
      diffs.add(_computeDiff(from, to));
    }

    return diffs;
  }

  /// Compute diff between two specific versions
  VersionDiff computeDiff(int fromVersion, int toVersion) {
    final from = getVersion(fromVersion);
    final to = getVersion(toVersion);

    if (from == null || to == null) {
      throw ArgumentError('Version not found');
    }

    return _computeDiff(from, to);
  }

  /// Internal method to compute diff between two versions
  VersionDiff _computeDiff(PromptVersion from, PromptVersion to) {
    // Simple character-level diff (can be improved with proper diff algorithm)
    final changes = <TextChange>[];
    final fromText = from.text;
    final toText = to.text;

    // Simple implementation: mark entire text as changed if different
    if (fromText != toText) {
      if (fromText.isNotEmpty) {
        changes.add(TextChange(
          type: ChangeType.deletion,
          text: fromText,
          startIndex: 0,
          length: fromText.length,
        ));
      }

      if (toText.isNotEmpty) {
        changes.add(TextChange(
          type: ChangeType.addition,
          text: toText,
          startIndex: 0,
          length: toText.length,
        ));
      }
    }

    // Compute summary
    final tokenDiff = to.estimatedTokens - from.estimatedTokens;
    final charDiff = toText.length - fromText.length;
    final changePercent = fromText.isEmpty
        ? 100.0
        : ((toText.length - fromText.length).abs() / fromText.length * 100)
            .clamp(0.0, 100.0);

    String summary;
    if (charDiff > 0) {
      summary = 'Expanded by $charDiff characters';
    } else if (charDiff < 0) {
      summary = 'Reduced by ${-charDiff} characters';
    } else {
      summary = 'Rephrased';
    }

    if (tokenDiff != 0) {
      summary += ' (${tokenDiff > 0 ? '+' : ''}$tokenDiff tokens)';
    }

    return VersionDiff(
      from: from,
      to: to,
      changes: changes,
      summary: summary,
      changePercentage: changePercent,
    );
  }

  /// Add a tag to the session
  void addTag(String tag) {
    if (!tags.contains(tag)) {
      tags.add(tag);
    }
  }

  /// Remove a tag from the session
  void removeTag(String tag) {
    tags.remove(tag);
  }

  /// Check if session has a specific tag
  bool hasTag(String tag) => tags.contains(tag);

  /// Create a copy with updated fields
  SessionMemory copyWith({
    String? sessionId,
    String? templateSlug,
    List<PromptVersion>? versions,
    Map<String, dynamic>? userPreferences,
    List<String>? tags,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isFavorite,
  }) {
    return SessionMemory(
      sessionId: sessionId ?? this.sessionId,
      templateSlug: templateSlug ?? this.templateSlug,
      versions: versions ?? this.versions,
      userPreferences: userPreferences ?? this.userPreferences,
      tags: tags ?? this.tags,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }

  @override
  String toString() => 'SessionMemory($sessionId, ${versions.length} versions)';
}
