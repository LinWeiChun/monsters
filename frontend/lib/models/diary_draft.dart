import 'entry_drawing.dart';
import 'entry_media.dart';
import 'entry_record.dart';

export 'entry_drawing.dart';
export 'entry_media.dart';
export 'entry_record.dart';

enum DiaryChatStep {
  intro,
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

typedef DiaryRecordMethod = EntryRecordMethod;
typedef DiaryMediaFile = EntryMediaFile;
typedef DiaryDrawingFile = EntryDrawingFile;

const diaryScores = entryScores;
