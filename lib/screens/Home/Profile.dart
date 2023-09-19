import 'dart:convert';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animated_dialog/flutter_animated_dialog.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import '../../Connectivity/No_internet.dart';
import '../../Connectivity/connectivity_provider.dart';
import '../../Model/Product_Model.dart';
import '../../utilities/AppManagement.dart';
import '../../utilities/constants.dart';
import '../../utilities/palette.dart';
import '../../utilities/web_privacy.dart';
import '../../utilities/web_view.dart';
import '../Credentials/Login.dart';
import '../Payment/OrderList.dart';
import 'NavigationItemBar.dart';

class Profile extends StatefulWidget {
  const Profile({Key? key}) : super(key: key);
  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  List<ContactUsModel> contactUs = [];
  List<ProfileModel> profile = [];
  bool showCont = false, log = true,showCont1 = false, 
  log1 = true,showCont2 = false, log2 = true,showCont3 = false, log3 = true,showCont4 = false, log4 = true;
  final Controller c = Get.put(Controller());
  String shareApp = '';

  @override
  void initState() {
    Provider.of<ConnectivityProvider>(context, listen: false).startMonitoring();
    super.initState();
    getData();
  }

  getData() async {
    profile = [];
    contactUs = [];
    String userid = await Util.getStringValuesSF('userid');
    try {
      final productList = http.MultipartRequest(
          'POST', Uri.parse('${Util.baseurl}profile.php'));
      productList.fields['userid'] = userid;
      productList.fields['client'] = Util.clientName;
      final snd = await productList.send();
      final response = await http.Response.fromStream(snd);
      if (response.statusCode == 200) {
        var dec = jsonDecode(response.body);
        if (dec['success']) {
          if (dec['contactus'].length > 0) {
            contactUs.add(ContactUsModel(
                email: dec['contactus'][0]['email'],
                mobile: dec['contactus'][0]['mobilenumber'],
                address: dec['contactus'][0]['address']));
          }
          if (userid != '' && dec['profile'].length > 0) {
            profile.add(ProfileModel(
                email: dec['profile'][0]['email'],
                mobile: dec['profile'][0]['mobile'],
                address: dec['profile'][0]['address'],
                name: dec['profile'][0]['name'],
                image: dec['profile'][0]['image']));
          }
          shareApp = dec['shareapp']['msg'];
        }
      }
    } catch (e) {
      Util.logDebug(e);
    }
    if (mounted) {
      setState(() {
        if (userid.toString() == 'null' || userid == '') {
          log = true;
        } else {
          log = false;
        }
      });
    }
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
          padding: EdgeInsets.fromLTRB(0, 0, 0, Platform.isAndroid ? 0 : 20),
          child: Scaffold(
            key: scaffoldKey,
            backgroundColor: Palette.background,
            body: SafeArea(child: checkConnection()),
            bottomSheet: Container(
              color: Palette.white,
              height: 50,
              child: const NavigationItemBar(
                state: 4,
              ),
            ),
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
    return Padding(
      padding: const EdgeInsets.all(40.0),
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 90, 0, 0),
            child: Column(
              children: [
                Card(
                  color: Palette.white,
                  shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(10.0),
                          topRight: Radius.circular(10.0))),
                  child: Container(
                    decoration: BoxDecoration(
                        color: Palette.white,
                        borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(10.0),
                            topRight: Radius.circular(10.0))),
                    child: Column(
                      children: [
                        profile.isNotEmpty
                            ? Container(
                                decoration: BoxDecoration(
                                  color: Palette.color1,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(10.0),
                                  child: Column(
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.fromLTRB(
                                            0, 0, 0, 10),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              profile[0].name.toUpperCase(),
                                              style: Util.txt(Palette.proTxt,
                                                  16, FontWeight.w500),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.fromLTRB(
                                            0, 0, 0, 10),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              profile[0].email,
                                              style: Util.txt(Palette.proTxt,
                                                  14, FontWeight.w500),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.fromLTRB(
                                            0, 0, 0, 10),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              profile[0].mobile,
                                              style: Util.txt(Palette.proTxt,
                                                  14, FontWeight.w500),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.fromLTRB(
                                            0, 0, 0, 10),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Flexible(
                                                child: Text(
                                              profile[0].address,
                                              style: Util.txt(Palette.proTxt,
                                                  14, FontWeight.w500),
                                            )),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            : Container(),
                        ListTile(
                          leading:
                              const Icon(MaterialCommunityIcons.truck_outline),
                          title: Text(
                            'My orders',
                            style: Util.txt(Palette.black, 14, FontWeight.w500),
                          ),
                          trailing: const Icon(Icons.navigate_next),
                          dense: true,
                          contentPadding:
                              const EdgeInsets.fromLTRB(12, 0, 0, 0),
                          onTap: () {
                            if (log) {
                              Util.showDog(
                                  context, 'Please Login to view MY orders');
                            } else {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          const MyOrdersList()));
                            }
                          },
                        ),
                        const Divider(
                          height: 1,
                        ),
                        ListTile(
                          leading: const Icon(AntDesign.customerservice),
                          title: Text(
                            'Contact us',
                            style: Util.txt(Palette.black, 14, FontWeight.w500),
                          ),
                          trailing: Icon(showCont
                              ? Icons.keyboard_arrow_down
                              : Icons.navigate_next),
                          dense: true,
                          contentPadding:
                              const EdgeInsets.fromLTRB(12, 0, 0, 0),
                          onTap: () {
                            if (contactUs.isNotEmpty) {
                              setState(() {
                                showCont ? showCont = false : showCont = true;
                              });
                            }
                          },
                        ),
                        showCont && contactUs.isNotEmpty
                            ? Container(
                                decoration: BoxDecoration(
                                    border: Border(
                                        top: BorderSide(color: Palette.orange),
                                        bottom:
                                            BorderSide(color: Palette.orange))),
                                child: Column(
                                  children: [
                                    ListTile(
                                      // leading: Icon(Feather.user),
                                      title: GestureDetector(
                                          onTap: () {
                                            if (contactUs[0].email != '') {
                                              Util.launchEmail(
                                                  contactUs[0].email,
                                                  'WEMart Global');
                                            }
                                          },
                                          child: Text(
                                            contactUs[0].email,
                                            style: Util.txt(Palette.proTxt, 14,
                                                FontWeight.w500),
                                          )),
                                      dense: true,
                                      contentPadding: const EdgeInsets.fromLTRB(
                                          12, 0, 0, 0),
                                    ),
                                    ListTile(
                                      // leading: Icon(Feather.user),
                                      title: GestureDetector(
                                          onTap: () {
                                            if (contactUs[0].mobile != '') {
                                              Util.phoneCall(
                                                  contactUs[0].mobile);
                                            }
                                          },
                                          child: Text(
                                            contactUs[0].mobile,
                                            style: Util.txt(Palette.proTxt, 14,
                                                FontWeight.w500),
                                          )),
                                      dense: true,
                                      contentPadding: const EdgeInsets.fromLTRB(
                                          12, 0, 0, 0),
                                    ),
                                    // ListTile(
                                    //   // leading: Icon(Feather.user),
                                    //   title: Text(contactUs[0].address,style: Util.txt(Palette.proTxt, 14, FontWeight.w500),),
                                    //   dense: true,
                                    //   contentPadding: EdgeInsets.fromLTRB(12, 0, 0, 0),
                                    // ),
                                  ],
                                ),
                              )
                            : Container(),
                        const Divider(
                          height: 1,
                        ),
                        ListTile(
                          leading: const Icon(MaterialCommunityIcons.truck_outline),
                          title: Text(
                            'shipping and delivery',
                            style: Util.txt(Palette.black, 14, FontWeight.w500),
                          ),
                          trailing: Icon(showCont1
                              ? Icons.keyboard_arrow_down
                              : Icons.navigate_next),
                          dense: true,
                          contentPadding:
                              const EdgeInsets.fromLTRB(12, 0, 0, 0),
                          onTap: () {
                            Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          const WebViewApp()));
                          },
                        ),
                        const Divider(
                          height: 1,
                        ),
                        ListTile(
                          leading: const Icon(MaterialCommunityIcons.shield_account_outline),
                          title: Text(
                            'Privacy policy',
                            style: Util.txt(Palette.black, 14, FontWeight.w500),
                          ),
                          trailing: Icon(showCont1
                              ? Icons.keyboard_arrow_down
                              : Icons.navigate_next),
                          dense: true,
                          contentPadding:
                              const EdgeInsets.fromLTRB(12, 0, 0, 0),
                          onTap: () {
                            Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          const PrivacyWebView()));
                          },
                        ),
                        const Divider(
                          height: 1,
                        ),
                        /*ListTile(
                          leading: const Icon(AntDesign.customerservice),
                          title: Text(
                            'cancellation and refund',
                            style: Util.txt(Palette.black, 14, FontWeight.w500),
                          ),
                          trailing: Icon(showCont2
                              ? Icons.keyboard_arrow_down
                              : Icons.navigate_next),
                          dense: true,
                          contentPadding:
                              const EdgeInsets.fromLTRB(12, 0, 0, 0),
                          onTap: () {
                            if (contactUs.isNotEmpty) {
                              setState(() {
                                showCont2 ? showCont2 = false : showCont2 = true;
                              });
                            }
                          },
                        ),
                        const Divider(
                          height: 1,
                        ),
                        ListTile(
                          leading: const Icon(AntDesign.customerservice),
                          title: Text(
                            'terms and conditions',
                            style: Util.txt(Palette.black, 14, FontWeight.w500),
                          ),
                          trailing: Icon(showCont3
                              ? Icons.keyboard_arrow_down
                              : Icons.navigate_next),
                          dense: true,
                          contentPadding:
                              const EdgeInsets.fromLTRB(12, 0, 0, 0),
                          onTap: () {
                            if (contactUs.isNotEmpty) {
                              setState(() {
                                showCont3 ? showCont3 = false : showCont3 = true;
                              });
                            }
                          },
                        ),
                        const Divider(
                          height: 1,
                        ),
                         ListTile(
                          leading: const Icon(AntDesign.customerservice),
                          title: Text(
                            'privacy policy',
                            style: Util.txt(Palette.black, 14, FontWeight.w500),
                          ),
                          trailing: Icon(showCont4
                              ? Icons.keyboard_arrow_down
                              : Icons.navigate_next),
                          dense: true,
                          contentPadding:
                              const EdgeInsets.fromLTRB(12, 0, 0, 0),
                          onTap: () {
                            if (contactUs.isNotEmpty) {
                              setState(() {
                                showCont4 ? showCont4 = false : showCont4 = true;
                              });
                            }
                          },
                        ),
                        const Divider(
                          height: 1,
                        ),*/
                        ListTile(
                          leading: Icon(Platform.isAndroid
                              ? Ionicons.share_social_outline
                              : Ionicons.share_outline),
                          title: Text(
                            'Share',
                            style: Util.txt(Palette.black, 14, FontWeight.w500),
                          ),
                          // trailing: const Icon(Icons.navigate_next),
                          dense: true,
                          contentPadding:
                              const EdgeInsets.fromLTRB(12, 0, 0, 0),
                          onTap: () {
                            if (shareApp != '') {
                              Util.shareMsg(shareApp);
                            }
                          },
                        ),
                        const Divider(
                          height: 1,
                        ),
                        log
                            ? ListTile(
                                leading: const Icon(Ionicons.log_in_outline),
                                title: Text(
                                  'Login',
                                  style: Util.txt(
                                      Palette.black, 14, FontWeight.w500),
                                ),
                                dense: true,
                                contentPadding:
                                    const EdgeInsets.fromLTRB(12, 0, 0, 0),
                                onTap: () {
                                  c.nav.value = 0;
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => const Login(
                                                share: {'nav': 3},
                                              )));
                                },
                              )
                            : Column(
                                children: [
                                  ListTile(
                                    leading:
                                        const Icon(Ionicons.log_out_outline),
                                    title: Text(
                                      'Logout',
                                      style: Util.txt(
                                          Palette.black, 14, FontWeight.w500),
                                    ),
                                    onTap: logoutConfirm,
                                    dense: true,
                                    contentPadding:
                                        const EdgeInsets.fromLTRB(12, 0, 0, 0),
                                  ),
                                  const Divider(
                                    height: 1,
                                  ),
                                  ListTile(
                                    leading: const Icon(MaterialCommunityIcons
                                        .account_remove_outline),
                                    title: Text(
                                      'Delete Account',
                                      style: Util.txt(
                                          Palette.black, 14, FontWeight.w500),
                                    ),
                                    onTap: confirmMsg,
                                    dense: true,
                                    contentPadding:
                                        const EdgeInsets.fromLTRB(12, 0, 0, 0),
                                  ),
                                ],
                              ),
                        // Divider(height: 1,),
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),
          // Row(mainAxisAlignment: MainAxisAlignment.center,
          //   children: [
          //     Badge(
          //       position: BadgePosition(bottom: 6,start: 90),
          //       badgeColor: Colors.white,
          //       padding: EdgeInsets.all(0.0),
          //       badgeContent: IconButton(icon: Icon(Icons.camera_alt,color: Palette.proBack,size: 20.0,), onPressed: (){
          //         setState(() {
          //           // getImage(ImageSource.gallery);
          //         });
          //       },
          //         padding: EdgeInsets.all(0.0),),
          //       child: _avatarImage(),
          //     ),
          //   ],
          // ),
        ],
      ),
    );
  }

  logOut() async {
    Util.addStringToSF('userid','','');
    c.cart.value = 0;
    Util.customDialog('Logged out', '', context);
    getData();
    // Navigator.push(context, MaterialPageRoute(builder: (context)=>Login()));
  }

  logoutConfirm() {
    if (Platform.isAndroid) {
      showAnimatedDialog(
        context: context,
        barrierDismissible: true,
        builder: (BuildContext context) {
          return ClassicGeneralDialogWidget(
            titleText: 'Logout',
            contentText: 'Are you sure you want to logout',
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
                    logOut();
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
                  'Logout',
                  style: Util.txt(Colors.black, 16, FontWeight.w500),
                ),
                content: Text(
                  'Are you sure you want to logout',
                  style: Util.txt(Colors.black, 14, FontWeight.w400),
                ),
                actions: [
                  CupertinoButton(
                    child: Text('Cancel',
                        style: Util.txt(Colors.black, 16, FontWeight.w500)),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                  CupertinoButton(
                    child: Text('Ok',
                        style: Util.txt(Colors.black, 16, FontWeight.w500)),
                    onPressed: () {
                      Navigator.pop(context);
                      logOut();
                    },
                  ),
                ],
              ));
    }
  }

  confirmMsg() {
    if (Platform.isAndroid) {
      showAnimatedDialog(
        context: context,
        barrierDismissible: true,
        builder: (BuildContext context) {
          return ClassicGeneralDialogWidget(
            titleText: 'Delete',
            contentText: 'Are you sure want to delete account',
            actions: [
              TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text(
                    'Cancel',
                    style: Util.txt(Palette.black, 16, FontWeight.w500),
                  )),
              TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    deleteAccount();
                  },
                  child: Text(
                    'Ok',
                    style: Util.txt(Palette.black, 16, FontWeight.w500),
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
          builder: (BuildContext context) => CupertinoAlertDialog(
                title: Text(
                  'Delete',
                  style: Util.txt(Palette.black, 16, FontWeight.w500),
                ),
                content: Text(
                  'Are you sure want to delete account',
                  style: Util.txt(Palette.black, 15, FontWeight.w500),
                ),
                actions: [
                  CupertinoButton(
                    child: Text('Cancel',
                        style: Util.txt(Palette.black, 16, FontWeight.w500)),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                  CupertinoButton(
                    child: Text('Ok',
                        style: Util.txt(Palette.black, 16, FontWeight.w500)),
                    onPressed: () {
                      Navigator.pop(context);
                      deleteAccount();
                    },
                  ),
                ],
              ));
    }
  }

  deleteAccount() async {
    Util.showProgress(context);
    String userid = await Util.getStringValuesSF('userid');
    try {
      final del = http.MultipartRequest(
          'POST', Uri.parse('${Util.baseurl}delete-account.php'));
      del.fields['userid'] = userid;
      del.fields['client'] = Util.clientName;
      var a = await del.send();
      var ar = await http.Response.fromStream(a);
      if (ar.statusCode == 200) {
        Util.dismissDialog(scaffoldKey.currentContext!);
        var dec = jsonDecode(ar.body);
        if (dec['success']) {
          deleteId();
        } else {
          // Util.showToast('Account not deleted');
        }
      } else {
        Util.dismissDialog(scaffoldKey.currentContext!);
        Util.customDialog('Try again', '', scaffoldKey.currentContext!);
      }
    } catch (e) {
      Util.logDebug(e);
    }
  }

  deleteId() async {
    Util.addStringToSF('userid', '','');
    c.cart.value = 0;
    Util.customDialog('Account deleted', '', context);
    getData();
    // Navigator.push(context, MaterialPageRoute(builder: (context)=>const Login()));
  }
  }
