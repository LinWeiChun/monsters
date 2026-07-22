import 'entry_record.dart';

export 'entry_record.dart';

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

typedef AnnoyanceRecordMethod = EntryRecordMethod;

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

const annoyanceScores = entryScores;
