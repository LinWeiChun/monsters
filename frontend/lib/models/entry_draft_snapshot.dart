import 'package:json_annotation/json_annotation.dart';

part 'entry_draft_snapshot.g.dart';

@JsonSerializable(createToJson: false)
class EntryDraftEnvelopeModel {
  const EntryDraftEnvelopeModel({required this.draft});

  factory EntryDraftEnvelopeModel.fromJson(Map<String, dynamic> json) =>
      _$EntryDraftEnvelopeModelFromJson(json);

  final EntryDraftSnapshot? draft;
}

@JsonSerializable(createToJson: false)
class EntryDraftSnapshot {
  const EntryDraftSnapshot({
    required this.id,
    required this.entryType,
    required this.step,
    required this.category,
    required this.recordMethod,
    required this.content,
    required this.wantsDrawing,
    required this.score,
    required this.isShared,
    required this.expiresAt,
    required this.contentMedia,
    required this.drawingMedia,
  });

  factory EntryDraftSnapshot.fromJson(Map<String, dynamic> json) =>
      _$EntryDraftSnapshotFromJson(json);

  final int id;
  final String entryType;
  final String step;
  final EntryDraftCategorySnapshot? category;
  final String? recordMethod;
  final String? content;
  final bool? wantsDrawing;
  final int? score;
  final bool? isShared;
  final DateTime expiresAt;
  final EntryDraftMediaSnapshot? contentMedia;
  final EntryDraftMediaSnapshot? drawingMedia;
}

@JsonSerializable(createToJson: false)
class EntryDraftCategorySnapshot {
  const EntryDraftCategorySnapshot({required this.code, required this.name});

  factory EntryDraftCategorySnapshot.fromJson(Map<String, dynamic> json) =>
      _$EntryDraftCategorySnapshotFromJson(json);

  final String code;
  final String name;
}

@JsonSerializable(createToJson: false)
class EntryDraftMediaSnapshot {
  const EntryDraftMediaSnapshot({
    required this.id,
    required this.role,
    required this.type,
    required this.fileName,
    required this.contentType,
    required this.sizeBytes,
    required this.durationSeconds,
    required this.downloadUrl,
  });

  factory EntryDraftMediaSnapshot.fromJson(Map<String, dynamic> json) =>
      _$EntryDraftMediaSnapshotFromJson(json);

  final int id;
  final String role;
  final String type;
  final String fileName;
  final String contentType;
  final int sizeBytes;
  final double? durationSeconds;
  final String downloadUrl;
}
