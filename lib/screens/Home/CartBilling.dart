import 'dart:convert';
import 'package:dotted_decoration/dotted_decoration.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import '../../Model/Product_Model.dart';
import '../../utilities/AppManagement.dart';
import '../../utilities/constants.dart';
import '../../utilities/palette.dart';
import '../Payment/DeliveryAddress.dart';


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
    print('outofstock$outofstockcount');
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
  @override
  Widget build(BuildContext context) {
    return Obx(()=>Container(
      height: 100,//246,
      decoration: DottedDecoration(
          borderRadius: BorderRadius.circular(10.0),
          // shape: Shape.box
          // border: Border.all(color: Palette.black,width: 1.0)
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          Table(
            border: TableBorder.all(color: Palette.background),
            // defaultColumnWidth: FixedColumnWidth(120),
            columnWidths: const {0:FixedColumnWidth(140),1:FixedColumnWidth(150)},
            children: [
              TableRow(
                  children: [
                    Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(5.0),
                          child: Text('Total (${c.cart.value} items)',style: Util.txt(Palette.black,14, FontWeight.w300),),
                        )
                      ],
                    ),
                    Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(5.0),
                          child: Text(":   \u20B9 ${c.totalAmount}",style: Util.txt(Palette.black,16, FontWeight.w500),),
                        )
                      ],
                    ),
                  ]
              ),
              // TableRow(
              //     children: [
              //       Row(
              //         children: [
              //           Padding(
              //             padding: const EdgeInsets.all(5.0),
              //             child: Text('Shipping Charges',style: Util.txt(Palette.black,14, FontWeight.w300),),
              //           )
              //         ],
              //       ),
              //       Row(
              //         children: [
              //           Padding(
              //             padding: const EdgeInsets.all(5.0),
              //             child: Text(':   To Pay ',style: Util.txt(Palette.black,16, FontWeight.w500),),
              //           )
              //         ],
              //       ),
              //     ]
              // ),
              // if(!c.promo.value)
              // TableRow(
              //     children: [
              //       Row(
              //         children: [
              //           Padding(
              //             padding: const EdgeInsets.all(5.0),
              //             child: Text('Discount amount ',style: Util.txt(Palette.black,14, FontWeight.w300),),
              //           )
              //         ],
              //       ),
              //       Row(
              //         children: [
              //           Padding(
              //             padding: const EdgeInsets.all(5.0),
              //             child: Text(':   -\u20B9 ${c.totalAmount.toDouble()}',style: Util.txt(Palette.black,16, FontWeight.w500),),
              //           )
              //         ],
              //       ),
              //     ]
              // ),
              // TableRow(
              //     children: [
              //       Row(
              //         children: [
              //           Padding(
              //             padding: const EdgeInsets.all(5.0),
              //             child: Text('Total amount',style: Util.txt(Palette.black,14, FontWeight.w400),),
              //           )
              //         ],
              //       ),
              //       Row(
              //         children: [
              //           Padding(
              //             padding: const EdgeInsets.all(5.0),
              //             child: Text(":   \u20B9 ${c.checkOutPrice}",style: Util.txt(Palette.black,16, FontWeight.w500),),
              //           )
              //         ],
              //       ),
              //     ]
              // ),
            ],
          ),
          // Row(
          //   mainAxisAlignment: MainAxisAlignment.center,
          //   children: [
          //     Text(c.promo.value?'':'PromoCode Applied',style: const TextStyle(color: Colors.teal),)            ],
          // ),
          // Padding(
          //   padding: const EdgeInsets.fromLTRB(10, 10, 10, 20),
          //   child: Row(
          //     children: [
          //       Expanded(
          //         child: TextField(
          //           controller: promoCode,
          //           enabled: c.promo.value,
          //           keyboardType: TextInputType.text,
          //           style: Util.txt(Palette.black, 14, FontWeight.w400),
          //           decoration: InputDecoration(
          //             hintText: 'Enter Promocode',
          //             hintStyle: Util.txt(Palette.black, 14, FontWeight.w400),
          //             fillColor: Palette.white,
          //             enabledBorder: InputBorder.none,
          //             focusedBorder: InputBorder.none,
          //             border: InputBorder.none,
          //             isDense: true,
          //             filled: true,
          //             contentPadding: EdgeInsets.all(10.0),
          //           ),
          //         ),
          //       ),
          //       SizedBox(width: 5.0,),
          //       Container(height: 36,
          //         child: OutlinedButton(onPressed: (){
          //           if(c.promo.value){
          //             checkprmCode();
          //           }
          //           else{
          //             setState(() {
          //               c.promo.value=true;
          //               c.checkOutPrice.value=c.totalAmount.toDouble();
          //               if(c.checkOutPrice.toDouble()<1000){c.checkOutPrice.value=c.checkOutPrice.value+c.charges.value;}
          //             });
          //           }
          //         },
          //           style: ButtonStyle(
          //             side: MaterialStateProperty.all(BorderSide(color: Palette.black)),
          //             tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          //             padding: MaterialStateProperty.all(EdgeInsets.fromLTRB(4, 0, 4, 0)),
          //           ),
          //           child: Text(c.promo.value?'Apply':'Change',style: Util.txt(Palette.black, 16, FontWeight.w500),),
          //         ),
          //       ),
          //     ],
          //   ),
          // ),
          //if(available != '')
          SizedBox(
            height: 40,
            child: Card(
              color: Colors.amber,
              elevation: 1,
              child: SizedBox(height: 30,
                child: TextButton(
                    onPressed: () async { 
                      available = await Util.getStringValuesSF('availability');
                      print('status is : $available');
                      if(available.toString() == '1' && outofstockcount == '0'){
                       Navigator.push(context, MaterialPageRoute(builder: (context)=>const DeliveryAddress()));
                      }
                      else{
                       available.toString() != '1'?showResponseAlert('sorry, we are not accepting orders at this moment'): showResponseAlert('sorry, remove out of stock item'); 
                      }
                    },
                    style: ButtonStyle(
                      padding: MaterialStateProperty.all(const EdgeInsets.fromLTRB(10, 4, 10, 4))
                    ),
                    child: Text('Proceed to Checkout',textAlign: TextAlign.center,style: Util.txt(Palette.black, 16, FontWeight.w500),)),
              ),
            ),
          ),
        ],
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
  //-----
}
