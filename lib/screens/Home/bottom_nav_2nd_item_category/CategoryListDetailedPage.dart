import 'dart:convert';
import 'dart:io';
import 'package:fancy_shimmer_image/fancy_shimmer_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import '../../../Connectivity/No_internet.dart';
import '../../../Connectivity/connectivity_provider.dart';
import '../../../Model/Product_Model.dart';
import '../../../utilities/constants.dart';
import '../../../utilities/palette.dart';
import 'CategoryList.dart';
import '../bottom_nav_1st_item_home/home_detailed_view.dart';
import '../HomeScreen.dart';
import '../bottom_nav_bar.dart';

class ProductList extends StatefulWidget {
  const ProductList({Key? key, required this.name, required this.state})
      : super(key: key);
  final String name;
  final int state;
  @override
  _ProductListState createState() => _ProductListState();
}

class _ProductListState extends State<ProductList> {
  final GlobalKey<ScaffoldState> _scaffoldkey = GlobalKey<ScaffoldState>();
  String available = '';
  List<ProductModel> prodList = [];
  bool loader = true;

  @override
  void initState() {
    Provider.of<ConnectivityProvider>(context, listen: false).startMonitoring();
    super.initState();
    getData();
  }

  getData() async {
    String userid = await Util.getStringValuesSF('userid');
    available = await Util.getStringValuesSF('availability');
    try {
      final productList = http.MultipartRequest(
          'POST', Uri.parse('${Util.baseurl}listbyname.php'));
      productList.fields['userid'] = userid;
      productList.fields['name'] = widget.name;
      productList.fields['client'] = Util.clientName;
      final snd = await productList.send();
      final response = await http.Response.fromStream(snd);
      if (response.statusCode == 200) {
        var dec = jsonDecode(response.body);
        if (dec['data'].length == 0) {
          loader = false;
        }
        for (int i = 0; i < dec['data'].length; i++) {
          prodList.add(ProductModel(
              name: dec['data'][i]['name'],
              image: dec['data'][i]['image'],
              uuid: dec['data'][i]['uuid'],
              count: dec['data'][i]['count'],
              price: dec['data'][i]['price'],
              rating: dec['data'][i]['rating'],
              stock: dec['data'][i]['stock'],
              weight: dec['data'][i]['weight']));
        }
      }
    } catch (e) {
      Util.logDebug(e);
    }
    if (mounted) {
      setState(() {});
    }
  }

