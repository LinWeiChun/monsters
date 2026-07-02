// ignore_for_file: file_names

import 'dart:convert';
import 'dart:io';

Data diaryFromJson(String str) => Data.fromJson(json.decode(str));

String diaryToJson(Data data) => json.encode(data.toJson());

class Data {
  List<Diary> data;
  bool result;
  String errorCode;
  String message;
  Data({
    required this.data,
    required this.result,
    required this.errorCode,
    required this.message,
  });


  factory Data.fromJson(Map<String, dynamic> json) => Data(
        data: List<Diary>.from(json["data"].map((x) => Diary.fromJson(x))),
        result: json["result"],
        errorCode: json["errorCode"],
        message: json["message"],
      );

  Map<String, dynamic> toJson() => {
        "data": List<dynamic>.from(data.map((x) => x.toJson())),
        "result": result,
        "errorCode": errorCode,
        "message": message,
      };
}

class Diary {
  int? id;
  String? account;
  String? content;
  int? monsterId;
  String? mood;
  int? index;
  String? time;
  int? share;
  String? imageContent;
  String? audioContent;
  bool? newMonster;
  int? newMonsterGroup;
  Diary({
    this.id,
    this.account,
    this.content,
    this.monsterId,
    this.mood,
    this.index,
    this.time,
    this.share,
    this.imageContent,
    this.audioContent,
    this.newMonster,
    this.newMonsterGroup,
  });

  factory Diary.fromJson(Map<String, dynamic> json) => Diary(
        id: json['id'],
        account: json['account'],
        content: json['content'],
        monsterId: json['monsterId'],
        mood: json['mood'],
        index: json['index'],
        time: json['time'],
        share: json['share'],
        imageContent: json['imageContent'],
        audioContent: json['audioContent'],
        newMonster: json['newMonster'],
        newMonsterGroup: json['newMonsterGroup'],
      );
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['account'] = account;
    data['content'] = content;
    data['monsterId'] = monsterId;
    data['mood'] = mood;
    data['index'] = index;
    data['time'] = time;
    data['share'] = share;
    data['imageContent'] = imageContent;
    data['audioContent'] = audioContent;
    data['newMonster'] = newMonster;
    data['newMonsterGroup'] = newMonsterGroup;
    return data;
  }
}
