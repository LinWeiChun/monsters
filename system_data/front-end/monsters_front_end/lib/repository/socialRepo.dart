// ignore_for_file: file_names

import 'dart:convert';
import 'dart:developer';
import 'package:flutter/foundation.dart';
import 'package:monsters_front_end/main.dart';
import 'package:monsters_front_end/repository/annoyanceRepo.dart';

import '../API/socialAPI.dart';
import '../model/socialModel.dart';
import 'package:http/http.dart' as http;

class SocialRepository implements SocialApiDataSource {
  final client = http.Client();
  @override
  Future<Map<String, dynamic>?> searchSocialByType(int type) {
    String searchType = "2";
    // if (type == 1) {
    //   searchType = "3";
    // }
    if (type == 2) {
      searchType = "1";
    }
    if (type == 3) {
      searchType = "2";
    }
    if (type == 4) {
      return _searchSocialByType(Uri.parse('$domain/social/$userAccount'));
    }

    return _searchSocialByType(Uri.parse('$domain/social/all/$searchType'));
  }

  Future<Map<String, dynamic>?> _searchSocialByType(Uri url) async {
    try {
      final request =
          await client.get(url, headers: {'Content-type': 'application/json'});
      // log("*" * 20);
      // log("social status");
      // log("status: " + request.statusCode.toString());
      // log("body: " + request.body.toString().substring(0, 30));
      // log("*" * 20);
      if (request.statusCode == 200) {
        Map<String, dynamic> social = jsonDecode(request.body);
        return Future.value(social);
      } else {
        Map<String, dynamic> social = jsonDecode(request.body);
        return social;
      }
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  @override
  Future<Map<String, dynamic>?> createSocialAnnoyanceComment(Social comment) {
    return _createSocialAnnoyanceComment(
        Uri.parse('$domain/social/comment/annoyance'), comment);
  }

  Future<Map<String, dynamic>?> _createSocialAnnoyanceComment(
    Uri url,
    Social comment,
  ) async {
    try {
      final request = await client.post(url,
          headers: {'Content-type': 'application/json'},
          body: json.encode(comment));

      log("_createSocialAnnoyanceComment");
      log("body: " + request.body.toString());
      log("status: " + request.statusCode.toString());
      if (request.statusCode == 200) {
        Map<String, dynamic> social = jsonDecode(request.body);
        return Future.value(social);
      } else {
        Map<String, dynamic> social = jsonDecode(request.body);
        return social;
      }
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  @override
  Future<Map<String, dynamic>?> createSocialDiaryComment(Social comment) {
    return _createSocialDiaryComment(
        Uri.parse('$domain/social/comment/diary'), comment);
  }

  Future<Map<String, dynamic>?> _createSocialDiaryComment(
    Uri url,
    Social comment,
  ) async {
    try {
      final request = await client.post(url,
          headers: {'Content-type': 'application/json'},
          body: json.encode(comment));
      if (request.statusCode == 200) {
        Map<String, dynamic> social = jsonDecode(request.body);
        return Future.value(social);
      } else {
        Map<String, dynamic> social = jsonDecode(request.body);
        return social;
      }
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  @override
  Future<Map<String, dynamic>?> searchCommentByTypeById(int type, int id) {
    return _searchCommentByTypeById(
        Uri.parse('$domain/social/comment/$type/$id'));
  }

  Future<Map<String, dynamic>?> _searchCommentByTypeById(Uri url) async {
    try {
      final request =
          await client.get(url, headers: {'Content-type': 'application/json'});
      if (request.statusCode == 200) {
        Map<String, dynamic> annoyance = jsonDecode(request.body);
        return Future.value(annoyance);
      } else {
        Map<String, dynamic> annoyance = jsonDecode(request.body);
        return annoyance;
      }
    } catch (e) {
      print(e.toString());
      return null;
    }
  }
}
