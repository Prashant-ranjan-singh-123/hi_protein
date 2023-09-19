import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animated_dialog/flutter_animated_dialog.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:hi_protein/main.dart';
import 'package:html/parser.dart' show parse;
import 'package:http/http.dart' as http;
import 'package:webview_flutter/webview_flutter.dart';

import '../../utilities/constants.dart';
import '../../utilities/palette.dart';
import '../Home/CartList.dart';
import 'OrderList.dart';

//change to it false when your application is in production.
bool isTesting = false;
final Set<JavascriptChannel> jsChannels = {
  JavascriptChannel(
      name: 'Print',
      onMessageReceived: (JavascriptMessage message) {
        print('message is :${message.message.toString()}');
        
      }),
      
};

class PaymentScreen extends StatefulWidget {
  const PaymentScreen(
      {Key? key,
      required this.encryptedstring,
      required this.accescodestring,
      required this.addressvalue,
      required this.tidvalue,
      required this.orderidvalue,
      required this.totalAmountvalue,
      required this.mobilenumbervalue,
      required this.shippingchargesvalue,
      required this.shipperstringis,
      required this.totaltimevalue,
      required this.discountvalue})
      : super(key: key);
  final String encryptedstring;
  final String accescodestring;
  final String addressvalue;
  final String tidvalue;
  final String orderidvalue;
  final String totalAmountvalue;
  final String mobilenumbervalue;
  final String shippingchargesvalue;
  final String shipperstringis;
  final String totaltimevalue;
  final String discountvalue;
  @override
  PaymentScreenState createState() => PaymentScreenState();
}

