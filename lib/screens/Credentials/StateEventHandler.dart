import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../utilities/constants.dart';
import 'globals.dart';

final lifecycleEventHandler = LifecycleEventHandler._();
class LifecycleEventHandler extends WidgetsBindingObserver {
  bool isavailable = true;
  var inBackground = true;
  Timer? timer;
  LifecycleEventHandler._();
  init() {
    WidgetsBinding.instance.addObserver(lifecycleEventHandler);
  }
  @override
  Future<void> didChangeAppLifecycleState(AppLifecycleState state) async {
    switch (state) {
      case AppLifecycleState.resumed:
        inBackground = false;
        timer = Timer.periodic(const Duration(seconds: 30), (Timer t) => checkForStatusMethod());
        break;
      case AppLifecycleState.inactive:
        timer?.cancel();
        break;
      case AppLifecycleState.paused:
        timer?.cancel();
        break;
      case AppLifecycleState.detached:
        inBackground = true;
        timer?.cancel();
        break;
      case AppLifecycleState.hidden:
    }
  }
  checkForStatusMethod() {
    availibilityCheck();
  }

  availibilityCheck() async {
    String userid = await Util.getStringValuesSF('userid');
    try {
      final availabilityCheck =http.MultipartRequest('POST', Uri.parse('${Util.baseurl}availability.php'));
      availabilityCheck.fields['client'] = Util.clientName;
      availabilityCheck.fields['userid'] = userid;
      final snd = await availabilityCheck.send();
      final response = await http.Response.fromStream(snd);
      if (response.statusCode == 200) {
        var dec = jsonDecode(response.body);
        if (dec['status'] == '1') {
          isavailable = true;
          Util.addStringToSF('availability', dec['status'].toString(),'');
          Util.addStringToSF('availabl', dec['available'].toString(),'');
          Util.addStringToSF('msg', dec['message'].toString(),'');
        } else {
          if(isavailable == true){
            Util.addStringToSF('availability', '0','');
            Util.addStringToSF('availabl', dec['available'].toString(),'');
            isavailable = false;
            alert();
          }
        }
      } else {
      }
    } catch (e) {
      Util.logDebug(e);
    }
  }
  void alert(){
   SnackBar snackBar = const SnackBar(content: Text("sorry, we are not accepting orders at this moment"));
   snackbarKey.currentState?.showSnackBar(snackBar); 
  }
  void showAlertDialog() {
    showDialog(
      barrierDismissible: false,
      context: navigatorKey.currentState!.context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: const Text('alert'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.pop(context, true);
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }
}
