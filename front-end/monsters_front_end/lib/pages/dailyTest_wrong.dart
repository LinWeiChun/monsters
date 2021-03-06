import 'package:flutter/material.dart';
import 'package:adobe_xd/pinned.dart';
import 'package:adobe_xd/page_link.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:monsters_front_end/pages/daily_test.dart';

class DailyTest_wrong extends StatefulWidget {
  DailyTest_wrong({
    Key? key,
  }) : super(key: key);
  @override
  _DailyTest_wrongState createState() => _DailyTest_wrongState();
}

class _DailyTest_wrongState extends State<DailyTest_wrong> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfffffed4),
      body: Stack(
        children: <Widget>[
          Pinned.fromPins(
            Pin(size: 188.0, middle: 0.5),
            Pin(size: 63.0, start: 11.0),
            child: Text(
              '每日測驗',
              style: TextStyle(
                fontFamily: 'Segoe UI',
                fontSize: 47,
                color: const Color(0xffa0522d),
              ),
              softWrap: false,
            ),
          ),
          Pinned.fromPins(
            Pin(start: 34.0, end: 34.0),
            Pin(size: 219.0, end: 64.0),
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xffffffff),
                borderRadius: BorderRadius.circular(22.0),
              ),
            ),
          ),
          Pinned.fromPins(
            Pin(size: 45.6, start: 13.7),
            Pin(size: 41.1, start: 21.9),
            child:
                // Adobe XD layer: 'Icon ionic-md-arrow…' (shape)
                PageLink(
              links: [
                PageLinkInfo(
                  transition: LinkTransition.Fade,
                  ease: Curves.easeOut,
                  duration: 0.3,
                  pageBuilder: () => Daily_test(),
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
            Pin(start: 34.0, end: 34.0),
            Pin(size: 112.0, middle: 0.3168),
            child: Stack(
              children: <Widget>[
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xffffffff),
                    borderRadius: BorderRadius.circular(22.0),
                  ),
                ),
                Pinned.fromPins(
                  Pin(size: 180.0, middle: 0.5),
                  Pin(start: 16.0, end: 16.0),
                  child: Text(
                    '答錯囉',
                    style: TextStyle(
                      fontFamily: 'Segoe UI',
                      fontSize: 60,
                      color: const Color(0xff979797),
                    ),
                    softWrap: false,
                  ),
                ),
              ],
            ),
          ),
          Pinned.fromPins(
            Pin(start: 36.2, end: 36.2),
            Pin(size: 66.0, middle: 0.5941),
            child: Stack(
              children: <Widget>[
                Pinned.fromPins(
                  Pin(size: 48.5, middle: 0.3333),
                  Pin(start: 0.0, end: 0.0),
                  child: Stack(
                    children: <Widget>[
                      Stack(
                        children: <Widget>[
                          Pinned.fromPins(
                            Pin(start: 0.0, end: 0.0),
                            Pin(size: 23.2, start: 0.0),
                            child: Stack(
                              children: <Widget>[
                                Container(
                                  decoration: BoxDecoration(
                                    color: const Color(0xffffffff),
                                    borderRadius: BorderRadius.circular(7.0),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Pinned.fromPins(
                            Pin(size: 9.0, middle: 0.5),
                            Pin(start: 0.0, end: 0.0),
                            child: Text(
                              '3\n\n',
                              style: TextStyle(
                                fontFamily: 'Segoe UI',
                                fontSize: 17,
                                color: const Color(0xffa0522d),
                              ),
                              softWrap: false,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Pinned.fromPins(
                  Pin(size: 48.5, middle: 0.5),
                  Pin(start: 0.0, end: 0.0),
                  child: Stack(
                    children: <Widget>[
                      Stack(
                        children: <Widget>[
                          Pinned.fromPins(
                            Pin(start: 0.0, end: 0.0),
                            Pin(size: 23.2, start: 0.0),
                            child: Stack(
                              children: <Widget>[
                                Container(
                                  decoration: BoxDecoration(
                                    color: const Color(0xffffffff),
                                    borderRadius: BorderRadius.circular(7.0),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Pinned.fromPins(
                            Pin(size: 9.0, middle: 0.4951),
                            Pin(start: 0.0, end: 0.0),
                            child: Text(
                              '4\n\n',
                              style: TextStyle(
                                fontFamily: 'Segoe UI',
                                fontSize: 17,
                                color: const Color(0xffa0522d),
                              ),
                              softWrap: false,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Pinned.fromPins(
                  Pin(size: 48.5, start: 48.5),
                  Pin(start: 0.0, end: 0.0),
                  child: Stack(
                    children: <Widget>[
                      Stack(
                        children: <Widget>[
                          Pinned.fromPins(
                            Pin(start: 0.0, end: 0.0),
                            Pin(size: 23.2, start: 0.0),
                            child: Stack(
                              children: <Widget>[
                                Container(
                                  decoration: BoxDecoration(
                                    color: const Color(0xffffffff),
                                    borderRadius: BorderRadius.circular(7.0),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Pinned.fromPins(
                            Pin(size: 9.0, middle: 0.4984),
                            Pin(start: 0.0, end: 0.0),
                            child: Text(
                              '2\n\n',
                              style: TextStyle(
                                fontFamily: 'Segoe UI',
                                fontSize: 17,
                                color: const Color(0xffa0522d),
                              ),
                              softWrap: false,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Align(
                  alignment: Alignment.topLeft,
                  child: SizedBox(
                    width: 49.0,
                    height: 44.0,
                    child: Stack(
                      children: <Widget>[
                        Stack(
                          children: <Widget>[
                            Pinned.fromPins(
                              Pin(start: 0.0, end: 0.0),
                              Pin(size: 23.2, start: 0.0),
                              child: Stack(
                                children: <Widget>[
                                  Container(
                                    decoration: BoxDecoration(
                                      color: const Color(0xffffffff),
                                      borderRadius: BorderRadius.circular(7.0),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Pinned.fromPins(
                              Pin(size: 9.0, middle: 0.5),
                              Pin(start: 0.0, end: 0.0),
                              child: Text(
                                '1\n',
                                style: TextStyle(
                                  fontFamily: 'Segoe UI',
                                  fontSize: 17,
                                  color: const Color(0xffa0522d),
                                ),
                                softWrap: false,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                Pinned.fromPins(
                  Pin(size: 48.5, middle: 0.6667),
                  Pin(start: 0.0, end: 0.0),
                  child: Stack(
                    children: <Widget>[
                      Stack(
                        children: <Widget>[
                          Pinned.fromPins(
                            Pin(start: 0.0, end: 0.0),
                            Pin(size: 23.2, start: 0.0),
                            child: Stack(
                              children: <Widget>[
                                Container(
                                  decoration: BoxDecoration(
                                    color: const Color(0xffffffff),
                                    borderRadius: BorderRadius.circular(7.0),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Pinned.fromPins(
                            Pin(size: 9.0, middle: 0.5),
                            Pin(start: 0.0, end: 0.0),
                            child: Text(
                              '5\n\n',
                              style: TextStyle(
                                fontFamily: 'Segoe UI',
                                fontSize: 17,
                                color: const Color(0xffa0522d),
                              ),
                              softWrap: false,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Pinned.fromPins(
                  Pin(size: 48.5, end: 48.5),
                  Pin(start: 0.0, end: 0.0),
                  child: Stack(
                    children: <Widget>[
                      Stack(
                        children: <Widget>[
                          Pinned.fromPins(
                            Pin(start: 0.0, end: 0.0),
                            Pin(size: 23.2, start: 0.0),
                            child: Stack(
                              children: <Widget>[
                                Container(
                                  decoration: BoxDecoration(
                                    color: const Color(0xffffffff),
                                    borderRadius: BorderRadius.circular(7.0),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Pinned.fromPins(
                            Pin(size: 9.0, middle: 0.5),
                            Pin(start: 0.0, end: 0.0),
                            child: Text(
                              '6\n\n',
                              style: TextStyle(
                                fontFamily: 'Segoe UI',
                                fontSize: 17,
                                color: const Color(0xffa0522d),
                              ),
                              softWrap: false,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Pinned.fromPins(
                  Pin(size: 48.5, end: 0.0),
                  Pin(start: 0.0, end: 0.0),
                  child: Stack(
                    children: <Widget>[
                      Stack(
                        children: <Widget>[
                          Pinned.fromPins(
                            Pin(start: 0.0, end: 0.0),
                            Pin(size: 23.2, start: 0.0),
                            child: Stack(
                              children: <Widget>[
                                Container(
                                  decoration: BoxDecoration(
                                    color: const Color(0xffffffff),
                                    borderRadius: BorderRadius.circular(7.0),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Pinned.fromPins(
                            Pin(size: 9.0, middle: 0.5),
                            Pin(start: 0.0, end: 0.0),
                            child: Text(
                              '7\n\n',
                              style: TextStyle(
                                fontFamily: 'Segoe UI',
                                fontSize: 17,
                                color: const Color(0xffa0522d),
                              ),
                              softWrap: false,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Pinned.fromPins(
            Pin(size: 30.4, start: 3.6),
            Pin(size: 38.2, middle: 0.5123),
            child:
                // Adobe XD layer: 'Icon material-direc…' (shape)
                SvgPicture.string(
              _svg_u6ihw,
              allowDrawingOutsideViewBox: true,
              fit: BoxFit.fill,
            ),
          ),
        ],
      ),
    );
  }
}

const String _svg_ryq30 =
    '<svg viewBox="13.7 21.9 45.6 41.1" ><path transform="translate(8.07, 15.61)" d="M 47.28736877441406 22.92952919006348 L 19.54702568054199 22.92952919006348 L 30.30613327026367 13.09178352355957 C 31.84870529174805 11.54302215576172 31.84870529174805 9.040220260620117 30.30613327026367 7.491456031799316 C 28.76356315612793 5.942692756652832 26.26174545288086 5.942692756652832 24.70621109008789 7.491456031799316 L 6.791648864746094 24.09420013427734 C 6.013882637023926 24.81282615661621 5.624999046325684 25.79164695739746 5.624999046325684 26.86958694458008 L 5.624999046325684 26.91914939880371 C 5.624999046325684 27.99708938598633 6.013882637023926 28.97590446472168 6.791648864746094 29.69453430175781 L 24.69325065612793 46.29727935791016 C 26.24878120422363 47.84604263305664 28.75060272216797 47.84604263305664 30.29317092895508 46.29727935791016 C 31.83573913574219 44.74851226806641 31.83573913574219 42.2457160949707 30.29317092895508 40.69694900512695 L 19.5340633392334 30.85920524597168 L 47.27440643310547 30.85920524597168 C 49.46512222290039 30.85920524597168 51.24102020263672 29.08742141723633 51.24102020263672 26.89437294006348 C 51.25398254394531 24.66414642333984 49.47808074951172 22.92952919006348 47.28736877441406 22.92952919006348 Z" fill="#ffbb00" stroke="none" stroke-width="1" stroke-miterlimit="4" stroke-linecap="butt" /></svg>';
const String _svg_u6ihw =
    '<svg viewBox="3.6 379.0 30.4 38.2" ><path transform="matrix(0.997564, 0.069756, -0.069756, 0.997564, 1.98, 376.5)" d="M 22.71305847167969 8.975848197937012 C 24.62021446228027 8.975848197937012 26.18061637878418 7.455781936645508 26.18061637878418 5.597923755645752 C 26.18061637878418 3.740065813064575 24.62021446228027 2.220000505447388 22.71305847167969 2.220000505447388 C 20.8059024810791 2.220000505447388 19.2455005645752 3.740065813064575 19.2455005645752 5.597923755645752 C 19.2455005645752 7.455781936645508 20.8059024810791 8.975848197937012 22.71305847167969 8.975848197937012 Z M 16.47145462036133 32.45241546630859 L 18.20523262023926 25.0209846496582 L 21.84616851806641 28.39890670776367 L 21.84616851806641 38.53268051147461 L 25.3137264251709 38.53268051147461 L 25.3137264251709 25.8654670715332 L 21.67279243469238 22.4875431060791 L 22.71305847167969 17.42065811157227 C 24.96697235107422 19.9541015625 28.43453025817871 21.64306259155273 32.24884414672852 21.64306259155273 L 32.24884414672852 18.26513862609863 C 28.95466232299805 18.26513862609863 26.18061637878418 16.5761775970459 24.79359245300293 14.21162986755371 L 23.05981254577637 11.50929164886475 C 22.36630058288574 10.49591541290283 21.32603454589844 9.820329666137695 20.11239051818848 9.820329666137695 C 19.59225463867188 9.820329666137695 19.2455005645752 9.989225387573242 18.72536659240723 9.989225387573242 L 9.709713935852051 13.70494174957275 L 9.709713935852051 21.64306259155273 L 13.17727184295654 21.64306259155273 L 13.17727184295654 15.90059280395508 L 16.29807472229004 14.71831893920898 L 13.52402782440186 28.39891052246094 L 5.028511524200439 26.70994758605957 L 4.335000038146973 30.08787155151367 L 16.4714527130127 32.45241928100586 Z" fill="#a0522d" stroke="none" stroke-width="1" stroke-miterlimit="4" stroke-linecap="butt" /></svg>';
