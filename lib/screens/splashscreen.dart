import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:hi_protein/screens/Home/HomeScreen.dart';
import 'package:http/http.dart' as http;
import 'package:upgrader/upgrader.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:io';

import '../main.dart';
import '../utilities/constants.dart';
import '../utilities/images.dart';
import '../utilities/palette.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}
class _SplashScreenState extends State<SplashScreen> {
  String versionAndroid = '1.0.7';
  String versionIOS='1.0.6';
  @override
  void initState() {
    checkLogin();
    fcm();
    super.initState();
  }

  checkLogin() async {
    Util.updateNotification();
    checkVersion();
    //await Future.delayed(const Duration(seconds: 2)).then((value) => nav());
  }
  checkVersion()async{
    final response = await http.get(Uri.parse('${Util.baseurl}appupdate.php'));
    try{
      if(response.statusCode==200){
        var deco = jsonDecode(response.body);
        if(Platform.isAndroid){
          if(deco['version']==versionAndroid){
            checking();
          }
          else{
            // ignore: use_build_context_synchronously
            /*showDialog(context: context,
                builder: (_)=>AlertDialog(
                  title: Text(deco['title'],style: Util.txt(Palette.black, 16, FontWeight.w600),),
                  content: Text(deco['message'],style: Util.txt(Palette.black, 14, FontWeight.w400),),
                  actions: [
                    deco['priority']=='low'?TextButton(onPressed: (){
                      Navigator.pop(context);
                      checking();
                    }, child: Text('IGNORE',style: Util.txt(Palette.black, 16, FontWeight.w500),)):Container(),
                    deco['priority']!='maintenance'? TextButton(onPressed: (){
                     // String url ='https://play.google.com/store/apps/details?id=com.hiprotein.hiprotein';
                     // _launchURL(url);
                    }, child: Text('UPDATE NOW',style: Util.txt(Palette.black, 16, FontWeight.w500),)):Container(),
                  ],
                ));*/
          }
        }
        else if(Platform.isIOS){
          if(deco['versionIOS']==versionIOS){
            checking();
          }
          else{
            // ignore: use_build_context_synchronously
           /* showCupertinoDialog(context: context,
                builder: (_)=>CupertinoAlertDialog(
                  title: Text(deco['title'],style: Util.txt(Palette.black, 16, FontWeight.w600),),
                  content: Text(deco['messageIOS'],style: Util.txt(Palette.black, 14, FontWeight.w400),),
                  actions: [
                    deco['priority']=='low'?TextButton(onPressed: (){
                      Navigator.pop(context);
                      checking();
                    }, child: Text('IGNORE',style: Util.txt(Palette.black, 16, FontWeight.w500),)):Container(),
                    deco['priority']!='maintenance'?TextButton(onPressed: (){
                      String url ='https://apps.apple.com/us/app/hi-protein/id6450906125';
                      _launchURL(url);
                    }, child: Text('UPDATE NOW',style: Util.txt(Palette.black, 16, FontWeight.w500),)):Container(),
                  ],
                ));*/

          }
        }
      }
    }catch(e){}
  }

  _launchURL(String url) async {
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    } else {
      throw 'Could not launch $url';
    }
  }
  void checking()async{
    await Future.delayed(const Duration(seconds: 1));
    nav();
  }
  nav() {
    Navigator.push(context,MaterialPageRoute(builder: (context) => const HomeScreen()));
  }
  fcm() {
    FirebaseMessaging.instance
        .getInitialMessage()
        .then((RemoteMessage? message) {
      if (message != null) {
        Util.logDebug(message);
        // Navigator.pop(context);
      }
    });
    const initialzationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    final IOSInitializationSettings initializationSettingsIOS =
        IOSInitializationSettings(
            onDidReceiveLocalNotification: onDidReceiveLocalNotification);
    IOSFlutterLocalNotificationsPlugin().getNotificationAppLaunchDetails();
    final initializationSettings = InitializationSettings(
        android: initialzationSettingsAndroid, iOS: initializationSettingsIOS);
    flutterLocalNotificationsPlugin.initialize(initializationSettings);
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification?.android;
      if (notification != null && android != null) {
        flutterLocalNotificationsPlugin.show(
          notification.hashCode,
          notification.title,
          notification.body,
          NotificationDetails(
            android: AndroidNotificationDetails(
              channel.id,
              channel.name,
              channelDescription: channel.description,
              icon: android.smallIcon,
            ),
          ),
        );
      }
    });
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {});
  }

  Future onDidReceiveLocalNotification(
      int id, String? title, String? body, String? payload) async {
    // print('pT$title');print('pT$body');
    // display a dialog with the notification details, tap ok to go to another page
    showDialog(
      context: context,
      builder: (BuildContext context) => CupertinoAlertDialog(
        title: Text(title.toString()),
        content: Text(body.toString()),
      ),
    );
  }
  @override
  Widget build(BuildContext context) {
    return UpgradeAlert(
      upgrader: Upgrader(
        canDismissDialog: false,
        showLater: false,
        showIgnore: false,
        showReleaseNotes: false
      ),
      child: Scaffold(
        backgroundColor: Palette.white,
        body: Column(
          children: [
            Expanded(
              child: Center(
                child: Image.asset(Images.logo),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 0, 10, 0),
                  child: Text(
                    'powered by veramasa',
                    style: Util.txt(Palette.black, 18, FontWeight.w500),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
