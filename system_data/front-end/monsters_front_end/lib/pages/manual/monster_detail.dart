// ignore_for_file: no_logic_in_create_state, camel_case_types, must_be_immutable

import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:monsters_front_end/main.dart';
import 'package:monsters_front_end/model/monsterModel.dart';
import 'package:monsters_front_end/pages/settings/monsters_information.dart';
import 'package:monsters_front_end/pages/settings/style.dart';

import '../../repository/monsterRepo.dart';

class Monster_detail extends StatefulWidget {
  int index;
  Monster_detail(this.index, {Key? key}) : super(key: key);

  @override
  _Monster_detailState createState() => _Monster_detailState(index);
}

class _Monster_detailState extends State<Monster_detail> {
  final MonsterRepository monsterRepository = MonsterRepository();
  late Future _future;
  int index;
  _Monster_detailState(this.index);
  AssetImage _button1 = const AssetImage('assets/image/skin_1_no.png');
  AssetImage _button2 = const AssetImage('assets/image/skin_2_no.png');
  AssetImage _button3 = const AssetImage('assets/image/skin_3_no.png');
  int _selectedSkin = 0;

  @override
  void initState() {
    _future = getSkinList();
    // setState(() {});
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    _future = getSkinList();

    setState(() {});
    String monsterName = monsterNamesList[index];
    String monsterName_CH = monsterNamesList_CH[index];

    return Scaffold(
      backgroundColor: const Color(0xfffffed4),
      appBar: secondAppBar("圖鑑"),
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
            return Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                //monster圖框
                Expanded(
                  flex: 55,
                  child: Container(
                    margin: const EdgeInsets.symmetric(
                        horizontal: 50, vertical: 70),
                    decoration: BoxDecoration(
                      color: const Color(0xffffffff),
                      borderRadius: BorderRadius.circular(22.0),
                      border: Border.all(
                          width: 2.65, color: const Color(0xffa0522d)),
                    ),
                    child: Container(
                      margin: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          // image: getMonsterSkin(
                          //     index, snapshot.data["_selectedSkin"]),
                          image: getMonsterSkin(index, _selectedSkin),
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ),
                ),
                //monster名稱
                Expanded(
                  flex: 15,
                  child: Stack(
                    children: [
                      Align(
                        alignment: Alignment.center,
                        child: Container(
                          alignment: Alignment.topCenter,
                          child: Container(
                            width: 200,
                            height: 60,
                            decoration: const BoxDecoration(
                              border: Border(
                                bottom: BorderSide(
                                  width: 2.5,
                                  color: BackgroundColorWarm,
                                ),
                              ),
                            ),
                            child: Text(
                              monsterName_CH,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontFamily: 'Segoe UI',
                                fontSize: 40,
                                color: Color(0xffa0522d),
                              ),
                              softWrap: false,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                //造型選項
                Expanded(
                    flex: 30,
                    child: Wrap(
                      spacing: 20,
                      children: [
                        GestureDetector(
                          onTap: () {
                            if (snapshot.data["ownSkinList"].contains(1)) {
                              if (_selectedSkin == 1) {
                                modifySkin(0);
                              } else {
                                modifySkin(1);
                              }
                              setState(() {});
                            }
                          },
                          child: CircleAvatar(
                            backgroundColor: BackgroundColorWarm,
                            radius: 45.0,
                            child: CircleAvatar(
                              backgroundImage: _button1,
                              radius: 42.0,
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            if (snapshot.data["ownSkinList"].contains(2)) {
                              if (_selectedSkin == 2) {
                                modifySkin(0);
                              } else {
                                modifySkin(2);
                              }
                              setState(() {});
                            }
                          },
                          child: CircleAvatar(
                            backgroundColor: BackgroundColorWarm,
                            radius: 45.0,
                            child: CircleAvatar(
                              backgroundImage: _button2,
                              radius: 42.0,
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            if (snapshot.data["ownSkinList"].contains(3)) {
                              if (_selectedSkin == 3) {
                                modifySkin(0);
                              } else {
                                modifySkin(3);
                              }
                              setState(() {});
                            }
                          },
                          child: CircleAvatar(
                            backgroundColor: BackgroundColorWarm,
                            radius: 45.0,
                            child: CircleAvatar(
                              backgroundImage: _button3,
                              radius: 42.0,
                            ),
                          ),
                        ),
                      ],
                    ))
              ],
            );
          }),
    );
  }

  Future<Map> getSkinList() async {
    Map finalMap = {};
    Future<Data> skins = monsterRepository
        .searchSkinByMonsterGroup(index)
        .then((value) => Data.fromJson(value!));

    await skins.then((value) {
      log("userAccount: " + userAccount);
      log("Use skin from DB: " + value.data.first.use.toString());
      String temp = jsonDecode(value.data.first.ownSkin!).toString();
      temp = temp.substring(1, temp.length - 1);
      List<String> skinResult = temp.split(",");
      final List<int> ownSkinList =
          skinResult.map((e) => int.parse(e)).toList();
      _selectedSkin = value.data.first.use!;

      log("ownSkinList skin: " + ownSkinList.toString());
      log("_selectedSkin skin: " + _selectedSkin.toString());
      finalMap.putIfAbsent("ownSkinList", () => ownSkinList);
      finalMap.putIfAbsent("_selectedSkin", () => _selectedSkin);

      if (ownSkinList.contains(1)) {
        _button1 = const AssetImage('assets/image/skin_1_yes.png');
        if (_selectedSkin == 1) {
          _button1 = const AssetImage('assets/image/skin_1_wear.png');
        }
      }
      if (ownSkinList.contains(2)) {
        _button2 = const AssetImage('assets/image/skin_2_yes.png');
        if (_selectedSkin == 2) {
          _button2 = const AssetImage('assets/image/skin_2_wear.png');
        }
      }
      if (ownSkinList.contains(3)) {
        _button3 = const AssetImage('assets/image/skin_3_yes.png');
        if (_selectedSkin == 3) {
          _button3 = const AssetImage('assets/image/skin_3_wear.png');
        }
      }
    });

    return finalMap;
  }

  Future<void> modifySkin(int i) async {
    if (_selectedSkin == i) {
      _selectedSkin = 0;
    } else {
      _selectedSkin = i;
    }
    await monsterRepository.modifySkin(Monster(
        account: userAccount,
        monsterGroup: index.toString(),
        use: index * 4 + i));
    setState(() {});
  }
}
