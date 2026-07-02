// ignore_for_file: file_names

import 'package:monsters_front_end/model/annoyanceModel.dart';

abstract class AnnoyanceApiDataSource{
  Future<Map<String, dynamic>?> createAnnoyance(Annoyance annoyance);

  Future<Map<String, dynamic>?> searchAnnoyanceByAccount(String account);
  
  Future<String> modifyAnnoyance(int id, Annoyance annoyance);
}