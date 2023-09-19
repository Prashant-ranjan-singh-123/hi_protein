
import 'package:flutter/material.dart';

import '../utilities/constants.dart';
import '../utilities/palette.dart';




class NoInternet extends StatelessWidget {
  const NoInternet({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
     body: Center(
       child: Text('offline',style: Util.txt(Palette.black, 16, FontWeight.w500),),
     ),
    );
  }
}