import 'dart:convert';
import 'package:badges/badges.dart' as badge;
import 'package:badges/badges.dart';
import 'package:flutter/material.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:get/get.dart';
import '../../utilities/AppManagement.dart';
import '../../utilities/constants.dart';
import '../../utilities/palette.dart';
import 'bottom_nav_4th_item_cart/CartList.dart';
import 'bottom_nav_2nd_item_category/CategoryList.dart';
import 'HomeScreen.dart';
import 'package:http/http.dart' as http;
import 'bottom_nav_5th_item_profile/Profile.dart';
import 'bottom_nav_3rd_item_search/Search.dart';

class NavigationItemBar extends StatefulWidget {
  NavigationItemBar(
      {Key? key, required this.state, this.initialDishToSearch = ''})
      : super(key: key);
  final int state;
  String initialDishToSearch;
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
        print('Cart Value: ${dec}');
        if (dec['success']) {
          if (dec['count'] != null) {
            c.cart.value = dec['count'];
          }
        }
      }
    } catch (e) {
      Util.logDebug('nav Error $e');
      print('Error Occured');
    }
  }

  Widget _activeCard({required IconData icon, required String name}) {
    return Column(
      children: [
        Icon(icon, size: 24, color: Palette.blue_tone_light_4),
        Text(
          name,
          style: TextStyle(
              fontWeight: FontWeight.w600, color: Palette.blue_tone_light_4),
        )
      ],
    );
  }

  Widget _inactiveCard({required IconData icon, required String name}) {
    return Column(
      children: [
        Icon(icon, size: 24, color: Palette.blue_tone_light_4.withOpacity(0.5)),
        Text(
          name,
          style: TextStyle(
              fontWeight: FontWeight.w600,
              color: Palette.blue_tone_light_4.withOpacity(0.5)),
        )
      ],
    );
  }

  Widget _bottom_nav_item(
      {required int index,
      required IconData active_icon,
      required String name,
      required IconData inactive_icon}) {
    return InkWell(
        onTap: () => nav(index),
        child: widget.state == index
            ? _activeCard(icon: active_icon, name: name)
            : _inactiveCard(icon: inactive_icon, name: name));
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      left: false,
      right: false,
      top: false,
      child: Scaffold(
        backgroundColor: Palette.blue_tone_white,
        body: Obx(() => Column(
              children: [
                Expanded(child: _currentPage()),
                Container(
                  width: MediaQuery.of(context).size.width,
                  decoration: BoxDecoration(
                    color: Palette.blue_tone_light_1,
                    // borderRadius: const BorderRadius.only(
                    //     topLeft: Radius.circular(20),
                    //     topRight: Radius.circular(20)
                    // ),
                  ),
                  child: Padding(
                    // padding: const EdgeInsets.fromLTRB(10, 2, 10, 2),
                    padding: const EdgeInsets.only(top: 10, bottom: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _bottom_nav_item(
                            index: 0,
                            name: 'Home',
                            active_icon: IconlyBold.home,
                            inactive_icon: IconlyLight.home),
                        _bottom_nav_item(
                            index: 1,
                            name: 'Category',
                            active_icon: IconlyBold.category,
                            inactive_icon: IconlyLight.category),
                        _bottom_nav_item(
                            index: 2,
                            name: 'Search',
                            active_icon: IconlyBold.search,
                            inactive_icon: IconlyLight.search),
                        _badge(
                          child: _bottom_nav_item(
                              index: 3,
                              name: 'Cart',
                              active_icon: IconlyBold.buy,
                              inactive_icon: IconlyLight.buy),
                        ),
                        _bottom_nav_item(
                            index: 4,
                            name: 'Profile',
                            active_icon: IconlyBold.profile,
                            inactive_icon: IconlyLight.profile),
                      ],
                    ),
                  ),
                ),
              ],
            )),
      ),
    );
  }

  Widget _currentPage() {
    switch (widget.state) {
      case 0:
        return const HomeScreen();
      case 1:
        return const CategoryList();
      case 2:
        return Search(
          share: {'state': 0},
          initialDish: widget.initialDishToSearch,
        );
      case 3:
        return const CartList();
      case 4:
        return const Profile();
      default:
        return const HomeScreen();
    }
  }

  Widget _badge({required Widget child}) {
    return badge.Badge(
        badgeStyle: BadgeStyle(
            badgeColor: Palette.blue_tone_light_4,
            padding: const EdgeInsets.all(5)),
        badgeAnimation:
            const BadgeAnimation.fade(animationDuration: Duration(milliseconds: 0)),
        badgeContent: Text(c.cart.toString(),
            style: Util.txt(Palette.blue_tone_light_1, 15, FontWeight.w500),
            softWrap: true),
        child: child);
  }

  nav(int state) {
    if (state == 0) {
      Navigator.pushReplacement(context,
          MaterialPageRoute(builder: (context) => NavigationItemBar(state: 0)));
    } else if (state == 1) {
      Navigator.pushReplacement(context,
          MaterialPageRoute(builder: (context) => NavigationItemBar(state: 1)));
    } else if (state == 2) {
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => NavigationItemBar(
                    state: 2,
                    initialDishToSearch: widget.initialDishToSearch,
                  )));
    } else if (state == 3) {
      Navigator.pushReplacement(context,
          MaterialPageRoute(builder: (context) => NavigationItemBar(state: 3)));
    } else if (state == 4) {
      Navigator.pushReplacement(context,
          MaterialPageRoute(builder: (context) => NavigationItemBar(state: 4)));
    }
  }
}
