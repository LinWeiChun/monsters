class DiaryResponse {
  const DiaryResponse({
    required this.id,
    required this.recordMethod,
    required this.content,
    required this.score,
    required this.isShared,
    required this.occurredAt,
    required this.media,
    this.reward,
  });

  factory DiaryResponse.fromJson(Map<String, dynamic> json) {
    return DiaryResponse(
      id: json['id'] as int,
      recordMethod: json['recordMethod'] as String,
      content: json['content'] as String?,
      score: json['score'] as int,
      isShared: json['isShared'] as bool,
      occurredAt: json['occurredAt'] as String,
      media: (json['media'] as List<dynamic>? ?? const [])
          .map(
            (item) => DiaryMediaResponse.fromJson(item as Map<String, dynamic>),
          )
          .toList(growable: false),
      reward: json['reward'],
    );
  }

  final int id;
  final String recordMethod;
  final String? content;
  final int score;
  final bool isShared;
  final String occurredAt;
  final List<DiaryMediaResponse> media;
  final Object? reward;
}

class DiaryMediaResponse {
  const DiaryMediaResponse({
    required this.id,
    required this.type,
    required this.contentType,
    required this.sizeBytes,
    required this.downloadUrl,
    this.durationSeconds,
  });

  factory DiaryMediaResponse.fromJson(Map<String, dynamic> json) {
    return DiaryMediaResponse(
      id: json['id'] as int,
      type: json['type'] as String,
      contentType: json['contentType'] as String,
      sizeBytes: json['sizeBytes'] as int,
      durationSeconds: (json['durationSeconds'] as num?)?.toDouble(),
      downloadUrl: json['downloadUrl'] as String,
    );
  }

  final int id;
  final String type;
  final String contentType;
  final int sizeBytes;
  final double? durationSeconds;
  final String downloadUrl;
}
