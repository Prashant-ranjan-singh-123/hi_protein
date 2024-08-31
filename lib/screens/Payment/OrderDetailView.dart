import 'dart:async';
import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:timeline_tile/timeline_tile.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import '../../Connectivity/No_internet.dart';
import '../../Connectivity/connectivity_provider.dart';
import '../../Model/orderdetails.dart';
import '../../utilities/constants.dart';
import '../../utilities/palette.dart';
import '../Home/bottom_nav_4th_item_cart/CartList.dart';
import 'OrderList.dart';

class OrderDetailView extends StatefulWidget {
   const OrderDetailView({Key? key, required this.share}) : super(key: key);
  final  Map<String,dynamic>share;
  @override
  _OrderDetailViewState createState() => _OrderDetailViewState();
}

class _OrderDetailViewState extends State<OrderDetailView> {
  final GlobalKey<ScaffoldState> _scaffoldkey =  GlobalKey<ScaffoldState>();
  List<OrderDetails> orders=[];
  List shipmentActivities=[];
  bool loader = true,showTrack=false;
  String orderstatus = '';
  Timer? timer;
  int count=0;
  @override
  void initState() {
    Provider.of<ConnectivityProvider>(context, listen: false).startMonitoring();
    super.initState();
    getData();
  }
  getData()async{
    orders=[];shipmentActivities=[];
    String userid = await Util.getStringValuesSF('userid');
    try{
      final productList = http.MultipartRequest('POST',Uri.parse('${Util.baseurl}order_details_by_id.php'));
      productList.fields['userid']=userid;
      productList.fields['client']=Util.clientName;
      productList.fields['id']=widget.share['id'];
      final snd = await productList.send();
      final response = await http.Response.fromStream(snd);
      if(response.statusCode==200){
        var dec = jsonDecode(response.body);
        //print('dec:$dec');
        if(dec['success']){
          orders=List<OrderDetails>.from(dec['data'].map((i)=>OrderDetails.fromJson(i)));
          shipmentActivities.addAll(dec['data'][0]['shipment_track_activities']);
          orderstatus = dec['data'][0]['status'];
        }
        else{setState((){if(count==3){errorDlog('Something went wrong');}else{count++;Util.showProgress(context);startTimer();}});}
      }
    }catch(e){Util.logDebug(e);}
    if(mounted){
      setState((){loader=false;});
    }
  }
  void startTimer(){
    timer=Timer(const Duration(seconds:6),(){
      timer?.cancel();
      Util.dismissDialog(context);
      getData();
      setState((){});
    });
  }
  errorDlog(String message){
    showDialog(
      context: context,
      barrierDismissible: false, // Prevents dismissal by tapping outside
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Failed',
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
                    builder: (context) => const MyOrdersList(), // Navigate to MyOrdersList
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
  navBack(){Navigator.push(context, MaterialPageRoute(builder:(context)=>const MyOrdersList()));}
  @override
  Widget build(BuildContext context){
    return WillPopScope(
      onWillPop: ()async{
        navBack();
        return true;
      },
      child: Scaffold(
        key: _scaffoldkey,
        backgroundColor: Palette.background,
        appBar: AppBar(
          backgroundColor: Palette.background,
          elevation: 0,
          leading: IconButton(onPressed: navBack,icon: Icon(Ionicons.arrow_back,color: Palette.black,),),
          title: Text('Order Details',style: Util.txt(Palette.black, 18, FontWeight.w600),),
          actions:[
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: TextButton(onPressed: (){
                reOrder();
              },
                style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(Palette.color1)
                ), child: Text('Buy Again',style: Util.txt(Palette.color2, 14, FontWeight.w600),),),
            ),
          ],
        ),
        body: SafeArea(child: checkConnection()),
      ),
    );
  }

