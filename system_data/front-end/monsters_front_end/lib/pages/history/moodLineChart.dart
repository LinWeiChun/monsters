import 'dart:math';
import 'dart:developer' as dv;
import 'package:date_format/date_format.dart';
import 'package:flutter/material.dart';
import 'package:monsters_front_end/pages/settings/style.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:monsters_front_end/repository/historyRepo.dart';
import '../../model/moodLineModel.dart';

class MoodLineChart extends StatefulWidget {
  const MoodLineChart({Key? key}) : super(key: key);

  @override
  _MoodLineChartState createState() => _MoodLineChartState();
}

class _MoodLineChartState extends State<MoodLineChart> {
  List dateTimeData = [];
  List moodData = [];
  List totalCount = [0, 0, 0, 0, 0];
  late Future _future;
  int selectionTab_type = 1;

  @override
  void initState() {
    super.initState();
    _future = getIndexMap();
    setState(() {});
  }

  Future<Map> getIndexMap() async {
    Map finalMap = {};
    HistoryRepository historyRepository = HistoryRepository();
    Future<Data> indexMap = historyRepository
        .searchIndexByType(selectionTab_type)
        .then((value) => Data.fromJson(value!));
    Map indexMapResult = {};
    await indexMap.then((value) {
      var indexList = [];
      var timeList = [];
      // if (value.data.length < 7) {
      //   for (int i = 0; i < min(7, value.data.length); i++) {
      //     indexList.add(0);
      //     timeList.add("_");
      //   }
      // }

      for (int i = 0; i < min(7, value.data.length); i++) {
        indexList.add(value.data.elementAt(i).index);
        timeList.add(value.data.elementAt(i).time);
      }
      for (int j = indexList.length; j < 7; j++) {
        indexList.add(0);
        timeList.add("_");
      }
      timeList = timeList.reversed.toList();
      indexList = indexList.reversed.toList();
      indexMapResult.putIfAbsent("indexList", () => indexList);
      indexMapResult.putIfAbsent("timeList", () => timeList);
      dateTimeData = indexMapResult["timeList"];
      moodData = indexMapResult["indexList"];
      countDay();
      dv.log("indexList" + indexMapResult["indexList"].toString());
      dv.log("timeList" + indexMapResult["timeList"].toString());
    });

    return finalMap;
  }

  void countDay() {
    int happy = 0;
    int fine = 0;
    int notBad = 0;
    int notGood = 0;
    int bad = 0;
    for (var i in moodData) {
      if (i == 1) {
        bad++;
      }
      if (i == 2) {
        notGood++;
      }
      if (i == 3) {
        notBad++;
      }
      if (i == 4) {
        fine++;
      }
      if (i == 5) {
        happy++;
      }
    }
    totalCount[0] = happy;
    totalCount[1] = fine;
    totalCount[2] = notBad;
    totalCount[3] = notGood;
    totalCount[4] = bad;
    dv.log("累積數" + totalCount.toString());
  }

