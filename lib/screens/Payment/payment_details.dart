import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_animated_dialog/flutter_animated_dialog.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:http/http.dart' as http;
import '../../Connectivity/No_internet.dart';
import '../../Connectivity/connectivity_provider.dart';
import '../../Model/Product_Model.dart';
import '../../utilities/AppManagement.dart';
import '../../utilities/constants.dart';
import '../../utilities/palette.dart';
import '../Home/CartList.dart';
import 'DeliveryAddress.dart';
import 'OrderList.dart';
import 'payment_screen.dart';

class PaymentDetails extends StatefulWidget {
  const PaymentDetails(
      {Key? key,
      required this.address,
      required this.state,
      required this.share,required this.shippervalue})
      : super(key: key);
  final List<AddressModel> address;
  final int state;
  final Map<String, dynamic> share;
  final Map<String, dynamic> shippervalue;
  @override
  State<PaymentDetails> createState() => _PaymentDetailsState();
}

class _PaymentDetailsState extends State<PaymentDetails> {
  final GlobalKey<ScaffoldState> _scaffoldkey = GlobalKey<ScaffoldState>();
  String available = '',message = '';
  String shippervaluestring = '';
  TextEditingController promoCode = TextEditingController();
  final Controller c = Get.put(Controller());
  List<PromoCodeModel> promoCodes = [];
  List<ContactUsModel> contactUs = [];
  List<PaymentModel> payKeys = [];
  String paymentStatus = '',
      sentId = '',
      orderID = '',
      tidvalue = '',
      mobile = '',
      email = '',
      currenttime = '';
  String? encryptedstring;
  String? accesscodestring;
  var addtime = 10, totaltime = 0;
  final Razorpay _razorpay = Razorpay();
  double discountAmount = 0.0;
  @override
  void initState() {
    Provider.of<ConnectivityProvider>(context, listen: false).startMonitoring();
    super.initState();
    getPromo();
    /* _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);*/
  }

