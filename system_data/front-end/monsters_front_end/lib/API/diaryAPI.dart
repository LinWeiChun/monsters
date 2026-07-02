// ignore_for_file: file_names

import 'package:monsters_front_end/model/diaryModel.dart';

abstract class DiaryApiDataSource{
  Future<Map<String, dynamic>?> createDiary(Diary diary);

  Future<Map<String, dynamic>?> searchDiaryByAccount(String account);
  
  Future<String> modifyDiary(int id, Diary diary);
}

