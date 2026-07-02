// ignore_for_file: file_names

import 'package:monsters_front_end/model/monsterModel.dart';

abstract class MonsterApiDataSource {
  Future<Map<String, dynamic>?> searchMonsterByAccount();

  Future<Map<String, dynamic>?> searchSkinByMonsterGroup(int monsterGroup);
  
  Future<String> modifySkin(Monster monster);
}
