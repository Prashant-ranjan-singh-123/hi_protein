// ignore_for_file: unnecessary_null_comparison
import 'dart:convert';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:pinput/pinput.dart';
import 'package:hi_protein/utilities/images.dart';
import 'package:sms_autofill/sms_autofill.dart';
import 'package:email_validator/email_validator.dart';
import 'package:provider/provider.dart';
import '../../Connectivity/No_internet.dart';
import '../../Connectivity/connectivity_provider.dart';
import '../../utilities/constants.dart';
import '../../utilities/palette.dart';
import '../Home/bottom_nav_1st_item_home/home_detailed_view.dart';
import '../Home/bottom_nav_2nd_item_category/CategoryListDetailedPage.dart';
import '../Home/bottom_nav_5th_item_profile/Profile.dart';
import '../Home/bottom_nav_3rd_item_search/Search.dart';

class Login extends StatefulWidget {
  const Login({Key? key, required this.share}) : super(key: key);
  final Map<String, dynamic> share;
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final GlobalKey<ScaffoldState> _scaffoldkey = GlobalKey<ScaffoldState>();
  TextEditingController name = TextEditingController();
  TextEditingController otp = TextEditingController();
  final focusNode = FocusNode();
  bool showPass = false, rSend = true;

  @override
  void initState() {
    SmsAutoFill().listenForCode;
    Provider.of<ConnectivityProvider>(context, listen: false).startMonitoring();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        navHome();
        return true;
      },
      child: Scaffold(
        key: _scaffoldkey,
        backgroundColor: Palette.white,
        appBar: AppBar(
          backgroundColor: Palette.white,
          elevation: 0,
          leading: IconButton(
            onPressed: navHome,
            icon: Icon(
              Ionicons.arrow_back,
              color: Palette.black,
            ),
          ),
        ),
        body: SafeArea(child: checkConnection()),
      ),
    );
  }

  Widget checkConnection() {
    return Consumer<ConnectivityProvider>(
      builder: (consumerContext, model, child) {
        return model.isOnline?page():const NoInternet();
      },
    );
  }

  page() {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: ListView(
        children: [
          SizedBox(
            width: 200,
            height: 200,
            child: Image.asset(
              Images.logo,
              fit: BoxFit.fitHeight,
              width: 200,
            ),
          ),
          const SizedBox(
            height: 60,
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 22),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 0, 0, 10),
                  child: TextField(
                    controller: name,
                    cursorColor: Palette.black,
                    keyboardType: TextInputType.text,
                    textInputAction: TextInputAction.next,
                    style: Util.txt(Palette.black, 14, FontWeight.w400),
                    decoration: InputDecoration(
                      hintText: 'Enter Email or Mobile number(India)',
                      hintStyle: Util.txt(Palette.black, 14, FontWeight.w400),
                      fillColor: Palette.white,
                      enabledBorder: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: Palette.orange, width: 1.6)),
                      focusedBorder: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: Palette.orange, width: 1.6)),
                      border: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: Palette.orange, width: 1.6)),
                      isDense: true,
                      // filled: true,
                      contentPadding: const EdgeInsets.all(20.0),
                    ),
                  ),
                ),
                /*Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: OutlinedButton(onPressed: validate,
                    style: ButtonStyle(
                      side: MaterialStateProperty.all(BorderSide(color: Palette.black)),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      padding: MaterialStateProperty.all(const EdgeInsets.fromLTRB(10, 0, 10, 0)),
                    ),
                    child: Text(showPass?'Resend OTP':'Get OTP',style: Util.txt(Palette.black, 15, FontWeight.w500),),
                  ),
                ),
                if(showPass)
                  Column(
                    children: [
                      pinPutStyle(),
                      Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: OutlinedButton(onPressed: validateOTP,
                          style: ButtonStyle(
                            side: MaterialStateProperty.all(BorderSide(color: Palette.black)),
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            padding: MaterialStateProperty.all(EdgeInsets.fromLTRB(4, 0, 4, 0)),
                          ),
                          child: Text('Login',style: Util.txt(Palette.black, 15, FontWeight.w500),),
                        ),
                      ),
                    ],
                  ),*/
                if (showPass)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Text(
                              'Please enter the OTP send to ${name.text}',
                              style: Util.txt(
                                  Palette.gray, 14, FontWeight.normal)),
                        ),
                        pinPutStyle(),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(0, 20, 0, 30),
                          child: Row(
                            children: [
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: validateOTP,
                                  style: ButtonStyle(
                                    backgroundColor: MaterialStateProperty.all(
                                        Palette.orange),
                                    // tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                    padding: MaterialStateProperty.all(
                                        const EdgeInsets.all(10)),
                                  ),
                                  child: Text(
                                    'Login',
                                    style: Util.txt(
                                        Palette.white, 16, FontWeight.w500),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            InkWell(
                                onTap: () {
                                  otp.text = '';
                                  validate();
                                },
                                child: Text(
                                  'Resend OTP',
                                  style: Util.txt(
                                      Palette.orange, 14, FontWeight.normal),
                                )),
                            // if(!rSend)
                            // Text(_start>9?'00:$_start':'00:0$_start',style: Util.txt(Palette.gray, 14, FontWeight.normal),),
                          ],
                        ),
                      ],
                    ),
                  ),
                if (!showPass)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0, 20, 0, 20),
                    child: Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: validate,
                            style: ButtonStyle(
                              backgroundColor:
                                  MaterialStateProperty.all(Palette.orange),
                              elevation: MaterialStateProperty.all(0),
                              // tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              padding: MaterialStateProperty.all(
                                  const EdgeInsets.all(10)),
                            ),
                            child: Text(
                              'Continue',
                              style:
                                  Util.txt(Palette.white, 16, FontWeight.w500),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(
                  height: 10,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  Widget pinPutStyle() {
    const length = 6;
    const borderColor = Colors.red;
    const errorColor = Color.fromRGBO(255, 234, 238, 1);
    //const fillColor = Colors.white;
    const fillColor1 = Colors.grey;
    final defaultPinTheme = PinTheme(
      width: 64,
      height: 50,
      textStyle: Util.txt(Palette.black, 22, FontWeight.w500),
      decoration: BoxDecoration(
        color: fillColor1,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.transparent),
      ),
    );
    return SizedBox(
      height: 50,
      child: Pinput(
        // androidSmsAutofillMethod: AndroidSmsAutofillMethod.smsRetrieverApi,
        length: length,
        controller: otp,
        focusNode: focusNode,
        defaultPinTheme: defaultPinTheme,
        onCompleted: (pin) {},
        onChanged: (p) {
          if (p.length == 4) {}
        },
        focusedPinTheme: defaultPinTheme.copyWith(
          height: 50,
          width: 64,
          decoration: defaultPinTheme.decoration!.copyWith(
            border: Border.all(color: borderColor),
          ),
        ),
        errorPinTheme: defaultPinTheme.copyWith(
          decoration: BoxDecoration(
            color: errorColor,
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }

  validate() {
    FocusScope.of(context).requestFocus(FocusNode());
    if (isNumeric(name.text)) {
      if (name.text.isNotEmpty && name.text.length == 10) {
        getOtp('', name.text);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              "Invalid phone number",
            ),
          ),
        );
      }
    } else {
      final bool isValid = EmailValidator.validate(name.text);
      if (isValid) {
        getOtp(name.text, '');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              "Invalid Email Id",
            ),
          ),
        );
      }
    }
    /*if (name.text.isNotEmpty) {
      if (name.text.isEmail) {
        final bool isValid = EmailValidator.validate(name.text);
        if (isValid) {
          getOtp(name.text, '');
        } else {
          Util.showDog(context, 'Invalid Email');
        }
      } 
     if (name.text.isNotEmpty && name.text.length == 10) {
        getOtp('', name.text);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              "Invalid Mobile Number",
            ),
          ),
        );
      }
    } else {
      if (name.text.isEmpty) {
        Util.showDog(context, 'Please Enter Email or Mobile number');
      }
    }*/
  }

  validateOTP() {
    FocusScope.of(context).requestFocus(FocusNode());
    if (name.text.isNotEmpty && otp.text.isNotEmpty) {
      if (name.text.isEmail) {
        create(0);
      } else {
        create(1);
      }
    } else {
      if (name.text.isEmpty) {
        Util.showDog(context, 'Please Enter Email or Mobile number');
      } else if (otp.text.isEmpty) {
        Util.showDog(context, 'Please Enter OTP');
      }
    }
  }

  getOtp(String email, mobile) async {
    Util.showProgress(context);
    String temsig = '';
    if (Platform.isAndroid) {
      temsig = await SmsAutoFill().getAppSignature;
      SmsAutoFill().listenForCode;
    }
    final otpCheck = http.MultipartRequest(
        'POST', Uri.parse('${Util.baseurl}otp-request.php'));
    otpCheck.fields['email'] = email;
    otpCheck.fields['mobile'] = mobile;
    otpCheck.fields['hashcode'] = temsig;
    otpCheck.fields['client'] = Util.clientName;
    otpCheck.fields['platform'] = Platform.isAndroid ? 'android' : 'ios';
    final snd = await otpCheck.send();
    final response = await http.Response.fromStream(snd);
    try {
      if (response.statusCode == 200) {
        Util.dismissDialog(_scaffoldkey.currentContext!);
        var dec = jsonDecode(response.body);
        if (dec['success']){
          setState(() {
            focusNode.requestFocus();
            showPass = true;
          });
          Util.showDog(_scaffoldkey.currentContext!, dec['message']);
        } else {
          Util.showDog(_scaffoldkey.currentContext!, dec['message']);
        }
      } else {
        Util.dismissDialog(_scaffoldkey.currentContext!);
        Util.showDog(_scaffoldkey.currentContext!, 'Try again');
      }
    } catch (e) {
      Util.logDebug(e);
      return false;
    }
  }

  create(int a) async {
    Util.showProgress(context);
    try {
      final loginCheck =http.MultipartRequest('POST', Uri.parse('${Util.baseurl}login.php'));
      loginCheck.fields['email'] = name.text;
      loginCheck.fields['otp'] = otp.text;
      loginCheck.fields['type'] = a.toString();
      loginCheck.fields['client'] = Util.clientName;
      print('Otp Sent is: ${otp.text}');
      final snd = await loginCheck.send();
      final response = await http.Response.fromStream(snd);
      if (response.statusCode == 200) {
        Util.dismissDialog(_scaffoldkey.currentContext!);
        var dec = jsonDecode(response.body);
        print('Otp Check Response data: ${dec}');
        if (dec['success']) {
          Util.addStringToSF('userid', dec['response'][0]['userid'].toString(),'');
          Util.updateNotification();
          navHome();
          // confirmMsg('Success',dec['message'],1);
        }else {
          confirmMsg('Fail', dec['message'], 0);
        }
      } else {
        Util.dismissDialog(_scaffoldkey.currentContext!);
        print('Otp Check Response Error Code: ${response.statusCode}');
      }
    } catch (e) {
      Util.logDebug(e);
      print('Api Error');
    }
  }
  confirmMsg(String title, body, int a) {
    if (Platform.isAndroid) {
      showDialog(
        context: context,
        barrierDismissible: true, // Allows the dialog to be dismissed by tapping outside
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(
              title,
              style: Util.txt(Palette.black, 16, FontWeight.w500),
            ),
            content: Text(
              body,
              style: Util.txt(Palette.black, 14, FontWeight.w400),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context); // Closes the dialog
                  if (a == 1) {
                    navHome(); // Navigate to home if condition is met
                  }
                },
                child: Text(
                  'Ok',
                  style: Util.txt(Palette.black, 16, FontWeight.w500),
                ),
              ),
            ],
          );
        },
      );
    } else {
      showCupertinoDialog(
          context: context,
          builder: (BuildContext context) => CupertinoAlertDialog(
                title: Text(
                  title,
                  style: Util.txt(Palette.black, 16, FontWeight.w500),
                ),
                content: Text(
                  body,
                  style: Util.txt(Palette.black, 15, FontWeight.w500),
                ),
                actions: [
                  CupertinoButton(
                    child: Text('Ok',
                        style: Util.txt(Palette.black, 16, FontWeight.w500)),
                    onPressed: () {
                      Navigator.pop(context);
                      if (a == 1) {
                        navHome();
                      }
                    },
                  ),
                ],
              ));
    }
  }

  navHome() {
    // Navigator.push(context, MaterialPageRoute(builder: (context)=>const HomeScreen()));
    if (widget.share['nav'] == 0) {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => ProductList(
                  name: widget.share['name'], state: widget.share['state'])));
    } else if (widget.share['nav'] == 1) {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => Search(
                    share: {'state': 1, 'search': widget.share['search']},
                  )));
    } else if (widget.share['nav'] == 2) {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => DetailedView(
                  name: widget.share['name'],
                  id: widget.share['id'],
                  state: widget.share['state'])));
    } else if (widget.share['nav'] == 3) {
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => const Profile()));
    }
  }

  bool isNumeric(String s) {
    if (s == null) {
      return false;
    }
    return double.tryParse(s) != null;
  }
}
