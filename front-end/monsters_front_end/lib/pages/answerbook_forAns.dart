// ignore_for_file: file_names, use_key_in_widget_constructors
import 'dart:convert';

import 'package:adobe_xd/adobe_xd.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:http/http.dart' as http;
import 'package:monsters_front_end/model/answerbookModel.dart';

import '../API/answerbookAPI.dart';
import 'interaction.dart';

class AnswerbookRepository implements AnswerbookApiDataSource {
  final client = http.Client();
  final String domain = "http://10.0.2.2:8080";
  @override
  Future<Map<String, dynamic>> getAnswerbook() {
    return _getAnswerBook(Uri.parse('$domain/answerBook/search'));
  }

  Future<Map<String, dynamic>> _getAnswerBook(Uri url) async {
    final request =
        await client.get(url, headers: {'Content-type': 'application/json'});
    if (request.statusCode == 200) {
      Map<String, dynamic> answerBook = jsonDecode(request.body);
      return Future.value(answerBook);
    } else {
      Map<String, dynamic> answerBook = jsonDecode(request.body);
      return answerBook;
    }
  }
}

class AnswerbookforAnsPage extends StatefulWidget {
  @override
  _AnswerbookforAnsPage createState() => _AnswerbookforAnsPage();
}

class _AnswerbookforAnsPage extends State<AnswerbookforAnsPage> {
  final AnswerbookRepository answerbookRepository = AnswerbookRepository();
  String answer = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfffffed4),
      body: Stack(
        children: <Widget>[
          Pinned.fromPins(
            Pin(size: 188.0, middle: 0.5),
            Pin(size: 63.0, start: 9.0),
            child: const Text(
              '解答之書',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Segoe UI',
                fontSize: 30,
                color: Color(0xffa0522d),
              ),
              softWrap: false,
            ),
          ),
          Pinned.fromPins(
            Pin(size: 41.0, end: 15.0),
            Pin(size: 36.0, start: 25.0),
            child: Stack(
              children: <Widget>[
                Pinned.fromPins(
                  Pin(start: 0.0, end: 0.0),
                  Pin(size: 4.0, start: 0.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xffffbb00),
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                ),
                Pinned.fromPins(
                  Pin(start: 0.0, end: 0.0),
                  Pin(size: 4.0, middle: 0.5),
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xffffbb00),
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                ),
                Pinned.fromPins(
                  Pin(start: 0.0, end: 0.0),
                  Pin(size: 5.0, end: 0.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xffffbb00),
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Pinned.fromPins(
            Pin(size: 45.6, start: 14.4),
            Pin(size: 41.1, start: 23.4),
            child:
                // Adobe XD layer: 'Icon ionic-md-arrow…' (shape)
                PageLink(
              links: [
                PageLinkInfo(
                  transition: LinkTransition.Fade,
                  ease: Curves.easeOut,
                  duration: 0.3,
                  pageBuilder: () => InteractionPage(),
                ),
              ],
              child: SvgPicture.string(
                _svg_ryq30,
                allowDrawingOutsideViewBox: true,
                fit: BoxFit.fill,
              ),
            ),
          ),
          Pinned.fromPins(
            Pin(start: -8.0, end: -9.0),
            Pin(size: 555.0, end: 105.0),
            child:
                // Adobe XD layer: '14253' (shape)
                Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: const AssetImage(
                      'assets/image/background_answerBook.png'),
                  fit: BoxFit.fill,
                  colorFilter: ColorFilter.mode(
                      Colors.black.withOpacity(0.45), BlendMode.dstIn),
                ),
              ),
            ),
          ),
          Pinned.fromPins(
            Pin(size: 136.0, middle: 0.5),
            Pin(size: 64.0, end: 73.0),
            child: Stack(
              children: <Widget>[
                Stack(
                  children: <Widget>[
                    Pinned.fromPins(
                      Pin(size: 66.0, middle: 0.5),
                      Pin(start: 0.0, end: 0.0),
                      child: Container(
                        color: const Color(0xffffed97),
                      ),
                    ),
                    Pinned.fromPins(
                      Pin(size: 70.0, start: 0.0),
                      Pin(start: 0.0, end: 0.0),
                      child: Container(
                        decoration: const BoxDecoration(
                          color: Color(0xffffed97),
                          borderRadius: BorderRadius.all(
                              Radius.elliptical(9999.0, 9999.0)),
                        ),
                      ),
                    ),
                    Pinned.fromPins(
                      Pin(size: 70.0, end: 0.0),
                      Pin(start: 0.0, end: 0.0),
                      child: Container(
                        decoration: const BoxDecoration(
                          color: Color(0xffffed97),
                          borderRadius: BorderRadius.all(
                              Radius.elliptical(9999.0, 9999.0)),
                        ),
                      ),
                    ),
                  ],
                ),
                Pinned.fromPins(
                  Pin(size: 100.0, middle: 0.5),
                  Pin(start: 6.0, end: 4.0),
                  child: TextButton(
                    child: const Text('再一次',
                        style: TextStyle(
                            fontFamily: 'Segoe UI',
                            fontSize: 23,
                            color: Color(0xffa0522d))),
                    onPressed: () {
                      setState(() {
                        Future<Answerbook> answers = answerbookRepository
                            .getAnswerbook()
                            .then((value) => Answerbook.fromMap(value));
                        answers.then((value) => answer = value.content);
                        print(answer);
                      });
                    },
                  ),
                ),
              ],
            ),
          ),
          Pinned.fromPins(
            Pin(start: 32.0, end: 31.0),
            Pin(size: 251.0, middle: 0.3491),
            child: Container(
              color: const Color(0xc9ffffff),
            ),
          ),
          Pinned.fromPins(
              Pin(start: 50.0, end: 50.0), Pin(size: 50.0, middle: 0.4),
              child: Center(
                child: Text(
                  answer,
                  style: const TextStyle(
                    fontFamily: 'Segoe UI',
                    fontSize: 25,
                    color: Color.fromARGB(255, 185, 40, 83),
                  ),
                  softWrap: false,
                ),
              )),
          Pinned.fromPins(
            Pin(start: 64.0, end: 64.0),
            Pin(size: 154.0, middle: 0.726),
            child:
                // Adobe XD layer: 'book-png-transparen…' (shape)
                Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image:
                      AssetImage('assets/image/background_answerBook_logo.png'),
                  fit: BoxFit.fill,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

const String _svg_ryq30 =
    '<svg viewBox="13.7 21.9 45.6 41.1" ><path transform="translate(8.07, 15.61)" d="M 47.28736877441406 22.92952919006348 L 19.54702568054199 22.92952919006348 L 30.30613327026367 13.09178352355957 C 31.84870529174805 11.54302215576172 31.84870529174805 9.040220260620117 30.30613327026367 7.491456031799316 C 28.76356315612793 5.942692756652832 26.26174545288086 5.942692756652832 24.70621109008789 7.491456031799316 L 6.791648864746094 24.09420013427734 C 6.013882637023926 24.81282615661621 5.624999046325684 25.79164695739746 5.624999046325684 26.86958694458008 L 5.624999046325684 26.91914939880371 C 5.624999046325684 27.99708938598633 6.013882637023926 28.97590446472168 6.791648864746094 29.69453430175781 L 24.69325065612793 46.29727935791016 C 26.24878120422363 47.84604263305664 28.75060272216797 47.84604263305664 30.29317092895508 46.29727935791016 C 31.83573913574219 44.74851226806641 31.83573913574219 42.2457160949707 30.29317092895508 40.69694900512695 L 19.5340633392334 30.85920524597168 L 47.27440643310547 30.85920524597168 C 49.46512222290039 30.85920524597168 51.24102020263672 29.08742141723633 51.24102020263672 26.89437294006348 C 51.25398254394531 24.66414642333984 49.47808074951172 22.92952919006348 47.28736877441406 22.92952919006348 Z" fill="#ffbb00" stroke="none" stroke-width="1" stroke-miterlimit="4" stroke-linecap="butt" /></svg>';
