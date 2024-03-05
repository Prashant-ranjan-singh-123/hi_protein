import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class WebViewApp extends StatefulWidget {
  const WebViewApp({super.key});
  @override
  State<WebViewApp> createState() => _WebViewAppState();
}

class _WebViewAppState extends State<WebViewApp> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Razorpay'),
      ),
      body: Center(child: InAppWebView(
  initialUrlRequest: URLRequest(
    url: Uri.parse("https://merchant.razorpay.com/policy/MA26N4tjT6Cwcf/shipping"),
  ),
  onLoadStop: (controller, url) async {
    const String functionBody = """
        var p = new Promise(function (resolve, reject) {
           window.setTimeout(function() {
             if (x >= 0) {
               resolve(x);
             } else {
               reject(y);
             }
           }, 1000);
        });
        await p;
        return p;
      """;
    var result = await controller.callAsyncJavaScript(
        functionBody: functionBody,
        arguments: {'x': 49, 'y': 'error message'});

    result = await controller.callAsyncJavaScript(
        functionBody: functionBody,
        arguments: {'x': -49, 'y': 'error message'});
  },
), ),
    );
  }
  
}