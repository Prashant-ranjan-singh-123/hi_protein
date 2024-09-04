import 'dart:convert';
import 'package:dotted_decoration/dotted_decoration.dart';
import 'package:flutter/material.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:slide_to_act/slide_to_act.dart';

import '../../../Model/Product_Model.dart';
import '../../../utilities/AppManagement.dart';
import '../../../utilities/constants.dart';
import '../../../utilities/palette.dart';
import '../../Payment/DeliveryAddress.dart';


class CartBilling extends StatefulWidget {
  const CartBilling({Key? key}) : super(key: key);
  @override
  _CartBillingState createState() => _CartBillingState();
}

class _CartBillingState extends State<CartBilling> {
  final GlobalKey<ScaffoldState> _scaffoldkey =  GlobalKey<ScaffoldState>();
  String available = '',outofstockcount = '';
  TextEditingController promoCode = TextEditingController();
  final Controller c = Get.put(Controller());
  List<PromoCodeModel> promoCodes=[];
  @override
  void initState() {
    getData();
    super.initState();
  }

  getData()async{
    promoCodes=[];
    String userid = await Util.getStringValuesSF('userid');
    available = await Util.getStringValuesSF('availability');
    outofstockcount = await Util.getStringValuesSF('outofstockvalue');
    // await availibilityCheck();
    try{
      final productList = http.MultipartRequest('POST',Uri.parse('${Util.baseurl}promocode.php'));
      productList.fields['userid']=userid;
      productList.fields['client']=Util.clientName;
      final snd = await productList.send();
      final response = await http.Response.fromStream(snd);
      if(response.statusCode==200){
        var dec = jsonDecode(response.body);
        for(int i=0;i<dec['data'].length;i++){
          promoCodes.add(PromoCodeModel(code: dec['data'][i]['pcode'], amount: dec['data'][i]['minamount'], discount: dec['data'][i]['discount']));
        }
      }
    }catch(e){
      Util.logDebug(e);
    }
    if(mounted){
      setState(() {
      });
    }
  }


  availibilityCheck()async {
    String userid = await Util.getStringValuesSF('userid');
    try {
      final availabilityCheck =http.MultipartRequest('POST', Uri.parse('${Util.baseurl}availability.php'));
      availabilityCheck.fields['client'] = Util.clientName;
      availabilityCheck.fields['userid'] = userid;
      final snd = await availabilityCheck.send();
      final response = await http.Response.fromStream(snd);
      print('availability.php response code: ${response.statusCode}');
      if (response.statusCode == 200) {
        var dec = jsonDecode(response.body);
        print('availability.php data: ${response.body}');
        if (dec['status'] == '1') {
          // isavailable = true;
          Util.addStringToSF('availability', dec['status'].toString(),'');
          Util.addStringToSF('availabl', dec['available'].toString(),'');
          Util.addStringToSF('msg', dec['message'].toString(),'');
        } else {
            Util.addStringToSF('availability', '0','');
            Util.addStringToSF('availabl', dec['available'].toString(),'');
            // isavailable = false;
            // alert();
        }
      } else {
        // Util.addStringToSF('availability', dec['status'].toString(),'');
        // Util.addStringToSF('availabl', dec['available'].toString(),'');
        // Util.addStringToSF('msg', dec['message'].toString(),'');
      }
    } catch (e) {
      Util.logDebug(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Obx(()=>SizedBox(
      width: MediaQuery.of(context).size.width,
      height: 140,
      child: Card(
        color: Palette.blue_tone_green.withGreen(150),
        shape: const RoundedRectangleBorder(
            borderRadius:  BorderRadius.only(
              topLeft: Radius.circular(12),
              topRight: Radius.circular(12),
              bottomLeft: Radius.circular(0),
              bottomRight: Radius.circular(0),
            )
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  const Spacer(),
                  Text('Total (${c.cart.value} items):',style: Util.txt(Palette.blue_tone_white,18, FontWeight.w500),),
                  const Spacer(),
                  Text("\u20B9 ${c.totalAmount}",style: Util.txt(Palette.blue_tone_white ,20, FontWeight.w800),),
                  const Spacer()
                ],
              ),
            ),
            slide_action()
          ],
        ),
      ),
    )) ;
  }
  //------
      checkprmCode(){
          FocusScope.of(context).requestFocus(FocusNode());
          double tempChkprice=0,finalpri=0;
          bool inc=true,psc123=false;
          tempChkprice=c.totalAmount.toDouble();
          for(int i=0;i<promoCodes.length;i++){
            if(promoCodes[i].code==promoCode.text){
                  inc = false;
              if(tempChkprice>=double.parse(promoCodes[i].amount)){
                    psc123=true;
                    double dicot =1-(int.parse(promoCodes[i].discount)/100);
                    finalpri = (dicot*tempChkprice).roundToDouble();
                    Util.showDog(context,'PromoCode Applied');
              }
              else{
                Util.showDog(context,'PromoCode Not Applicable');
              }
            }
          }
          if(inc){
            Util.showDog(context,'Invalid PromoCode');
          }
          setState(() {
           if(psc123){
              c.checkOutPrice.value=finalpri;
              c.promo.value=false;
              // if(c.totalAmount.toDouble()<1000){c.checkOutPrice.value=c.checkOutPrice.value+c.charges.value;}
            }
          });
    }
  void showResponseAlert(String msg) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(''),
          content: Text(msg),
          actions: <Widget>[
            ElevatedButton(
                child: const Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop();
                }),
          ],
        );
      },
    );
  }

  Widget slide_action() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: SlideAction(
        innerColor: Palette.blue_tone_white,
        elevation: 0,
          height: 60,
        sliderButtonIconPadding:12,
          borderRadius:70,
        sliderButtonIcon: const Icon(IconlyLight.wallet),
        // outerColor: Palette.blue_tone_black,
        outerColor: Palette.blue_tone_green.withGreen(80),
        textColor: Palette.blue_tone_white,
        text: 'Checkout',
        textStyle: TextStyle(
            color: Palette.blue_tone_white,
            fontWeight: FontWeight.w700,
            fontFamily: 'Poppins',
            fontSize: 20),
        // borderRadius: 55,
        onSubmit: () async {
          await availibilityCheck();
          available = await Util.getStringValuesSF('availability');
          print('Available: ${available}');
          if(available.toString() == '1' && outofstockcount == '0'){
            print('COndition 1');
            // ignore: use_build_context_synchronously
            Navigator.push(context, MaterialPageRoute(builder: (context)=>const DeliveryAddress()));
          }
          else{
            print('COndition 2');
            available.toString() != '1'?showResponseAlert('sorry, we are not accepting orders at this moment'): showResponseAlert('sorry, remove out of stock item');
          }
        },
      ),
    );
  }
  //-----
}
