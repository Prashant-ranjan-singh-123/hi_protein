// // ignore_for_file: unrelated_type_equality_checks
//
// import 'dart:async';
// import 'dart:convert';
// import 'dart:io';
// import 'dart:math';
//
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_animated_dialog/flutter_animated_dialog.dart';
// import 'package:flutter_inappwebview/flutter_inappwebview.dart';
// import 'package:flutter_vector_icons/flutter_vector_icons.dart';
// import 'package:html/parser.dart' show parse;
// import 'package:http/http.dart' as http;
// import 'package:webview_flutter/webview_flutter.dart';
//
// import '../../utilities/constants.dart';
// import '../../utilities/palette.dart';
// import '../Home/CartList.dart';
// import 'OrderList.dart';
//
// //change to it false when your application is in production.
// bool isTesting = false;
// final Set<JavascriptChannel> jsChannels = {
//   JavascriptChannel(
//     name: 'Print',
//     onMessageReceived: (JavascriptMessage message) {
//       // Handle JavaScript messages here
//       print('Message from JavaScript: ${message.message}');
//     },
//   ),
// };
//
// class PaymentScreen extends StatefulWidget {
//   const PaymentScreen(
//       {Key? key,
//       required this.encryptedstring,
//       required this.accescodestring,
//       required this.addressvalue,
//       required this.tidvalue,
//       required this.orderidvalue,
//       required this.totalAmountvalue,
//       required this.mobilenumbervalue,
//       required this.shippingchargesvalue,
//       required this.shipperstringis,
//       required this.totaltimevalue,
//       required this.discountvalue})
//       : super(key: key);
//   final String encryptedstring;
//   final String accescodestring;
//   final String addressvalue;
//   final String tidvalue;
//   final String orderidvalue;
//   final String totalAmountvalue;
//   final String mobilenumbervalue;
//   final String shippingchargesvalue;
//   final String shipperstringis;
//   final String totaltimevalue;
//   final String discountvalue;
//   @override
//   PaymentScreenState createState() => PaymentScreenState();
// }
//
// class PaymentScreenState extends State<PaymentScreen> {
//   String finalhtmlContent = '';
//   final GlobalKey<ScaffoldState> _scafoldkey = GlobalKey<ScaffoldState>();
//   bool isloading = false;
//   List username = [];
//   String? url; //encryptedstring = '', accesscodestring = '';
//   //String? random13DigitNumber;
//   //String? orderid6DigitNumber;
//   String orderstatus = '', trackingidvalue = '';
//   bool initializedPayment = false;
//   String errorMessage = "";
//   String loadingMessage = "";
//   //late WebViewController controller;
//   late InAppWebViewController webViewController;
//   double progress = 0;
//   String cancelUrl = "https://redbag.vensframe.com/app/ccavenueResponse.php";
//   String redirectUrl = "https://redbag.vensframe.com/app/ccavenueResponse.php";
//   String requestInitiateUrl = "https://redbag.vensframe.com/app/ccavenueRequest.php";
//   @override
//   void initState() {
//    // generateRandomNumber();
//     Future.delayed(const Duration(microseconds: 1)).then((value) => initAsync());
//     super.initState();
//   }
//   @override
//   void dispose() {
//     webViewController;
//     // close the webview here
//     super.dispose();
//   }
//   initAsync() async {
//     Util.showProgress(context);
//     try {
//       errorMessage = "";
//       loadingMessage = "Please Do not close window,\nprocessing your request....";
//       setState(() {});
//       //final res = await initPayment(); //(widget.amount ~/ 100).toString()
//       url = "https://${isTesting ? "test" : "secure"}.ccavenue.com/transaction.do?command=initiateTransaction&encRequest=${widget.encryptedstring}&access_code=${widget.accescodestring}";
//       initializedPayment = true;
//       setState(() {});
//     } catch (e) {
//       errorMessage = "Something went wrong";
//     } finally {
//       loadingMessage = "";
//       setState(() {});
//     }
//   }
//   @override
//   Widget build(context) {
//     return WillPopScope(
//       onWillPop: _onWillPop,
//       child: Scaffold(
//         key: _scafoldkey,
//         appBar: AppBar(
//           title: Text("Payment Screen",style: Util.txt(Palette.black, 16, FontWeight.w500)),
//           elevation: 0,
//             leading: IconButton(
//               onPressed: (){
//                 backButtonAction();
//                 },
//               icon: Icon(
//                 Ionicons.arrow_back,
//                 color: Palette.black,
//               ),
//             ),
//         ),
//         body: initializedPayment
//             ? Platform.isAndroid
//                 ? InAppWebView(
//                   initialUrlRequest: URLRequest(url: Uri.parse(url!),),
//                   onWebViewCreated: (InAppWebViewController controller) {webViewController = controller;},
//                   onLoadStop: (controller, url) async {
//                     finalhtmlContent = await controller.evaluateJavascript(source: "new XMLSerializer().serializeToString(document);");
//                     url.toString() == redirectUrl.toString()?redirectedAndroidMethod():'';
//                     if(isloading == false){Util.dismissDialog(_scafoldkey.currentContext!);isloading = true;}},
//                   onProgressChanged: (InAppWebViewController controller, int progress) {
//                     setState(() {this.progress = progress / 100;});},)
//                 : Column(
//                     children: [
//                       Expanded(
//                           child:InAppWebView(
//                   initialUrlRequest: URLRequest(url: Uri.parse(url!),),
//                   onWebViewCreated: (InAppWebViewController controller) {webViewController = controller;},
//                   onLoadStop: (controller, url) async {
//                     finalhtmlContent = await controller.evaluateJavascript(source: "new XMLSerializer().serializeToString(document);");
//                     url.toString() == redirectUrl.toString()?redirectediOSMethod():'';
//                     if(isloading == false){Util.dismissDialog(_scafoldkey.currentContext!);isloading = true;}},
//                   onProgressChanged: (InAppWebViewController controller, int progress) {
//                     setState(() {this.progress = progress / 100;});},))
//                     ],
//                   )
//             : (loadingMessage.isNotEmpty
//                 ? const Center(
//                     child: CircularProgressIndicator(),
//                   )
//                 : (errorMessage.isNotEmpty
//                     ? Center(
//                         child: Text(
//                           errorMessage,
//                           style: const TextStyle(
//                             color: Colors.red,
//                           ),
//                         ),
//                       )
//                     : const SizedBox.shrink())),
//       ),
//     );
//   }
//   loadHtmlFromAssets() async {
//     String filehtmlcontents = await rootBundle.loadString('assets/images/blank.html');
//     //controller.loadUrl(Uri.dataFromString(filehtmlcontents,mimeType: 'text/html',encoding: Encoding.getByName('utf-8')).toString());
//     webViewController.loadData(data:filehtmlcontents,mimeType: 'text/html',encoding:'utf-8');
//   }
//
//   void generateRandomNumber() {
//     //var loopCount = 1;
//     /*final random = Random();
//     // for (var i = 0; i < loopCount; i++) {
//     final doubleValue = random.nextDouble();
//     random13DigitNumber = doubleValue.toString().substring(5);
//     orderid6DigitNumber = doubleValue.toString().substring(12);*/
//     // }
//   }
//   void redirectediOSMethod(){
//     loadHtmlFromAssets();
//     redirectUrlMethodIos();
//   }
//   redirectUrlMethodIos() async {
//     //String htmlContent = await controller.runJavascriptReturningResult('document.documentElement.outerHTML');
//     //final parsedJson = parse(htmlContent);
//     final parsedJson = parse(finalhtmlContent);
//     var jsonData = parsedJson.body?.text;
//     webViewController.clearCache();
//     final result = jsonDecode(jsonData!);
//     username = result['status'];
//     for (String statusEntry in username) {
//       if (statusEntry.startsWith('order_status=')) {
//         orderstatus = statusEntry.substring('order_status='.length);
//       }
//       if (statusEntry.startsWith('tracking_id=')) {
//         trackingidvalue = statusEntry.substring('tracking_id='.length);
//       }
//     }
//     if (orderstatus == 'Success') {
//       updata();
//     } else {
//       uDateTemCart('0');
//       showResponseAlert(orderstatus);
//     }
//   }
//   void redirectedAndroidMethod(){
//     loadHtmlFromAssets();
//     redirectUrlMethodAndroid();
//   }
//   redirectUrlMethodAndroid() async {
//    // String htmlContent = await controller.runJavascriptReturningResult('document.documentElement.outerHTML');
//     final parsedJson = parse(finalhtmlContent);
//     var jsonData = parsedJson.body?.text;
//     webViewController.clearCache();
//     final result = jsonDecode(jsonData!);
//     username = result['status'];
//     for (String statusEntry in username) {
//       if (statusEntry.startsWith('order_status=')) {
//         orderstatus = statusEntry.substring('order_status='.length);
//       }
//       if (statusEntry.startsWith('tracking_id=')) {
//         trackingidvalue = statusEntry.substring('tracking_id='.length);
//       }
//     }
//     if (orderstatus == 'Success') {
//       updata();
//     } else {
//       uDateTemCart('0');
//       showResponseAlert(orderstatus);
//     }
//   }
//
//   void handleURLRedirect(String initialURL) async {
//     try {
//       var response = await http.post(Uri.parse(initialURL));
//       if (response.statusCode == 200) {
//       } else {
//       }
//     } catch (e){}
//
//   }
//
//   String formatHtmlString(String string) {
//     return string
//         .replaceAll("<html><head></head><body>", "") // Paragraphs
//         .replaceAll("</body></html>", "") // Line Breaks
//         .trim(); // Whitespace
//   }
//
//   void showResponseAlert(String responseMessage) {
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: const Text('order status'),
//           content: Text(responseMessage),
//           actions: <Widget>[
//             ElevatedButton(
//                 child: const Text('OK'),
//                 onPressed: () {
//                   Navigator.push(
//                       context,
//                       MaterialPageRoute(
//                           builder: (context) => const CartList()));
//                   //Navigator.of(context).pop();
//                 }),
//           ],
//         );
//       },
//     );
//   }
//   backButtonAction() async {
//      showDialog(
//           context: context,
//           builder: (context) => AlertDialog(
//             content: Text('Do you want to cancel the order?',
//                 style: Util.txt(Palette.black, 16, FontWeight.w500)),
//             actions: <Widget>[
//               TextButton(
//                 onPressed: (){uDateTemCart('0');Navigator.of(context).pop(false);showResponseAlert('Failed');},
//                     //SystemNavigator.pop(), //Navigator.of(context).pop(true)
//                 child: Text('Yes',style: Util.txt(Palette.black, 14, FontWeight.w500)),
//               ),
//               TextButton(
//                 onPressed: () => Navigator.of(context).pop(false),
//                 child: Text(
//                   'No',
//                   style: Util.txt(Palette.black, 14, FontWeight.w500),
//                 ),
//               ),
//             ],
//           ),
//         );
//   }
//   uDateTemCart(String status) async {
//     Util.logDebug('status is $status');
//     String userid = await Util.getStringValuesSF('userid');
//     String stam;
//     Map<String, String> map = {
//       'userid': userid,
//       'address': widget.addressvalue,
//       'totalamount': widget.totaltimevalue,
//       'Rpayorderid': widget.tidvalue, //tid //Rpayorderid
//       'status': status,
//       'orderid': widget.orderidvalue,
//       'client': Util.clientName
//     };
//     var respon = await http.post(Uri.parse('${Util.baseurl}updatetempcart.php'),
//         body: jsonEncode(map));
//     stam = respon.statusCode.toString();
//     try {
//       if (respon.statusCode == 200) {
//       } else {
//         Map<String, String> map = {
//           'email': userid,
//           'instance': 'order id',
//           'error': '$stam not updated after getting orderid'
//         };
//         var response = await http.post(Uri.parse('${Util.baseurl}logs.php'),
//             body: jsonEncode(map));
//         if (response.statusCode == 200){
//         }
//       }
//     } catch (e) {
//       Map<String, String> map = {
//         'email': userid,
//         'instance': 'payment error',
//         'error': e.toString()
//       };
//       var response = await http.post(Uri.parse('${Util.baseurl}logs.php'),
//           body: jsonEncode(map));
//       if (response.statusCode == 200) {
//       }
//     }
//   }
//   void updata() async {
//     // Util.showProgress(context);
//     String tempo;
//     String userid = await Util.getStringValuesSF('userid');
//     Map<String, dynamic> map = {
//       'userid': userid,
//       'mobilenumber': widget.mobilenumbervalue,
//       'orderid': widget.orderidvalue,
//       'address': widget.addressvalue,
//       'paymentstatus': trackingidvalue, //tracking_id //paymentstatus //1
//       'totalamount': widget.totalAmountvalue,
//       'Rpayorderid': widget.tidvalue, //tid  //Rpayorderid
//       'orderstatus': 'Placed',
//       'feedbackstatus': '0',
//       'client': Util.clientName,
//       'shippingCharges': widget.shippingchargesvalue,
//       'shipper': widget.shipperstringis,
//       'eDate': widget.totaltimevalue, //widget.share['estimate_time'],
//       'discount': widget.discountvalue
//     };
//     var respo = await http.post(Uri.parse('${Util.baseurl}placeorder.php'),
//         body: jsonEncode(map));
//     tempo = respo.statusCode.toString();
//     try {
//       if (respo.statusCode == 200) {
//         // Util.dismissDialog(_scaffoldkey.currentContext!);
//         var decc = jsonDecode(respo.body);
//         if (decc['success'] == 'true') {
//           //showDlog(decc['message']);
//           showResponseAlert1(decc['message']);
//         } else {
//           Map<String, String> map = {
//             'email': userid,
//             'instance': 'orderdata Insertion',
//             'error': tempo + decc['message']
//           };
//           var respo = await http.post(Uri.parse('${Util.baseurl}logs.php'),
//               body: jsonEncode(map));
//           if (respo.statusCode == 200) {}
//         }
//       } else {
//         Map<String, String> map = {
//           'email': userid,
//           'instance': 'orderdata Insertion',
//           'error': tempo
//         };
//         var respo = await http.post(Uri.parse('${Util.baseurl}logs.php'),
//             body: jsonEncode(map));
//         if (respo.statusCode == 200) {}
//       }
//     } catch (e) {
//       // Util.dismissDialog(_scaffoldkey.currentContext!);
//       Map<String, String> map = {
//         'email': userid,
//         'instance': 'orderdata Insertion',
//         'error': e.toString()
//       };
//       var respo = await http.post(Uri.parse('${Util.baseurl}logs.php'),
//           body: jsonEncode(map));
//       if (respo.statusCode == 200) {}
//     }
//   }
//
//   void showResponseAlert1(String responseMessage) {
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: const Text('Payment Success'),
//           content: Text(responseMessage),
//           actions: <Widget>[
//             ElevatedButton(
//                 child: const Text('OK'),
//                 onPressed: () {
//                   Navigator.pop(context);
//                   Navigator.push(
//                       context,
//                       MaterialPageRoute(
//                           builder: (context) => const MyOrdersList()));
//                   //Navigator.of(context).pop();
//                 }),
//           ],
//         );
//       },
//     );
//   }
//
//   showDlog(String message) {
//     showAnimatedDialog(
//       context: context,
//       barrierDismissible: false,
//       builder: (BuildContext context) {
//         return ClassicGeneralDialogWidget(
//           titleText: 'Payment Success',
//           contentText: message,
//           actions: [
//             TextButton(
//                 onPressed: () {
//                   Navigator.pop(context);
//                   Navigator.push(
//                       context,
//                       MaterialPageRoute(
//                           builder: (context) => const MyOrdersList()));
//                 },
//                 child: Text(
//                   'Ok',
//                   style: Util.txt(Palette.black, 16, FontWeight.w600),
//                 )),
//           ],
//         );
//       },
//       animationType: DialogTransitionType.slideFromLeftFade,
//       curve: Curves.fastOutSlowIn,
//       duration: const Duration(seconds: 1),
//     );
//   }
//    Future<bool> _onWillPop() async {
//     return (await showDialog(
//           context: context,
//           builder: (context) => AlertDialog(
//             content: Text('Do you want to cancel the order?',
//                 style: Util.txt(Palette.black, 16, FontWeight.w500)),
//             actions: <Widget>[
//               TextButton(
//                 onPressed: (){uDateTemCart('0');Navigator.of(context).pop(false);showResponseAlert('Failed');},
//                     //SystemNavigator.pop(), //Navigator.of(context).pop(true)
//                 child: Text('Yes',style: Util.txt(Palette.black, 14, FontWeight.w500)),
//               ),
//               TextButton(
//                 onPressed: () => Navigator.of(context).pop(false),
//                 child: Text(
//                   'No',
//                   style: Util.txt(Palette.black, 14, FontWeight.w500),
//                 ),
//               ),
//             ],
//           ),
//         )) ??
//         false;
//   }
// }