class PaymentScreenState extends State<PaymentScreen> {
  String filePath = 'assets/images/blank.html';
  final GlobalKey<ScaffoldState> _scafoldkey = GlobalKey<ScaffoldState>();
  bool isredirected = false, isloading = false;
  List username = [];
  String? url; //encryptedstring = '', accesscodestring = '';
  String? random13DigitNumber;
  String? orderid6DigitNumber;
  String orderstatus = '', trackingidvalue = '';
  bool initializedPayment = false;
  String errorMessage = "";
  String loadingMessage = "";
  late WebViewController controller;
  String cancelUrl = "https://redbag.vensframe.com/app/ccavenueResponse.php";
  String redirectUrl = "https://redbag.vensframe.com/app/ccavenueResponse.php";
  String requestInitiateUrl = "https://redbag.vensframe.com/app/ccavenueRequest.php";
  @override
  void initState() {
   // generateRandomNumber();
    Future.delayed(const Duration(microseconds: 1)).then((value) => initAsync());
    super.initState();
  }
  initAsync() async {
    Util.showProgress(context);
    //Generating payment order and fetching URLs for the payment
    try {
      errorMessage = "";
      loadingMessage =
          "Please Do not close window,\nprocessing your request....";
      setState(() {});
      //final res = await initPayment(); //(widget.amount ~/ 100).toString()
      url = "https://${isTesting ? "test" : "secure"}.ccavenue.com/transaction.do?command=initiateTransaction&encRequest=${widget.encryptedstring}&access_code=${widget.accescodestring}";
      initializedPayment = true;
      setState(() {});
    } catch (e) {
      errorMessage = "Something went wrong";
    } finally {
      loadingMessage = "";
      setState(() {});
    }
  }
  /*initPayment() async {
    //print(widget.amount);
    var url = requestInitiateUrl;
    Uri uri = Uri.parse(url);
    var res = await http.post(uri, body: {
      'tid': random13DigitNumber!,
      'merchant_id': '2661103',
      'order_id': orderid6DigitNumber!,
      'amount': '10',
      'currency': 'INR',
      'redirect_url': redirectUrl,
      'cancel_url': cancelUrl,
      'language': 'EN',
      'billing_name': 'Nageswara Rao',
      'billing_address': 'borabanda',
      'billing_city': 'Hyderabad',
      'billing_state': 'telangana',
      'billing_zip': '500018',
      'billing_country': 'in',
      'billing_tel': '9346762968',
      'billing_email': 'vajram88@gmail.com',
    });
    if (res.statusCode == 200) {
      var jsonData = jsonDecode(res.body);
      //encryptedstring = jsonData['encryptdata'];
      //accesscodestring = jsonData['access'];
      //print('jsonData: $jsonData');
      // print('accesscode:$accesscodestring');
      return jsonData;
    } else {
      throw Exception();
    }
  }*/
  @override
  Widget build(context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        key: _scafoldkey,
        appBar: AppBar(
          title: Text("Payment Screen",style: Util.txt(Palette.black, 16, FontWeight.w500)),
          elevation: 0,
            leading: IconButton(
              onPressed: (){
                backButtonAction();
                },
              icon: Icon(
                Ionicons.arrow_back,
                color: Palette.black,
              ),
            ),
        ),
        body: initializedPayment
            ? Platform.isAndroid
                ? WebView(
                    initialUrl: url,
                    javascriptMode: JavascriptMode.unrestricted,
                    javascriptChannels: jsChannels,
                    onWebViewCreated: (c) async {
                      controller = c;
                      setState(() {});
                    },
                    onPageFinished: (url) async {
                      if(isloading == false){Util.dismissDialog(_scafoldkey.currentContext!);isloading = true;}
                      if (url == redirectUrl) {
                        // handleURLRedirect(url);
                        if(isredirected == false){
                          loadHtmlFromAssets();
                          redirectUrlMethodAndroid();
                          isredirected = true;
                        }
                      }
                      if (url == cancelUrl) {}
                    },
                    navigationDelegate: (NavigationRequest nav) async {
                      if (nav.url == redirectUrl) {
                        return nav.url == url
                            ? NavigationDecision.navigate
                            : NavigationDecision.prevent;
                        //return NavigationDecision.navigate;
                      }
                      if (nav.url == cancelUrl) {
                        return NavigationDecision.navigate;
                      }
                      return NavigationDecision.prevent;
                    },
                  )
                : Column(
                    children: [
                      Expanded(
                          child: WebView(
                        javascriptMode: JavascriptMode.unrestricted,
                        javascriptChannels: jsChannels,
                        initialUrl: url,
                        onWebViewCreated: (c) async {
                          controller = c;
                          setState(() {});
                        },
                        onPageFinished: (url) async {
                          if(isloading == false){Util.dismissDialog(_scafoldkey.currentContext!);isloading = true;}
                          if (url == redirectUrl) {
                            if(isredirected == false){
                              print('redirecturl');
                              loadHtmlFromAssets();
                              redirectUrlMethodIos();
                              isredirected = true;
                            }
                            // Uri uri = Uri.parse(redirectUrl);
                            // var res = await http.post(uri);
    
                            // print(res);
                            // handleURLRedirect(url);
                            /*if (redirectUrl.contains("status")) {
                              var token = redirectUrl.split("status")[1];
                              print(token);
                              //_prefs.setString('token', token);
                            }*/
                            //var htmlContent = await controller.runJavascript('window.document.getElementsByText');
                            // Uri uri = Uri.parse(redirectUrl);
                            // var res = await http.post(uri);
                            //print(htmlContent);
                            //var jsonData = jsonDecode(res.body);
                            //redirectUrlMethod();
                          }
                          if (url == cancelUrl) {}
                        },
                        // onPageFinished: (String url) {
                        //   SystemChannels.textInput.invokeMethod('TextInput.hide');
                        //   if (url.contains(redirectUrl)) {
                        //     print('nag');
                        //     redirectUrlMethod();
                        //   }
                        //   // print('Page finished loading: $redirectUrl');
                        // },
                        // javascriptChannels: jsChannels,
                        // onWebViewCreated: (c) async {
                        //   print('created');
                        //   controller = c;
                        //   setState(() {});
                        // },
                      ))
                    ],
                  )
            : (loadingMessage.isNotEmpty
                ? const Center(
                    child: CircularProgressIndicator(),
                  )
                : (errorMessage.isNotEmpty
                    ? Center(
                        child: Text(
                          errorMessage,
                          style: const TextStyle(
                            color: Colors.red,
                          ),
                        ),
                      )
                    : const SizedBox.shrink())),
      ),
    );
  }
  loadHtmlFromAssets() async {
    String filehtmlcontents = await rootBundle.loadString(filePath);
    controller.loadUrl(Uri.dataFromString(filehtmlcontents,mimeType: 'text/html',encoding: Encoding.getByName('utf-8')).toString());

  }
  void generateRandomNumber() {
    //var loopCount = 1;
    final random = Random();
    // for (var i = 0; i < loopCount; i++) {
    final doubleValue = random.nextDouble();
    random13DigitNumber = doubleValue.toString().substring(5);
    orderid6DigitNumber = doubleValue.toString().substring(12);
    // }
  }
  redirectUrlMethodIos() async {
    String htmlContent = await controller.runJavascriptReturningResult('document.documentElement.outerHTML');
   // print(htmlContent);
    final parsedJson = parse(htmlContent);
    var jsonData = parsedJson.body?.text;
   // print('jsonData: $jsonData');
    controller.clearCache();
    final result = jsonDecode(jsonData!);
   // print('result: $result');
   // final jsonResponse = json.decode(formatHtmlString(result));
   // print(jsonResponse);
    username = result['status'];
    for (String statusEntry in username) {
      if (statusEntry.startsWith('order_status=')) {
        orderstatus = statusEntry.substring('order_status='.length);
      }
      if (statusEntry.startsWith('tracking_id=')) {
        trackingidvalue = statusEntry.substring('tracking_id='.length);
      }
    }
    /*if (orderstatus == 'Aborted' ||
        orderstatus == 'Failure' ||
        orderstatus == 'Invalid')*/
    //  print('Order Status: $orderstatus');
    //  print('tracking order: $trackingidvalue');
    if (orderstatus == 'Success') {
      updata();
    } else {
      uDateTemCart('0');
      showResponseAlert(orderstatus);
    }
  }
  redirectUrlMethodAndroid() async {
    String htmlContent = await controller
        .runJavascriptReturningResult('document.documentElement.outerHTML');
    final parsedJson = parse(htmlContent);
    var jsonData = parsedJson.body?.text;
    controller.clearCache();
    final result = jsonDecode(jsonData!);
    final jsonResponse = json.decode(formatHtmlString(result));
    username = jsonResponse['status'];
    for (String statusEntry in username) {
      if (statusEntry.startsWith('order_status=')) {
        orderstatus = statusEntry.substring('order_status='.length);
      }
      if (statusEntry.startsWith('tracking_id=')) {
        trackingidvalue = statusEntry.substring('tracking_id='.length);
      }
    }
     // print('Order Status: $orderstatus');
    //  print('tracking order: $trackingidvalue');
    if (orderstatus == 'Success') {
      updata();
    } else {
      uDateTemCart('0');
      showResponseAlert(orderstatus);
    }
  }

  void handleURLRedirect(String initialURL) async {
    try {
      var response = await http.post(Uri.parse(initialURL));
      if (response.statusCode == 200) {
        print('Response1: ${response.body}');
      } else {
        print('Error: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  String formatHtmlString(String string) {
    return string
        .replaceAll("<html><head></head><body>", "") // Paragraphs
        .replaceAll("</body></html>", "") // Line Breaks
        .trim(); // Whitespace
  }

  void showResponseAlert(String responseMessage) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('order status'),
          content: Text(responseMessage),
          actions: <Widget>[
            ElevatedButton(
                child: const Text('OK'),
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const CartList()));
                  //Navigator.of(context).pop();
                }),
          ],
        );
      },
    );
  }
  backButtonAction() async {
     showDialog(
          context: context,
          builder: (context) => AlertDialog(
            content: Text('Do you want to cancel the order?',
                style: Util.txt(Palette.black, 16, FontWeight.w500)),
            actions: <Widget>[
              TextButton(
                onPressed: (){uDateTemCart('0');Navigator.of(context).pop(false);showResponseAlert('Failed');},
                    //SystemNavigator.pop(), //Navigator.of(context).pop(true)
                child: Text('Yes',style: Util.txt(Palette.black, 14, FontWeight.w500)),
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
        );
  }
  uDateTemCart(String status) async {
    Util.logDebug('status is $status');
    String userid = await Util.getStringValuesSF('userid');
    String stam;
    Map<String, String> map = {
      'userid': userid,
      'address': widget.addressvalue,
      'totalamount': widget.totaltimevalue,
      'tid': widget.tidvalue, //tid //Rpayorderid
      'status': status,
      'orderid': widget.orderidvalue,
      'client': Util.clientName
    };
    var respon = await http.post(Uri.parse('${Util.baseurl}updatetempcart.php'),
        body: jsonEncode(map));
    stam = respon.statusCode.toString();
    try {
      if (respon.statusCode == 200) {
         print('sucess $status');
      } else {
        Map<String, String> map = {
          'email': userid,
          'instance': 'order id',
          'error': '$stam not updated after getting orderid'
        };
        var response = await http.post(Uri.parse('${Util.baseurl}logs.php'),
            body: jsonEncode(map));
        if (response.statusCode == 200) {
          //print(status);
        }
      }
    } catch (e) {
      Map<String, String> map = {
        'email': userid,
        'instance': 'payment error',
        'error': e.toString()
      };
      var response = await http.post(Uri.parse('${Util.baseurl}logs.php'),
          body: jsonEncode(map));
      if (response.statusCode == 200) {
        //print(status);
      }
    }
  }

  void updata() async {
    // Util.showProgress(context);
    String tempo;
    String userid = await Util.getStringValuesSF('userid');
    Map<String, dynamic> map = {
      'userid': userid,
      'mobilenumber': widget.mobilenumbervalue,
      'orderid': widget.orderidvalue,
      'address': widget.addressvalue,
      'paymentstatus': trackingidvalue, //tracking_id //paymentstatus //1
      'totalamount': widget.totalAmountvalue,
      'Rpayorderid': widget.tidvalue, //tid  //Rpayorderid
      'orderstatus': 'Placed',
      'feedbackstatus': '0',
      'client': Util.clientName,
      'shippingCharges': widget.shippingchargesvalue,
      'shipper': widget.shipperstringis,
      'eDate': widget.totaltimevalue, //widget.share['estimate_time'],
      'discount': widget.discountvalue
    };
    var respo = await http.post(Uri.parse('${Util.baseurl}placeorder.php'),
        body: jsonEncode(map));
    tempo = respo.statusCode.toString();
    try {
      if (respo.statusCode == 200) {
        // Util.dismissDialog(_scaffoldkey.currentContext!);
        var decc = jsonDecode(respo.body);
        if (decc['success'] == 'true') {
          //showDlog(decc['message']);
          showResponseAlert1(decc['message']);
        } else {
          Map<String, String> map = {
            'email': userid,
            'instance': 'orderdata Insertion',
            'error': tempo + decc['message']
          };
          var respo = await http.post(Uri.parse('${Util.baseurl}logs.php'),
              body: jsonEncode(map));
          if (respo.statusCode == 200) {}
        }
      } else {
        Map<String, String> map = {
          'email': userid,
          'instance': 'orderdata Insertion',
          'error': tempo
        };
        var respo = await http.post(Uri.parse('${Util.baseurl}logs.php'),
            body: jsonEncode(map));
        if (respo.statusCode == 200) {}
      }
    } catch (e) {
      print('error ---- $e');
      // Util.dismissDialog(_scaffoldkey.currentContext!);
      Map<String, String> map = {
        'email': userid,
        'instance': 'orderdata Insertion',
        'error': e.toString()
      };
      var respo = await http.post(Uri.parse('${Util.baseurl}logs.php'),
          body: jsonEncode(map));
      if (respo.statusCode == 200) {}
    }
  }

  void showResponseAlert1(String responseMessage) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Payment Success'),
          content: Text(responseMessage),
          actions: <Widget>[
            ElevatedButton(
                child: const Text('OK'),
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const MyOrdersList()));
                  //Navigator.of(context).pop();
                }),
          ],
        );
      },
    );
  }

  showDlog(String message) {
    showAnimatedDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return ClassicGeneralDialogWidget(
          titleText: 'Payment Success',
          contentText: message,
          actions: [
            TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const MyOrdersList()));
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
  }
   Future<bool> _onWillPop() async {
    return (await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            content: Text('Do you want to cancel the order?',
                style: Util.txt(Palette.black, 16, FontWeight.w500)),
            actions: <Widget>[
              TextButton(
                onPressed: (){uDateTemCart('0');Navigator.of(context).pop(false);showResponseAlert('Failed');},
                    //SystemNavigator.pop(), //Navigator.of(context).pop(true)
                child: Text('Yes',style: Util.txt(Palette.black, 14, FontWeight.w500)),
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
}