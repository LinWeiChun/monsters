// ignore_for_file: file_names

import 'dart:convert';

Data monsterFromJson(String str) => Data.fromJson(json.decode(str));

String monsterToJson(Data data) => json.encode(data.toJson());

class Data {
  Data({
    required this.data,
    required this.result,
    required this.errorCode,
    required this.message,
  });

  List<Monster> data;
  bool result;
  String errorCode;
  String message;

  factory Data.fromJson(Map<String, dynamic> json) => Data(
        data: List<Monster>.from(json["data"].map((x) => Monster.fromJson(x))),
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

class Monster {
  String? account;
  String? monsterId;
  String? monsterGroup;
  String? ownSkin;
  int? use;
  // String? nickName;

  Monster({
    required this.account,
    this.monsterId,
    this.monsterGroup,
    this.ownSkin,
    this.use,
  });

  factory Monster.fromJson(Map<String, dynamic> json) => Monster(
        account: json['account'],
        monsterId: json['monsterId'],
        monsterGroup: json['monsterGroup'],
        ownSkin: json['ownSkin'],
        use: json['use'],
      );

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['account'] = account;
    data['monsterId'] = monsterId;
    data['monsterGroup'] = monsterGroup;
    data['ownSkin'] = ownSkin;
    data['use'] = use;
    return data;
  }
}
