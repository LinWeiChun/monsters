// ignore_for_file: file_names

import '../model/socialModel.dart';

abstract class SocialApiDataSource {
  Future<Map<String, dynamic>?> searchSocialByType(int type);

  Future<Map<String, dynamic>?> createSocialAnnoyanceComment(Social comment);

  Future<Map<String, dynamic>?> createSocialDiaryComment(Social comment);
  
  Future<Map<String, dynamic>?> searchCommentByTypeById(int type, int id);
}
