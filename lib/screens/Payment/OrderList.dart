import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import '../../Connectivity/No_internet.dart';
import '../../Connectivity/connectivity_provider.dart';
import '../../model/OrdersModel.dart';
import '../../utilities/constants.dart';
import '../../utilities/palette.dart';
import '../Home/CartList.dart';
import '../Home/NavigationItemBar.dart';
import '../Home/Profile.dart';
import '../Home/feed_back.dart';
import 'OrderDetailView.dart';

class MyOrdersList extends StatefulWidget {
  const MyOrdersList({Key? key}) : super(key: key);

  @override
  _MyOrdersListState createState() => _MyOrdersListState();
}

class _MyOrdersListState extends State<MyOrdersList> {
  final GlobalKey<ScaffoldState> _scaffoldkey = GlobalKey<ScaffoldState>();
  List<OrderListModel> orders = [];
  bool loader = true;

  @override
  void initState() {
    Provider.of<ConnectivityProvider>(context, listen: false).startMonitoring();
    super.initState();
    getData();
  }
  getData() async {
    orders = [];
    String userid =await Util.getStringValuesSF('userid');
    try {
      final productList = http.MultipartRequest(
          'POST', Uri.parse('${Util.baseurl}orderslist.php'));
      productList.fields['userid'] = userid;
      productList.fields['client'] = Util.clientName;
      final snd = await productList.send();
      final response = await http.Response.fromStream(snd);
      if (response.statusCode == 200) {
        var dec = jsonDecode(response.body);
        if (dec['success']){
          orders=List<OrderListModel>.from(
              dec['data'].map((i) => OrderListModel.fromJson(i)));
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
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.push(context, MaterialPageRoute(builder: (context) => const Profile()));
        return true;
      },
      child: Scaffold(
        key: _scaffoldkey,
        backgroundColor: Palette.background,
        appBar: AppBar(
          backgroundColor: Palette.background,
          elevation: 0,
          leading: IconButton(
            onPressed: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => const Profile()));
            },
            icon: Icon(
              Ionicons.arrow_back,
              color: Palette.black,
            ),
          ),
          title: Text(
            'Orders',
            style: Util.txt(Palette.black, 18, FontWeight.w600),
          ),
        ),
        body: SafeArea(child: checkConnection()),
        bottomSheet: Container(
          color: Palette.white,
          height: 50,
          child: const NavigationItemBar(
            state: 5,
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
    return orders.isNotEmpty
        ? Padding(
            padding: const EdgeInsets.all(10.0),
            child: ListView(
              children: [
                for (int i = 0; i < orders.length; i++)
                  InkWell(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => OrderDetailView(
                                    share: {'id': orders[i].orderid},
                                  )));
                    },
                    child: Card(
                      color: Palette.cardBg,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Order # ${orders[i].orderid}',
                                  style: Util.txt(
                                      Palette.black, 16, FontWeight.w600),
                                ),
                                Text(
                                  orders[i].date,
                                  style: Util.txt(
                                      Palette.black, 14, FontWeight.w400),
                                ),
                              ],
                            ),
                            Padding(
                              padding: const EdgeInsets.fromLTRB(0, 4, 0, 4),
                              child: Row(
                                children: [
                                  Container(
                                      decoration: BoxDecoration(
                                          color: Palette.color1,
                                          borderRadius:
                                              BorderRadius.circular(10.0)),
                                      child: Padding(
                                        padding: const EdgeInsets.all(4.0),
                                        child: Row(
                                          children: [
                                            Text(
                                              '\u20B9 ',
                                              style: Util.txt(Colors.red, 14,
                                                  FontWeight.w400),
                                            ),
                                            Text(
                                              orders[i].amount,
                                              style: Util.txt(Palette.color2,
                                                  16, FontWeight.w600),
                                            ),
                                          ],
                                        ),
                                      )),
                                ],
                              ),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                    color: Palette.background,
                                    child: Padding(
                                      padding: const EdgeInsets.all(4.0),
                                      child: orders[i].status == ''
                                          ? Text(
                                              'In Process',
                                              style: Util.txt(Palette.black, 14,
                                                  FontWeight.w500),
                                            )
                                          : Text(
                                              orders[i].status,
                                              style: Util.txt(Palette.black, 14,
                                                  FontWeight.w500),
                                            ),
                                    )),
                                TextButton(
                                  onPressed: () {
                                    reOrder(i);
                                  },
                                  style: ButtonStyle(
                                      backgroundColor:
                                          MaterialStateProperty.all(
                                              Palette.color1)),
                                  child: Text(
                                    'Buy Again',
                                    style: Util.txt(
                                        Palette.color2, 16, FontWeight.w600),
                                  ),
                                ),
                                orders[i].feedbackstatus == '0' ||
                                        orders[i].feedbackstatus == ''
                                    ? TextButton(
                                        onPressed: () {
                                          Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      FeedBackScreen(
                                                        orderid:
                                                            orders[i].orderid,
                                                      )));
                                        },
                                        style: ButtonStyle(
                                            backgroundColor:
                                                MaterialStateProperty.all(
                                                    Palette.fBg)),
                                        child: Text(
                                          'Feedback',
                                          style: Util.txt(Palette.white, 16,
                                              FontWeight.w500),
                                        ),
                                      )
                                    : Row(
                                        children: [
                                          const Icon(
                                            Icons.star,
                                            color: Colors.amber,
                                          ),
                                          const SizedBox(
                                            width: 10.0,
                                          ),
                                          Text(
                                            orders[i].feedbackstatus,
                                            style: Util.txt(Palette.black, 16,
                                                FontWeight.w500),
                                          ),
                                        ],
                                      ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                const SizedBox(
                  height: 50,
                ),
              ],
            ),
          )
        : Center(
            child: loader
                ? const CupertinoActivityIndicator()
                : Text(
                    'No orders found',
                    style: Util.txt(Palette.black, 14, FontWeight.w500),
                  ),
          );
  }

  reOrder(int index) async {
    Util.showProgress(context);
    List itemCodes = [];
    for (int i = 0; i < orders[index].itemslist.length; i++) {
      itemCodes.add(orders[index].itemslist[i].itemcode);
    }
    String userid = await Util.getStringValuesSF('userid');
    Map<String, dynamic> map = {
      'userid': userid,
      'itemcodelist': itemCodes,
      'client': Util.clientName
    };
    var response = await http.post(Uri.parse('${Util.baseurl}reOrder.php'),
        body: jsonEncode(map));
    try {
      if (response.statusCode == 200) {
        Util.dismissDialog(_scaffoldkey.currentContext!);
        var deco = jsonDecode(response.body);
        if (deco['success'] == 'true') {
          confDial('Success', deco['message']);
        } else {
          Util.customDialog(
              'Fail', deco['message'], _scaffoldkey.currentContext!);
        }
      } else {
        Util.dismissDialog(_scaffoldkey.currentContext!);
      }
    } catch (e) {
      // Util.dismissDialog(_scaffoldkey.currentContext!);
      Util.logDebug(e.toString());
    }
  }

  confDial(
    String title,
    String message,
  ) {
    showDialog(
      context: context,
      barrierDismissible: true, // Allows dismissal by tapping outside
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            title,
            style: Util.txt(Palette.black, 16, FontWeight.w600),
          ),
          content: Text(
            message,
            style: Util.txt(Palette.black, 14, FontWeight.w400),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CartList(), // Navigate to CartList
                  ),
                );
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
}
