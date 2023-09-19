import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:http/http.dart' as http;

import '../../utilities/constants.dart';
import '../../utilities/palette.dart';
import '../Payment/OrderList.dart';

class FeedBackScreen extends StatefulWidget {
  const FeedBackScreen({super.key, required this.orderid});
  final String orderid;
  @override
  _FeedBackScreenState createState() => _FeedBackScreenState();
}

class _FeedBackScreenState extends State<FeedBackScreen> {
  final GlobalKey<ScaffoldState> _scaffoldkey = GlobalKey<ScaffoldState>();
  double ratinG = 0.0;
  TextEditingController wuLit = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldkey,
      backgroundColor: Palette.background,
      appBar: AppBar(
        elevation: 0.5,
        backgroundColor: Palette.background,
        title: Text(
          'Feed Back',
          style: Util.txt(Palette.black, 16, FontWeight.w600),
        ),
        leading: IconButton(
          icon: Icon(
            Ionicons.arrow_back,
            color: Palette.black,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Column(
              children: [
                Card(
                  elevation: 0,
                  color: Palette.background,
                  child: Container(
                    margin: const EdgeInsets.all(10.0),
                    height: 150.0,
                    width: double.infinity,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              ratinG == 1
                                  ? 'VERY BAD'
                                  : ratinG == 2
                                      ? 'BAD'
                                      : ratinG == 3
                                          ? 'AVERAGE'
                                          : ratinG == 4
                                              ? 'GOOD'
                                              : ratinG == 5
                                                  ? 'LOVED IT'
                                                  : '',
                              style:
                                  Util.txt(Palette.black, 25, FontWeight.w800),
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 10.0,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              height: 40.0,
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 5.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: <Widget>[
                                    RatingBar(
                                      initialRating: ratinG,
                                      minRating: 1,
                                      maxRating: 5,
                                      direction: Axis.horizontal,
                                      allowHalfRating: false,
                                      itemCount: 5,
                                      itemSize: 40.0,
                                      itemPadding: const EdgeInsets.symmetric(
                                          horizontal: 1.0),
                                      // itemBuilder: (context, _) => Icon(
                                      //   Icons.star,
                                      //   color: Colors.amber,
                                      // ),
                                      onRatingUpdate: (value) {
                                        setState(() {
                                          ratinG = value;
                                        });
                                      },
                                      glow: true,
                                      glowColor: Colors.amberAccent,
                                      tapOnlyMode: true,
                                      glowRadius: 10.0,
                                      ratingWidget: RatingWidget(
                                          full: const Icon(
                                            Icons.star,
                                            color: Colors.amber,
                                          ),
                                          empty: const Icon(
                                            Icons.star_border,
                                            color: Colors.black,
                                          ),
                                          half: const Icon(
                                            Icons.star_half,
                                            color: Colors.amber,
                                          )),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.all(10.0),
                  child: TextField(
                    controller: wuLit,
                    textInputAction: TextInputAction.newline,
                    keyboardType: TextInputType.multiline,
                    maxLines: 8,
                    style: Util.txt(Palette.black, 14, FontWeight.w400),
                    decoration: InputDecoration(
                      hintText: 'Tell us what you loved...',
                      hintStyle: Util.txt(Palette.black, 14, FontWeight.w400),
                      fillColor: Palette.white,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      border: InputBorder.none,
                      isDense: true,
                      filled: true,
                      contentPadding: const EdgeInsets.all(10.0),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 20.0,
            ),
            TextButton(
              onPressed: enable,
              style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(Palette.color1)),
              child: Text(
                'SUBMIT FEEDBACK',
                style: Util.txt(Palette.color2, 16, FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }

  enable() {
    FocusScope.of(context).requestFocus(FocusNode());
    if (ratinG != 0.0) {
      saveData();
    }
  }

  saveData() async {
    Util.showProgress(context);
    Map<String, String> map = {
      'orderid': widget.orderid,
      'fbstatus': ratinG.toString(),
      'fbtext': wuLit.text,
      'client': Util.clientName
    };
    var repo = await http.post(Uri.parse('${Util.baseurl}fedbckupdate.php'),
        body: map);
    try {
      if (repo.statusCode == 200) {
        Util.dismissDialog(_scaffoldkey.currentContext!);
        var decodd = jsonDecode(repo.body);
        if (decodd['message'] == 'Success') {
          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (context) => const MyOrdersList()));
        }
      } else {
        Util.dismissDialog(_scaffoldkey.currentContext!);
      }
    } catch (e) {
      Util.dismissDialog(_scaffoldkey.currentContext!);
      print(e.toString());
    }
  }
}
