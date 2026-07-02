// ignore_for_file: camel_case_types, use_key_in_widget_constructors, unused_field

import 'dart:developer' as dv;
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:monsters_front_end/model/moodLineModel.dart';
import 'package:monsters_front_end/repository/historyRepo.dart';

import '../pages/settings/style.dart';

class dev_moodLine extends StatefulWidget {
  @override
  _dev_moodLine createState() => _dev_moodLine();
}

class _dev_moodLine extends State<dev_moodLine> {
  late Future _future;

  @override
  void initState() {
    _future = getIndexMap();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<Map> getIndexMap() async {
    Map finalMap = {};
    HistoryRepository historyRepository = HistoryRepository();
    Future<Data> indexMap = historyRepository
        .searchIndexByType(1)
        .then((value) => Data.fromJson(value!));
    Map indexMapResult = {};
    await indexMap.then((value) {
      var indexList = [];
      var timeList = [];

      for (int i = 0; i < min(7, value.data.length); i++) {
        indexList.add(value.data.elementAt(i).index);
        timeList.add(value.data.elementAt(i).time);
      }

      indexMapResult.putIfAbsent("indexList", () => indexList);
      indexMapResult.putIfAbsent("timeList", () => timeList);
      dv.log(indexMapResult["indexList"].toString());
      dv.log(indexMapResult["timeList"].toString());
    });

    return finalMap;
    // 在futureBuilder中用snapshot.data["indexList"]可以獲得分數List
    // 在futureBuilder中用snapshot.data["timeList"]可以獲得分數List
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: secondAppBar("dev-page"), body: Container());
  }
}