  @override
  Widget build(BuildContext context) {
    _future = getIndexMap();
    setState(() {});
    return Scaffold(
      appBar: secondAppBar("心的軌跡"),
      backgroundColor: const Color(0xfffffed4),
      body: SafeArea(
          child: FutureBuilder<dynamic>(
              future: _future,
              builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
                if (snapshot.data == null || moodData.length < 7) {
                  return const Center(
                      child: Text(
                    "Loading...",
                    style: TextStyle(fontSize: 30),
                  ));
                }
                return Column(
                  children: <Widget>[
                    //標籤
                    AspectRatio(
                        aspectRatio: 6.10,
                        child: Container(
                          alignment: Alignment.center,
                          padding: const EdgeInsets.only(left: 15, bottom: 10),
                          child: Center(
                            child: Wrap(
                              spacing: 20,
                              //標籤設定
                              children: [
                                //煩惱標籤
                                InkWell(
                                    child: Container(
                                      width: 80,
                                      decoration: BoxDecoration(
                                        color: selectionTab_type == 1
                                            ? const Color(0xffa0522d)
                                            : const Color(0xffffed97),
                                        borderRadius: const BorderRadius.all(
                                            Radius.elliptical(9999.0, 9999.0)),
                                      ),
                                      child: Text(
                                        '煩惱',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            fontFamily: 'Segoe UI',
                                            fontSize: 20,
                                            color: selectionTab_type ==
                                                    1 //點按後更新文字顏色
                                                ? const Color(0xffffffff)
                                                : const Color(0xffa0522d)),
                                      ),
                                    ),
                                    onTap: () {
                                      if (selectionTab_type != 1) {
                                        selectionTab_type = 1;
                                        setState(() {});
                                      }
                                    }),
                                //日記標籤
                                InkWell(
                                    child: Container(
                                      width: 80,
                                      decoration: BoxDecoration(
                                        color: selectionTab_type == 2
                                            ? const Color(0xffa0522d)
                                            : const Color(0xffffed97),
                                        borderRadius: const BorderRadius.all(
                                            Radius.elliptical(100.0, 100.0)),
                                      ),
                                      child: Text(
                                        '日記',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            fontFamily: 'Segoe UI',
                                            fontSize: 20,
                                            color: selectionTab_type ==
                                                    2 //點按後更新文字顏色
                                                ? const Color(0xffffffff)
                                                : const Color(0xffa0522d)),
                                      ),
                                    ),
                                    onTap: () {
                                      if (selectionTab_type != 2) {
                                        selectionTab_type = 2;
                                        setState(() {});
                                      }
                                    }),
                              ],
                            ),
                          ),
                        )),
                    AspectRatio(
                      aspectRatio: 1.10,
                      child: Container(
                        decoration: const BoxDecoration(color: Colors.white),
                        child: Container(
                          margin: const EdgeInsets.only(top: 20),
                          padding: const EdgeInsets.fromLTRB(20, 24, 30, 12),
                          child: LineChart(
                            mainData(),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20.0),
                    //downside face and day counter
                    AspectRatio(
                      aspectRatio: 2.10,
                      child: Padding(
                        padding: const EdgeInsets.all(10),
                        child: Stack(
                          children: <Widget>[
                            Container(
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: const Color(0xffa0522d),
                                ),
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(10),
                                child: Stack(children: [
                                  Align(
                                    alignment: Alignment.topLeft,
                                    child: SizedBox(
                                      width: 150.0,
                                      height: 40.0,
                                      child: Text(
                                        dateTimeData[0].substring(0, 5) +
                                            '~' +
                                            dateTimeData[6].substring(0, 5),
                                        style: const TextStyle(
                                          fontFamily: 'Segoe UI',
                                          fontSize: 18,
                                          color: Color(0xffa0522d),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Align(
                                    alignment: Alignment.center,
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: [
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.end,
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          children: [
                                            Container(
                                              width: 50.0,
                                              height: 50.0,
                                              decoration: const BoxDecoration(
                                                image: DecorationImage(
                                                  image: AssetImage(
                                                      'assets/image/mood/moodPoint_5.png'),
                                                  fit: BoxFit.cover,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(height: 5.0),
                                            SizedBox(
                                              width: 40.0,
                                              height: 30.0,
                                              child: Text(
                                                totalCount[0].toString() + '次',
                                                style: const TextStyle(
                                                  fontFamily: 'Segoe UI',
                                                  fontSize: 20,
                                                  color: Color(0xffa0522d),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.end,
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          children: [
                                            Container(
                                              width: 50.0,
                                              height: 50.0,
                                              decoration: const BoxDecoration(
                                                image: DecorationImage(
                                                  image: AssetImage(
                                                      'assets/image/mood/moodPoint_4.png'),
                                                  fit: BoxFit.cover,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(height: 5.0),
                                            SizedBox(
                                              width: 40.0,
                                              height: 30.0,
                                              child: Text(
                                                totalCount[1].toString() + '次',
                                                style: const TextStyle(
                                                  fontFamily: 'Segoe UI',
                                                  fontSize: 20,
                                                  color: Color(0xffa0522d),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.end,
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          children: [
                                            Container(
                                              width: 50.0,
                                              height: 50.0,
                                              decoration: const BoxDecoration(
                                                image: DecorationImage(
                                                  image: AssetImage(
                                                      'assets/image/mood/moodPoint_3.png'),
                                                  fit: BoxFit.cover,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(height: 5.0),
                                            SizedBox(
                                              width: 40.0,
                                              height: 30.0,
                                              child: Text(
                                                totalCount[2].toString() + '次',
                                                style: const TextStyle(
                                                  fontFamily: 'Segoe UI',
                                                  fontSize: 20,
                                                  color: Color(0xffa0522d),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.end,
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          children: [
                                            Container(
                                              width: 50.0,
                                              height: 50.0,
                                              decoration: const BoxDecoration(
                                                image: DecorationImage(
                                                  image: AssetImage(
                                                      'assets/image/mood/moodPoint_2.png'),
                                                  fit: BoxFit.cover,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(height: 5.0),
                                            SizedBox(
                                              width: 40.0,
                                              height: 30.0,
                                              child: Text(
                                                totalCount[3].toString() + '次',
                                                style: const TextStyle(
                                                  fontFamily: 'Segoe UI',
                                                  fontSize: 20,
                                                  color: Color(0xffa0522d),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.end,
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          children: [
                                            Container(
                                              width: 50.0,
                                              height: 50.0,
                                              decoration: const BoxDecoration(
                                                image: DecorationImage(
                                                  image: AssetImage(
                                                      'assets/image/mood/moodPoint_1.png'),
                                                  fit: BoxFit.cover,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(height: 5.0),
                                            SizedBox(
                                              width: 40.0,
                                              height: 30.0,
                                              child: Text(
                                                totalCount[4].toString() + '次',
                                                style: const TextStyle(
                                                  fontFamily: 'Segoe UI',
                                                  fontSize: 20,
                                                  color: Color(0xffa0522d),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ]),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              })),
    );
  }

  Widget bottomTitleWidgets(double value, TitleMeta meta) {
    const style = TextStyle(
      color: Color(0xffa0522d),
      fontWeight: FontWeight.bold,
      fontSize: 16,
    );
    Widget text;
    switch (value.toInt()) {
      case 1:
        text = Text(
            dateTimeData[0].toString().substring(0, 5) +
                "\n" +
                dateTimeData[0].toString().substring(6, 11),
            style: style);
        break;
      case 2:
        text = Text(
            dateTimeData[1].toString().substring(0, 5) +
                "\n" +
                dateTimeData[1].toString().substring(6, 11),
            style: style);
        break;
      case 3:
        text = Text(
            dateTimeData[2].toString().substring(0, 5) +
                "\n" +
                dateTimeData[2].toString().substring(6, 11),
            style: style);
        break;
      case 4:
        text = Text(
            dateTimeData[3].toString().substring(0, 5) +
                "\n" +
                dateTimeData[3].toString().substring(6, 11),
            style: style);
        break;
      case 5:
        text = Text(
            dateTimeData[4].toString().substring(0, 5) +
                "\n" +
                dateTimeData[4].toString().substring(6, 11),
            style: style);
        break;
      case 6:
        text = Text(
            dateTimeData[5].toString().substring(0, 5) +
                "\n" +
                dateTimeData[5].toString().substring(6, 11),
            style: style);
        break;
      case 7:
        text = Text(
            dateTimeData[6].toString().substring(0, 5) +
                "\n" +
                dateTimeData[6].toString().substring(6, 11),
            style: style);
        break;
      default:
        text = const Text('', style: style);
        break;
    }

    return SideTitleWidget(
      axisSide: meta.axisSide,
      space: 8.0,
      child: text,
    );
  }

  Widget leftTitleWidgets(double value, TitleMeta meta) {
    Image mood;
    switch (value.toInt()) {
      case 1:
        mood = const Image(
          image: AssetImage('assets/image/mood/moodPoint_1.png'),
        );
        break;
      case 2:
        mood = const Image(
          image: AssetImage('assets/image/mood/moodPoint_2.png'),
        );
        break;
      case 3:
        mood = const Image(
          image: AssetImage('assets/image/mood/moodPoint_3.png'),
        );
        break;
      case 4:
        mood = const Image(
          image: AssetImage('assets/image/mood/moodPoint_4.png'),
        );
        break;
      case 5:
        mood = const Image(
          image: AssetImage('assets/image/mood/moodPoint_5.png'),
        );
        break;
      default:
        return Container();
    }

    return Container(margin: const EdgeInsets.only(right: 5), child: mood);
  }

  LineChartData mainData() {
    return LineChartData(
      backgroundColor: Colors.white,
      gridData: FlGridData(
        show: true,
        drawVerticalLine: false,
        horizontalInterval: 1,
        verticalInterval: 1,
        getDrawingHorizontalLine: (value) {
          return FlLine(
            color: const Color(0xffa0522d).withOpacity(0.3),
            strokeWidth: 1,
          );
        },
        getDrawingVerticalLine: (value) {
          return FlLine(
            color: const Color(0xffa0522d).withOpacity(0.3),
            strokeWidth: 1,
          );
        },
      ),
      titlesData: FlTitlesData(
        show: true,
        rightTitles: AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        topTitles: AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 60,
            interval: 1,
            getTitlesWidget: bottomTitleWidgets,
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            interval: 1,
            getTitlesWidget: leftTitleWidgets,
            reservedSize: 45,
          ),
        ),
      ),
      borderData: FlBorderData(
        show: true,
        border: const Border(
          top: BorderSide(color: Color(0xffa0522d), width: 0.3),
          left: BorderSide(color: Color(0xffa0522d), width: 2),
          bottom: BorderSide(color: Color(0xffa0522d), width: 2),
        ),
      ),
      minX: 1,
      maxX: 7,
      minY: 0,
      maxY: 5,
      lineBarsData: [
        LineChartBarData(
          // 改為曲線
          // isCurved: true,
          spots: [
            FlSpot(1, moodData[0].toDouble()),
            FlSpot(2, moodData[1].toDouble()),
            FlSpot(3, moodData[2].toDouble()),
            FlSpot(4, moodData[3].toDouble()),
            FlSpot(5, moodData[4].toDouble()),
            FlSpot(6, moodData[5].toDouble()),
            FlSpot(7, moodData[6].toDouble()),
          ],
          color: const Color(0xffffbb00),
          barWidth: 5,
          isStrokeCapRound: true,
        ),
      ],
    );
  }
}