  getPromo() async {
    promoCodes = [];
    try {
      final productList = http.MultipartRequest(
          'POST', Uri.parse('${Util.baseurl}promocode.php'));
      productList.fields['client'] = Util.clientName;
      final snd = await productList.send();
      final response = await http.Response.fromStream(snd);
      if (response.statusCode == 200) {
        var dec = jsonDecode(response.body);
        for (int i = 0; i < dec['data'].length; i++) {
          promoCodes.add(PromoCodeModel(
              code: dec['data'][i]['pcode'],
              amount: dec['data'][i]['minamount'],
              discount: dec['data'][i]['discount']));
        }
      }
    } catch (e) {
      Util.logDebug(e);
    }
    if (mounted) {
      setState(() {
        double a = 0;
        a = double.parse(widget.share['estimate_price'].toString());
        c.checkOutPrice.value = c.totalAmount.value + a;
      });
    }
    getData();
  }
  getData() async {
    currenttime = '${widget.share['estimate_time']}';
    shippervaluestring = '${widget.shippervalue['shipper']}';
    //print('shipper value is :$shippervaluestring');
    var c = int.parse(currenttime);
    totaltime = c + addtime;
    payKeys = [];
    contactUs = [];
    String userid = await Util.getStringValuesSF('userid');
    available = await Util.getStringValuesSF('availabl');
    //print('available:$available');
    message = await Util.getStringValuesSF('msg');
    //print('message:$message');
    try {
      final productList = http.MultipartRequest(
          'POST', Uri.parse('${Util.baseurl}addresslist.php'));
      productList.fields['userid'] = userid;
      productList.fields['client'] = Util.clientName;
      final snd = await productList.send();
      final response = await http.Response.fromStream(snd);
      if (response.statusCode == 200) {
        var dec = jsonDecode(response.body);
        //print('description: $dec');
        if (dec['success']) {
          if (dec['contactus'].length > 0) {
            contactUs.add(ContactUsModel(
                email: dec['contactus'][0]['email'],
                mobile: dec['contactus'][0]['mobilenumber'],
                address: dec['contactus'][0]['address']));
          }
          payKeys.add(PaymentModel(
              keyId: dec['paymentKeys'][0]['MerchantId'], //merchantid  //keyId
              keySecret: dec['paymentKeys'][0]
                  ['access_code'], //accesscode //keySecret
              url: dec['paymentKeys'][0]['url'])); //
          // print('keyid:${dec['paymentKeys'][0]['MerchantId']}');
          orderID = dec['orderid'];
          tidvalue = dec['tid'];
          mobile = dec['userdetails'][0]['mobile'];
          email = dec['userdetails'][0]['email'];
        } else {
         // print('hiprote');
        }
      }
    } catch (e) {
      Util.logDebug(e);
    }
  }
  @override
  Widget build(BuildContext context) {
   // print('email :$email');
    return Scaffold(
      key: _scaffoldkey,
      backgroundColor: Palette.background,
      appBar: AppBar(
        backgroundColor: Palette.background,
        elevation: 0,
        leading: IconButton(
          onPressed: () {
            c.delAddress.value = '';
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const DeliveryAddress()));
          },
          icon: Icon(
            Ionicons.arrow_back,
            color: Palette.black,
          ),
        ),
        title: Text(
          'Payment Details',
          style: Util.txt(Palette.black, 18, FontWeight.w600),
        ),
      ),
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
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Column(
        children: [
          Table(
            border: TableBorder.all(color: Palette.background),
            // defaultColumnWidth: FixedColumnWidth(120),
            columnWidths: const {
              0: FixedColumnWidth(140),
              1: FixedColumnWidth(150)
            },
            children: [
              TableRow(children: [
                Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(5.0),
                      child: Text(
                        'Total (${c.cart.value} items)',
                        style: Util.txt(Palette.black, 14, FontWeight.w300),
                      ),
                    )
                  ],
                ),
                Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(5.0),
                      child: Text(
                        ":    \u20B9 ${c.totalAmount}",
                        style: Util.txt(Palette.black, 16, FontWeight.w500),
                      ),
                    )
                  ],
                ),
              ]),
              TableRow(children: [
                Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(5.0),
                      child: Text(
                        'Shipping Charges',
                        style: Util.txt(Palette.black, 14, FontWeight.w300),
                      ),
                    )
                  ],
                ),
                Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(5.0),
                      child: Text(
                        ':    \u20B9 ${widget.share['estimate_price']} ',
                        style: Util.txt(Palette.black, 16, FontWeight.w500),
                      ),
                    )
                  ],
                ),
              ]),
              if (!c.promo.value)
                TableRow(children: [
                  Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(5.0),
                        child: Text(
                          'Discount amount ',
                          style: Util.txt(Palette.black, 14, FontWeight.w300),
                        ),
                      )
                    ],
                  ),
                  Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(5.0),
                        child: Text(
                          ':   -\u20B9 $discountAmount',
                          style: Util.txt(Palette.black, 16, FontWeight.w500),
                        ),
                      )
                    ],
                  ),
                ]),
              TableRow(children: [
                Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(5.0),
                      child: Text(
                        'Total amount',
                        style: Util.txt(Palette.black, 14, FontWeight.w400),
                      ),
                    )
                  ],
                ),
                Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(5.0),
                      child: Text(
                        ":     \u20B9 ${c.checkOutPrice}",
                        style: Util.txt(Palette.black, 16, FontWeight.w500),
                      ),
                    )
                  ],
                ),
              ]),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                c.promo.value ? '' : 'PromoCode Applied',
                style: const TextStyle(color: Colors.teal),
              )
            ],
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: promoCode,
                    enabled: c.promo.value,
                    keyboardType: TextInputType.text,
                    style: Util.txt(Palette.black, 14, FontWeight.w400),
                    decoration: InputDecoration(
                      hintText: 'Enter Promocode',
                      hintStyle: Util.txt(Palette.black, 14, FontWeight.w400),
                      fillColor: Palette.white,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      border: InputBorder.none,
                      isDense: true,
                      filled: true,
                      contentPadding: const EdgeInsets.all(10.0),
                    ),
                  ),
                ),
                const SizedBox(
                  width: 5.0,
                ),
                SizedBox(
                  height: 36,
                  child: OutlinedButton(
                    onPressed: () {
                      if (c.promo.value) {
                        checkprmCode();
                      } else {
                        setState(() {
                          c.promo.value = true;
                          c.checkOutPrice.value = c.totalAmount.toDouble();
                          if (c.checkOutPrice.toDouble() < 1000) {
                            c.checkOutPrice.value =
                                c.checkOutPrice.value + c.charges.value;
                          }
                        });
                      }
                    },
                    style: ButtonStyle(
                      side: MaterialStateProperty.all(
                          BorderSide(color: Palette.black)),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      padding: MaterialStateProperty.all(
                          const EdgeInsets.fromLTRB(4, 0, 4, 0)),
                    ),
                    child: Text(
                      c.promo.value ? 'Apply' : 'Change',
                      style: Util.txt(Palette.black, 16, FontWeight.w500),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 0, 0, 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Estimated delivery time $totaltime minutes', //${widget.share['estimate_time']}
                  style: const TextStyle(color: Colors.teal),
                )
              ],
            ),
          ),
          ElevatedButton(
              onPressed: (){availibilityCheck();},
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(Palette.color2),
              ),
              child: Text(
                ' Pay ',
                style: Util.txt(Palette.white, 16, FontWeight.w600),
              ))
        ],
      ),
    );
  }
  availibilityCheck() async {
    String userid = await Util.getStringValuesSF('userid');
    try {
      final availabilityCheck =http.MultipartRequest('POST', Uri.parse('${Util.baseurl}availability.php'));
      availabilityCheck.fields['client'] = Util.clientName;
      availabilityCheck.fields['userid'] = userid;
      final snd = await availabilityCheck.send();
      final response = await http.Response.fromStream(snd);
      if (response.statusCode == 200) {
        var dec = jsonDecode(response.body);
        //print('availbility dec: $dec');
        if (dec['status'] == '1') {
          //isavailable = true;
         // print('status1 is');
         // print(dec['available'].toString());
          Util.addStringToSF('availability', dec['status'].toString(),'');
          Util.addStringToSF('availabl', dec['available'].toString(),'');
          Util.addStringToSF('msg', dec['message'].toString(),'');
          if(dec['available'].toString()== 'true'){createRequest();}else{showResponseAlert(dec['message'].toString());}
          
        } else {
          //if(isavailable == true){
           // print('status0');
            Util.addStringToSF('availability', '0','');
            Util.addStringToSF('availabl', dec['available'].toString(),'');
            showResponseAlert(dec['available'].toString());
           //isavailable = false;
            //alert();
            //showAlertDialog();
          //}
        }
      } else {
      }
    } catch (e) {
      Util.logDebug(e);
    }
  }
  void showResponseAlert(String responseMessage) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(''),
          content: Text(responseMessage),
          actions: <Widget>[
            ElevatedButton(
                child: const Text('OK'),
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const CartList()));
                  //Navigator.of(context).pop();
                }),
          ],
        );
      },
    );
  }
  //------
  checkprmCode() {
    FocusScope.of(context).requestFocus(FocusNode());
    double tempChkprice = 0, finalpri = 0;
    discountAmount = 0;
    bool inc = true, psc123 = false;
    tempChkprice = c.totalAmount.toDouble();
    for (int i = 0; i < promoCodes.length; i++) {
      if (promoCodes[i].code == promoCode.text) {
        inc = false;
        if (tempChkprice >= double.parse(promoCodes[i].amount)) {
          psc123 = true;
          double dicot = 1 - (int.parse(promoCodes[i].discount) / 100);
          finalpri = (dicot * tempChkprice).roundToDouble();
          Util.showDog(context, 'PromoCode Applied');
        } else {
          Util.showDog(context, 'PromoCode Not Applicable');
        }
      }
    }
    if (inc) {
      Util.showDog(context, 'Invalid Promocode');
    }
    setState(() {
      if (psc123) {
        c.checkOutPrice.value =
            finalpri + double.parse(widget.share['estimate_price'].toString());
        c.promo.value = false;
        discountAmount = tempChkprice - finalpri;
        // if(c.totalAmount.toDouble()<1000){c.checkOutPrice.value=c.checkOutPrice.value+c.charges.value;}
      }
    });
  }
  //-----

  createRequest() async {
    if (payKeys[0].keyId == '') {
      Util.showDog(
          _scaffoldkey.currentContext!, 'Payment gateway is under Maintenance');
      return;
    }
    /*String keyId = payKeys[0].keyId,
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
    sentId = jsonDecode(response.body)['id'];*/
    uDateTemCart('1');
    initPayment();
    //openCheckout(); //commentedbyme
  }

  uDateTemCart(String status) async {
    //print(tidvalue);
    Util.logDebug('status is $status');
    String userid = await Util.getStringValuesSF('userid');
    String stam;
    Map<String, String> map = {
      'userid': userid,
      'address': c.delAddress.value,// widget.address[widget.state].id
      'totalamount': c.checkOutPrice.toString(),
      'Rpayorderid': tidvalue, //tid //Rpayorderid
      'status': status,
      'orderid': orderID.toString(),
      'client': Util.clientName
    };
    var respon = await http.post(Uri.parse('${Util.baseurl}updatetempcart.php'),
        body: jsonEncode(map));
    stam = respon.statusCode.toString();
    try {
      if (respon.statusCode == 200) {
        //print('temp success');
      } else {
        Map<String, String> map = {
          'email': userid,
          'instance': 'order id',
          'error': '$stam not updated after getting orderid'
        };
        var response = await http.post(Uri.parse('${Util.baseurl}logs.php'),
            body: jsonEncode(map));
        if (response.statusCode == 200) {
         // print('temp success1');
        }
      }
    } catch (e) {
      Map<String, String> map = {
        'email': userid,
        'instance': 'payment error',
        'error': e.toString()
      };
      var response = await http.post(Uri.parse('${Util.baseurl}logs.php'),
          body: jsonEncode(map));
      if (response.statusCode == 200) {
        //print('temp success2');
      }
    }
  }

  void initPayment() async {
    //print(widget.amount);
    var url = "https://redbag.vensframe.com/app/ccavenueRequest.php";
    Uri uri = Uri.parse(url);
    var res = await http.post(uri,body:{
      'tid': sentId,
      'merchant_id': payKeys[0].keyId,
      'order_id': orderID.toString(),
      'amount': c.checkOutPrice.toString(),
      'currency': 'INR',
      'redirect_url': "https://redbag.vensframe.com/app/ccavenueResponse.php",
      'cancel_url': "https://redbag.vensframe.com/app/ccavenueResponse.php",
      'language': 'EN',
      'billing_name': c.isfirstname.value,
      'billing_address': c.delAddress.value, //widget.address[widget.state].id,
      'billing_city': c.iscity.value,
      'billing_state': c.isstate.value,
      'billing_zip': c.ispincode.value,
      'billing_country': 'India',
      'billing_tel': c.delMobile.value,
      'billing_email': email,
    });
    
    //print('body:$body');
    if (res.statusCode == 200) {
      var jsonData = jsonDecode(res.body);
      encryptedstring = jsonData['encryptdata'];
      accesscodestring = jsonData['access'];
      print('jsonData: $jsonData');
      print('encryptdata: ${jsonData['encryptdata']}');
      print('access: ${jsonData['access']}');
      navigate();
      // print('accesscode:$accesscodestring');
      return jsonData;
    } else {
      throw Exception();
    }
  }

  void navigate() {
    Navigator.push(context,
        MaterialPageRoute(
            builder: (builder) => PaymentScreen(
                encryptedstring: encryptedstring!,
                accescodestring: accesscodestring!,
                addressvalue: widget.address[widget.state].id,
                tidvalue: tidvalue,
                orderidvalue: orderID.toString(),
                totalAmountvalue: c.checkOutPrice.toString(),
                mobilenumbervalue: c.delMobile.value,
                shippingchargesvalue: widget.share['estimate_price'].toString(),
                shipperstringis : shippervaluestring,
                totaltimevalue: totaltime.toString(),
                discountvalue: discountAmount.toString(),
                )));
  }

  void openCheckout()async{
    String userid = await Util.getStringValuesSF('userid');
    // String email = await Util.getStringValuesSF('email');
    // String mobile = await Util.getStringValuesSF('mobile');
    var options = {
      'key': payKeys[0].keyId,
      'amount': (c.checkOutPrice.value) * 100, //*100(c.checkOutPrice.value)*
      'name': 'PAYMENT',
      'payment_capture': 1,
      'order_id': sentId,
      // 'timeout': 180,
      'prefill': {'contact':mobile,'email':email},
      'external': {
        'wallets': ['paytm']
      }
    };
    try{
      _razorpay.open(options);
    } catch (e) {
      Map<String, String> map={
        'email': userid,
        'instance': 'payment error',
        'error': e.toString()
      };
      var response = await http.post(Uri.parse('${Util.baseurl}logs.php'),
          body: jsonEncode(map));
      if (response.statusCode == 200){}
    }
  }
  void updata()async{
    Util.showProgress(context);
    String tempo;
    String userid = await Util.getStringValuesSF('userid');
    Map<String, dynamic> map = {
      'userid': userid,
      'mobilenumber': c.delMobile.value,
      'orderid': orderID.toString(),
      'address': widget.address[widget.state].id,
      'tracking_id': paymentStatus, //tracking_id //paymentstatus
      'totalamount': c.checkOutPrice.toString(),
      'tid': sentId, //tid  //Rpayorderid
      'orderstatus': 'Placed',
      'feedbackstatus': '0',
      'client': Util.clientName,
      'shippingCharges': widget.share['estimate_price'],
      'shipper': widget.share['name'],
      'eDate': totaltime, //widget.share['estimate_time'],
      'discount': discountAmount
    };
    var respo = await http.post(Uri.parse('${Util.baseurl}placeorder.php'),
        body: jsonEncode(map));
    tempo = respo.statusCode.toString();
    try {
      if (respo.statusCode == 200) {
        Util.dismissDialog(_scaffoldkey.currentContext!);
        var decc = jsonDecode(respo.body);
        if (decc['success'] == 'true') {
          showDlog(decc['message']);
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
      print('error ---- $e');
      // Util.dismissDialog(_scaffoldkey.currentContext!);
      Map<String, String> map={
        'email':userid,
        'instance':'orderdata Insertion',
        'error':e.toString()
      };
      var respo = await http.post(Uri.parse('${Util.baseurl}logs.php'),
          body: jsonEncode(map));
      if (respo.statusCode == 200) {}
    }
  }
  showDlog(String message) {
    showAnimatedDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return ClassicGeneralDialogWidget(
          titleText:'Payment Success',
          contentText:message,
          actions: [
            TextButton(
                onPressed:(){
                  Navigator.pop(context);
                  Navigator.push(context,MaterialPageRoute(
                          builder:(context)=> const MyOrdersList()));
                },
                child:Text('Ok',style:Util.txt(Palette.black,16,FontWeight.w600),)),
          ],
        );
      },
      animationType: DialogTransitionType.slideFromLeftFade,
      curve: Curves.fastOutSlowIn,
      duration: const Duration(seconds: 1),
    );
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) async {
    // Util.customDialog('Payment Success','Your Payment ID : '+response.paymentId.toString(), context);
    paymentStatus = response.paymentId.toString();
    // updata(); //commentedbyme
  }

  void _handlePaymentError(PaymentFailureResponse response) async {
    // String email = await Util.getStringValuesSF("email");
    var dec = jsonDecode(response.message.toString());
    String msg = dec['error']['description'] +
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
        'Info', response.walletName.toString(), _scaffoldkey.currentContext!);
    // Map<String,String>map = {'email':email,'instance':'payment wallet','error':response.walletName.toString()};
    // var respo = await http.post(Uri.parse(Util.baseurl+'logs.php'),body: jsonEncode(map));
    // if(respo.statusCode==200){}
  }

  @override
  void dispose() {
    super.dispose();
    _razorpay.clear();
  }
}
