// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'entry_draft_snapshot.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

EntryDraftEnvelopeModel _$EntryDraftEnvelopeModelFromJson(
  Map<String, dynamic> json,
) => EntryDraftEnvelopeModel(
  draft:
      json['draft'] == null
          ? null
          : EntryDraftSnapshot.fromJson(json['draft'] as Map<String, dynamic>),
);

EntryDraftSnapshot _$EntryDraftSnapshotFromJson(Map<String, dynamic> json) =>
    EntryDraftSnapshot(
      id: (json['id'] as num).toInt(),
      entryType: json['entryType'] as String,
      step: json['step'] as String,
      category:
          json['category'] == null
              ? null
              : EntryDraftCategorySnapshot.fromJson(
                json['category'] as Map<String, dynamic>,
              ),
      recordMethod: json['recordMethod'] as String?,
      content: json['content'] as String?,
      wantsDrawing: json['wantsDrawing'] as bool?,
      score: (json['score'] as num?)?.toInt(),
      isShared: json['isShared'] as bool?,
      expiresAt: DateTime.parse(json['expiresAt'] as String),
      contentMedia:
          json['contentMedia'] == null
              ? null
              : EntryDraftMediaSnapshot.fromJson(
                json['contentMedia'] as Map<String, dynamic>,
              ),
      drawingMedia:
          json['drawingMedia'] == null
              ? null
              : EntryDraftMediaSnapshot.fromJson(
                json['drawingMedia'] as Map<String, dynamic>,
              ),
    );

EntryDraftCategorySnapshot _$EntryDraftCategorySnapshotFromJson(
  Map<String, dynamic> json,
) => EntryDraftCategorySnapshot(
  code: json['code'] as String,
  name: json['name'] as String,
);

EntryDraftMediaSnapshot _$EntryDraftMediaSnapshotFromJson(
  Map<String, dynamic> json,
) => EntryDraftMediaSnapshot(
  id: (json['id'] as num).toInt(),
  role: json['role'] as String,
  type: json['type'] as String,
  fileName: json['fileName'] as String,
  contentType: json['contentType'] as String,
  sizeBytes: (json['sizeBytes'] as num).toInt(),
  durationSeconds: (json['durationSeconds'] as num?)?.toDouble(),
  downloadUrl: json['downloadUrl'] as String,
);
