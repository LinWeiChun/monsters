import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:monsters_front_end/model/annoyanceModel.dart';
import 'package:monsters_front_end/model/audio_Model/audio_player.dart';
import 'package:monsters_front_end/pages/chat_items/Timer_Widget.dart';
import 'package:monsters_front_end/pages/chat_items/audio_main.dart';
import 'package:monsters_front_end/pages/chat_items/drawing_colors.dart';
import 'package:monsters_front_end/pages/settings/style.dart';
import 'package:monsters_front_end/repository/annoyanceRepo.dart';

class dev_annoyanceChat extends StatefulWidget {
  @override
  _dev_annoyanceChatState createState() => _dev_annoyanceChatState();
}

class _dev_annoyanceChatState extends State<dev_annoyanceChat> {
  String base64String =
      "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iigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKK6ax1fUIvB16sd5MqxzRRoA33VIfIHsaisdK0p7HTJLx7zzb6V4h5RXahDAA8j36VVtbL+rivpdnPUVvR6Vp1rY3NxqL3TGC9Nrttyo3YBOeQfSkvNDhtBrA82RzZ+UYjwNwcj7w+hqelwuYVFdJY2On2et6OJ1uJRcRQygK6jEjN3yOV46dfemSXGj2vimKVYLgQx3LGcTMrj73VQFHA645qrBc56iul1p7t4LaTUJ4dRsvPO27t2G/GOY8kfLxzgik8Sf2UsVmIILpJ2s4TGWkXbtx/EAuScd80raBc5uiuivNK0a3MlsLm5juxarOrysvlligbZ0zk54P4VZs/CiXFnagxag01zB5y3EceYIzgkK3Ge3Jzxmhp6/wBf1sF1/X9eZylFdBoeiW2pQRmS31OZ5JfLL20WY4RxyxIOevQY4FS2egWJt5ftktz5yT3EQMRXb+6QNnBHfkflRysLnNUrKy43KRkZGR2ro7bTLW28U+Uoaa2igN0iS4JP7rzAGxwecVSskOualcXGpXEzJFC88rLgsVUfdXPA7D0FFguZFFdNfwWdzYaBDA1wttI0w5XfIBvGRgdTUWp6JbWNnb3zW2pW8Bn8qSG6AWRhjO5TjHr2NFguc9RXSeJP7KWKzEEF0k7WcJjLSLt24/iAXJOO+aX/AIR2CTSp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MskkRyDGE35XPqP51WN9bf2l9oGnQfZsbfs+5sben3s53e/r2osFyhRWnqVtFpWsgRIJrfCTRrL/ABIwDANj64o1i0gga1ubRSlvdwiVYyc7Dkhlz3AINIZmUVPNbGGGGXzon80E7UbLL/vDtUFJNPYbTW4UUUUxBRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQB1Npqemq2n6jJdMlxZWphNr5RJkYBgpDdAPm7+lZ2kzWjabqFjdXQtftHlskjIzLlSSQdoJ71j0U7isdJaW9pL4WminvlgiGoDbN5bMrfIew55HtTptVsL++1iGSdoLe8WNYp2jLY8sjGQOecVznnS+T5PmP5W7fs3Hbu6Zx60yi4WNy71K1GuabLC7S29ikMfmbcF9hySAenemXcelf20JWvjc2k8jtIYY2VowTx94c9e3pWNRRcLG9ql7bf2JDYJqLajIs/mJIUZREm3G0bueTg46cVHqslle2Npcx3qieG2jha2aNt2V4JDY2479axaKG7hY1dZv0n1Pz7Odtpt4oyy5XOI1Vh9OCK2rfXrZbCzkW7t4Jra38oo1iJJSwyAVcjgHI6kY5rkKKL7/ANf1uFtv6/rY6rRdR0u0srJmltYZ4pS1x5tn5rv82QVbBxx9PWkXWLACfM/3rq8kHyNyskW1D07n/wCvXLUUOVwSsdJHqlmfE0U5l/0Z7Vbd5Np+UmEITj2P8qyv7Iuf7S+w7od+N3meavl7eu7dnGMc1Qoobu7sLWNfWHTUtbWGyIlVUjt42ztD7VC556AkUa5LEosbGKVJfscHlvIhypcsWIB7gZxn2rIopXHYt3lolrFa/OWkliEjrjhc9B+VVKc8jyNud2Y4AyxzwOlNqYppalSab0CiiiqJCiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooA//9k=";

