enum AnnoyanceChatStep {
  intro,
  category,
  recordMethod,
  content,
  drawingDecision,
  drawing,
  score,
  sharing,
  review,
  submitting,
  completed,
}

enum AnnoyanceRecordMethod { text, image, audio, video }

class AnnoyanceCategory {
  const AnnoyanceCategory({required this.code, required this.name});

  final String code;
  final String name;
}

const annoyanceCategories = <AnnoyanceCategory>[
  AnnoyanceCategory(code: 'ACADEMIC', name: '學業'),
  AnnoyanceCategory(code: 'CAREER', name: '職涯'),
  AnnoyanceCategory(code: 'LOVE', name: '感情'),
  AnnoyanceCategory(code: 'FRIENDSHIP', name: '友情'),
  AnnoyanceCategory(code: 'FAMILY', name: '家庭'),
  AnnoyanceCategory(code: 'OTHER', name: '其他'),
];

const annoyanceScores = <int>[1, 2, 3, 4, 5];

extension AnnoyanceScoreLabel on int {
  String get scoreLabel => '$this分';
}

extension AnnoyanceRecordMethodLabel on AnnoyanceRecordMethod {
  String get apiValue => name.toUpperCase();

  String get label => switch (this) {
    AnnoyanceRecordMethod.text => '文字',
    AnnoyanceRecordMethod.image => '圖片',
    AnnoyanceRecordMethod.audio => '錄音',
    AnnoyanceRecordMethod.video => '影片',
  };
}
