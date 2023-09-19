import 'dart:convert';
import 'package:badges/badges.dart' as badge;
import 'package:flutter/material.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:get/get.dart';
import '../../utilities/AppManagement.dart';
import '../../utilities/constants.dart';
import '../../utilities/palette.dart';
import 'CartList.dart';
import 'CategoryList.dart';
import 'HomeScreen.dart';
import 'package:http/http.dart' as http;
import 'Profile.dart';
import 'Search.dart';

class NavigationItemBar extends StatefulWidget {
  const NavigationItemBar({Key? key, required this.state}) : super(key: key);
  final int state;
  @override
  _NavigationItemBarState createState() => _NavigationItemBarState();
}

class _NavigationItemBarState extends State<NavigationItemBar> {
  final Controller c = Get.put(Controller());
  @override
  void initState() {
    getData();
    super.initState();
  }
  getData() async {
    String userid = await Util.getStringValuesSF('userid');
    try {
      final productList = http.MultipartRequest(
          'POST', Uri.parse('${Util.baseurl}retrivecartlength.php'));
      productList.fields['userid'] = userid;
      productList.fields['client'] = Util.clientName;
      final snd = await productList.send();
      final response = await http.Response.fromStream(snd);
      if (response.statusCode == 200) {
        var dec = jsonDecode(response.body);
        if (dec['success']) {
          if (dec['count'] != null) {
            c.cart.value = dec['count'];
          }
        }
      }
    } catch (e) {
      Util.logDebug('nav Error $e');
    }
  }
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      left: false,
      right: false,
      top: false,
      child: Scaffold(
        body: Obx(() => Container(
              height: 50,
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(
                color: Palette.white,
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(10, 2, 10, 2),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    InkWell(
                        onTap: () => nav(0),
                        child: Card(
                          elevation: 0,
                          margin: EdgeInsets.zero,
                          child: Icon(
                            Feather.home,
                            size: 30,
                            color: widget.state == 0
                                ? Palette.black
                                : Palette.gray,
                          ),
                        )),
                    InkWell(
                        onTap: () => nav(1),
                        child: Card(
                          elevation: 0,
                          margin: EdgeInsets.zero,
                          child: Icon(
                            Ionicons.list,
                            size: 30,
                            color: widget.state == 1
                                ? Palette.black
                                : Palette.gray,
                          ),
                        )),
                    InkWell(
                        onTap: () => nav(2),
                        child: Card(
                          elevation: 0,
                          margin: EdgeInsets.zero,
                          child: Icon(
                            Ionicons.search_outline,
                            size: 30,
                            color: widget.state == 2
                                ? Palette.black
                                : Palette.gray,
                          ),
                        )),
                    InkWell(
                        onTap: () => nav(3),
                        child: badge.Badge(
                            shape: badge.BadgeShape.circle,
                            badgeColor: Palette.white,
                            borderSide:
                                BorderSide(color: Palette.black, width: 1),
                            position:
                                const badge.BadgePosition(end: -16, top: -12),
                            badgeContent: Center(
                                child: Text(c.cart.toString(),
                                    style: Util.txt(
                                        Palette.black, 16, FontWeight.w500),
                                    softWrap: true)),
                            child: Card(
                              elevation: 0,
                              margin: EdgeInsets.zero,
                              child: Icon(
                                Ionicons.cart_outline,
                                size: 30,
                                color: widget.state == 3
                                    ? Palette.black
                                    : Palette.gray,
                              ),
                            ))),
                    InkWell(
                        onTap: () => nav(4),
                        child: Card(
                          elevation: 0,
                          margin: EdgeInsets.zero,
                          child: Icon(
                            Feather.user,
                            size: 30,
                            color: widget.state == 4
                                ? Palette.black
                                : Palette.gray,
                          ),
                        ))
                  ],
                ),
              ),
            )),
      ),
    );
  }

  nav(int state) {
    if (state == 0) {
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => const HomeScreen()));
    } else if (state == 1) {
      Navigator.push(context,
          MaterialPageRoute(builder: (context) => const CategoryList()));
    } else if (state == 2) {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => const Search(
                    share: {'state': 0},
                  )));
    } else if (state == 3) {
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => const CartList()));
    } else if (state == 4) {
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => const Profile()));
    }
  }
}
