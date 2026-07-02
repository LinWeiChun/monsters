// ignore_for_file: file_names

import 'dart:convert';
import 'dart:developer';

import 'package:monsters_front_end/repository/annoyanceRepo.dart';

import '../API/monsterAPI.dart';
import '../main.dart';
import '../model/monsterModel.dart';
import 'package:http/http.dart' as http;

class MonsterRepository implements MonsterApiDataSource {
  final client = http.Client();
  @override
  Future<Map<String, dynamic>?> searchMonsterByAccount() {
    return _searchMonsterByAccount(
        Uri.parse('$domain/monster/search/$userAccount'));
  }

  @override
  Future<Map<String, dynamic>?> searchSkinByMonsterGroup(int monsterGroup) {
    return _searchSkinByMonsterId(
        Uri.parse('$domain/monster/skin/search/$monsterGroup/$userAccount'));
  }

  @override
  Future<String> modifySkin(Monster monster) {
    return _modifySkin(
        Uri.parse('$domain/monster/modify/skin/$userAccount'), monster);
  }

  Future<Map<String, dynamic>?> _searchMonsterByAccount(Uri url) async {
    try {
      // log("doing..._searchMonsterByAccount()");
      final request =
          await client.get(url, headers: {'Content-type': 'application/json'});
      if (request.statusCode == 200) {
        Map<String, dynamic> monster = jsonDecode(request.body);
        return Future.value(monster);
      } else {
        Map<String, dynamic> monster = jsonDecode(request.body);
        return monster;
      }
    } catch (e) {
      print(e.toString());
      return null;
    }
  }



  Future<Map<String, dynamic>?> _searchSkinByMonsterId(Uri url) async {
    try {
      final request =
          await client.get(url, headers: {'Content-type': 'application/json'});
      log("*" * 20);
      log("monster status");
      log("status: " + request.statusCode.toString());
      log("body: " + request.body.toString());
      log("*" * 20);
      if (request.statusCode == 200) {
        Map<String, dynamic> monsterSkin = jsonDecode(request.body);
        return Future.value(monsterSkin);
      } else {
        Map<String, dynamic> monsterSkin = jsonDecode(request.body);
        return monsterSkin;
      }
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  Future<String> _modifySkin(
    Uri url,
    Monster monster,
  ) async {
    log(json.encode(monster).toString());
    try {
      final request = await client.patch(
        url,
        headers: {'Content-type': 'application/json'},
        body: json.encode(monster),
      );
      log("modifySkin statusCode: " + request.statusCode.toString());
      log("modifySkin body: " + request.body.toString());
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
