class AnnoyanceResponse {
  const AnnoyanceResponse({
    required this.id,
    required this.category,
    required this.recordMethod,
    required this.content,
    required this.score,
    required this.isShared,
    required this.isSolved,
    required this.occurredAt,
    required this.media,
    this.reward,
  });

  factory AnnoyanceResponse.fromJson(Map<String, dynamic> json) {
    return AnnoyanceResponse(
      id: json['id'] as int,
      category: AnnoyanceCategoryResponse.fromJson(
        json['category'] as Map<String, dynamic>,
      ),
      recordMethod: json['recordMethod'] as String,
      content: json['content'] as String?,
      score: json['score'] as int,
      isShared: json['isShared'] as bool,
      isSolved: json['isSolved'] as bool,
      occurredAt: json['occurredAt'] as String,
      media: (json['media'] as List<dynamic>? ?? const [])
          .map(
            (item) =>
                AnnoyanceMediaResponse.fromJson(item as Map<String, dynamic>),
          )
          .toList(growable: false),
      reward: json['reward'],
    );
  }

  final int id;
  final AnnoyanceCategoryResponse category;
  final String recordMethod;
  final String? content;
  final int score;
  final bool isShared;
  final bool isSolved;
  final String occurredAt;
  final List<AnnoyanceMediaResponse> media;
  final Object? reward;
}

class AnnoyanceCategoryResponse {
  const AnnoyanceCategoryResponse({required this.code, required this.name});

  factory AnnoyanceCategoryResponse.fromJson(Map<String, dynamic> json) {
    return AnnoyanceCategoryResponse(
      code: json['code'] as String,
      name: json['name'] as String,
    );
  }

  final String code;
  final String name;
}

class AnnoyanceMediaResponse {
  const AnnoyanceMediaResponse({
    required this.id,
    required this.type,
    required this.contentType,
    required this.sizeBytes,
    required this.downloadUrl,
    this.durationSeconds,
  });

  factory AnnoyanceMediaResponse.fromJson(Map<String, dynamic> json) {
    return AnnoyanceMediaResponse(
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
