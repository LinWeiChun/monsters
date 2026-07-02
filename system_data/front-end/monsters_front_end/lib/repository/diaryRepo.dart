// ignore_for_file: file_names

import 'dart:convert';
import 'dart:developer';

import 'package:monsters_front_end/main.dart';

import '../API/diaryAPI.dart';
import '../model/diaryModel.dart';
import 'package:http/http.dart' as http;

import 'annoyanceRepo.dart';

class DiaryRepository implements DiaryApiDataSource {
  final client = http.Client();
  @override
  Future<Map<String, dynamic>?> createDiary(Diary diary) {
    return _createDiary(Uri.parse('$domain/diary/create'), diary);
  }

  @override
  Future<Map<String, dynamic>?> searchDiaryByAccount(String account) {
    return _searchDiaryByAccount(
        Uri.parse('$domain/diary/search/$userAccount'));
  }

  @override
  Future<String> modifyDiary(int id, Diary diary) {
    return _modifyDiary(
        Uri.parse('$domain/diary/modify/$id/$userAccount'), diary);
  }

  Future<Map<String, dynamic>?> _createDiary(
    Uri url,
    Diary diary,
  ) async {
    try {
      var body = json.encode(diary);
      var request = await client.post(url,
          headers: {'Content-type': 'application/json'}, body: body);
      log("_createDiary status: " + request.statusCode.toString());
      log("_createDiary body: " + request.body.toString());
      if (request.statusCode == 201) {
        Map<String, dynamic> diary = jsonDecode(request.body);
        return Future.value(diary);
      } else {
        Map<String, dynamic> diary = jsonDecode(request.body);
        return diary;
      }
    } catch (e) {
      print(e);
      return null;
    }
  }

  Future<Map<String, dynamic>?> _searchDiaryByAccount(Uri url) async {
    try {
      final request =
          await client.get(url, headers: {'Content-type': 'application/json'});
      if (request.statusCode == 200) {
        Map<String, dynamic> diary = jsonDecode(request.body);
        return Future.value(diary);
      } else {
        Map<String, dynamic> diary = jsonDecode(request.body);
        return diary;
      }
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  Future<String> _modifyDiary(
    Uri url,
    Diary diary,
  ) async {
    log(json.encode(diary).toString());
    try {
      final request = await client.patch(
        url,
        headers: {'Content-type': 'application/json'},
        body: json.encode(diary),
      );
      log("modify statusCode: " + request.statusCode.toString());
      log("modify body: " + request.body.toString());
      if (request.statusCode == 200) {
        return request.body;
      } else {
        return Future.value(request.body);
      }
    } catch (e) {
      return e.toString();
    }
  }
}
