
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class PushNotification {
  FirebaseMessaging messaging = FirebaseMessaging.instance;
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =FlutterLocalNotificationsPlugin();
  AndroidNotificationChannel channel = const AndroidNotificationChannel(
    'high_importance_channel', // id
    'High Importance Notifications', // title
    description:'This channel is used for important notifications.',
    playSound:true,
    sound:RawResourceAndroidNotificationSound('notification'),
    importance: Importance.high,
  );

  initialise()async{
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
    NotificationSettings settings=await messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: true,
      criticalAlert: false,
      provisional: false,
      sound: true,


    );
    await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
      alert: true, 
      badge: true,
      sound: true,  
    );
    //util.logDebug('User granted permission: ${settings.authorizationStatus}');
    fcm();
  }
  remoteNotification(){
    FirebaseMessaging.onMessage.listen((RemoteMessage message){
      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification?.android;
      if (notification!= null && android != null){
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
              playSound: true,
              sound: const RawResourceAndroidNotificationSound('notification'), 
              importance: Importance.max,
              priority: Priority.high,
            ),
          ),
        );
      }
    });
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message){
      _handleMessage(message);
    });
  }
  void _handleMessage(RemoteMessage message){
    if(message.data['screen_name']=='order_details'){
        //print('order details id :${message.data['id']}');
    }
  }
  fcm(){
    FirebaseMessaging.instance.getInitialMessage().then((RemoteMessage? message) {
      if(message != null) {}
    });
    remoteNotification();
  }
  Future onDidReceiveLocalNotification(int id, String? title, String? body, String? payload) async {
    // print('pT$title');print('pT$body');
    // display a dialog with the notification details, tap ok to go to another page
    // showCupertinoDialog(
    //   context: context,
    //   builder: (BuildContext context) => CupertinoAlertDialog(
    //     title: Text(title.toString()),
    //     content: Text(body.toString()),
    //   ),
    // );
  }
}
PushNotification pushNotification = PushNotification();