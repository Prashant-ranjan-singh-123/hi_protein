import 'dart:convert';
import 'dart:io';
import 'package:fancy_shimmer_image/fancy_shimmer_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animated_dialog/flutter_animated_dialog.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import '../../Connectivity/No_internet.dart';
import '../../Connectivity/connectivity_provider.dart';
import '../../Model/Product_Model.dart';
import '../../utilities/AppManagement.dart';
import '../../utilities/constants.dart';
import '../../utilities/palette.dart';
import 'CartBilling.dart';
import 'NavigationItemBar.dart';

class CartList extends StatefulWidget {
  const CartList({Key? key}) : super(key: key);

  @override
  _CartListState createState() => _CartListState();
}

class _CartListState extends State<CartList> {
  List<ProductModel> prodList = [];
  List countnotAvailableprodList = [];
  final Controller c = Get.put(Controller());
  bool loader = true;
  @override
  void initState() {
    Provider.of<ConnectivityProvider>(context, listen: false).startMonitoring();
    super.initState();
    getData();
  }

  getData() async {
    prodList = [];
    countnotAvailableprodList = [];
    double totalAmount = 0;
    setState(() {
      loader = true;
    });
    String userid = await Util.getStringValuesSF('userid');
    if (userid == '' || userid.toString() == 'null') {
      // Util.showToast('Please Login');
    } else {
      try {
        final productList = http.MultipartRequest(
            'POST', Uri.parse('${Util.baseurl}cart-list.php'));
        productList.fields['userid'] = userid;
        productList.fields['client'] = Util.clientName;
        final snd = await productList.send();
        final response = await http.Response.fromStream(snd);
        if (response.statusCode == 200) {
          var dec = jsonDecode(response.body);
          print('cartlist:$dec');
          if (dec['success']) {
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
              if (dec['data'][i]['stock'] != 'not available') {
                double junk = double.parse(dec['data'][i]['price']);
                int book = dec['data'][i]['count'];
                totalAmount = totalAmount + (junk * book).roundToDouble();
              }
              if(dec['data'][i]['stock'] == 'not available'){
                  countnotAvailableprodList.add(dec['data'][i]['stock']);
                  print('nag===> ${countnotAvailableprodList.length}');
              }
              print('===> ${countnotAvailableprodList.length}');
              Util.addStringToSF('outofstockvalue','${countnotAvailableprodList.length}','');
              String outofstock = await Util.getStringValuesSF('outofstockvalue');  
              print('outofstackcount: $outofstock');
            }
            c.totalAmount.value = totalAmount;
            c.charges.value = double.parse(dec['shippingcharges']);
            c.checkOutPrice.value = totalAmount;
            c.promo.value = true;
          }
        }
      } catch (e) {
        Util.logDebug(e);
      }
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
          padding: EdgeInsets.fromLTRB(0, 0, 0, Platform.isAndroid ? 0 : 20),
          child: Scaffold(
            backgroundColor: Palette.background,
            // appBar: AppBar(
            //   backgroundColor: Palette.white,
            //   title: Text(widget.name,style: Util.txt(Palette.black, 16, FontWeight.w600),),
            //   leading: IconButton(onPressed: nav, icon: Icon(Platform.isAndroid?Icons.arrow_back:Icons.arrow_back_ios,color: Palette.black,)),
            // ),
            body: SafeArea(child: checkConnection()),
            bottomSheet: Container(
              color: Palette.white,
              height: 50,
              child: const NavigationItemBar(
                state: 3,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget checkConnection() {
    return Consumer<ConnectivityProvider>(
      builder: (consumerContext, model, child) {
        return model.isOnline ? page() : NoInternet();
      },
    );
  }

  page() {
    return prodList.isNotEmpty
        ? ListView(
            children: [
              const Padding(
                padding: EdgeInsets.fromLTRB(2, 2, 2, 4),
                child: CartBilling(),
              ),
              for (int i = 0; i < prodList.length; i++)
                Column(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.fromLTRB(0, 0, 10, 0),
                      child: Row(
                        children: <Widget>[
                          SizedBox(
                            height: 160.0,
                            width: 150.0,
                            child: ClipRRect(
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(10.0)),
                              child: FancyShimmerImage(
                                height: 160,
                                width: 150,
                                imageUrl: prodList[i].image,
                                shimmerBaseColor: Colors.grey[300],
                                shimmerHighlightColor: Colors.grey[100],
                                errorWidget: Image.network(
                                    'https://i0.wp.com/www.dobitaobyte.com.br/wp-content/uploads/2016/02/no_image.png?ssl=1'),
                              ),
                            ),
                          ),
                          Expanded(
                              child: SizedBox(
                            height: 160,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Row(
                                  children: <Widget>[
                                    Flexible(
                                      child: Padding(
                                        padding: const EdgeInsets.all(5.0),
                                        child: Text(prodList[i].name,
                                            style: Util.txt(Palette.black, 16,
                                                FontWeight.w500),
                                            softWrap: true),
                                      ),
                                    ),
                                  ],
                                ),
                                Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(5, 0, 0, 0),
                                  child: Row(
                                    children: <Widget>[
                                      Text(
                                        '\u20B9 ',
                                        style: Util.txt(
                                            Colors.red, 16, FontWeight.w500),
                                      ),
                                      Text(
                                        prodList[i].price,
                                        style: Util.txt(
                                            Palette.black, 14, FontWeight.w500),
                                      ),
                                    ],
                                  ),
                                ),
                                prodList[i].stock == 'not available'
                                    ? Row(
                                        mainAxisAlignment:MainAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Out of Stock',
                                            style: Util.txt(Colors.red, 18,
                                                FontWeight.w500),
                                            softWrap: true,
                                            textAlign: TextAlign.justify,
                                          ),
                                        ],
                                      )
                                    : SizedBox(
                                        height: 40,
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          children: <Widget>[
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.end,
                                              children: <Widget>[
                                                Visibility(
                                                  visible:
                                                      prodList[i].count == 0
                                                          ? true
                                                          : false,
                                                  child: Padding(
                                                    padding: const EdgeInsets
                                                        .fromLTRB(0, 0, 0, 5),
                                                    child: Row(
                                                      children: <Widget>[
                                                        SizedBox(
                                                          width: 60,
                                                          height: 30,
                                                          child: OutlinedButton(
                                                            onPressed: () {
                                                              onlineCart(
                                                                  prodList[i]
                                                                      .uuid,
                                                                  i,
                                                                  1);
                                                            },
                                                            style: ButtonStyle(
                                                                side: MaterialStateProperty.all(
                                                                    BorderSide(
                                                                        color: Palette
                                                                            .black,
                                                                        width:
                                                                            1.2)),
                                                                tapTargetSize:
                                                                    MaterialTapTargetSize
                                                                        .shrinkWrap,
                                                                padding: MaterialStateProperty
                                                                    .all(EdgeInsets
                                                                        .zero),
                                                                shape: MaterialStateProperty.all(
                                                                    const RoundedRectangleBorder(
                                                                        borderRadius:
                                                                            BorderRadius.all(Radius.circular(10.0))))),
                                                            child: Text('ADD',
                                                                style: Util.txt(
                                                                    Palette
                                                                        .black,
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
                                                      prodList[i].count == 0
                                                          ? false
                                                          : true,
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
                                                              int sky = prodList[
                                                                          i]
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
                                                          }, //
                                                          style: ButtonStyle(
                                                              padding: MaterialStateProperty.all(
                                                                  const EdgeInsets
                                                                          .symmetric(
                                                                      horizontal:
                                                                          0.0)),
                                                              side: MaterialStateProperty
                                                                  .all(BorderSide(
                                                                      color: Palette
                                                                          .black,
                                                                      width:
                                                                          1.2)),
                                                              shape: MaterialStateProperty.all(
                                                                  const RoundedRectangleBorder(
                                                                      borderRadius:
                                                                          BorderRadius.all(Radius.circular(10.0))))),
                                                          child: prodList[i]
                                                                      .count ==
                                                                  1
                                                              ? Icon(
                                                                  Icons
                                                                      .delete_outline,
                                                                  color: Palette
                                                                      .black)
                                                              : Icon(
                                                                  Icons.remove,
                                                                  color: Palette
                                                                      .black,
                                                                ),
                                                        ),
                                                      ),
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(5.0),
                                                        child: Container(
                                                          height: 30,
                                                          width: 50,
                                                          decoration:
                                                              BoxDecoration(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        10.0),
                                                            border: Border.all(
                                                                color: Palette
                                                                    .black,
                                                                width: 1.2),
                                                          ),
                                                          child: Center(
                                                              child: Text(
                                                            prodList[i]
                                                                .count
                                                                .toString(),
                                                            textAlign: TextAlign
                                                                .center,
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
                                                            int sky =
                                                                prodList[i]
                                                                        .count +
                                                                    1;
                                                            onlineCart(
                                                                prodList[i]
                                                                    .uuid,
                                                                i,
                                                                sky);
                                                          },
                                                          style: ButtonStyle(
                                                              padding: MaterialStateProperty.all(
                                                                  const EdgeInsets
                                                                          .symmetric(
                                                                      horizontal:
                                                                          0.0)),
                                                              side: MaterialStateProperty
                                                                  .all(BorderSide(
                                                                      color: Palette
                                                                          .black,
                                                                      width:
                                                                          1.2)),
                                                              shape: MaterialStateProperty.all(
                                                                  const RoundedRectangleBorder(
                                                                      borderRadius:
                                                                          BorderRadius.all(Radius.circular(10.0))))),
                                                          child: Icon(
                                                            Icons.add,
                                                            color:
                                                                Palette.black,
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
                                Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(10, 0, 0, 2),
                                  child: Row(
                                    children: [
                                      SizedBox(
                                        width: 80,
                                        height: 30,
                                        child: OutlinedButton(
                                          onPressed: () {
                                            confDial1(prodList[i].uuid,i, 0);
                                            //onlineCart(prodList[i].uuid, i, 0);
                                          },
                                          style: ButtonStyle(
                                              backgroundColor:
                                                  MaterialStateProperty.all(
                                                      Palette.gray),
                                              // side: MaterialStateProperty.all(BorderSide(color: Palette.gray,width: 1.2)),
                                              tapTargetSize:
                                                  MaterialTapTargetSize
                                                      .shrinkWrap,
                                              padding:
                                                  MaterialStateProperty.all(
                                                      EdgeInsets.zero),
                                              shape: MaterialStateProperty.all(
                                                  const RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.all(
                                                              Radius.circular(
                                                                  10.0))))),
                                          child: Text('Remove',
                                              style: Util.txt(Palette.black, 16,
                                                  FontWeight.w500)),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          )),
                        ],
                      ),
                    ),
                    const Divider(
                      height: 2,
                    ),
                  ],
                ),
              const SizedBox(
                height: 50,
              ),
            ],
          )
        : Center(
            child: loader
                ? const CupertinoActivityIndicator()
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Ionicons.cart_outline,
                        size: 46,
                        color: Palette.gray,
                      ),
                      const SizedBox(
                        height: 4.0,
                      ),
                      Text(
                        'Shopping Cart empty',
                        style: Util.txt(Palette.black, 14, FontWeight.w300),
                      ),
                    ],
                  ),
          );
  }
  confDial1( String prdid, int index, int status) {
      showAnimatedDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return ClassicGeneralDialogWidget(
          titleText: 'cart',
          contentText: 'Are you sure want to remove this product ?',
          actions: [
            TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  onlineCart(prdid, index, 0);
                },
                child: Text(
                  'Ok',
                  style: Util.txt(Palette.black, 16, FontWeight.w600),
                )),
                TextButton(
                onPressed: () {
                  Navigator.pop(context);
                 // Navigator.push(context,MaterialPageRoute( builder: (context) => const MyMapPicker()));
                },
                child: Text(
                  'Cancel',
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
  //---------
  onlineCart(String itemcode, int index, int count) async {
    String userid = await Util.getStringValuesSF('userid');
    double totalAmount = 0;
    Map<String, String> map = {
      'userid': userid,
      'itemcode': itemcode,
      'count': count.toString(),
      'client': Util.clientName
    };
    var response = await http.post(Uri.parse('${Util.baseurl}carttemp.php'),
        body: jsonEncode(map));
    try {
      if (response.statusCode == 200) {
        var dec = jsonDecode(response.body);
        if (dec['status'] == '1') {
          c.cart.value = dec['count'];
        }
        if (count != 0) {
          prodList[index].count = count;
          for (int i = 0; i < prodList.length; i++) {
            double junk = double.parse(prodList[i].price);
            int book = prodList[i].count;
            totalAmount = totalAmount + (junk * book).roundToDouble();
          }
          c.totalAmount.value = totalAmount;
          c.checkOutPrice.value = totalAmount;
          c.promo.value = true;
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
    if (count != 0) {
      setState(() {});
    } else {
      getData();
    }
  }

//----------increment and decrement
}
