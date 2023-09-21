import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animated_dialog/flutter_animated_dialog.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import '../../Connectivity/No_internet.dart';
import '../../Connectivity/connectivity_provider.dart';
import '../../Model/Product_Model.dart';
import '../../utilities/constants.dart';
import '../../utilities/geditaddressmap.dart';
import '../../utilities/palette.dart';
import 'DeliveryAddress.dart';

class AddressForm extends StatefulWidget {
  const AddressForm(
      {Key? key,
      required this.type,
      required this.state,
      required this.address})
      : super(key: key);
  final String type;
  final int state;
  final List<AddressModel> address;
  @override
  _AddressFormState createState() => _AddressFormState();
}
class _AddressFormState extends State<AddressForm> {
  final GlobalKey<ScaffoldState> _scafoldkey = GlobalKey<ScaffoldState>();
  String latitudeStr = '', longitudeStr = '';
  TextEditingController address = TextEditingController();
  TextEditingController mobile = TextEditingController();
  TextEditingController fn = TextEditingController();
  TextEditingController ln = TextEditingController();
  TextEditingController city = TextEditingController();
  TextEditingController state = TextEditingController();
  TextEditingController pinCode = TextEditingController();
  TextEditingController country = TextEditingController();

  @override
  void initState() {
    Provider.of<ConnectivityProvider>(context, listen: false).startMonitoring();
    super.initState();
    edit();
  }
  edit() {
    if (widget.type == 'edit') {
      setState(() {
        address.text = widget.address[widget.state].address;
        mobile.text = widget.address[widget.state].mobile;
        fn.text = widget.address[widget.state].fn;
        ln.text = widget.address[widget.state].ln;
        city.text = widget.address[widget.state].city;
        pinCode.text = widget.address[widget.state].pincode;
        latitudeStr = widget.address[widget.state].latitude;
        longitudeStr = widget.address[widget.state].longitude;
        // country.text = widget.address[widget.state].country;
        state.text = widget.address[widget.state].state;
      });
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scafoldkey,
      backgroundColor: Palette.background,
      appBar: AppBar(
        backgroundColor: Palette.background,
        elevation: 0,
        leading: IconButton(
          onPressed: () {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => const DeliveryAddress()));
          },
          icon: Icon(
            Ionicons.arrow_back,
            color: Palette.black,
          ),
        ),
        title: Text('Delivery Address',style: Util.txt(Palette.black, 18, FontWeight.w600),
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
      child: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 0, 0, 10),
            child: TextField(
              controller: fn,
              cursorColor: Palette.black,
              keyboardType: TextInputType.text,
              textInputAction: TextInputAction.next,
              style: Util.txt(Palette.black, 14, FontWeight.w400),
              decoration: InputDecoration(
                hintText: 'Enter First name',
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
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 0, 0, 10),
            child: TextField(
              controller: ln,
              cursorColor: Palette.black,
              keyboardType: TextInputType.text,
              textInputAction: TextInputAction.next,
              style: Util.txt(Palette.black, 14, FontWeight.w400),
              decoration: InputDecoration(
                hintText: 'Enter Last name',
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
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 0, 0, 10),
            child: TextField(
              controller: mobile,
              cursorColor: Palette.black,
              keyboardType: TextInputType.phone,
              maxLength: 10,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp('[0-9]'))
              ],
              textInputAction: TextInputAction.next,
              style: Util.txt(Palette.black, 14, FontWeight.w400),
              decoration: InputDecoration(
                counterText: '',
                hintText: 'Enter Mobile number',
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
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 0, 0, 10),
            child: TextField(
              controller: address,
              cursorColor: Palette.black,
              keyboardType: TextInputType.multiline,
              textInputAction: TextInputAction.newline,
              maxLines: 4,
              style: Util.txt(Palette.black, 14, FontWeight.w400),
              decoration: InputDecoration(
                hintText: 'Enter Address',
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
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 0, 0, 10),
            child: TextField(
              controller: city,
              cursorColor: Palette.black,
              keyboardType: TextInputType.text,
              textInputAction: TextInputAction.next,
              style: Util.txt(Palette.black, 14, FontWeight.w400),
              decoration: InputDecoration(
                hintText: 'Enter City',
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
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 0, 0, 10),
            child: TextField(
              controller: state,
              cursorColor: Palette.black,
              keyboardType: TextInputType.text,
              textInputAction: TextInputAction.next,
              style: Util.txt(Palette.black, 14, FontWeight.w400),
              decoration: InputDecoration(
                hintText: 'Enter State',
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
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 0, 0, 10),
            child: TextField(
              controller: pinCode,
              cursorColor: Palette.black,
              keyboardType: TextInputType.number,
              textInputAction: TextInputAction.next,
              style: Util.txt(Palette.black, 14, FontWeight.w400),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp('[0-9]'))
              ],
              maxLength: 6,
              decoration: InputDecoration(
                hintText: 'Enter Pincode',
                hintStyle: Util.txt(Palette.black, 14, FontWeight.w400),
                counterText: '',
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
          if (widget.type == 'edit')
           Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  TextButton(
                    onPressed: () {
                       Navigator.push(context,MaterialPageRoute(builder: (context) =>  GeditAddressMap(
                        latitudevalue: latitudeStr,
                        longitudevalue: longitudeStr,
                       )));
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Palette.black,
                    ),
                    child: Text('Point on map',
                        style: Util.txt(Palette.white, 14, FontWeight.w400),),
                  ),
                ],
              ),

          /*Padding(
            padding: const EdgeInsets.fromLTRB(0, 0, 0, 10),
            child: TextField(
              controller: country,
              cursorColor: Palette.black,
              keyboardType: TextInputType.text,
              textInputAction: TextInputAction.next,
              style: Util.txt(Palette.black, 14, FontWeight.w400),
              decoration: InputDecoration(
                hintText: 'Edit Location',
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
          ),*/
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: OutlinedButton(
              onPressed: validate,
              style: ButtonStyle(
                side:
                    MaterialStateProperty.all(BorderSide(color: Palette.black)),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                padding: MaterialStateProperty.all(
                    const EdgeInsets.fromLTRB(4, 0, 4, 0)),
              ),
              child: Text(
                widget.type == 'add' ? 'Create' : 'Update',
                style: Util.txt(Palette.black, 15, FontWeight.w500),
              ),
            ),
          ),
        ],
      ),
    );
  }

  validate() async{
    FocusScope.of(context).requestFocus(FocusNode());
    if (fn.text.isNotEmpty &&
        ln.text.isNotEmpty &&
        address.text.isNotEmpty &&
        mobile.text.isNotEmpty &&
        city.text.isNotEmpty &&
        state.text.isNotEmpty &&
        pinCode.text.isNotEmpty) {
      create();
    } else {
      if (fn.text.isEmpty) {
        Util.showDog(_scafoldkey.currentContext!, 'Please Enter First name');
      } else if (ln.text.isEmpty) {
        Util.showDog(_scafoldkey.currentContext!, 'Please Enter Last name');
      } else if (mobile.text.isEmpty) {
        Util.showDog(_scafoldkey.currentContext!, 'Please Enter Mobile number');
      } else if (address.text.isEmpty) {
        Util.showDog(_scafoldkey.currentContext!, 'Please Enter Address');
      } else if (city.text.isEmpty) {
        Util.showDog(_scafoldkey.currentContext!, 'Please Enter City');
      } else if (state.text.isEmpty) {
        Util.showDog(_scafoldkey.currentContext!, 'Please Enter State');
      } else if (pinCode.text.isEmpty) {
        Util.showDog(_scafoldkey.currentContext!, 'Please Enter Pincode');
      }
      // else if (await Util.getStringValuesSF('latlang') == null) {
      //   Util.showDog(_scafoldkey.currentContext!, 'Please select location');
      // }
      // else if(country.text.isEmpty){Util.showDog(_scafoldkey.currentContext!,'Please Enter Country');}
    }
  }
  shipmentCheck() async {
    Util.showProgress(context);
    final shipCheck = http.MultipartRequest(
        'POST', Uri.parse('${Util.baseurl}shipping/shipment-check.php'));
    shipCheck.fields['delivery_postcode'] = pinCode.text;
    shipCheck.fields['weight'] = '1';
    var res = await shipCheck.send();
    var response = await http.Response.fromStream(res);
    Util.logDebug(response);
    try {
      if (response.statusCode == 200) {
        Util.dismissDialog(_scafoldkey.currentContext!);
        var dec = jsonDecode(response.body);
        Util.logDebug(dec);
        if (dec['status'] == 0) {
          create();
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
  create() async {
    Util.showProgress(context);
    String userid = await Util.getStringValuesSF('userid');
    String latlang = await Util.getStringValuesSF('latlang');
    try {
      final createAddress = http.MultipartRequest(
          'POST', Uri.parse('${Util.baseurl}deleteaddress.php'));
      createAddress.fields['userid'] = userid;
      createAddress.fields['mobile'] = mobile.text;
      createAddress.fields['address'] = address.text;
      createAddress.fields['firstname'] = fn.text;
      createAddress.fields['lastname'] = ln.text;
      createAddress.fields['city'] = city.text;
      createAddress.fields['state'] = state.text;
      createAddress.fields['pincode'] = pinCode.text;
      createAddress.fields['latlng'] = latlang;
      createAddress.fields['country'] = 'india';
      createAddress.fields['client'] = Util.clientName;
      createAddress.fields['id'] =
          widget.type == 'add' ? '' : widget.address[widget.state].id;
      createAddress.fields['type'] = widget.type == 'add' ? '1' : '2';
      final snd = await createAddress.send();
      final response = await http.Response.fromStream(snd);
      if (response.statusCode == 200) {
        Util.dismissDialog(_scafoldkey.currentContext!);
        var dec = jsonDecode(response.body);
        Util.logDebug('response: $dec');
        if (dec['success']) {
          showAnimatedDialog(
            context: context,
            barrierDismissible: true,
            builder: (BuildContext context) {
              return ClassicGeneralDialogWidget(
                contentText: dec['message'],
                actions: [
                  TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const DeliveryAddress()));
                      },
                      child: Text(
                        'Ok',
                        style: Util.txt(Palette.black, 16, FontWeight.w600),
                      )),
                ],
              );
            },
            animationType: DialogTransitionType.slideFromTopFade,
            curve: Curves.fastOutSlowIn,
            duration: const Duration(seconds: 1),
          );
        } else {
          showAnimatedDialog(
            context: context,
            barrierDismissible: true,
            builder: (BuildContext context) {
              return ClassicGeneralDialogWidget(
                contentText: dec['message'],
                actions: [
                  TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: Text(
                        'Ok',
                        style: Util.txt(Palette.black, 16, FontWeight.w600),
                      )),
                ],
              );
            },
            animationType: DialogTransitionType.slideFromTopFade,
            curve: Curves.fastOutSlowIn,
            duration: const Duration(seconds: 1),
          );
        }
      } else {
        Util.dismissDialog(_scafoldkey.currentContext!);
      }
    } catch (e) {
      // Util.dismissDialog(_scafoldkey.currentContext!);
      Util.logDebug(e);
    }
  }
}