  Widget checkConnection() {
    return Consumer<ConnectivityProvider>(
      builder: (consumerContext, model, child) {
        return model.isOnline
            ? page()
            : const NoInternet();
      },
    );
  }
  manageTrack(){
    setState((){
      showTrack?showTrack=false:showTrack=true;
    });
  }
  page() {
    return orders.isNotEmpty?Padding(
      padding: const EdgeInsets.all(10.0),
      child: ListView(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Palette.color1,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Table(
                border: TableBorder.all(color: Palette.color1),
                // defaultColumnWidth: FixedColumnWidth(120),
                columnWidths: const {0:FixedColumnWidth(140),1:FixedColumnWidth(150)},
                children: [
                  TableRow(
                      children: [
                        Row(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(5.0),
                              child: Text('Order #',style: Util.txt(Palette.color2,14, FontWeight.w400),),
                            )
                          ],
                        ),
                        Row(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(5.0),
                              child: Text(orders[0].orderid,style: Util.txt(Palette.color2,16, FontWeight.w500),),
                            )
                          ],
                        ),
                      ]
                  ),
                  TableRow(
                      children: [
                        Row(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(5.0),
                              child: Text('Date',style: Util.txt(Palette.color2,14, FontWeight.w400),),
                            )
                          ],
                        ),
                        Row(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(5.0),
                              child: Text(orders[0].date,style: Util.txt(Palette.color2,15, FontWeight.w400),),
                            )
                          ],
                        ),
                      ]
                  ),
                    TableRow(
                        children: [
                          Row(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(5.0),
                                child: Text('Amount ',style: Util.txt(Palette.color2,14, FontWeight.w400),),
                              )
                            ],
                          ),
                          Row(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(5.0),
                                child: Text(orders[0].amount,style: Util.txt(Palette.color2,16, FontWeight.w500),),
                              )
                            ],
                          ),
                        ]
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10,),
          if(orderstatus != 'cancelled')
          Row(
            children: [
              Padding(
                padding: const EdgeInsets.all(5.0),
                child: Text('Shipping details',style: Util.txt(Palette.color2,16, FontWeight.w600),),
              )
            ],
          ),
          if(orderstatus != 'cancelled')
          Card(
            margin: EdgeInsets.zero,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              children: [
                GestureDetector(
                  onTap:manageTrack,
                  child: Card(
                    color: Palette.color1,margin: EdgeInsets.zero,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Palette.color1,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                      Text('Delivery Estimate: ${orders[0].deliverydate}',style: Util.txt(Palette.black, 14, FontWeight.w500),),
                                    ],
                                  ),
                                  const SizedBox(height: 2,),
                                  Row(
                                    children: [
                                      Text('Tracking : ${orders[0].trackingid}',style: Util.txt(Palette.black, 14, FontWeight.w500),),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            GestureDetector(onTap:manageTrack,child: Icon(showTrack?Entypo.chevron_small_up:Entypo.chevron_small_down,color: Palette.black,))
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                if(showTrack)
                tractActivities(),
              ],
            ),
          ),
          const SizedBox(height: 10,),
          Row(
            children: [
              Padding(
                padding: const EdgeInsets.all(5.0),
                child: Text('Shipping Address',style: Util.txt(Palette.color2,16, FontWeight.w600),),
              )
            ],
          ),
          Container(
            decoration: BoxDecoration(
              color: Palette.color1,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(5.0),
                        child: Text('${orders[0].address[0].first_name} ${orders[0].address[0].last_name}',style: Util.txt(Palette.color2,14, FontWeight.w400),),
                      )
                    ],
                  ),
                  Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(5.0),
                        child: Text(orders[0].address[0].email,style: Util.txt(Palette.color2,14, FontWeight.w400),),
                      )
                    ],
                  ),
                  Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(5.0),
                        child: Text(orders[0].address[0].mobilenumber,style: Util.txt(Palette.color2,14, FontWeight.w400),),
                      )
                    ],
                  ),
                  Row(
                    children: [
                      Flexible(
                        child: Padding(
                          padding: const EdgeInsets.all(5.0),
                          child: Text(orders[0].address[0].address,style: Util.txt(Palette.color2,14, FontWeight.w400),),
                        ),
                      )
                    ],
                  ),
                  Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(5.0),
                        child: Text(orders[0].address[0].city,style: Util.txt(Palette.color2,14, FontWeight.w400),),
                      )
                    ],
                  ),
                  Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(5.0),
                        child: Text(orders[0].address[0].state,style: Util.txt(Palette.color2,14, FontWeight.w400),),
                      )
                    ],
                  ),
                  Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(5.0),
                        child: Text(orders[0].address[0].pincode,style: Util.txt(Palette.color2,14, FontWeight.w400),),
                      )
                    ],
                  ),
                  Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(5.0),
                        child: Text(orders[0].address[0].country,style: Util.txt(Palette.color2,14, FontWeight.w400),),
                      )
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10,),
          for(int i=0;i<orders[0].itemslist.length;i++)
            Column(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 0, 10, 0),
                  child: Row(
                    children: <Widget>[
                      CachedNetworkImage(
                        imageUrl: orders[0].itemslist[i].image,
                        fit: BoxFit.fill,
                        width: 150,
                        height: 150,
                        placeholder: (context, url) => const CupertinoActivityIndicator(),
                        errorWidget: (context, url, error) => Image.asset("images/wemart.jpeg"),
                      ),
                      Expanded(
                          child: SizedBox(height: 160,
                            child: Column(
                              // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Row(
                                  children: <Widget>[
                                    Flexible(
                                      child: Padding(
                                        padding: const EdgeInsets.all(5.0),
                                        child: Text(orders[0].itemslist[i].name,style: Util.txt(Palette.black, 16, FontWeight.w500),softWrap: true),
                                      ),
                                    ),
                                  ],
                                ),
                                Padding(
                                  padding: const EdgeInsets.fromLTRB(5, 0, 0, 6),
                                  child: Row(
                                    children: <Widget>[
                                      Text('\u20B9 ',style: Util.txt(Colors.red, 16, FontWeight.w500),),
                                      Text(orders[0].itemslist[i].price,style: Util.txt(Palette.black, 14, FontWeight.w500),),
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.fromLTRB(5, 0, 0, 0),
                                  child: Row(
                                    children: <Widget>[
                                      Text('Quantity : ',style: Util.txt(Palette.black, 14, FontWeight.w400),),
                                      Text(orders[0].itemslist[i].count,style: Util.txt(Palette.black, 14, FontWeight.w500),),
                                    ],
                                  ),
                                ),

                              ],
                            ),
                          )),
                    ],
                  ),
                ),
                const Divider(height: 2,),
              ],
            ),
        ],
      ),
    ):Center(
      child: loader?const CupertinoActivityIndicator():const Text('No orders found'),
    );
  }
  Widget tractActivities(){
    return shipmentActivities.isNotEmpty?SizedBox(height: 300,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(8, 0, 2, 8),
        child: ListView(
          // mainAxisSize: MainAxisSize.min,
          children: [
            for(int ta=0;ta<shipmentActivities.length;ta++)
            TimelineTile(
              axis: TimelineAxis.vertical,
              alignment: TimelineAlign.manual,
              isFirst: ta==0?true:false,isLast: shipmentActivities.length-1==ta?true:false,
              lineXY: 0.0,
              indicatorStyle: IndicatorStyle(
                width: 12,
                color: ta==0?Palette.color2:Palette.loader,
                padding: const EdgeInsets.all(4.0),
                indicatorXY: 0.33
              ),
              beforeLineStyle: LineStyle(
                color: Palette.color1,
                thickness: 1.2,
              ),
              afterLineStyle: LineStyle(
                color: Palette.color1,
                thickness: 1.2,
              ),
              endChild: Padding(
                padding: const EdgeInsets.fromLTRB(14, 14, 0, 14),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Flexible(child: Text('${shipmentActivities[ta]['activity']}  ${shipmentActivities[ta]['date']}',style: Util.txt(Palette.black, 14, FontWeight.w400),)),
                        ],
                    ),
                    const SizedBox(height: 6,),
                    Row(
                      children: [
                        Text(shipmentActivities[ta]['location'],style: Util.txt(Palette.black, 14, FontWeight.w400),),
                      ],
                    ),

                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    ):Container();
  }
  reOrder()async{
    Util.showProgress(context);
    List itemCodes=[];
    for(int i=0;i<orders[0].itemslist.length;i++){
      itemCodes.add(orders[0].itemslist[i].itemcode);
    }
    String userid = await Util.getStringValuesSF('userid');
    Map<String,dynamic>map={'userid':userid,'itemcodelist':itemCodes,'client':Util.clientName};
    var response = await http.post(Uri.parse('${Util.baseurl}reOrder.php'),body: jsonEncode(map));
    try{
      if(response.statusCode==200){
        Util.dismissDialog(_scaffoldkey.currentContext!);
        var deco = jsonDecode(response.body);
        if(deco['success']=='true')
        {
          confDial('Success', deco['message']);
         // Util.customDialog('Success', deco['message'], _scaffoldkey.currentContext!);
          // Navigator.push(context, MaterialPageRoute(builder: (context)=>ContentScreen(bin: 4,)));
        }
        else{
          Util.customDialog('Fail', deco['message'], _scaffoldkey.currentContext!);
        }
      }
      else{
        Util.dismissDialog(_scaffoldkey.currentContext!);
      }
    }catch(e){
      Util.logDebug(e);
    }
  }
    confDial( String title, String message,) {
      showDialog(
        context: context,
        barrierDismissible: true, // Allows dismissing by tapping outside
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
                  Navigator.pop(context); // Closes the dialog
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
