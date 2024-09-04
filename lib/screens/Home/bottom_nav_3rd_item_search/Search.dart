import 'dart:convert';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import '../../../Connectivity/No_internet.dart';
import '../../../Connectivity/connectivity_provider.dart';
import '../../../Model/Product_Model.dart';
import '../../../utilities/constants.dart';
import '../../../utilities/palette.dart';
import '../bottom_nav_1st_item_home/home_detailed_view.dart';
import '../bottom_nav_bar.dart';

class Search extends StatefulWidget {
  Search({Key? key, required this.share, required this.initialDish}) : super(key: key);
  final Map<String, dynamic> share;
  String initialDish;
  @override
  _SearchState createState() => _SearchState();
}

class _SearchState extends State<Search> {
  final GlobalKey<ScaffoldState> _scaffoldkey = GlobalKey<ScaffoldState>();
  List<SearchModel> srchList = [];
  bool loader = false, showClose = false;
  TextEditingController search = TextEditingController();

  @override
  void initState() {
    Provider.of<ConnectivityProvider>(context, listen: false).startMonitoring();
    super.initState();
    if (widget.share['state'] == 1) {
      getData(widget.share['search']);
    }
    _setStringSearch(dishName: widget.initialDish);
  }

  void _setStringSearch({required String dishName}){
    if(dishName.length<2){}else {
      setState(() {
        search.text = dishName;
        showClose = true;
        getData(search.text);
      });
    }
  }

