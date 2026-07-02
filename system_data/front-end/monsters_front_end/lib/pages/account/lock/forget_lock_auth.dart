import 'dart:developer' as dv;
import 'dart:math';
import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:email_auth/email_auth.dart';
import 'package:monsters_front_end/main.dart';
import 'package:monsters_front_end/model/memberModel.dart';
import 'package:monsters_front_end/pages/account/lock/setting_lock_page.dart';
import 'package:monsters_front_end/pages/settings/style.dart';
import 'package:monsters_front_end/repository/memberRepo.dart';

class Forget_Lock_Auth extends StatefulWidget {
  @override
  _Forget_Lock_AuthState createState() => _Forget_Lock_AuthState();
}

class _Forget_Lock_AuthState extends State<Forget_Lock_Auth> {
  final TextEditingController _mailController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late EmailAuth emailAuth;
  late Future _future;
  String hintEmail = "";
  String userEmail = "";

  @override
  void initState() {
    super.initState();
    _future = getPersonalInfo();
    VerifyCode = 0;
    // Initialize the package
    // emailAuth = EmailAuth(
    //   sessionName: "貘nsters",
    // );
  }

  void verifyCode(String input) {
    var inputCode = int.parse(input);
    if (inputCode == VerifyCode) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          duration: Duration(seconds: 1),
          backgroundColor: BackgroundColorWarm,
          content: Text(
            "認證成功",
            style: TextStyle(color: Colors.white, fontSize: 30),
          )));
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => SettingLockPage()));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          duration: Duration(seconds: 1),
          backgroundColor: BackgroundColorWarm,
          content: Text(
            "認證失敗",
            style: TextStyle(color: Colors.white, fontSize: 30),
          )));
    }
  }

  Future sendVerifyEmail({
    required String userEmail,
    required int code,
  }) async {
    print("sending VerifyEmail");
    String? email = userEmail; //useremail
    const serviceId = "service_v0eahku";
    const templateId = "template_989nvlq";
    const userId = "x0TtUpsa7W7aHFIbl";
    final url = Uri.parse('https://api.emailjs.com/api/v1.0/email/send');
    final response = await http.post(url,
        headers: {
          'origin': 'http://localhost',
          'Content-Type': 'application/json'
        },
        body: json.encode({
          'service_id': serviceId,
          'template_id': templateId,
          'user_id': userId,
          'accessToken': "9OoipUoZgha107DzjjE3w",
          'template_params': {
            'user_email': email,
            'verify_code': code,
          }
        }));

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          duration: Duration(seconds: 1),
          backgroundColor: BackgroundColorWarm,
          content: Text(
            "驗證碼傳送成功",
            style: TextStyle(color: Colors.white, fontSize: 30),
          )));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          duration: Duration(seconds: 1),
          backgroundColor: BackgroundColorWarm,
          content: Text(
            "驗證碼傳送失敗",
            style: TextStyle(color: Colors.white, fontSize: 30),
          )));
    }
  }

  Future<Map> getPersonalInfo() async {
    Map personalInfoResult = {};
    print("doing...");
    final MemberRepository memberRepository = MemberRepository();
    Future<Data> personalInfo = memberRepository
        .searchPersonalInfoByAccount()
        .then((value) => Data.fromJson(value!));

    await personalInfo.then((value) async {
      personalInfoResult["mail"] = value.data.first.mail;
    });
    userEmail = personalInfoResult["mail"];
    hintEmailFunc(personalInfoResult["mail"]);
    setState(() {});
    return personalInfoResult;
  }

  void hintEmailFunc(String email) {
    List<String> splitEmail = email.split('@');
    String hintFront = splitEmail[0].substring(0, 1);
    var lenth = splitEmail[0].length;
    String hintBack = splitEmail[0].substring(lenth - 1);
    String hintMiddle = "*" * (lenth - 2);
    hintEmail = hintFront + hintMiddle + hintBack + "@" + splitEmail[1];
    print(userEmail);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: const Color(0xfffffed4),
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
          return SafeArea(
            child: SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 5),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 25.0),
                        child: Stack(
                          children: [
                            //上一頁
                            Align(
                                alignment: Alignment.topLeft,
                                child: IconButton(
                                  icon: const Icon(Icons.arrow_back_rounded),
                                  color: const Color.fromRGBO(255, 187, 0, 1),
                                  iconSize: 57.0,
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                )),
                            //標題
                            Container(
                              alignment: Alignment.topCenter,
                              padding: const EdgeInsets.only(top: 8),
                              child: const Text(
                                '忘記密碼鎖',
                                style: TextStyle(
                                  fontFamily: 'Segoe UI',
                                  fontSize: 40,
                                  color: Color.fromRGBO(160, 82, 45, 1),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 50.0),
                      //信箱
                      TextFormField(
                        style: const TextStyle(color: Colors.black),
                        autofocus: false,
                        controller: _mailController,
                        decoration: InputDecoration(
                          labelText: "信箱",
                          hintText: hintEmail,
                          prefixIcon: const Icon(Icons.email),
                          border: const OutlineInputBorder(
                            ///設定邊框四個角的弧度
                            borderRadius: BorderRadius.all(Radius.circular(90)),

                            ///用來配置邊框的樣式
                            borderSide: BorderSide(
                              ///設定邊框的顏色
                              color: Color.fromRGBO(160, 82, 45, 1),
                              width: 2.0,
                            ),
                          ),
                          fillColor: Color.fromRGBO(255, 255, 255, 1),
                          filled: true,
                        ),
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        validator: (email) =>
                            email != null && !EmailValidator.validate(email)
                                ? '請輸入正確的信箱格式'
                                : null,
                      ),
                      SizedBox(height: 10.0),
                      //傳送認證碼
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                            onPressed: () {
                              if (_mailController.text == userEmail) {
                                VerifyCode = Random().nextInt(899999) + 100000;
                                sendVerifyEmail(
                                    userEmail: _mailController.text,
                                    code: VerifyCode);
                              } else {
                                showAlertDialog(context);
                              }
                            },
                            //sendOTP(),
                            child: const Text(
                              '傳送認證碼',
                              style: TextStyle(
                                fontFamily: 'Segoe UI',
                                fontSize: 20,
                                color: Color.fromRGBO(160, 82, 45, 1),
                              ),
                            )),
                      ),
                      SizedBox(height: 10.0),
                      //認證碼
                      TextFormField(
                        style: const TextStyle(color: Colors.black),
                        controller: _otpController,
                        decoration: const InputDecoration(
                          labelText: "認證碼",
                          hintText: '請輸入認證碼',
                          prefixIcon: Icon(Icons.password),
                          border: OutlineInputBorder(
                            ///設定邊框四個角的弧度
                            borderRadius: BorderRadius.all(Radius.circular(90)),

                            ///用來配置邊框的樣式
                            borderSide: BorderSide(
                              ///設定邊框的顏色
                              color: Color.fromRGBO(160, 82, 45, 1),
                              width: 2.0,
                            ),
                          ),
                          fillColor: Color.fromRGBO(255, 255, 255, 1),
                          filled: true,
                        ),
                        obscureText: true,
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        validator: (value) {
                          if (value!.isNotEmpty && value.length == 6) {
                            return null;
                          } else if (value.isNotEmpty && value.length < 6) {
                            return '認證碼為6數';
                          } else {
                            return '認證碼不得空白';
                          }
                        },
                      ),
                      SizedBox(height: 50.0),
                      //認證
                      SizedBox(
                        width: 200.0,
                        height: 60.0,
                        child: RaisedButton(
                          color: Color.fromRGBO(160, 82, 45, 1),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(22.0)),
                          child: const Text(
                            '認證',
                            style: TextStyle(
                              fontFamily: 'Segoe UI',
                              fontSize: 30,
                              color: Color.fromRGBO(255, 255, 255, 1),
                            ),
                            softWrap: false,
                          ),
                          onPressed: () {
                            final isValidForm =
                                _formKey.currentState!.validate();
                            if (isValidForm) {
                              verifyCode(_otpController.text);
                              //verifyOTP();
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

showAlertDialog(BuildContext context) {
  AlertDialog dialog = AlertDialog(
    //backgroundColor: const Color(0xfffffed4),
    title: const Text(
      "信箱錯誤",
      style: TextStyle(
        fontFamily: 'Segoe UI',
        fontSize: 30,
        color: Color.fromRGBO(160, 82, 45, 1),
      ),
      softWrap: true,
    ),
    content: const Text(
      "請依照提示輸入與註冊時相同的信箱",
      style: TextStyle(
        fontFamily: 'Segoe UI',
        fontSize: 25,
        color: Colors.black,
      ),
      softWrap: true,
    ),
    actions: [
      RaisedButton(
          color: const Color.fromRGBO(160, 82, 45, 1),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(22.0)),
          child: const Text(
            "OK",
            style: TextStyle(
              fontFamily: 'Segoe UI',
              fontSize: 15,
              color: Color.fromRGBO(255, 255, 255, 1),
            ),
            softWrap: true,
          ),
          onPressed: () {
            Navigator.pop(context);
          })
    ],
  );
  showDialog(
      context: context,
      builder: (BuildContext context) {
        return dialog;
      });
}

int VerifyCode = 1;
