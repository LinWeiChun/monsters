import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:developer' as dev;
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:monsters_front_end/pages/settings/monsters_information.dart';
import 'package:monsters_front_end/pages/settings/style.dart';
import 'package:monsters_front_end/repository/historyRepo.dart';
import 'package:video_player/video_player.dart';

import '../model/annoyanceModel.dart';

class dev_media extends StatefulWidget {
  @override
  _dev_mediaState createState() => _dev_mediaState();
}

class _dev_mediaState extends State<dev_media> {
  late Future _future;
  // late Future<VideoPlayerController> _futureController;
  // late VideoPlayerController _controller;
  // late final VideoPlayerController _videoPlayerController;

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void initState() {
    _future = getHistoryMapByAccount();
    super.initState();
  }

  Future<Map> getHistoryMapByAccount() async {
    Map finalMap = {};
    HistoryRepository historyRepository = HistoryRepository();

    Future<Data> histories = historyRepository
        .searchHistoryByType(2)
        .then((value) => Data.fromJson(value!));
    await histories.then((value) {
      finalMap.putIfAbsent("mood", () => value.data.first.imageContent);
    });

    return finalMap;
  }

/*
  playVideo() async {
    Uint8List decodedbytes = base64.decode(base64String);
    File decodedimgfile = await File("image.mp4").writeAsBytes(decodedbytes);
    File contentFile = decodedimgfile;
    _videoPlayerController = VideoPlayerController.file(contentFile)
      ..initialize().then((_) {
        _videoPlayerController.play();
      });
    setState(() {});
  }
*/
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: secondAppBar("dev_media"),
        body: FutureBuilder<dynamic>(
            future: _future,
            builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
              if (snapshot.data == null) {
                return const Center(
                    child: Text(
                  "Loading...",
                  style: TextStyle(fontSize: 30),
                ));
              }
              return Image.memory(base64Decode(snapshot.data["mood"]),
                  width: 200, height: 200, filterQuality: FilterQuality.high);
            })
        // body: Column(
        //   children: [
        //     GestureDetector(
        //       onTap: () => playVideo(),
        //       child: Container(
        //         color: Colors.red,
        //         height: 300,
        //         width: 300,
        //       ),
        //     ),
        //     Container(
        //   padding: EdgeInsets.only(left: 10, right: 10),
        //   child: Row(
        //     mainAxisAlignment: MainAxisAlignment.end,
        //     children: [
        //       Padding(
        //         padding: EdgeInsets.all(10.0),
        //         child: Container(
        //             color: Color.fromRGBO(255, 237, 151, 1),
        //             //訊息文字格式
        //             child: Padding(
        //               padding: EdgeInsets.all(2.0),
        //               child: Row(
        //                 mainAxisSize: MainAxisSize.min,
        //                 children: <Widget>[
        //                   SizedBox(
        //                     width: 3.0,
        //                   ),
        //                   Flexible(
        //                       child: Container(
        //                           width:
        //                               (_videoPlayerController.value.size.width >
        //                                       _videoPlayerController
        //                                           .value.size.height)
        //                                   ? 288
        //                                   : 162,
        //                           height:
        //                               (_videoPlayerController.value.size.width >
        //                                       _videoPlayerController
        //                                           .value.size.height)
        //                                   ? 162
        //                                   : 288,
        //                           alignment: Alignment.centerRight,
        //                           child: AspectRatio(
        //                             aspectRatio:
        //                                 (_videoPlayerController.value.size.width >
        //                                         _videoPlayerController
        //                                             .value.size.height)
        //                                     ? 16 / 9
        //                                     : 9 / 16,
        //                             child:
        //                                 _videoPlayerController.value.isInitialized
        //                                     ? VideoPlayer(_videoPlayerController)
        //                                     : Container(),
        //                       ),
        //                     ),
        //                   ),
        //                   SizedBox(
        //                     width: 3.0,
        //                   ),
        //                 ],
        //               ),
        //             )),
        //       ),
        //     ],
        //   ),
        // ),],
        // ),
        );
  }
}
