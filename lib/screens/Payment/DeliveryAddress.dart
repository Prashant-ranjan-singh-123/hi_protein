import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:get/get.dart';
import 'package:hi_protein/screens/Payment/payment_details.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:razorpay_flutter/razorpay_flutter.dart';
import '../../Connectivity/No_internet.dart';
import '../../Connectivity/connectivity_provider.dart';
import '../../Model/Product_Model.dart';
import '../../utilities/AppManagement.dart';
import '../../utilities/constants.dart';
import '../../utilities/google_search_places.dart';
import '../../utilities/palette.dart';
import '../Home/bottom_nav_4th_item_cart/CartList.dart';
import 'AddressForm.dart';
import 'OrderList.dart';

class DeliveryAddress extends StatefulWidget {
  const DeliveryAddress({Key? key}) : super(key: key);
  @override
  _DeliveryAddressState createState() => _DeliveryAddressState();
}
class _DeliveryAddressState extends State<DeliveryAddress> {
  final GlobalKey<ScaffoldState> _scafoldkey = GlobalKey<ScaffoldState>();
  List<AddressModel> adresList = [];
  List<bool> selLoc = [];
  List<ContactUsModel> contactUs = [];
  List<PaymentModel> payKeys = [];
  String paymentStatus = '', sentId = '', orderID = '', weight = '0.5',tidvalue = '';
  final Razorpay _razorpay = Razorpay();
  final Controller c = Get.put(Controller());
  bool loader = true;
  int ins = 0;
  @override
  void initState() {
    Provider.of<ConnectivityProvider>(context, listen: false).startMonitoring();
    super.initState();
    getData();
    /*_razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);*/
  }
  getData() async {
    c.delAddress.value = '';
    adresList = [];
    selLoc = [];
    payKeys = [];
    contactUs = [];
    String userid = await Util.getStringValuesSF('userid');
    try {
      final productList = http.MultipartRequest('POST', Uri.parse('${Util.baseurl}addresslist.php'));
      productList.fields['userid'] = userid;
      productList.fields['client'] = Util.clientName;
      final snd = await productList.send();
      final response = await http.Response.fromStream(snd);
      if (response.statusCode == 200) {
        var dec = jsonDecode(response.body);
        if (dec['success']) {
          for (int i = 0; i < dec['data'].length; i++) {
            adresList.add(AddressModel(
                id: dec['data'][i]['id'],
                mobile: dec['data'][i]['mobile'],
                address: dec['data'][i]['address'],
                state: dec['data'][i]['state'],
                ln: dec['data'][i]['lastname'],
                city: dec['data'][i]['city'],
                country: dec['data'][i]['country'],
                fn: dec['data'][i]['firstname'],
                pincode: dec['data'][i]['pincode'],
                latitude: dec['data'][i]['lat'],
                longitude: dec['data'][i]['lng']));
            selLoc.add(false);
          }
          if (dec['contactus'].length > 0) {
            contactUs.add(ContactUsModel(
                email: dec['contactus'][0]['email'],
                mobile: dec['contactus'][0]['mobilenumber'],
                address: dec['contactus'][0]['address']));
          }
          payKeys.add(PaymentModel(
              keyId: dec['paymentKeys'][0]['MerchantId'],
              keySecret: dec['paymentKeys'][0]['access_code'],
              url: dec['paymentKeys'][0]['url']));
          orderID = dec['orderid'];
          tidvalue = dec['tid'];
          weight = dec['weight'];
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
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => const CartList()));
        return true;
      },
      child: Scaffold(
        key: _scafoldkey,
        backgroundColor: Palette.background,
        appBar: AppBar(
          backgroundColor: Palette.background,
          elevation: 0,
          leading: IconButton(
            onPressed: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => const CartList()));
            },
            icon: Icon(
              Ionicons.arrow_back,
              color: Palette.black,
            ),
          ),
          title: Text(
            'Choose Delivery Address',
            style: Util.txt(Palette.black, 18, FontWeight.w600),
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
        floatingActionButton: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Row(
              mainAxisAlignment: adresList.isNotEmpty
                  ? MainAxisAlignment.spaceEvenly
                  : MainAxisAlignment.end,
              children: [
                adresList.isNotEmpty
                    ? SizedBox(
                        height: 40,
                        width: MediaQuery.of(context).size.width * 0.60,
                        child: InkWell(
                          onTap: () {
                            if (c.delAddress.value == '') {
                              Util.customDialog('Info','Please Select Delivery Address', context);
                            } else {
                              checkShipment();
                              //createRequest();
                            }
                          },
                          child: Card(
                            elevation: 5,
                            child: Center(
                                child: Text(
                              'Deliver to this address',
                              textAlign: TextAlign.center,
                              style:
                                  Util.txt(Palette.black, 16, FontWeight.w500),
                            )),
                          ),
                        ),
                      )
                    : Container(),
                FloatingActionButton.small(
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const MapSearchPlaces(), //MyMap()
                                  //type: 'add',
                                  //state: 0,
                                  //address: const [],
                                ));
                  },
                  backgroundColor: Palette.white,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6.0)),
                  child: Icon(
                    Icons.add_location_alt_outlined,
                    color: Palette.black,
                  ),
                )
              ],
            ),
          ],
        ),
        body: checkConnection(),
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
  page() {
    return adresList.isNotEmpty
        ? Padding(
            padding: const EdgeInsets.all(8.0),
            child: ListView(
              children: [
                for (int i = 0; i < adresList.length; i++)
                  Column(
                    children: [
                      Container(
                        color: Palette.white,
                        child: IntrinsicHeight(
                          child: Padding(
                            padding: const EdgeInsets.all(2.0),
                            child: Row(
                              children: [
                                Checkbox(
                                  value: selLoc[i],
                                  onChanged: (v) {
                                    manage(i);
                                  },
                                  materialTapTargetSize:MaterialTapTargetSize.shrinkWrap,
                                ),
                                const VerticalDivider(),
                                Expanded(
                                  child: Column(
                                    children: [
                                      Row(
                                        children: [
                                          Flexible(
                                              child: Text(
                                            '${adresList[i].fn} ${adresList[i].ln}',
                                            style: Util.txt(Palette.black, 14,
                                                FontWeight.w400),
                                          )),
                                        ],
                                      ),
                                      const SizedBox(
                                        height: 2,
                                      ),
                                      Row(
                                        children: [
                                          Flexible(
                                              child: Text(
                                            adresList[i].address,
                                            style: Util.txt(Palette.black, 14,
                                                FontWeight.w400),
                                          )),
                                        ],
                                      ),
                                      const SizedBox(
                                        height: 2,
                                      ),
                                      Row(
                                        children: [
                                          Flexible(
                                              child: Text(
                                            adresList[i].city,
                                            style: Util.txt(Palette.black, 14,
                                                FontWeight.w400),
                                          )),
                                        ],
                                      ),
                                      const SizedBox(
                                        height: 2,
                                      ),
                                      Row(
                                        children: [
                                          Flexible(
                                              child: Text(
                                            adresList[i].state,
                                            style: Util.txt(Palette.black, 14,
                                                FontWeight.w400),
                                          )),
                                        ],
                                      ),
                                      const SizedBox(
                                        height: 2,
                                      ),
                                      Row(
                                        children: [
                                          Flexible(
                                              child: Text(
                                            adresList[i].pincode,
                                            style: Util.txt(Palette.black, 14,
                                                FontWeight.w400),
                                          )),
                                        ],
                                      ),
                                      const SizedBox(
                                        height: 2,
                                      ),
                                      Row(
                                        children: [
                                          Flexible(
                                              child: Text(
                                            adresList[i].country,
                                            style: Util.txt(Palette.black, 14,
                                                FontWeight.w400),
                                          )),
                                        ],
                                      ),
                                      const SizedBox(
                                        height: 2,
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Row(
                                            children: [
                                              Icon(
                                                Ionicons.call_outline,
                                                color: Palette.gray,
                                              ),
                                              Text(
                                                adresList[i].mobile,
                                                style: Util.txt(Palette.black,
                                                    12, FontWeight.w400),
                                              ),
                                            ],
                                          ),
                                          Row(
                                            children: [
                                              Padding(
                                                padding:
                                                    const EdgeInsets.fromLTRB(
                                                        0, 0, 16, 0),
                                                child: InkWell(
                                                    onTap: () {
                                                      Navigator.push(
                                                          context,
                                                          MaterialPageRoute(
                                                              builder: (context) =>
                                                                  AddressForm(
                                                                      type:
                                                                          'edit',
                                                                      state: i,
                                                                      address:
                                                                          adresList)));
                                                    },
                                                    child: const Icon(
                                                      Feather.edit,
                                                      color: Colors.blue,
                                                      size: 20,
                                                    )),
                                              ),
                                              Padding(
                                                padding:
                                                    const EdgeInsets.fromLTRB(
                                                        0, 0, 10, 0),
                                                child: InkWell(
                                                    onTap: () => confirmation(
                                                        adresList[i].id),
                                                    child: const Icon(
                                                      Feather.trash_2,
                                                      color: Colors.red,
                                                      size: 20,
                                                    )),
                                              ),
                                            ],
                                          )
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
                      const SizedBox(
                        height: 10,
                      ),
                    ],
                  ),
                const SizedBox(
                  height: 50,
                ),
              ],
            ),
          )
        : loader
            ? const Center(
                child: CupertinoActivityIndicator(),
              )
            : Center(
                child: Text(
                'Add Delivery Address',
                style: Util.txt(Palette.black, 14, FontWeight.w500),
              ));
  }

  navToPay(Map<String, dynamic> sh,Map<String, dynamic> shipper) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => PaymentDetails(
                  address: adresList,
                  state: ins,
                  share: sh,
                  shippervalue: shipper,
                )));
  }

  manage(int a){
    c.delAddress.value = adresList[a].address;
    c.delMobile.value = adresList[a].mobile;
    c.latitude.value = adresList[a].latitude;
    c.longitude.value = adresList[a].longitude;
    c.iscity.value = adresList[a].city;
    c.isstate.value = adresList[a].state;
    c.ispincode.value = adresList[a].pincode;
    c.isfirstname.value = adresList[a].fn;
    
    ins = a;
    setState(() {
      for (int b = 0; b < selLoc.length; b++) {
        if (b == a) {
          selLoc[a] = true;
        } else {
          selLoc[b] = false;
        }
      }
    });
  }
  checkShipment() async {
    Util.showProgress(context);
   // String latvalue = await Util.getStringValuesSF('latvalue');
   // String longvalue = await Util.getStringValuesSF('longvalue');
    final shipCheck = http.MultipartRequest('POST', 
    Uri.parse('${Util.baseurl}shipping/dunzo/quote.php'));
    Util.logDebug('ship api: $shipCheck');
    shipCheck.fields['droplat'] = c.latitude.value;
    shipCheck.fields['droplng'] = c.longitude.value;
    var res = await shipCheck.send();
    var response = await http.Response.fromStream(res);
    Util.logDebug('deliver response: $response');
    try {
      if (response.statusCode == 200){
        Util.dismissDialog(_scafoldkey.currentContext!);
        var dec = jsonDecode(response.body);
        Util.logDebug('deliver response1: $dec');
        if (dec['success'] == true) {
          navToPay(dec,dec);
        } else {
          Util.showDog(_scafoldkey.currentContext!, dec['message']);
        }
      } else {
        Util.dismissDialog(_scafoldkey.currentContext!);
        Util.showDog(_scafoldkey.currentContext!, 'Try again');
      }
    } catch (e) {
      Util.logDebug(e);
    }
  }

  confirmation(String id){
    showDialog(
      context: context,
      barrierDismissible: true, // Allows dismissing by tapping outside
      builder: (BuildContext context) {
        return AlertDialog(
          content: Text(
            'Delete address',
            style: Util.txt(Palette.black, 16, FontWeight.w600),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Closes the dialog
              },
              child: Text(
                'Cancel',
                style: Util.txt(Palette.black, 16, FontWeight.w600),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Closes the dialog
                deleteAddress(id); // Call your delete address function
              },
              child: Text(
                'Delete',
                style: Util.txt(Palette.black, 16, FontWeight.w600),
              ),
            ),
          ],
        );
      },
    );
  }

  deleteAddress(String id) async {
    Util.showProgress(context);
    try {
      final productList = http.MultipartRequest(
          'POST', Uri.parse('${Util.baseurl}deleteaddress.php'));
      productList.fields['id'] = id;
      productList.fields['type'] = '3';
      final snd = await productList.send();
      final response = await http.Response.fromStream(snd);
      if (response.statusCode == 200) {
        Util.dismissDialog(_scafoldkey.currentContext!);
        var dec = jsonDecode(response.body);
        if (dec['success']) {
          Util.showDog(_scafoldkey.currentContext!, dec['message']);
        } else {
          Util.showDog(_scafoldkey.currentContext!, dec['message']);
        }
      } else {
        Util.dismissDialog(_scafoldkey.currentContext!);
      }
    } catch (e) {
      Util.dismissDialog(_scafoldkey.currentContext!);
    }
    getData();
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) async {
    // Util.customDialog('Payment Success','Your Payment ID : '+response.paymentId.toString(), context);
    paymentStatus = response.paymentId.toString();
    updata();
  }

  void _handlePaymentError(PaymentFailureResponse response) async {
    // String email = await Util.getStringValuesSF("email");
    String msg = response.code.toString() +
        " - " +
        response.message.toString() +
        '\n\n' +
        'In case of any transaction disputes' +
        '\n' +
        contactUs[0].mobile;
    Util.customDialog('Payment Failed', msg, context);
    paymentStatus = 'Payment Failed';
    uDateTemCart('0');
    // Map<String,String>map = {'email':email,'instance':'payment failed','error':response.code.toString()+' - '+response.message.toString()};
    // var respo = await http.post(Uri.parse(Util.baseurl+'logs.php'),body: jsonEncode(map));
    // if(respo.statusCode==200){}
  }

  void _handleExternalWallet(ExternalWalletResponse response) async {
    String email = await Util.getStringValuesSF("email");
    Util.customDialog(
        'Info', response.walletName.toString(), _scafoldkey.currentContext!);
    // Map<String,String>map = {'email':email,'instance':'payment wallet','error':response.walletName.toString()};
    // var respo = await http.post(Uri.parse(Util.baseurl+'logs.php'),body: jsonEncode(map));
    // if(respo.statusCode==200){}
  }

  createRequest() async {
    if (payKeys[0].keyId == '') {
      Util.showDog(
          _scafoldkey.currentContext!, 'Payment gateway is under Maintenance');
      return;
    }
    String keyId = payKeys[0].keyId,
        keySecret = payKeys[0].keySecret,
        url = payKeys[0].url;
    String basicAuth =
        'Basic ${base64Encode(utf8.encode('$keyId:$keySecret'))}';
    var data = {
      'amount': (c.checkOutPrice.value * 100).toInt().toString(),
      'currency': 'INR'
    };
    var response = await http.post(Uri.parse(url),
        body: data,
        headers: {'Authorization': basicAuth, 'Accept': "application/json"});
    sentId = jsonDecode(response.body)['id'];
    uDateTemCart('1');
    openCheckout();
  }

  uDateTemCart(String status) async {
    String userid = await Util.getStringValuesSF('userid');
    String stam;
    Map<String, String> map = {
      'userid': userid,
      'address': c.delAddress.value,
      'totalamount': c.checkOutPrice.toString(),
      'Rpayorderid': sentId,
      'status': status,
      'orderid': orderID,
      'client': Util.clientName
    };
    var respon = await http.post(Uri.parse('${Util.baseurl}updatetempcart.php'),
        body: jsonEncode(map));
    stam = respon.statusCode.toString();
    try {
      if (respon.statusCode == 200) {
        print('updatetempcart value: ${respon.body}');
      } else {
        Map<String, String> map = {
          'email': userid,
          'instance': 'order id',
          'error': '$stam not updated after getting orderid'
        };
        var response = await http.post(Uri.parse('${Util.baseurl}logs.php'),
            body: jsonEncode(map));
        if (response.statusCode == 200) {}
      }
    } catch (e) {
      Map<String, String> map = {
        'email': userid,
        'instance': 'payment error',
        'error': e.toString()
      };
      var response = await http.post(Uri.parse('${Util.baseurl}logs.php'),
          body: jsonEncode(map));
      if (response.statusCode == 200) {}
    }
  }

  void openCheckout() async {
    String email = await Util.getStringValuesSF('email');
    String mobile = await Util.getStringValuesSF('mobile');
    var options = {
      'key': payKeys[0].keyId,
      'amount': (c.checkOutPrice.value) * 100, //*100(c.checkOutPrice.value)*
      'name': 'PAYMENT',
      'payment_capture': 1,
      'order_id': sentId,
      // 'timeout': 180,
      'prefill': {'contact': mobile, 'email': email},
      'external': {
        'wallets': ['paytm']
      }
    };

    try {
      _razorpay.open(options);
    } catch (e) {
      Map<String, String> map = {
        'email': email,
        'instance': 'payment error',
        'error': e.toString()
      };
      var response = await http.post(Uri.parse('${Util.baseurl}logs.php'),
          body: jsonEncode(map));
      if (response.statusCode == 200) {}
    }
  }

  void updata() async {
    Util.showProgress(context);
    String tempo;
    String userid = await Util.getStringValuesSF('userid');
    Map<String, dynamic> map = {
      'userid': userid,
      'mobilenumber': c.delMobile.value,
      'orderid': orderID.toString(),
      'address': c.delAddress.value,
      'paymentstatus': paymentStatus,
      'totalamount': c.checkOutPrice.toString(),
      'Rpayorderid': sentId,
      'orderstatus': 'Placed',
      'feedbackstatus': '0',
      'client': Util.clientName
    };
    var respo = await http.post(Uri.parse('${Util.baseurl}placeorder.php'),
        body: jsonEncode(map));
    tempo = respo.statusCode.toString();
    try {
      if (respo.statusCode == 200) {
        Util.dismissDialog(_scafoldkey.currentContext!);
        var decc = jsonDecode(respo.body);
        if (decc['success'] == 'true') {
          showDialog(
            context: context,
            barrierDismissible: false, // Prevents dismissing by tapping outside
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text(
                  'Payment Success',
                  style: Util.txt(Palette.black, 16, FontWeight.w600),
                ),
                content: Text(
                  decc['message'],
                  style: Util.txt(Palette.black, 16, FontWeight.w400),
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context); // Closes the dialog
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const MyOrdersList(),
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
        } else {
          Map<String, String> map = {
            'email': userid,
            'instance': 'orderdata Insertion',
            'error': tempo + decc['message']
          };
          var respo = await http.post(Uri.parse('${Util.baseurl}logs.php'),
              body: jsonEncode(map));
          if (respo.statusCode == 200) {}
        }
      } else {
        Map<String, String> map = {
          'email': userid,
          'instance': 'orderdata Insertion',
          'error': tempo
        };
        var respo = await http.post(Uri.parse('${Util.baseurl}logs.php'),
            body: jsonEncode(map));
        if (respo.statusCode == 200) {}
      }
    } catch (e) {
      Util.dismissDialog(_scafoldkey.currentContext!);
      Map<String, String> map = {
        'email': userid,
        'instance': 'orderdata Insertion',
        'error': e.toString()
      };
      var respo = await http.post(Uri.parse('${Util.baseurl}logs.php'),
          body: jsonEncode(map));
      if (respo.statusCode == 200) {}
    }
  }

  @override
  void dispose() {
    super.dispose();
    _razorpay.clear();
  }
}
