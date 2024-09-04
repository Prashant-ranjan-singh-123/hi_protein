import 'package:flutter/material.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:hi_protein/utilities/palette.dart';

class PrivacyWebView extends StatefulWidget {
  const PrivacyWebView({super.key});

  @override
  State<PrivacyWebView> createState() => _PrivacyWebViewState();
}

class _PrivacyWebViewState extends State<PrivacyWebView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Privacy Policy', style: TextStyle(color: Palette.black),),
        leading: IconButton(onPressed: (){
          Navigator.of(context).pop();
        }, icon: Icon(IconlyLight.arrowLeft, color: Palette.black,)),
      ),
      body: Center(child: InAppWebView(
  initialUrlRequest: URLRequest(
    url: Uri.parse("https://redbag.vensframe.com/privacy-hiprotein.html"),
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