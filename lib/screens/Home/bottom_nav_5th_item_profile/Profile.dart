import 'dart:convert';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import '../../../Connectivity/No_internet.dart';
import '../../../Connectivity/connectivity_provider.dart';
import '../../../Model/Product_Model.dart';
import '../../../utilities/AppManagement.dart';
import '../../../utilities/constants.dart';
import '../../../utilities/images.dart';
import '../../../utilities/palette.dart';
import '../../../utilities/web_privacy.dart';
import '../../../utilities/web_view.dart';
import '../../Credentials/Login.dart';
import '../../Payment/OrderList.dart';
import '../bottom_nav_bar.dart';

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
          // padding: EdgeInsets.fromLTRB(0, 0, 0, Platform.isAndroid ? 0 : 20),
          padding: EdgeInsets.all(0),
          child: Scaffold(
            key: scaffoldKey,
            backgroundColor: Palette.background,
            body: SafeArea(child: checkConnection()),
            // bottomSheet: Container(
            //   // color: Palette.white,
            //   height: Util.bottomNavBarHeight,
            //   child: const NavigationItemBar(
            //     state: 4,
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
    return SingleChildScrollView(
      child: Column(
        children: [
          // profile.isNotEmpty
          //     ? Container(
          //         decoration: BoxDecoration(
          //           color: Palette.color1,
          //           borderRadius: BorderRadius.circular(10),
          //         ),
          //         child: Padding(
          //           padding: const EdgeInsets.all(10.0),
          //           child: Column(
          //             children: [
          //               Padding(
          //                 padding: const EdgeInsets.fromLTRB(
          //                     0, 0, 0, 10),
          //                 child: Row(
          //                   mainAxisAlignment:
          //                       MainAxisAlignment.center,
          //                   children: [
          //                     Text(
          //                       profile[0].name.toUpperCase(),
          //                       style: Util.txt(Palette.proTxt,
          //                           16, FontWeight.w500),
          //                     ),
          //                   ],
          //                 ),
          //               ),
          //               Padding(
          //                 padding: const EdgeInsets.fromLTRB(
          //                     0, 0, 0, 10),
          //                 child: Row(
          //                   mainAxisAlignment:
          //                       MainAxisAlignment.center,
          //                   children: [
          //                     Text(
          //                       profile[0].email,
          //                       style: Util.txt(Palette.proTxt,
          //                           14, FontWeight.w500),
          //                     ),
          //                   ],
          //                 ),
          //               ),
          //               Padding(
          //                 padding: const EdgeInsets.fromLTRB(
          //                     0, 0, 0, 10),
          //                 child: Row(
          //                   mainAxisAlignment:
          //                       MainAxisAlignment.center,
          //                   children: [
          //                     Text(
          //                       profile[0].mobile,
          //                       style: Util.txt(Palette.proTxt,
          //                           14, FontWeight.w500),
          //                     ),
          //                   ],
          //                 ),
          //               ),
          //               Padding(
          //                 padding: const EdgeInsets.fromLTRB(
          //                     0, 0, 0, 10),
          //                 child: Row(
          //                   mainAxisAlignment:
          //                       MainAxisAlignment.center,
          //                   children: [
          //                     Flexible(
          //                         child: Text(
          //                       profile[0].address,
          //                       style: Util.txt(Palette.proTxt,
          //                           14, FontWeight.w500),
          //                     )),
          //                   ],
          //                 ),
          //               ),
          //             ],
          //           ),
          //         ),
          //       )
          //     : Container(),
          //
          SizedBox(
              width: MediaQuery.of(context).size.width*0.7,
              child: Image.asset(Images.logo)), // Update path as necessar
          clickableCard(
            child: ListTile(
              splashColor: Palette.blue_tone_light_4.withOpacity(0.1),
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
          ),
          clickableCard(
            child: ListTile(
              splashColor: Palette.blue_tone_light_4.withOpacity(0.1),
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
          ),

          if (showCont && contactUs.isNotEmpty) Container(
                  // decoration: BoxDecoration(
                  //     border: Border(
                  //         top: BorderSide(color: Palette.orange),
                  //         bottom:
                  //             BorderSide(color: Palette.orange))),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        clickableCard(
                          isMenu: true,
                          child: ListTile(
                            splashColor: Palette.blue_tone_light_4.withOpacity(0.1),
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
                        ),
                        clickableCard(
                          isMenu: true,
                          child: ListTile(
                            splashColor: Palette.blue_tone_light_4.withOpacity(0.1),
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
                        ),

                        SizedBox(height: 30,)
                        // ListTile(
                        //   // leading: Icon(Feather.user),
                        //   title: Text(contactUs[0].address,style: Util.txt(Palette.proTxt, 14, FontWeight.w500),),
                        //   dense: true,
                        //   contentPadding: EdgeInsets.fromLTRB(12, 0, 0, 0),
                        // ),
                      ],
                    ),
                  ),
                ) else Container(),

          clickableCard(
            child: ListTile(
              splashColor: Palette.blue_tone_light_4.withOpacity(0.1),
              leading: const Icon(MaterialCommunityIcons.truck_outline),
              title: Text(
                'Shipping and Delivery',
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
          ),
          clickableCard(
            child: ListTile(
              splashColor: Palette.blue_tone_light_4.withOpacity(0.1),
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
          clickableCard(
            child: ListTile(
              splashColor: Palette.blue_tone_light_4.withOpacity(0.1),
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
          ),
          
          if (log) clickableCard(
            cardColor: Palette.blue_tone_light_5.withBlue(100).withOpacity(0.2),
            child: ListTile(
              splashColor: Palette.blue_tone_light_4.withOpacity(0.1),
                    leading: Icon(Ionicons.log_in_outline, color: Palette.white,),
                    title: Text(
                      'Login',
                      style: Util.txt(
                          Palette.white, 14, FontWeight.w500),
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
                  ),
          ) else Column(
                  children: [
                    clickableCard(
                      cardColor: Palette.blue_tone_light_4.withOpacity(0.3),
                      child: ListTile(
                        splashColor: Palette.blue_tone_light_4.withOpacity(0.1),
                        leading:
                            const Icon(Ionicons.log_out_outline, color: Colors.white,),
                        title: Text(
                          'Logout',
                          style: Util.txt(
                              Palette.white, 14, FontWeight.w500),
                        ),
                        onTap: logoutConfirm,
                        dense: true,
                        contentPadding:
                            const EdgeInsets.fromLTRB(12, 0, 0, 0),
                      ),
                    ),
                    clickableCard(
                      cardColor: Palette.blue_tone_light_5.withOpacity(0.5),
                      child: ListTile(
                        splashColor: Palette.blue_tone_light_4.withOpacity(0.1),
                        leading: const Icon(MaterialCommunityIcons
                            .account_remove_outline, color: Colors.white,),
                        title: Text(
                          'Delete Account',
                          style: Util.txt(
                              Palette.white, 14, FontWeight.w500),
                        ),
                        onTap: confirmMsg,
                        dense: true,
                        contentPadding:
                            const EdgeInsets.fromLTRB(12, 0, 0, 0),
                      ),
                    ),
                  ],
                ),
          SizedBox(height: 35,)
          // Divider(height: 1,),
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
      showDialog(
        context: context,
        barrierDismissible: true, // Allows dismissal by tapping outside the dialog
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(
              'Logout',
              style: Util.txt(Palette.black, 16, FontWeight.w600),
            ),
            content: Text(
              'Are you sure you want to logout',
              style: Util.txt(Palette.black, 16, FontWeight.w400),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context); // Closes the dialog
                },
                child: Text(
                  'Cancel',
                  style: Util.txt(Palette.black, 16, FontWeight.w600),
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context); // Closes the dialog
                  logOut(); // Calls the logout function
                },
                child: Text(
                  'Ok',
                  style: Util.txt(Palette.black, 16, FontWeight.w600),
                ),
              ),
            ],
            // Optional: Add elevation and shape to match your design
            elevation: 24.0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.0),
            ),
          );
        },
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
  
  Widget clickableCard({required child, Color cardColor=Colors.white, bool isMenu=false}){
    return Padding(
      padding: isMenu? EdgeInsets.symmetric(horizontal: 28, vertical: 8) : EdgeInsets.all(8.0),
      child: Card(
          color: cardColor,
          elevation: 15,
          shadowColor: Palette.blue_tone_light_4,
          child: child
      ),
    );
  }

  confirmMsg() {
    if (Platform.isAndroid) {
      showDialog(
        context: context,
        barrierDismissible: true, // Allows the dialog to be dismissed by tapping outside of it
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(
              'Delete',
              style: Util.txt(Palette.black, 16, FontWeight.w500),
            ),
            content: Text(
              'Are you sure you want to delete the account?',
              style: Util.txt(Palette.black, 16, FontWeight.w400),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context); // Closes the dialog
                },
                child: Text(
                  'Cancel',
                  style: Util.txt(Palette.black, 16, FontWeight.w500),
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context); // Closes the dialog
                  deleteAccount(); // Calls the function to delete the account
                },
                child: Text(
                  'Ok',
                  style: Util.txt(Palette.black, 16, FontWeight.w500),
                ),
              ),
            ],
            // Optional: Add elevation and shape to match your design
            elevation: 24.0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.0),
            ),
          );
        },
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
