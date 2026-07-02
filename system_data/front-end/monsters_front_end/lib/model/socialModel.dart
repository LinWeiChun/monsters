// ignore_for_file: file_names

import 'dart:convert';
import 'dart:io';

Data socialFromJson(String str) => Data.fromJson(json.decode(str));

String socialToJson(Data data) => json.encode(data.toJson());

class Data {
  Data({
    required this.data,
    required this.result,
    required this.errorCode,
    required this.message,
  });

  List<Social> data;
  bool result;
  String errorCode;
  String message;

  factory Data.fromJson(Map<String, dynamic> json) => Data(
        data: List<Social>.from(json["data"].map((x) => Social.fromJson(x))),
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

class Social {
  int? id;
  String? nickName;
  String? content;
  int? type;
  int? monsterId;
  String? mood;
  int? index;
  String? time;
  int? solve;
  int? share;
  String? imageContent;
  String? audioContent;
  String? commentUser;
  String? commentContent;
  int? annoyanceId;
  int? diaryId;
  String? photo;
  String? date;

  Social({
    this.id,
    this.nickName,
    this.content,
    this.type,
    this.monsterId,
    this.mood,
    this.index,
    this.time,
    this.solve,
    this.share,
    this.imageContent,
    this.audioContent,
    this.commentUser,
    this.commentContent,
    this.annoyanceId,
    this.diaryId,
    this.photo,
    this.date,
  });

  factory Social.fromJson(Map<String, dynamic> json) => Social(
        id: json['id'],
        nickName: json['nickName'],
        content: json['content'],
        type: json['type'],
        monsterId: json['monsterId'],
        mood: json['mood'],
        index: json['index'],
        time: json['time'],
        solve: json['solve'],
        share: json['share'],
        imageContent: json['imageContent'],
        audioContent: json['audioContent'],
        commentUser: json['commentUser'],
        commentContent: json['commentContent'],
        annoyanceId: json['annoyanceId'],
        diaryId: json['diaryId'],
        photo: json['photo'],
        date: json['date'],
      );
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['nickName'] = nickName;
    data['content'] = content;
    data['type'] = type;
    data['monsterId'] = monsterId;
    data['mood'] = mood;
    data['index'] = index;
    data['time'] = time;
    data['solve'] = solve;
    data['share'] = share;
    data['imageContent'] = imageContent;
    data['audioContent'] = audioContent;
    data['commentUser'] = commentUser;
    data['commentContent'] = commentContent;
    data['annoyanceId'] = annoyanceId;
    data['diaryId'] = diaryId;
    data['photo'] = photo;
    data['date'] = date;
    return data;
  }
}