  final AnnoyanceRepository annoyanceRepository = AnnoyanceRepository();
  final timerController = TimerController();
  final player = AudioPlayer();
  File? contentFile;
  File? moodFile;
  File? imageFile;
  File? audioFile;
  File? _contentFile;

  int _type = 1;
  String? _content = "測試";
  String _mood = "否";
  int _index = 3;
  int _share = 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: secondAppBar("dev-page"),
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Center(
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    height: 100,
                    child: (_contentFile == null)
                        ? PopUpMen(
                            icon: const Icon(
                              Icons.drive_folder_upload,
                              color: Color.fromARGB(255, 164, 78, 38),
                              size: 100,
                            ),
                            menuList: [
                              PopupMenuItem(
                                child: ListTile(
                                    leading:
                                        const Icon(Icons.camera_alt_rounded),
                                    title: const Text("照相"),
                                    onTap: () => {
                                          //照相選項
                                          takePhoto(),
                                          Navigator.pop(context)
                                        }),
                              ),
                              PopupMenuItem(
                                child: ListTile(
                                    leading: const Icon(
                                        Icons.video_camera_front_rounded),
                                    title: const Text("錄影"),
                                    onTap: () => {
                                          //錄影選項
                                          recordVideo(),
                                          Navigator.pop(context)
                                        }),
                              ),
                              PopupMenuItem(
                                child: ListTile(
                                    leading: const Icon(
                                        Icons.keyboard_voice_rounded),
                                    title: const Text("錄音"),
                                    onTap: () => {
                                          //錄音選項
                                          Navigator.pop(context),
                                          recordAudio(context),
                                        }),
                              ),
                            ],
                          )
                        : Container(
                            height: 100,
                            width: 300,
                            margin: const EdgeInsets.only(top: 10),
                            color: Colors.teal,
                            child: TextButton(
                              child: const Text(
                                "重置多媒體煩惱為null",
                                style: TextStyle(
                                  fontSize: 20,
                                  color: Colors.white,
                                ),
                              ),
                              onPressed: () {
                                _contentFile = null;
                                imageFile = null;
                                audioFile = null;
                                setState(() {});
                              },
                            ),
                          ),
                  ),
                ],
              ),
              (moodFile == null)
                  ? Container(
                      height: 100,
                      width: 300,
                      margin: const EdgeInsets.all(10),
                      color: Colors.teal,
                      child: TextButton(
                        child: const Text(
                          "畫心情",
                          style: TextStyle(
                            fontSize: 20,
                            color: Colors.white,
                          ),
                        ),
                        onPressed: () => _navigateAndDisplayPaint(context),
                      ),
                    )
                  : Container(
                      height: 100,
                      width: 300,
                      margin: const EdgeInsets.all(10),
                      color: Colors.teal,
                      child: TextButton(
                        child: const Text(
                          "重置心情為null",
                          style: TextStyle(
                            fontSize: 20,
                            color: Colors.white,
                          ),
                        ),
                        onPressed: () {
                          moodFile = null;
                          setState(() {});
                        },
                      ),
                    ),
              Container(
                height: 100,
                width: 300,
                color: Colors.amberAccent,
                child: TextButton(
                  child: const Text(
                    "新增煩惱",
                    style: TextStyle(
                      fontSize: 30,
                      color: Colors.red,
                    ),
                  ),
                  onPressed: () {
                    _type = 2;
                    _content = "測試";
                    _mood = "否";
                    _index = 3;
                    _share = 0;
                    var pushContent;
                    if (_contentFile == null) {
                      pushContent = _content;
                    } else {
                      pushContent = null;
                    }
                    if (moodFile == null) {
                      _mood = "否";
                    } else {
                      _mood = "是";
                    }
                    String? _imageFile;
                    String? _audioFile;
                    _content = "文字煩惱";
                    if (moodFile != null) {
                      File file = moodFile!;
                      List<int> bytes = file.readAsBytesSync();
                      _mood = base64.encode(bytes);
                    }

                    if (imageFile != null) {
                      File file = imageFile!;
                      List<int> bytes = file.readAsBytesSync();
                      _imageFile = base64.encode(bytes);
                      _content = "圖片煩惱";
                      log(_imageFile.length.toString());
                    }

                    if (audioFile != null) {
                      File file = audioFile!;
                      List<int> bytes = file.readAsBytesSync();
                      _audioFile = base64.encode(bytes);
                      _content = "聲音煩惱";
                      log(_audioFile.length.toString());
                    }
                    setState(() {});

                    // File file = _contentFile!;
                    // List<int> bytes = file.readAsBytesSync();
                    // String base64String = base64.encode(bytes);

                    annoyanceRepository.createAnnoyance(
                      Annoyance(
                        id: 0,
                        account: "tonyhong", //"Lin"
                        content: _content, //"純文字不分享無多媒體"
                        type: 1,
                        monsterId: 0,
                        mood: _mood, //
                        index: 2, //3
                        time: "",
                        solve: 0,
                        share: 0, //0
                        imageContent: _imageFile,
                        audioContent: null,
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              SizedBox(
                height: 100,
                width: 100,
                child: GestureDetector(
                  onTap: () {
                    log(base64String.toString());
                  },
                  child: imageFile != null
                      ? Container(
                          child: Image.file(imageFile!,
                              width: (MediaQuery.of(context).size.width >
                                      MediaQuery.of(context).size.height)
                                  ? 288
                                  : 162,
                              height: (MediaQuery.of(context).size.width <
                                      MediaQuery.of(context).size.height)
                                  ? 240
                                  : 162,
                              filterQuality: FilterQuality.high),
                        )
                      : Container(),
                ),
              ),
              Container(
                color: Colors.blueGrey,
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
                child: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: Text(
                    "_content: \n" +
                        _content.toString() +
                        "\n\n\n" +
                        "imageFile: \n" +
                        imageFile.toString() +
                        "\n\n\n"
                            "audioFile: \n" +
                        audioFile.toString() +
                        "\n\n\n",
                    style: const TextStyle(fontSize: 20, color: Colors.white),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  //新增煩惱-照相
  takePhoto() async {
    final media = await ImagePicker().pickImage(source: ImageSource.camera);
    if (media == null) return;

    log("media:" + media.path.toString());
    imageFile = File(media.path);
    // if (imageFile != null) {
    //   messages.insert(0, {"data": 2, "image": imageFile});
    //   response(null, imageFile);
    // }

    setState(() {});
  }

  //新增煩惱-錄影
  recordVideo() async {
    XFile? recordedVideo = await ImagePicker().pickVideo(
        source: ImageSource.camera, maxDuration: const Duration(seconds: 15));
    if (recordedVideo == null) return;
    // _contentFile = File(recordedVideo.path);
    setState(() {});
  }

  //錄音功能
  recordAudio(BuildContext context) async {
    final media = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AudioMainPage()),
    );
    log("media:" + media.toString());
    if (media == null) return;
    final audioTemporary = File(media.toString());
    audioFile = audioTemporary;
    log("audioFile: " + audioFile.toString());
    audioFile = File(media);
    _contentFile = audioFile;
    setState(() {});
  }

  //畫心情功能
  _navigateAndDisplayPaint(BuildContext context) async {
    final moodImage = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => Draw_mood()),
    );
    if (moodImage == null) {
      log("畫心情失敗");
    } else {
      moodFile = File(moodImage.path);
    }

    setState(() {});
  }
}

//彈出選單設置
class PopUpMen extends StatelessWidget {
  final List<PopupMenuEntry> menuList;
  final Widget? icon;

  const PopUpMen({Key? key, required this.menuList, this.icon})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton(
      itemBuilder: ((context) => menuList),
      icon: icon,
      iconSize: 200,
    );
  }
}