  nav() {
    if (widget.state == 0) {
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => NavigationItemBar(state: 0)));
    } else {
      Navigator.push(context,
          MaterialPageRoute(builder: (context) => NavigationItemBar(state: 1)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        nav();
        return true;
      },
      child: Container(
        color: Palette.white,
        child: Padding(
          // padding: EdgeInsets.fromLTRB(0, 0, 0, Platform.isAndroid ? 0 : 20),
          padding: EdgeInsets.all(0),
          child: Scaffold(
            key: _scaffoldkey,
            backgroundColor: Palette.background,
            appBar: AppBar(
              elevation: 0,
              backgroundColor: Palette.white,
              title: Text(
                widget.name,
                style: Util.txt(Palette.black, 16, FontWeight.w600),
              ),
              leading: IconButton(
                  onPressed: nav,
                  icon: Icon(
                    Platform.isAndroid
                        ? Icons.arrow_back
                        : Icons.arrow_back_ios,
                    color: Palette.black,
                  )),
            ),
            body: checkConnection(),
            // bottomSheet: Container(
            //   // color: Palette.white,
            //   height: Util.bottomNavBarHeight,
            //   child: const NavigationItemBar(state: 5,),
            // ),
          ),
        ),
      ),
    );
  }

  Widget checkConnection() {
    return Consumer<ConnectivityProvider>(
      builder: (consumerContext, model, child) {
        return model.isOnline ? page() : const NoInternet();
      },
    );
  }

  onlineCart(String itemcode, int index, int count) async {
    String userid = await Util.getStringValuesSF('userid');
    if (userid == '' || userid.toString() == 'null') {
      Util.showLoginPop(
          _scaffoldkey.currentContext!,
          'Please Login to continue...',
          {'nav': 0, 'name': widget.name, 'state': widget.state});
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
          prodList[index].count = count;
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

  page() {
    return prodList.isNotEmpty
        ? ListView(
            children: [
              const SizedBox(
                height: 4,
              ),
              for (int i = 0; i < prodList.length; i++)
                items_card(context: context, i: i),
              const SizedBox(
                height: 50,
              ),
            ],
          )
        : Center(
            child: loader
                ? const CircularProgressIndicator()
                : const Text(
                    'Coming soon'), /*Image.asset(
                        'images/insugo_logo_icon.png',
                        height: 100,
                        width: 200,
                        fit: BoxFit.fitWidth,
                      ),*/
          ); //const Center(child: CupertinoActivityIndicator(),);
  }

  Widget items_card({
    required BuildContext context,
    required int i,
  }) {
    return GestureDetector(
        onTap: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => DetailedView(
                      name: widget.name,
                      id: prodList[i].uuid,
                      state: widget.state)));
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
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(12),
                      bottomLeft: Radius.circular(12),
                    ),
                    child: Container(
                      height: 160.0,
                      width: 150.0,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: NetworkImage(prodList[i].image),
                          fit: BoxFit.fill,
                        ),
                      ),
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
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.all(5.0),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          prodList[i].name,
                                          style: Util.txt(
                                              Palette.black, 17, FontWeight.w700),
                                          softWrap: true,
                                          overflow: TextOverflow.clip,
                                          maxLines: 3,
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(5.0),
                                          child: Text(
                                            prodList[i].weight,
                                            style: Util.txt(
                                                Palette.black, 16, FontWeight.w600),
                                            softWrap: true,
                                            overflow: TextOverflow.clip,
                                            maxLines: 3,
                                          ),
                                        ),
                                      ],
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
                                    prodList[i].price,
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
                                      rating: double.parse(prodList[i].rating),
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
                            prodList[i].stock == 'not available'
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
                                              visible: prodList[i].count == 0,
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
                                                        onPressed: () async {
                                                          String userid = await Util
                                                              .getStringValuesSF(
                                                                  'userid');
                                                          String available = await Util
                                                              .getStringValuesSF(
                                                                  'availability');
                                                          if (available ==
                                                              '1') {
                                                            onlineCart(
                                                                prodList[i]
                                                                    .uuid,
                                                                i,
                                                                1);
                                                          } else {
                                                            if (userid
                                                                    .isEmpty ||
                                                                userid ==
                                                                    'null') {
                                                              Util.showLoginPop(
                                                                _scaffoldkey
                                                                    .currentContext!,
                                                                'Please Login to continue...',
                                                                {'nav':0,'name':widget.name,'state':widget.state},
                                                              );
                                                              return;
                                                            }
                                                            Util.customDialog(
                                                              'Sorry, we are not accepting orders at this moment',
                                                              '',
                                                              context,
                                                            );
                                                          }
                                                        },
                                                        style: ButtonStyle(
                                                          side: MaterialStateProperty
                                                              .all(BorderSide(
                                                                  color: Palette
                                                                      .black,
                                                                  width: 1.2)),
                                                          tapTargetSize:
                                                              MaterialTapTargetSize
                                                                  .shrinkWrap,
                                                          padding:
                                                              MaterialStateProperty
                                                                  .all(EdgeInsets
                                                                      .zero),
                                                          shape:
                                                              MaterialStateProperty
                                                                  .all(
                                                            const RoundedRectangleBorder(
                                                              borderRadius: BorderRadius
                                                                  .all(Radius
                                                                      .circular(
                                                                          10.0)),
                                                            ),
                                                          ),
                                                        ),
                                                        child: Text(
                                                          'ADD',
                                                          style: Util.txt(
                                                              Palette.black,
                                                              16,
                                                              FontWeight.w500),
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                            Visibility(
                                              visible: prodList[i].count != 0,
                                              child: Row(
                                                children: <Widget>[
                                                  SizedBox(
                                                    width: 30,
                                                    height: 30,
                                                    child: OutlinedButton(
                                                      onPressed: () {
                                                        setState(() {
                                                          int sky = prodList[i]
                                                                  .count -
                                                              1;
                                                          if (sky >= 1) {
                                                            onlineCart(
                                                                prodList[i]
                                                                    .uuid,
                                                                i,
                                                                sky);
                                                          }
                                                          if (sky == 0) {
                                                            onlineCart(
                                                                prodList[i]
                                                                    .uuid,
                                                                i,
                                                                0);
                                                          }
                                                        });
                                                      },
                                                      style: ButtonStyle(
                                                        padding:
                                                            MaterialStateProperty.all(
                                                                const EdgeInsets
                                                                    .symmetric(
                                                                    horizontal:
                                                                        0.0)),
                                                        side:
                                                            MaterialStateProperty
                                                                .all(BorderSide(
                                                                    color: Palette
                                                                        .black,
                                                                    width:
                                                                        1.2)),
                                                        shape:
                                                            MaterialStateProperty
                                                                .all(
                                                          const RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius.all(
                                                                    Radius.circular(
                                                                        10.0)),
                                                          ),
                                                        ),
                                                      ),
                                                      child: prodList[i]
                                                                  .count ==
                                                              1
                                                          ? Icon(
                                                              Icons
                                                                  .delete_outline,
                                                              color:
                                                                  Palette.black)
                                                          : Icon(Icons.remove,
                                                              color: Palette
                                                                  .black),
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
                                                          prodList[i]
                                                              .count
                                                              .toString(),
                                                          textAlign:
                                                              TextAlign.center,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  SizedBox(
                                                    width: 30,
                                                    height: 30,
                                                    child: OutlinedButton(
                                                      onPressed: () {
                                                        int sky =
                                                            prodList[i].count +
                                                                1;
                                                        onlineCart(
                                                            prodList[i].uuid,
                                                            i,
                                                            sky);
                                                      },
                                                      style: ButtonStyle(
                                                        padding:
                                                            MaterialStateProperty.all(
                                                                const EdgeInsets
                                                                    .symmetric(
                                                                    horizontal:
                                                                        0.0)),
                                                        side:
                                                            MaterialStateProperty
                                                                .all(BorderSide(
                                                                    color: Palette
                                                                        .black,
                                                                    width:
                                                                        1.2)),
                                                        shape:
                                                            MaterialStateProperty
                                                                .all(
                                                          const RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius.all(
                                                                    Radius.circular(
                                                                        10.0)),
                                                          ),
                                                        ),
                                                      ),
                                                      child: Icon(Icons.add,
                                                          color: Palette.black),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            )));
  }
//----------
}
