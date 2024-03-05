import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:hi_protein/utilities/palette.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animated_dialog/flutter_animated_dialog.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import '../screens/Credentials/Login.dart';
import 'AppManagement.dart';

class Util {
  static String baseurl = 'https://redbag.vensframe.com/app/';
  static String clientName = 'HIPRO'; //REDB
  //--------------------------- text font family-----------------------------------------
  static txt(Color tc, double fs, FontWeight fw) {
    return GoogleFonts.notoSans(
        textStyle: TextStyle(fontSize: fs, fontWeight: fw, color: tc));
  }

  static final Controller control = Get.put(Controller());
  //------------------------- Loaders-----------------------------------------
  static void showProgress(BuildContext context) {
    if (Platform.isAndroid) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return Center(
            child: Card(
              elevation: 1.0,
              color: Palette.background,
              child: SizedBox(
                height: 60,
                width: 180,
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Row(
                    children: [
                      CircularProgressIndicator(
                        valueColor:
                            AlwaysStoppedAnimation<Color>(Palette.black),
                      ),
                      Expanded(
                          child: Center(
                              child: Text(
                        'Please wait...',
                        style: Util.txt(Palette.color2, 16, FontWeight.w500),
                      ))),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      );
    } else {
      showCupertinoDialog(
          context: context,
          builder: (_) => CupertinoAlertDialog(
                content: Row(
                  children: [
                    const CupertinoActivityIndicator(),
                    Expanded(
                        child: Center(
                            child: Text(
                      'Please wait...',
                      style: Util.txt(Colors.black, 16, FontWeight.w500),
                    ))),
                  ],
                ),
              ));
    }
  }

  static void dismissDialog(BuildContext context) {
    Navigator.pop(context);
  }

////////------------------------- Toast-----------------------------------------
  static showDog(BuildContext context, String msg) {
    if (Platform.isAndroid) {
      showAnimatedDialog(
        context: context,
        barrierDismissible: true,
        builder: (BuildContext context) {
          return ClassicGeneralDialogWidget(
            titleText: msg,
            // contentText: msg,
            actions: [
              TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text(
                    'Ok',
                    style: Util.txt(Palette.black, 16, FontWeight.w600),
                  )),
            ],
          );
        },
        animationType: DialogTransitionType.slideFromLeftFade,
        curve: Curves.fastOutSlowIn,
        duration: const Duration(seconds: 1),
      );
    } else {
      showCupertinoDialog(
          context: context,
          builder: (_) => CupertinoAlertDialog(
                title: Text(
                  msg,
                  style: Util.txt(Colors.black, 16, FontWeight.w500),
                ),
                // content: Text(msg,style: Util.txt(Colors.black, 14, FontWeight.w400),),
                actions: [
                  CupertinoButton(
                    child: Text('Ok',
                        style: Util.txt(Colors.black, 16, FontWeight.w500)),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                ],
              ));
    }
  }

  static showLoginPop(
      BuildContext context, String msg, Map<String, dynamic> share) {
    if (Platform.isAndroid) {
      showAnimatedDialog(
        context: context,
        barrierDismissible: true,
        builder: (BuildContext context) {
          return ClassicGeneralDialogWidget(
            titleText: msg,
            // contentText: msg,
            actions: [
              TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text(
                    'Cancel',
                    style: Util.txt(Palette.black, 16, FontWeight.w600),
                  )),
              TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => Login(
                                  share: share,
                                )));
                  },
                  child: Text(
                    'Login',
                    style: Util.txt(Palette.black, 16, FontWeight.w600),
                  )),
            ],
          );
        },
        animationType: DialogTransitionType.slideFromLeftFade,
        curve: Curves.fastOutSlowIn,
        duration: const Duration(seconds: 1),
      );
    } else {
      showCupertinoDialog(
          context: context,
          builder: (_) => CupertinoAlertDialog(
                title: Text(
                  msg,
                  style: Util.txt(Colors.black, 16, FontWeight.w500),
                ),
                // content: Text(msg,style: Util.txt(Colors.black, 14, FontWeight.w400),),
                actions: [
                  CupertinoButton(
                    child: Text('Cancel',
                        style: Util.txt(Colors.black, 16, FontWeight.w500)),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                  CupertinoButton(
                    child: Text('Login',
                        style: Util.txt(Colors.black, 16, FontWeight.w500)),
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => Login(
                                    share: share,
                                  )));
                    },
                  ),
                ],
              ));
    }
  }

  ////////------------------------- SF-----------------------------------------
  static void addStringToSF(String key, String val, String longString) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('key$key', val);
  }

  static Future<String> getStringValuesSF(String key) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String stringValue = prefs.getString('key$key') ?? '';
    return stringValue.toString();
  }

////////------------------------- Dialog-----------------------------------------
  static customDialog(String title, String message, BuildContext context) {
    showAnimatedDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return ClassicGeneralDialogWidget(
          titleText: title,
          contentText: message,
          actions: [
            TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text(
                  'Ok',
                  style: Util.txt(Palette.black, 16, FontWeight.w600),
                )),
          ],
        );
      },
      animationType: DialogTransitionType.slideFromTopFade,
      curve: Curves.fastOutSlowIn,
      duration: const Duration(seconds: 1),
    );
  }
  //--------------------------- Notification -----------------------------------------
  static updateNotification() async {
    String medium = '';
    String? fcmToken = await FirebaseMessaging.instance.getToken();
    logDebug("fcm: ${fcmToken!}");
    String userid = await Util.getStringValuesSF('userid');
    if (userid != '') {
      if (Platform.isAndroid) {
        medium = 'android';
      } else {
        medium = 'ios';
      }
      final updateToken = http.MultipartRequest(
          'POST', Uri.parse('${Util.baseurl}updatedevicetoken.php'));
      updateToken.fields['platform'] = medium;
      updateToken.fields['token'] = fcmToken;
      updateToken.fields['userid'] = userid;
      updateToken.fields['client'] = clientName;
      final respo = await updateToken.send();
      final response = await http.Response.fromStream(respo);
      try {
        if (response.statusCode == 200) {
          var dec = jsonDecode(response.body); logDebug('tokenupdate:$dec');
        }
      } catch (e) {
        logDebug(e);
      }
    }
  }
  static shareMsg(String msg) {
    Share.share(msg);
  }

  static void phoneCall(String num) async {
    String url = 'tel:$num';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    } else {
      throw 'Could not launch $url';
    }
  }

  static void launchEmail(String mail, String subject) async {
    String? encodeQueryParameters(Map<String, String> params) {
      return params.entries
          .map((e) =>
              '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}')
          .join('&');
    }
    final Uri emailLaunchUri = Uri(
      scheme: 'mailto',
      path: mail,
      query: encodeQueryParameters(<String, String>{'subject': subject}),
    );
    launchUrl(emailLaunchUri);
  }

  //--------------------------- debug -----------------------------------------
  static logDebug(Object a) {
    if (kDebugMode) {
      //print(a);
    }
  }
////////------------------------- End-----------------------------------------
}
