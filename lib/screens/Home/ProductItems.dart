import 'dart:convert';
import 'package:fancy_shimmer_image/fancy_shimmer_image.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:get/get.dart';
import 'package:hi_protein/screens/Payment/OrderDetailView.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import '../../Connectivity/No_internet.dart';
import '../../Connectivity/connectivity_provider.dart';
import '../../utilities/constants.dart';
import '../../utilities/gstreet_map.dart';
import '../../utilities/palette.dart';
import 'CarouselItem.dart';
import 'DetailedView.dart';
import 'ProductList.dart';

class ProductItems extends StatefulWidget {
  const ProductItems({Key? key}) : super(key: key);
  @override
  _ProductItemsState createState() => _ProductItemsState();
}
class _ProductItemsState extends State<ProductItems> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final ScrollController _controllerOne = ScrollController();
  List category = [], category1 = [], carousel = [], catImg = [];
  bool loader = true;
  String deliveryCode = 'Check Delivery Availability', deliveraddress = '';
  TextEditingController pincode = TextEditingController();
  int count = 1;
  final FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;
  @override
  void initState() {
    Provider.of<ConnectivityProvider>(context, listen: false).startMonitoring();
    super.initState();
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message){if(message.data['screen_name']=='order_details'){setState((){Navigator.push(context,MaterialPageRoute(builder:(context) =>OrderDetailView(share:{'id':message.data['id']},)));});}});
    getImages();
    getData();
    _controllerOne.addListener(lazyLoading);
    Future.delayed(const Duration(seconds: 1)).then((value) => deliveryavailabilitymethod());
  }
  getImages()async{
    deliveraddress = await Util.getStringValuesSF('deliverto');
    carousel = [];
    Map<String, String> map = {'client': Util.clientName};
    http.Response response = await http.post(Uri.parse('${Util.baseurl}carousel.php'), body: jsonEncode(map));
    try {
      if (response.statusCode == 200) {
        var dec = jsonDecode(response.body);
        //Util.logDebug('idec:$dec');
        if (dec['success']) {
          for (int i = 0; i < dec['imagelist'].length; i++) {
            carousel.add(dec['imagelist'][i]['url']);
          }
          catImg.addAll(dec['catlist']);
        }
      }
    } catch(e){
      Util.logDebug(e);
    }
    if(mounted) {
      setState(() {});
    }
  }
  getData() async{
    category = [];
    category1 = [];
    count = 1;
    Map<String, String> map = {'client':Util.clientName};
    http.Response response = await http
        .post(Uri.parse('${Util.baseurl}category.php'), body: jsonEncode(map));
    try {
      if (response.statusCode == 200) {
        var dec = jsonDecode(response.body);
        //Util.logDebug('ddec:$dec');
        if (dec['success']) {
          category1.addAll(dec['categorylist']);
          int tmp = 5;
          if (category1.length < 5) {
            tmp = category1.length;
          }
          for (int i = 0; i < tmp; i++) {
            category.add(category1[i]);
          }
        }
      }
    } catch (e) {
      Util.logDebug(e.toString());
    }
    if (mounted) {
      setState(() {
        loader = false;
      });
    }
  }
  lazyLoading() {
    if (_controllerOne.offset > _controllerOne.position.maxScrollExtent - 100) {
      lisner();
    }
  }
  lisner() {
    int limit = 0, a = 0, b = 0;
    count = count + 1;
    a = category1.length - category.length;
    b = category.length;
    if (count * 5 < a) {
      limit = count * 5;
    } else {
      limit = a;
    }
    int i = 0;
    while (i < limit) {
      category.add(category1[i + b]);
      i = i + 1;
    }
    setState(() {});
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Palette.background,
      body: checkConnection(),
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
    return SingleChildScrollView(
      controller: _controllerOne,
      physics: const ClampingScrollPhysics(),
      child: Column(
        children: [
          GestureDetector(
            onTap: mapActions,
            child: Card(
              elevation: 0,
              margin: EdgeInsets.zero,
              child: Container(
                color: Palette.white,
                width: MediaQuery.of(context).size.width,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(10, 2, 10, 2),
                  child: Obx(() => Row(
                        children: [
                          Icon(
                            Ionicons.location_outline,
                            color: Palette.black,
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          Flexible(
                              child: Text(
                            Util.control.deliveryAdd.value,
                            style: Util.txt(Colors.black, 13, FontWeight.w500),
                            maxLines: 1,
                          ))
                        ],
                      )),
                ),
              ),
            ),
          ),
          carousel.isNotEmpty
              ? SizedBox(
                  height:
                      MediaQuery.of(context).size.width < 600 ? 220.0 : 500.0,
                  child: CarouselItem(
                    carousel: carousel,
                  ))
              : Container(),
          const SizedBox(
            height: 8,
          ),
          if (catImg.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 0, 0, 10),
              child: Container(
                width: MediaQuery.of(context).size.width - 10,
                decoration: BoxDecoration(
                  color: Palette.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Wrap(
                    crossAxisAlignment: WrapCrossAlignment.start,
                    alignment: WrapAlignment.spaceEvenly,
                    runSpacing: 10,
                    children: [
                      for (var ci in catImg)
                        Padding(
                          padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
                          child: GestureDetector(
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => ProductList(
                                            name: ci['category'],
                                            state: 0,
                                          )));
                            },
                            child: Column(
                              children: [
                                Container(
                                  width: 70,
                                  height: 70,
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(50),
                                      image: DecorationImage(
                                          image: NetworkImage(ci['url']),
                                          fit: BoxFit.fill)),
                                ),
                                SizedBox(
                                  width: 70,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Flexible(
                                          child: Text(
                                        ci['category'],
                                        style: Util.txt(
                                            Palette.black, 14, FontWeight.w500),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ))
                                    ],
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          category.isNotEmpty
              ? Column(
                  children: [
                    for (int i = 0; i < category.length; i++)
                      Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(10, 0, 12, 6),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Flexible(
                                    child: Text(
                                  category[i]['name'],
                                  style: Util.txt(
                                      Palette.black, 16, FontWeight.w500),
                                  maxLines: 1,
                                )),
                                InkWell(
                                    onTap: () {
                                      Navigator.push(context, MaterialPageRoute(builder: (context) => ProductList(
                                                    name: category[i]['name'],
                                                    state: 0,
                                                  )));
                                    },
                                    child: Icon(
                                      Icons.navigate_next,
                                      color: Palette.black,
                                    )),
                              ],
                            ),
                          ),
                          Align(
                            alignment: Alignment.topLeft,
                            child: SizedBox(
                              height: 216,
                              child: ListView(
                                shrinkWrap: true,
                                scrollDirection: Axis.horizontal,
                                physics: const ClampingScrollPhysics(),
                                children: [
                                  for (int j = 0;
                                      j < category[i]['data'].length;
                                      j++)
                                    GestureDetector(
                                      onTap: () {
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    DetailedView(
                                                        name: '',
                                                        id: category[i]['data']
                                                            [j]['uuid'],
                                                        state: 2)));
                                      },
                                      child: Padding(
                                        padding: const EdgeInsets.all(1.0),
                                        child: Stack(
                                          children: [
                                            Column(
                                              children: <Widget>[
                                                Card(
                                                  elevation: 0,
                                                  shape: RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10.0)),
                                                  child: Container(
                                                    height: 160.0,
                                                    width: 120.0,
                                                    decoration: BoxDecoration(
                                                      // image: DecorationImage(
                                                      //   image:NetworkImage(category[i]['data'][j]['image']),//
                                                      //   fit: BoxFit.fill,
                                                      // ),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10.0),
                                                      color: Colors.white,
                                                    ),
                                                    child: ClipRRect(
                                                      borderRadius:
                                                          const BorderRadius
                                                                  .all(
                                                              Radius.circular(
                                                                  10.0)),
                                                      child: FancyShimmerImage(
                                                        height: 160,
                                                        width: 120,
                                                        imageUrl: category[i]
                                                                ['data'][j]
                                                            ['image'],
                                                        shimmerBaseColor:
                                                            Colors.grey[300],
                                                        shimmerHighlightColor:
                                                            Colors.grey[100],
                                                        errorWidget: Image.network(
                                                            'https://i0.wp.com/www.dobitaobyte.com.br/wp-content/uploads/2016/02/no_image.png?ssl=1'),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                SizedBox(
                                                  width: 120.0,
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: [
                                                      Flexible(
                                                        child: Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(1.0),
                                                          child: Text(
                                                            category[i]['data']
                                                                [j]['name'],
                                                            style: Util.txt(
                                                                Palette.black,
                                                                14,
                                                                FontWeight
                                                                    .w300),
                                                            textAlign: TextAlign
                                                                .center,
                                                            softWrap: true,
                                                            overflow:
                                                                TextOverflow
                                                                    .clip,
                                                            maxLines: 2,
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                            if (category[i]['data'][j]
                                                    ['discount'] !=
                                                '' && category[i]['data'][j]
                                                    ['discount'] !=
                                                '0')
                                              Positioned(
                                                top: 2,
                                                right: 2,
                                                child: Card(
                                                  color: Palette.green,
                                                  clipBehavior: Clip.none,
                                                  elevation: 0,
                                                  margin: EdgeInsets.zero,
                                                  shape: const RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.only(
                                                              topLeft: Radius
                                                                  .circular(10),
                                                              bottomLeft: Radius
                                                                  .circular(
                                                                      10))),
                                                  child: Padding(
                                                    padding: const EdgeInsets
                                                        .fromLTRB(10, 6, 10, 6),
                                                    child: Text(
                                                      category[i]['data'][j]
                                                              ['discount'] +
                                                          '%  OFF',
                                                      style: Util.txt(
                                                          Palette.white,
                                                          12,
                                                          FontWeight.normal),
                                                    ),
                                                  ),
                                                ),
                                              )
                                          ],
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                  ],
                )
              : loader
                  ? const Center(
                      child: CupertinoActivityIndicator(),
                    )
                  : Center(
                      child: Text(
                      'No data found',
                      style: Util.txt(Palette.black, 14, FontWeight.w500),
                    )),
          const SizedBox(
            height: 44,
          ),
        ],
      ),
    );
  }
  deliveryavailabilitymethod(){
    if(deliveraddress.toString() == ''){
    if(Util.control.deliveryAdd.value == 'Check Delivery Availability'){confDial('Info','Choose Check Delivery Availability');}else{}
    }else{
      setState(() {
        Util.control.deliveryAdd.value = deliveraddress.toString();
      });
    }
  }
  confDial( String title, String message,) {
    showDialog(
      context: context,
      barrierDismissible: true, // Allows the dialog to be dismissed by tapping outside of it
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            title,
            style: Util.txt(Palette.black, 16, FontWeight.w600),
          ),
          content: Text(
            message,
            style: Util.txt(Palette.black, 16, FontWeight.w400),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Closes the dialog
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const MyMapPicker()),
                ); // Navigates to the next screen
              },
              child: Text(
                'Ok',
                style: Util.txt(Palette.black, 16, FontWeight.w600),
              ),
            ),
          ],
          // Optional: Add elevation and shape to match your design
          elevation: 24.0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
        );
      },
    );
  }
  void openActions() {
    showDialog(
        context: context,
        builder: (context) => Dialog(
              child: SizedBox(
                width: MediaQuery.of(context).size.width,
                height: 240,
                child: CupertinoPageScaffold(
                  navigationBar: CupertinoNavigationBar(
                    automaticallyImplyLeading: false,
                    // leading: Container(),
                    middle: Row(
                      children: [
                        Text(
                          'Pincode',
                          style: Util.txt(Palette.black, 16, FontWeight.w500),
                        ),
                      ],
                    ),
                    trailing: IconButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        padding: EdgeInsets.zero,
                        alignment: Alignment.centerRight,
                        icon: const Icon(
                          Icons.close,
                          color: Colors.red,
                          size: 22,
                        )),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(10, 60, 10, 10),
                    child: Column(
                      children: [
                        CupertinoTextField(
                          controller: pincode,
                          placeholder: 'Enter Pincode',
                          placeholderStyle:
                              Util.txt(Palette.black, 16, FontWeight.w500),
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly
                          ],
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        ElevatedButton(
                            onPressed: () {
                              FocusScope.of(context).requestFocus(FocusNode());
                              if (pincode.text.isNotEmpty) {
                                shipmentCheck();
                              } else {
                                Util.showDog(_scaffoldKey.currentContext!,
                                    'Please enter pincode');
                              }
                            },
                            style: ButtonStyle(
                                backgroundColor:
                                    MaterialStateProperty.all(Palette.color2)),
                            child: Text(
                              'Apply',
                              style:
                                  Util.txt(Palette.white, 16, FontWeight.w600),
                            ))
                      ],
                    ),
                  ),
                ),
              ),
            ));
  }
  mapActions() {
    Util.logDebug('map');
    Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => const MyMapPicker())); //MyMap())); //StreetMap()));
  }
  shipmentCheck() async {
    Util.showProgress(context);
    final shipCheck = http.MultipartRequest(
        'POST', Uri.parse('${Util.baseurl}shipping/shipment-check.php'));
    shipCheck.fields['delivery_postcode'] = pincode.text;
    shipCheck.fields['weight'] = '1';
    var res = await shipCheck.send();
    var response = await http.Response.fromStream(res);
    try {
      if (response.statusCode == 200) {
        Util.dismissDialog(_scaffoldKey.currentContext!);
        var dec = jsonDecode(response.body);
        Util.logDebug(dec);
        if (dec['status'] == 0) {
          Util.control.deliveryAdd.value = 'Delivery to ${pincode.text}';
          Navigator.pop(_scaffoldKey.currentContext!);
        } else {
          Navigator.pop(_scaffoldKey.currentContext!);
          Util.showDog(_scaffoldKey.currentContext!, dec['message']);
        }
      } else {
        Util.dismissDialog(_scaffoldKey.currentContext!);
        Navigator.pop(_scaffoldKey.currentContext!);
        Util.showDog(_scaffoldKey.currentContext!, 'Try again');
      }
    } catch (e) {
      Util.logDebug(e);
    }
  }
}
