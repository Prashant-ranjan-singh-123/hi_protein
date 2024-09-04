import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../Connectivity/No_internet.dart';
import '../../Connectivity/connectivity_provider.dart';
import '../../utilities/constants.dart';
import '../../utilities/palette.dart';
import 'bottom_nav_bar.dart';
import 'bottom_nav_1st_item_home/home_entry_page.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);
  @override
  _HomeScreenState createState() => _HomeScreenState();
}
class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    Provider.of<ConnectivityProvider>(context, listen: false).startMonitoring();
   // Util.updateNotification();
    super.initState();
  }

  Future<bool> _onWillPop() async {
    return (await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            content: Text('Do you want to exit?',
                style: Util.txt(Palette.black, 16, FontWeight.w500)),
            actions: <Widget>[
              TextButton(
                onPressed: () =>
                    SystemNavigator.pop(), //Navigator.of(context).pop(true)
                child: Text('Yes',
                    style: Util.txt(Palette.black, 14, FontWeight.w500)),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text(
                  'No',
                  style: Util.txt(Palette.black, 14, FontWeight.w500),
                ),
              ),
            ],
          ),
        )) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Container(
        color: Palette.white,
        child: Padding(
          // padding: EdgeInsets.fromLTRB(0, 0, 0, Platform.isAndroid ? 0 : 20),
          padding: EdgeInsets.all(0),
          child: Scaffold(
            backgroundColor: Palette.background,
            body: SafeArea(child: checkConnection()),
            // bottomSheet: Container(
            //   // color: Palette.blue_tone_light_3,
            //   height: Util.bottomNavBarHeight,
            //   child: const NavigationItemBar(
            //     state: 0,
            //   ),
            // ),
          ),
        ),
      ),
    );
  }
  Widget checkConnection() {
    return Consumer<ConnectivityProvider>(
      builder: (consumerContext, model, child) {
        return model.isOnline ? page() : NoInternet();
      },
    );
  }
  page() {
    return const ProductItems();
  }
}
