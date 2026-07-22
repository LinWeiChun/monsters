enum EntryRecordMethod { text, image, audio, video }

const entryScores = <int>[1, 2, 3, 4, 5];

extension EntryScoreLabel on int {
  String get scoreLabel => '$this分';
}

extension EntryRecordMethodLabel on EntryRecordMethod {
  String get apiValue => name.toUpperCase();

  String get label => switch (this) {
    EntryRecordMethod.text => '文字',
    EntryRecordMethod.image => '圖片',
    EntryRecordMethod.audio => '錄音',
    EntryRecordMethod.video => '影片',
  };
}