  getData(String query) async {
    srchList = [];
    setState(() {
      loader = true;
    });
    await Future.delayed(const Duration(milliseconds: 100));
    try {
      String userid = await Util.getStringValuesSF('userid');
      final productList =
          http.MultipartRequest('POST', Uri.parse('${Util.baseurl}search.php'));
      productList.fields['query'] = query;
      productList.fields['userid'] = userid;
      productList.fields['client'] = Util.clientName;
      final snd = await productList.send();
      final response = await http.Response.fromStream(snd);
      if (response.statusCode == 200) {
        var dec = jsonDecode(response.body);
        if (dec['success']) {
          for (int i = 0; i < dec['data'].length; i++) {
            srchList.add(SearchModel(
                name: dec['data'][i]['name'],
                image: dec['data'][i]['image'],
                uuid: dec['data'][i]['uuid'],
                count: dec['data'][i]['count'],
                weight: dec['data'][i]['weight'],
                price: dec['data'][i]['price'],
                rating: dec['data'][i]['rating'],
                stock: dec['data'][i]['stock']));
          }
        }
      }
    } catch (e) {
      Util.logDebug(e);
    }
    if (mounted) {
      setState(() {
        loader = false;
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
            key: _scaffoldkey,
            backgroundColor: Palette.background,
            appBar: AppBar(
              elevation: 20,
              shadowColor: Palette.blue_tone_light_4.withOpacity(0.4),
              toolbarHeight: MediaQuery.of(context).size.height*0.12,
              backgroundColor: Palette.blue_tone_light_4.withOpacity(0.7),
              leadingWidth: 10.0,
              automaticallyImplyLeading: true,
              leading: Container(),
              title: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: const BorderRadius.all(Radius.circular(10)),
                          child: TextField(
                            controller: search,
                            cursorColor: Palette.black,
                            onChanged: (v) {
                              setState(() {
                                if (v.length > 2) {
                                  getData(v);
                                  showClose = true;
                                } else {
                                  srchList.clear();
                                  showClose = false;
                                }
                              });
                            },
                            autofocus: false,
                            keyboardType: TextInputType.text,
                            textInputAction: TextInputAction.done,
                            style: Util.txt(Palette.blue_tone_black, 14, FontWeight.w600),
                            decoration: InputDecoration(
                              labelText: 'Let\'s Explore',
                              labelStyle: Util.txt(Palette.black.withOpacity(0.5), 14, FontWeight.w600),
                              hintText: 'Chicken',
                              hintStyle:
                                  Util.txt(Palette.black.withOpacity(0.5), 14, FontWeight.w400),
                              enabledBorder: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              border: InputBorder.none,
                              isDense: true,
                              filled: true,
                              contentPadding: const EdgeInsets.all(10.0),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      showClose
                          ? InkWell(
                              onTap: () {
                                FocusScope.of(context).requestFocus(FocusNode());
                                //FocusScope.of(context).unfocus();
                                setState(() {
                                  search.text = '';
                                  srchList = [];
                                  showClose = false;
                                });
                              },
                              child: Icon(
                                Ionicons.ios_close,
                                color: Palette.blue_tone_light_1,
                              ))
                          : Container(),
                    ],
                  ),
                ],
              ),
            ),
            body: _page_builder(),
            // bottomSheet: Container(
            //   // color: Palette.white,
            //   height: Util.bottomNavBarHeight,
            //   child: const NavigationItemBar(
            //     state: 2,
            //   ),
            // ),
          ),
        ),
      ),
    );
  }

  Widget _no_internet() {
    return NoInternet();
  }

  Widget _page_builder() {
    Widget _if_internet() {
      return srchList.isNotEmpty
          ? _search_items()
          : loader
              ? _loading_screen()
              : _empty_search();
    }

    return Consumer<ConnectivityProvider>(
      builder: (consumerContext, model, child) {
        return model.isOnline ? _if_internet() : _no_internet();
      },
    );
  }

  Widget _empty_search() {
    return SingleChildScrollView(
      child: Container(
        height: MediaQuery.of(context).size.height*0.69,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Lottie.asset('assets/lottie/search.json'),
            const SizedBox(
              height: 4.0,
            ),
            Text(
              'Search Your Favourite Dish',
              style: Util.txt(Palette.blue_tone_light_4, 18, FontWeight.w500),
            )
          ],
        ),
      ),
    );
  }

  Widget _loading_screen() {
    return const Center(child: CupertinoActivityIndicator());
  }

  Widget _search_items() {
    return ListView(
      children: [
        const SizedBox(
          height: 4,
        ),
        for (var e in srchList)
          Column(
            children: <Widget>[
              GestureDetector(
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => DetailedView(
                            previous_search: search.text.toString(),
                              name: e.name, id: e.uuid, state: 3)));
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                  child: Card(
                    color: Colors.white,
                    elevation: 20,
                    shadowColor: Palette.blue_tone_light_4,
                    child: Row(
                      children: <Widget>[
                        ClipRRect(
                          borderRadius: const BorderRadius.only(topLeft: Radius.circular(12), bottomLeft: Radius.circular(12)),
                          child: Container(
                            height: 160.0,
                            width: 150.0,
                            decoration: BoxDecoration(
                                image: DecorationImage(
                              image: NetworkImage(e.image),
                              fit: BoxFit.fill,
                            )),
                          ),
                        ),
                        Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(right: 10),
                              child: SizedBox(
                              child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Row(
                                  children: <Widget>[
                                    Flexible(
                                      child: Padding(
                                        padding: const EdgeInsets.all(5.0),
                                        child: Text(
                                          e.name,
                                          style: Util.txt(
                                              Palette.black, 17, FontWeight.w700),
                                          softWrap: true,
                                          overflow: TextOverflow.clip,
                                          maxLines: 3,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                Padding(
                                  padding: const EdgeInsets.fromLTRB(5, 0, 0, 0),
                                  child: Row(
                                    children: <Widget>[
                                      Text(
                                        '\u20B9 ',
                                        style: Util.txt(
                                            Colors.red, 16, FontWeight.w600),
                                      ),
                                      Text(
                                        e.price,
                                        style: Util.txt(
                                            Palette.black, 16, FontWeight.w600),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(
                                  height: 30.0,
                                  child: Padding(
                                    padding:
                                        const EdgeInsets.symmetric(horizontal: 5.0),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      children: <Widget>[
                                        RatingBarIndicator(
                                          // initialRating: catItmL[i]['priority']!='' && catItmL[i]['priority']!=null?double.parse(catItmL[i]['priority'])>5.0?5.0:double.parse(catItmL[i]['priority']):1,
                                          rating: double.parse(e.rating),
                                          direction: Axis.horizontal,
                                          itemCount: 5,
                                          itemSize: 22.0,
                                          itemPadding: const EdgeInsets.symmetric(
                                              horizontal: 1.0),
                                          itemBuilder: (context, _) => const Icon(
                                            IconlyBold.star,
                                            color: Colors.amber,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                e.stock == 'not available'
                                    ? Text(
                                      'Out of Stock',
                                      style: Util.txt(
                                          Colors.red, 20, FontWeight.w700),
                                      softWrap: true,
                                      textAlign: TextAlign.justify,
                                    )
                                    : SizedBox(
                                        height: 40,
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.end,
                                          children: <Widget>[
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.end,
                                              children: <Widget>[
                                                Visibility(
                                                  visible:
                                                      e.count == 0 ? true : false,
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.fromLTRB(
                                                            0, 0, 0, 5),
                                                    child: Row(
                                                      children: <Widget>[
                                                        SizedBox(
                                                          width: 60,
                                                          height: 30,
                                                          child: OutlinedButton(
                                                            onPressed: () {
                                                              onlineCart(e.uuid,
                                                                  e.hashCode, 1);
                                                            },
                                                            style: ButtonStyle(
                                                                side: MaterialStateProperty
                                                                    .all(BorderSide(
                                                                        color: Palette
                                                                            .black,
                                                                        width:
                                                                            1.2)),
                                                                tapTargetSize:
                                                                    MaterialTapTargetSize
                                                                        .shrinkWrap,
                                                                padding:
                                                                    MaterialStateProperty.all(
                                                                        EdgeInsets
                                                                            .zero),
                                                                shape: MaterialStateProperty.all(
                                                                    const RoundedRectangleBorder(
                                                                        borderRadius:
                                                                            BorderRadius.all(Radius.circular(10.0))))),
                                                            child: Text('ADD',
                                                                style: Util.txt(
                                                                    Palette.black,
                                                                    16,
                                                                    FontWeight
                                                                        .w500)),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                                Visibility(
                                                  visible:
                                                      e.count == 0 ? false : true,
                                                  child: Row(
                                                    children: <Widget>[
                                                      SizedBox(
                                                        width: 30, height: 30,
                                                        // decoration: BoxDecoration(
                                                        //   borderRadius: BorderRadius.circular(10.0),
                                                        //   border: Border.all(color: Palette.black,width: 2.0),
                                                        // ),
                                                        child: OutlinedButton(
                                                          onPressed: () {
                                                            setState(() {
                                                              int sky = e.count - 1;
                                                              if (sky >= 1) {
                                                                onlineCart(
                                                                    e.uuid,
                                                                    e.hashCode,
                                                                    sky);
                                                              }
                                                              if (sky == 0) {
                                                                onlineCart(e.uuid,
                                                                    e.hashCode, 0);
                                                              }
                                                            });
                                                          }, //
                                                          style: ButtonStyle(
                                                              padding: MaterialStateProperty.all(
                                                                  const EdgeInsets
                                                                      .symmetric(
                                                                      horizontal:
                                                                          0.0)),
                                                              side: MaterialStateProperty.all(
                                                                  BorderSide(
                                                                      color: Palette
                                                                          .black,
                                                                      width: 1.2)),
                                                              shape: MaterialStateProperty.all(
                                                                  const RoundedRectangleBorder(
                                                                      borderRadius:
                                                                          BorderRadius.all(
                                                                              Radius.circular(10.0))))),
                                                          child: e.count == 1
                                                              ? Icon(
                                                                  IconlyLight.delete,
                                                                  color:
                                                                      Palette.black)
                                                              : Icon(
                                                                  Icons.remove,
                                                                  color:
                                                                      Palette.black,
                                                                ),
                                                        ),
                                                      ),
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets.all(
                                                                5.0),
                                                        child: Container(
                                                          height: 30,
                                                          width: 50,
                                                          decoration: BoxDecoration(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(10.0),
                                                            border: Border.all(
                                                                color:
                                                                    Palette.black,
                                                                width: 1.2),
                                                          ),
                                                          child: Center(
                                                              child: Text(
                                                            e.count.toString(),
                                                            textAlign:
                                                                TextAlign.center,
                                                          )),
                                                        ),
                                                      ),
                                                      SizedBox(
                                                        width: 30,
                                                        height: 30,
                                                        // decoration: BoxDecoration(
                                                        //   borderRadius: BorderRadius.circular(10.0),
                                                        //   border: Border.all(color: Colors.teal,width: 2.0),
                                                        // ),
                                                        child: OutlinedButton(
                                                          onPressed: () {
                                                            int sky = e.count + 1;
                                                            onlineCart(e.uuid,
                                                                e.hashCode, sky);
                                                          },
                                                          style: ButtonStyle(
                                                              padding: MaterialStateProperty.all(
                                                                  const EdgeInsets
                                                                      .symmetric(
                                                                      horizontal:
                                                                          0.0)),
                                                              side: MaterialStateProperty.all(
                                                                  BorderSide(
                                                                      color: Palette
                                                                          .black,
                                                                      width: 1.2)),
                                                              shape: MaterialStateProperty.all(
                                                                  const RoundedRectangleBorder(
                                                                      borderRadius:
                                                                          BorderRadius.all(
                                                                              Radius.circular(10.0))))),
                                                          child: Icon(
                                                            IconlyLight.plus,
                                                            color: Palette.black,
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            )
                                          ],
                                        ),
                                      ),
                              ],
                                                        ),
                                                      ),
                            )),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        const SizedBox(
          height: 44,
        ),
      ],
    );
  }

  onlineCart(String itemcode, int index, count) async {
    FocusScope.of(context).requestFocus(FocusNode());
    String userid = await Util.getStringValuesSF('userid');
    if (userid == '' || userid.toString() == 'null') {
      Util.showLoginPop(_scaffoldkey.currentContext!,
          'Please Login to continue...', {'nav': 1, 'search': search.text});
    } else {
      Map<String, String> map = {
        'userid': userid,
        'itemcode': itemcode,
        'count': count.toString(),
        'client': Util.clientName
      };
      print('Payload carttemp is: $map');
      var response = await http.post(Uri.parse('${Util.baseurl}carttemp.php'),
          body: jsonEncode(map));
      try {
        if (response.statusCode == 200) {
          var dec = jsonDecode(response.body);
          print('carttemp value: ${response.body}');
          if (dec['status'] == '1') {
            Util.control.cart.value = dec['count'];
          }
          for (int s = 0; s < srchList.length; s++) {
            if (srchList[s].hashCode == index) {
              srchList[s].count = count;
              break;
            }
          }
        }
      } catch (e) {
        Map<String, String> map = {
          'email': userid,
          'instance': 'count update and delete',
          'error': e.toString()
        };
        var respo = await http.post(Uri.parse('${Util.baseurl}logs.php'),
            body: jsonEncode(map));
        if (respo.statusCode == 200) {}
      }
    }
    setState(() {});
  }
}
