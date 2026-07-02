// ignore_for_file: use_key_in_widget_constructors, unnecessary_string_interpolations, prefer_const_constructors, file_names, avoid_unnecessary_containers, sized_box_for_whitespace, non_constant_identifier_names, camel_case_types, no_logic_in_create_state
import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:bubble/bubble.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:monsters_front_end/model/diaryModel.dart';
import 'package:monsters_front_end/pages/chat_items/Timer_Widget.dart';
import 'package:monsters_front_end/pages/settings/monsters_information.dart';
import 'package:monsters_front_end/pages/settings/style.dart';
import 'package:monsters_front_end/repository/diaryRepo.dart';
import 'package:video_player/video_player.dart';
import '../../model/audio_Model/audio_player.dart';

class historyDiaryChat extends StatefulWidget {
  var data;
  historyDiaryChat({required this.data});

  @override
  _historyDiaryChat createState() => _historyDiaryChat(data);
}

class _historyDiaryChat extends State<historyDiaryChat> {
  var data;
  _historyDiaryChat(this.data);
  final messageInsert = TextEditingController();
  final timerController = TimerController();
  final player = AudioPlayer();
  late final VideoPlayerController _videoPlayerController;
  int chatRound = 0;
  bool lastSpeaking = false;
  bool robotSpeakable = true;
  bool pickable = false;
  List<Map> messages = [];
  int acceptShare = 0;
  var userAnswers = [];
  @override
  Widget build(BuildContext context) {
    final DiaryRepository diaryRepository = DiaryRepository();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    response();

    if (data["imageContent"] == null) {
      response(data["content"]);
    } else {
      response(data["imageContent"]);
    }

    if (data["mood"] == "否") {
      response("否");
    } else {
      response("是");
    }
    response(data["moodIndex"].toString());

    if (data["share"] == 0) {
      response("否");
    } else {
      response("是");
    }

    setState(() {});
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(
          color: Color.fromARGB(255, 164, 78, 38), //修改颜色
        ),
        backgroundColor: Color.fromRGBO(255, 237, 151, 1),
        elevation: 2.0,
        title: Text(getMonsterAvatarName_CH(),
            style: TextStyle(
                fontSize: 22, color: Color.fromARGB(255, 164, 78, 38))),
        centerTitle: true,
      ),
      body: Container(
        color: Color.fromARGB(255, 255, 255, 229),
        child: Column(
          children: <Widget>[
            Flexible(
                child: ListView.builder(
                    reverse: true,
                    itemCount: messages.length,
                    itemBuilder: (context, index) => chat(
                        messages[index]["message"].toString(),
                        messages[index]["data"]))),
            SizedBox(
              height: 10,
            ),
            Container(
              decoration:
                  BoxDecoration(color: Color.fromRGBO(255, 237, 151, 1)),
              alignment: Alignment.bottomCenter,
              height: 70,
              //margin: EdgeInsets.only(bottom: 30),
              child: Container(
                child: Container(
                  child: Center(
                    child: Container(
                      width: 110,
                      height: 50,
                      margin: EdgeInsets.only(
                        right: 15,
                        bottom: 3,
                      ),
                      alignment: Alignment.centerLeft,
                      decoration: BoxDecoration(
                          color:
                              getShared() ? Colors.white : BackgroundColorWarm,
                          border:
                              Border.all(color: BackgroundColorWarm, width: 2),
                          borderRadius:
                              BorderRadius.all(Radius.circular(50.0))),
                      child: Center(
                        child: GestureDetector(
                          onTap: () {
                            int _share;
                            if (data["share"] == 0) {
                              _share = 1;
                            } else {
                              _share = 0;
                            }
                            diaryRepository.modifyDiary(
                              data["id"],
                              Diary(
                                id: data["id"],
                                share: _share,
                                index: data["moodIndex"],
                              ),
                            );
                            data["share"] = _share;
                            setState(() {});
                          },
                          child: Text(
                            getShared() ? "取消分享" : "分享",
                            style: TextStyle(
                                fontSize: 18,
                                color: getShared()
                                    ? BackgroundColorWarm
                                    : Colors.white),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

//聊天功能
  Widget chat(String message, int data) {
    Container chatContainer = Container();
    //text container
    if (data < 2) {
      chatContainer = Container(
        padding: EdgeInsets.only(left: 20, right: 20),
        child: Row(
          mainAxisAlignment:
              data == 1 ? MainAxisAlignment.end : MainAxisAlignment.start,
          children: [
            data == 0
                //左方怪獸頭貼
                ? Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border:
                          Border.all(width: 1, color: const Color(0xffa0522d)),
                    ),
                    height: 50,
                    width: 50,
                    child: CircleAvatar(
                      backgroundImage: AssetImage(
                        getMonsterAvatarPath(getMonsterAvatarName()),
                      ),
                    ),
                  )
                : Container(),
            //訊息框
            Padding(
              padding: EdgeInsets.all(10.0),
              child: Bubble(
                  radius: Radius.circular(15.0),
                  color: data == 0
                      ? Colors.white
                      : Color.fromRGBO(255, 237, 151, 1),
                  elevation: 2.0,
                  //訊息文字格式
                  child: Padding(
                    padding: EdgeInsets.all(2.0),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        SizedBox(
                          width: 3.0,
                        ),
                        Flexible(
                            child: Container(
                          constraints: BoxConstraints(maxWidth: 200),
                          child: Text(
                            message,
                            style: TextStyle(
                                color: data == 0
                                    ? Color.fromRGBO(160, 82, 45, 1)
                                    : Colors.black,
                                fontWeight: FontWeight.normal,
                                fontSize: 17),
                          ),
                        ))
                      ],
                    ),
                  )),
            ),
          ],
        ),
      );
    }

    //picture container
    if (data == 2) {
      //TODO: Level 2
      //ADD HERO https://youtu.be/1xipg02Wu8s?t=657
      ///wrap by something make it clickable
      chatContainer = Container(
        padding: EdgeInsets.only(left: 10, right: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            //訊息框
            Padding(
              padding: EdgeInsets.all(10.0),
              child: Bubble(
                  radius: Radius.circular(15.0),
                  color: Color.fromRGBO(255, 237, 151, 1),
                  elevation: 2.0,
                  //訊息文字格式
                  child: Padding(
                    padding: EdgeInsets.all(2.0),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        SizedBox(
                          width: 3.0,
                        ),
                        Flexible(
                            child: Container(
                            child: Image.memory(base64Decode(message),
                                    width: (MediaQuery.of(context).size.width >
                                            MediaQuery.of(context).size.height)
                                        ? 288
                                        : 162,
                                    height: (MediaQuery.of(context).size.width <
                                            MediaQuery.of(context).size.height)
                                        ? 240
                                        : 162,
                                filterQuality: FilterQuality.high),
                          ),
                        ),
                        SizedBox(
                          width: 3.0,
                        ),
                      ],
                    ),
                  )),
            ),
          ],
        ),
      );
    }

    //video container
    if (data == 3) {
      ///TODO: Level 2
      ///ADD HERO https://youtu.be/1xipg02Wu8s?t=657
      ///wrap by something make it clickable
      chatContainer = Container(
        padding: EdgeInsets.only(left: 10, right: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            //訊息框
            Padding(
              padding: EdgeInsets.all(10.0),
              child: Bubble(
                  radius: Radius.circular(15.0),
                  color: Color.fromRGBO(255, 237, 151, 1),
                  elevation: 2.0,
                  //訊息文字格式
                  child: Padding(
                    padding: EdgeInsets.all(2.0),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        SizedBox(
                          width: 3.0,
                        ),
                        Flexible(
                            child: Container(
                                width:
                                    (_videoPlayerController.value.size.width >
                                            _videoPlayerController
                                                .value.size.height)
                                        ? 288
                                        : 162,
                                height:
                                    (_videoPlayerController.value.size.width >
                                            _videoPlayerController
                                                .value.size.height)
                                        ? 162
                                        : 288,
                                alignment: Alignment.centerRight,
                                child: AspectRatio(
                                  aspectRatio:
                                      (_videoPlayerController.value.size.width >
                                              _videoPlayerController
                                                  .value.size.height)
                                          ? 16 / 9
                                          : 9 / 16,
                                  child:
                                      _videoPlayerController.value.isInitialized
                                          ? VideoPlayer(_videoPlayerController)
                                          : Container(),
                                ))),
                        SizedBox(
                          width: 3.0,
                        ),
                      ],
                    ),
                  )),
            ),
          ],
        ),
      );
    }

    //audio container
    if (data == 4) {
      chatContainer = Container(
        padding: EdgeInsets.only(left: 10, right: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            //訊息框
            Padding(
              padding: EdgeInsets.all(10.0),
              child: Bubble(
                  radius: Radius.circular(15.0),
                  color: Color.fromRGBO(255, 237, 151, 1),
                  elevation: 2.0,
                  //訊息文字格式
                  child: Padding(
                    padding: EdgeInsets.all(2.0),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        SizedBox(
                          width: 3.0,
                        ),
                        Flexible(
                            child: Container(
                          padding: EdgeInsets.all(20),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'The Audio',
                                style: TextStyle(
                                    fontSize: 24, fontWeight: FontWeight.bold),
                              ),
                              SizedBox(height: 20),
                              CircleAvatar(
                                radius: 35,
                                child: IconButton(
                                  icon: Icon(Icons.play_circle_fill),
                                  iconSize: 30,
                                  onPressed: () async {
                                    await player.togglePlaying(
                                        whenFinished: () => {setState(() {})});
                                  },
                                ),
                              )
                            ],
                          ),
                        )),
                        SizedBox(
                          width: 3.0,
                        ),
                      ],
                    ),
                  )),
            ),
          ],
        ),
      );
    }

    //painting container
    if (data == 5) {
      //TODO: Level 2
      ///ADD HERO https://youtu.be/1xipg02Wu8s?t=657
      ///wrap by something make it clickable to watch
      chatContainer = Container(
        padding: EdgeInsets.only(left: 10, right: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            //訊息框
            Padding(
              padding: EdgeInsets.all(10.0),
              child: Bubble(
                  radius: Radius.circular(15.0),
                  color: Color.fromRGBO(255, 237, 151, 1),
                  elevation: 2.0,
                  //訊息文字格式
                  child: Padding(
                    padding: EdgeInsets.all(2.0),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        SizedBox(
                          width: 3.0,
                        ),
                        Flexible(
                            child: Container(
                                child: Image.memory(base64Decode(message),
                                    width: 200,
                                    height: 200,
                                filterQuality: FilterQuality.high),
                          ),
                        ),
                        SizedBox(
                          width: 3.0,
                        ),
                      ],
                    ),
                  )),
            ),
          ],
        ),
      );
    }

    //moodImage container
    if (data == 6) {
      chatContainer = Container(
        padding: EdgeInsets.only(left: 20, right: 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Container(
              height: 50,
              width: 50,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(width: 1, color: const Color(0xffa0522d)),
              ),
              child: CircleAvatar(
                backgroundImage:
                    AssetImage(getMonsterAvatarPath(getMonsterAvatarName())),
              ),
            ),
            //訊息框
            Padding(
              padding: EdgeInsets.all(10.0),
              child: Bubble(
                  radius: Radius.circular(15.0),
                  color: Colors.white,
                  elevation: 2.0,
                  //訊息格式 以圖表示煩惱指數
                  child: Padding(
                    padding: EdgeInsets.all(2.0),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        SizedBox(
                          width: 3.0,
                        ),
                        Flexible(
                            child: Container(
                                constraints: BoxConstraints(maxWidth: 200),
                                child: moodPointRow()))
                      ],
                    ),
                  )),
            ),
          ],
        ),
      );
    }

    return chatContainer;
  }

  //確認是否符合選擇格式，符合->回覆 不符合->提示再次輸入
  Future<void> response([String? text, File? media]) async {
    //進入時自動訊息問安
    if (chatRound == 0) {
      int hourNow = DateTime.now().hour.toInt();
      if (hourNow < 5) {
        reply("凌晨睡不好嗎？\n甚麼事情都可以跟我說～"); //0~5點
      } else if (hourNow < 12) {
        reply("早安！\n可以跟我說任何事情！"); //5~12點
      } else if (hourNow < 14) {
        reply("中午好啊！\n午餐吃了嗎？發生任何事都可以找我說"); //12~14點
      } else if (hourNow < 18) {
        reply("下午好，快下班了吧？今天過得如何呀？"); //14~18點
      } else {
        reply("晚上好，今天過得如何呀？希望你有愉快的一天！"); //18~24點
      }
      reply("想跟我說些甚麼嗎？");
    }

    if (chatRound < 5) {
      //取得內容
      if (chatRound == 1) {
        if (data["imageContent"] == null) {
          insert(text!);
        } else {
          messages.insert(0, {"data": 2, "message": text});
        }
        reply("真是辛苦你了，想做一幅畫表達你的感受嗎？");
      }
      //取得是否畫心情
      if (chatRound == 2) {
        insert(text!);
        if (text == "是") {
          messages.insert(0, {"data": 5, "message": data["mood"]});
        }
        reply("給煩惱程度打一個分數～");
      }
      //取得心情分數
      if (chatRound == 3) {
        insert(text!);
        reply("想不想把這件事分享給別人呢？");
      }
      //取得是否分享
      if (chatRound == 4) {
        insert(text!);
        lastSpeaking = true;
        reply("我幫你記錄下來囉，想回顧的時候隨時跟我說！");
      }
    }

    chatRound++;
    setState(() {});
  }

  //怪獸文字回覆
  void reply(String text) {
    messages.insert(0, {"data": 0, "message": text});
  }

  //歷史文字回覆
  void insert(String text) {
    messages.insert(0, {"data": 1, "message": text});
  }

  void replyImage() {
    messages.insert(0, {"data": 6, "message": "print image"});
  }

  Row moodPointRow() {
    Row annoyancePointRow = Row();
    annoyancePointRow = Row(
      children: [
        moodPointColumn("1"),
        Spacer(),
        moodPointColumn("2"),
        Spacer(),
        moodPointColumn("3"),
        Spacer(),
        moodPointColumn("4"),
        Spacer(),
        moodPointColumn("5"),
        Spacer(),
      ],
    );

    return annoyancePointRow;
  }

  Column moodPointColumn(String point) {
    Column annoyanceImageColumn = Column();
    annoyanceImageColumn = Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CircleAvatar(
          radius: 19,
          backgroundImage: AssetImage('assets/image/mood/moodPoint_$point.png'),
        ),
        SizedBox(height: 1),
        Text(point,
            style:
                TextStyle(fontSize: 17, color: Color.fromRGBO(160, 82, 45, 1)))
      ],
    );

    return annoyanceImageColumn;
  }

  String getMonsterAvatarName() {
    return monsterNamesList[data["monsterId"]];
  }

  String getMonsterAvatarName_CH() {
    return monsterNamesList_CH[data["monsterId"]];
  }

  bool getSolved() {
    bool isSolved;
    if (data["solve"] == 1) {
      isSolved = true;
    } else {
      isSolved = false;
    }
    return isSolved;
  }

  bool getShared() {
    bool isShared;
    if (data["share"] == 1) {
      isShared = true;
    } else {
      isShared = false;
    }
    return isShared;
  }
}
