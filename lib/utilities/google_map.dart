// ignore_for_file: use_build_context_synchronously
import 'dart:async';
import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../utilities/gstreet_map.dart';
import '../../utilities/constants.dart';
import '../../utilities/palette.dart';
import 'package:http/http.dart' as http;
import '../screens/Payment/AddressForm.dart';

class MyMap extends StatefulWidget {
  const MyMap({super.key});
  @override
  _MyMapState createState() => _MyMapState();
}
class _MyMapState extends State<MyMap> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  GoogleMapController? _controller ;
  Position? position;
  Widget? _child;
  bool servicestatus = false, haspermission = false;
  String address = '';
  @override
  void initState() {
    getLocation();
    super.initState();
  }
  void _getCurrentLocation() async{
    Position res = await Geolocator.getCurrentPosition();
    setState(() {
      position = res;
      _child = _mapWidget();
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Current Location',textAlign: TextAlign.center,style: TextStyle(color: CupertinoColors.black),),
        actions: <Widget>[
          TextButton(
            onPressed: () {shipmentCheck();},
          /*style: ButtonStyle(
              side: MaterialStateProperty.all(BorderSide(color: Palette.black,width: 1.2)),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              padding: MaterialStateProperty.all(EdgeInsets.zero),
              shape: MaterialStateProperty.all(const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(10.0))))
              ),*/
          child:Text('CONFIRM',style: Util.txt(Palette.black, 16, FontWeight.w500)),),
        ],
      ),
      body:_child,
      bottomSheet: Container(
              color: Palette.white,
              height: 100,
              child: _changeLocation(),
            ),
    );
  }
  Future<void> getLocation() async {
   servicestatus = await Geolocator.isLocationServiceEnabled();
   if (!servicestatus) {
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Location services are disabled. Please enable the services')));
    return ;
  }
    if (servicestatus) {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
        } else if (permission == LocationPermission.deniedForever) {
        } else {
          haspermission = true;
        }
      } else {
        haspermission = true;
      }
      if (haspermission) {
        setState(() {});
        showToast('Access granted');
        _getCurrentLocation();
      }
    } else {
    }
    setState(() {});
  }
  Widget _mapWidget(){
    return GoogleMap(
      initialCameraPosition: CameraPosition(
        target: LatLng(position!.latitude,position!.longitude),
        zoom: 20.0,
      ),
      onMapCreated: (GoogleMapController controller){
        _controller = controller;
        //_setStyle(controller);
        addressShow();
      },
      mapType: MapType.normal,
      myLocationEnabled: true,
      //compassEnabled: false,
      zoomControlsEnabled: false,
      markers: _createMarker(),
    );
  }
  void _setStyle(GoogleMapController controller) async {
    String value = await DefaultAssetBundle.of(context)
        .loadString('assets/images/map_style.json');
    controller.setMapStyle(value);
  }
  Set<Marker> _createMarker(){
    return <Marker>{
      Marker(
        markerId: const MarkerId('home'),
        position: LatLng(position!.latitude,position!.longitude),
        icon: BitmapDescriptor.defaultMarker,
        infoWindow: const InfoWindow(title: 'Current Location')
      )
    };
  }

  void showToast(message){
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.CENTER,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0
    );
  }
  Widget _changeLocation(){
    return Container(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(0,0,10,0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Expanded(
              child: Text(address,style: Util.txt(Palette.black, 14, FontWeight.w500),maxLines: 4,
                overflow: TextOverflow.ellipsis,),
            ),
            SizedBox(
              width: 80,height: 30,
              // decoration: BoxDecoration(
              //   borderRadius: BorderRadius.circular(20.0),
              // ),
              child: OutlinedButton(onPressed: (){
                Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => const MyMapPicker()));//MapSearchPlaces()));
              },
              style: ButtonStyle(
              side: MaterialStateProperty.all(BorderSide(color: Palette.black,width: 1.2)),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              padding: MaterialStateProperty.all(EdgeInsets.zero),
              shape: MaterialStateProperty.all(const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(10.0))))
              ), child: Text('CHANGE',style: Util.txt(Palette.black, 16, FontWeight.w500)),
              ),
            ),
          ],
        ),
      ),
    );
  }
  addressShow() async{
   List placemark = await placemarkFromCoordinates(position!.latitude, position!.longitude);
   Placemark place = placemark[0];
   address = 'Name:${place.name}, Street:${place.street}, sub locality:${place.subLocality}, locality:${place.locality}, postal code:${place.postalCode}';
   setState(() {});
  }
  shipmentCheck() async {
    if (!servicestatus) {
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Location services are disabled. Please enable the services')));
    return ;
  }
    Util.showProgress(context);
    Util.logDebug(position!.latitude.toString());
    Util.logDebug(position!.longitude.toString());
    final shipCheck = http.MultipartRequest(
        'POST', Uri.parse('${Util.baseurl}shipping/dunzo/quote.php'));
    shipCheck.fields['droplat'] = position!.latitude.toString();
    shipCheck.fields['droplng'] = position!.longitude.toString();
    var resu = await shipCheck.send();
    var response = await http.Response.fromStream(resu);
    try {
      if (response.statusCode == 200) {
        Util.dismissDialog(context);
        var dec = jsonDecode(response.body);
        Util.logDebug(dec);
        if (dec['success'] == true) {
          var personInfoString = '${position!.latitude},${position!.longitude}';
          Util.logDebug('latlangValues:$personInfoString');
          Util.addStringToSF('latlang',personInfoString,'');
          Util.addStringToSF('latvalue',position!.latitude.toString(),'');
          Util.addStringToSF('longvalue',position!.longitude.toString(),'');
          Navigator.push(context,MaterialPageRoute(builder: (context) =>  const AddressForm(type: 'add',
                                  state: 0,
                                  address: [],

          )));
          Util.control.deliveryAdd.value = 'Delivery to $address';
        } else {
          Util.customDialog('Info',dec['message'], context);
          //Util.showDog(_scaffoldKey.currentContext!,dec['message']);
        }
      } else {
       /* Util.dismissDialog(_scaffoldKey.currentContext!);
        Navigator.pop(_scaffoldKey.currentContext!);
        Util.showDog(_scaffoldKey.currentContext!, 'Try again');*/
      }
    } catch (e) {
      Util.logDebug('error $e');
    }
  }
}