import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:html/parser.dart' show parse;
import 'package:http/http.dart' as http;

import '../../utilities/constants.dart';
import '../../utilities/palette.dart';
import '../Home/bottom_nav_4th_item_cart/CartList.dart';
import 'OrderList.dart';

bool isTesting = false;

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({
    Key? key,
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
    required this.discountvalue,
  }) : super(key: key);

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
  String finalHtmlContent = '';
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool isLoading = false;
  List<String> username = [];
  String? url;
  String orderStatus = '', trackingIdValue = '';
  bool initializedPayment = false;
  String errorMessage = "";
  String loadingMessage = "";
  late InAppWebViewController webViewController;
  double progress = 0;
  String cancelUrl = "https://redbag.vensframe.com/app/ccavenueResponse.php";
  String redirectUrl = "https://redbag.vensframe.com/app/ccavenueResponse.php";
  String requestInitiateUrl = "https://redbag.vensframe.com/app/ccavenueRequest.php";

  @override
  void initState() {
    Future.delayed(const Duration(microseconds: 1)).then((value) => initAsync());
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  initAsync() async {
    Util.showProgress(context);
    try {
      errorMessage = "";
      loadingMessage = "Please Do not close window,\nprocessing your request....";
      setState(() {});
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

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          title: Text("Payment Screen", style: Util.txt(Palette.black, 16, FontWeight.w500)),
          elevation: 0,
          leading: IconButton(
            onPressed: () {
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
            ? InAppWebView(
          initialUrlRequest: URLRequest(url: Uri.parse(url!)),
          onWebViewCreated: (InAppWebViewController controller) {
            webViewController = controller;
            _addJavaScriptHandlers(controller);
          },
          onLoadStop: (controller, url) async {
            finalHtmlContent = await controller.evaluateJavascript(source: "new XMLSerializer().serializeToString(document);");
            url.toString() == redirectUrl.toString() ? redirectedAndroidMethod() : '';
            if (!isLoading) {
              Util.dismissDialog(_scaffoldKey.currentContext!);
              isLoading = true;
            }
          },
          onProgressChanged: (InAppWebViewController controller, int progress) {
            setState(() {
              this.progress = progress / 100;
            });
          },
        )
            : Column(
          children: [
            Expanded(
              child: InAppWebView(
                initialUrlRequest: URLRequest(url: Uri.parse(url!)),
                onWebViewCreated: (InAppWebViewController controller) {
                  webViewController = controller;
                  _addJavaScriptHandlers(controller);
                },
                onLoadStop: (controller, url) async {
                  finalHtmlContent = await controller.evaluateJavascript(source: "new XMLSerializer().serializeToString(document);");
                  url.toString() == redirectUrl.toString() ? redirectedIOSMethod() : '';
                  if (!isLoading) {
                    Util.dismissDialog(_scaffoldKey.currentContext!);
                    isLoading = true;
                  }
                },
                onProgressChanged: (InAppWebViewController controller, int progress) {
                  setState(() {
                    this.progress = progress / 100;
                  });
                },
              ),
            ),
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

  void _addJavaScriptHandlers(InAppWebViewController controller) {
    controller.addJavaScriptHandler(
      handlerName: 'Print',
      callback: (args) {
        print('Message from JavaScript: ${args[0]}');
      },
    );
  }

  loadHtmlFromAssets() async {
    String fileHtmlContents = await rootBundle.loadString('assets/images/blank.html');
    webViewController.loadData(data: fileHtmlContents, mimeType: 'text/html', encoding: 'utf-8');
  }

  void generateRandomNumber() {
    // Your implementation
  }

  void redirectedIOSMethod() {
    loadHtmlFromAssets();
    redirectUrlMethodIos();
  }

  redirectUrlMethodIos() async {
    final parsedJson = parse(finalHtmlContent);
    var jsonData = parsedJson.body?.text;
    webViewController.clearCache();
    final result = jsonDecode(jsonData!);
    username = result['status'];
    for (String statusEntry in username) {
      if (statusEntry.startsWith('order_status=')) {
        orderStatus = statusEntry.substring('order_status='.length);
      }
      if (statusEntry.startsWith('tracking_id=')) {
        trackingIdValue = statusEntry.substring('tracking_id='.length);
      }
    }
    if (orderStatus == 'Success') {
      updata();
    } else {
      uDateTemCart('0');
      showResponseAlert(orderStatus);
    }
  }

  void redirectedAndroidMethod() {
    loadHtmlFromAssets();
    redirectUrlMethodAndroid();
  }

  redirectUrlMethodAndroid() async {
    final parsedJson = parse(finalHtmlContent);
    var jsonData = parsedJson.body?.text;
    webViewController.clearCache();
    final result = jsonDecode(jsonData!);
    username = result['status'];
    for (String statusEntry in username) {
      if (statusEntry.startsWith('order_status=')) {
        orderStatus = statusEntry.substring('order_status='.length);
      }
      if (statusEntry.startsWith('tracking_id=')) {
        trackingIdValue = statusEntry.substring('tracking_id='.length);
      }
    }
    if (orderStatus == 'Success') {
      updata();
    } else {
      uDateTemCart('0');
      showResponseAlert(orderStatus);
    }
  }

  void handleURLRedirect(String initialURL) async {
    try {
      var response = await http.post(Uri.parse(initialURL));
      if (response.statusCode == 200) {
        // Handle success
      } else {
        // Handle error
      }
    } catch (e) {
      // Handle exception
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
          title: const Text('Order Status'),
          content: Text(responseMessage),
          actions: <Widget>[
            ElevatedButton(
                child: const Text('OK'),
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const CartList()));
                }),
          ],
        );
      },
    );
  }

  void backButtonAction() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        content: Text('Do you want to cancel the order?',
            style: Util.txt(Palette.black, 16, FontWeight.w500)),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              uDateTemCart('0');
              Navigator.of(context).pop(false);
              showResponseAlert('Failed');
            },
            child: Text('Yes', style: Util.txt(Palette.black, 14, FontWeight.w500)),
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
    String userId = await Util.getStringValuesSF('userid');
    String responseBody;
    Map<String, String> map = {
      'userid': userId,
      'address': widget.addressvalue,
      'totalamount': widget.totaltimevalue,
      'Rpayorderid': widget.tidvalue, //tid //Rpayorderid
      'status': status,
      'orderid': widget.orderidvalue,
      'client': Util.clientName
    };
    var response = await http.post(Uri.parse('${Util.baseurl}updatetempcart.php'),
        body: jsonEncode(map));
    responseBody = response.statusCode.toString();
    try {
      if (response.statusCode == 200) {
        print('updatetempcart value: ${response.body}');
        // Handle success
      } else {
        Map<String, String> map = {
          'email': userId,
          'instance': 'order id',
          'error': '$responseBody not updated after getting orderid'
        };
        var logResponse = await http.post(Uri.parse('${Util.baseurl}logs.php'),
            body: jsonEncode(map));
        if (logResponse.statusCode == 200) {}
      }
    } catch (e) {
      Map<String, String> map = {
        'email': userId,
        'instance': 'payment error',
        'error': e.toString()
      };
      var logResponse = await http.post(Uri.parse('${Util.baseurl}logs.php'),
          body: jsonEncode(map));
      if (logResponse.statusCode == 200) {}
    }
  }

  void updata() async {
    String responseBody;
    String userId = await Util.getStringValuesSF('userid');
    Map<String, dynamic> map = {
      'userid': userId,
      'mobilenumber': widget.mobilenumbervalue,
      'orderid': widget.orderidvalue,
      'address': widget.addressvalue,
      'paymentstatus': trackingIdValue, //tracking_id //paymentstatus //1
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
    var response = await http.post(Uri.parse('${Util.baseurl}placeorder.php'),
        body: jsonEncode(map));
    responseBody = response.statusCode.toString();
    try {
      if (response.statusCode == 200) {
        var decodedResponse = jsonDecode(response.body);
        if (decodedResponse['success'] == 'true') {
          showResponseAlert1(decodedResponse['message']);
        } else {
          Map<String, String> map = {
            'email': userId,
            'instance': 'orderdata Insertion',
            'error': responseBody + decodedResponse['message']
          };
          var logResponse = await http.post(Uri.parse('${Util.baseurl}logs.php'),
              body: jsonEncode(map));
          if (logResponse.statusCode == 200) {}
        }
      } else {
        Map<String, String> map = {
          'email': userId,
          'instance': 'orderdata Insertion',
          'error': responseBody
        };
        var logResponse = await http.post(Uri.parse('${Util.baseurl}logs.php'),
            body: jsonEncode(map));
        if (logResponse.statusCode == 200) {}
      }
    } catch (e) {
      Map<String, String> map = {
        'email': userId,
        'instance': 'orderdata Insertion',
        'error': e.toString()
      };
      var logResponse = await http.post(Uri.parse('${Util.baseurl}logs.php'),
          body: jsonEncode(map));
      if (logResponse.statusCode == 200) {}
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
                }),
          ],
        );
      },
    );
  }

  showDlog(String message) {
    showDialog(
      context: context,
      barrierDismissible: false, // Prevents dismissal by tapping outside
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Payment Success',
            style: Util.txt(Palette.black, 16, FontWeight.w600),
          ),
          content: Text(
            message,
            style: Util.txt(Palette.black, 14, FontWeight.w400),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Closes the dialog
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const MyOrdersList()),
                ); // Navigate to MyOrdersList
              },
              child: Text(
                'Ok',
                style: Util.txt(Palette.black, 16, FontWeight.w600),
              ),
            ),
          ],
        );
      },
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
            onPressed: () {
              uDateTemCart('0');
              Navigator.of(context).pop(false);
              showResponseAlert('Failed');
            },
            child: Text('Yes', style: Util.txt(Palette.black, 14, FontWeight.w500)),
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
