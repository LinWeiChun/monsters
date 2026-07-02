// ignore_for_file: file_names

import 'dart:convert';

Data moodLineFromJson(String str) => Data.fromJson(json.decode(str));

String moodLineToJson(Data data) => json.encode(data.toJson());

class Data {
  Data({
    required this.data,
    required this.result,
    required this.errorCode,
    required this.message,
  });

  List<moodLine> data;
  bool result;
  String errorCode;
  String message;

  factory Data.fromJson(Map<String, dynamic> json) => Data(
        data: List<moodLine>.from(
            json["data"].map((x) => moodLine.fromJson(x))),
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

class moodLine {
  int? index;
  String? time;
  moodLine({
    this.index,
    this.time,
  });
  
  factory moodLine.fromJson(Map<String, dynamic> json) => moodLine(
        index: json['index'],
        time: json['time'],
      );
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['index'] = index;
    data['time'] = time;
    return data;
  }


  @override
  String toString() {
    return "{index: $index, time: $time}";
  }

}
