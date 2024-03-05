import 'dart:async';
import 'dart:convert';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_api_headers/google_api_headers.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter/material.dart';
import 'package:hi_protein/utilities/constants.dart';
import 'package:map_picker/map_picker.dart';
import 'package:geocoding/geocoding.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:flutter_google_places_hoc081098/flutter_google_places_hoc081098.dart';
import 'package:http/http.dart' as http;
import '../screens/Home/HomeScreen.dart';

class MyMapPicker extends StatefulWidget{
  const MyMapPicker({Key? key}) : super(key:key);
  @override
  State createState() => _MyMapPickerState();
}
class _MyMapPickerState extends State<MyMapPicker> {
  String googleApikey = "AIzaSyDY8p6whIPad6UA7-8DbD0wb_UdsYDjnKA";
  String locationaddress = "Search Address", latString = '', longString = '';
  final _controller = Completer<GoogleMapController>();
  MapPickerController mapPickerController = MapPickerController();
  bool servicestatus = false, haspermission = false;
  CameraPosition cameraPosition = const CameraPosition(
    target: LatLng(17.441536719386637,78.50424601903342),
    zoom: 20,
  );
  var textController=TextEditingController();
  @override
  void initState() {
    getLocation();
    //Future.delayed(const Duration(seconds: 1)).then((value) => _getCurrentLocation());
    _getCurrentLocation();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        //title: Text("search location",style: Util.txt(Palette.black, 16, FontWeight.w500)),
        elevation: 0,
        actions: <Widget>[
          IconButton(
            icon: const Icon(
              Icons.my_location,
              color: Colors.blue, //Palette.black,
            ),
            onPressed: () {
              _getCurrentLocation();
            },
          ),
          /*TextButton(
            onPressed: () {shipmentCheck();},
          child:Text('current location',style: Util.txt(Palette.black, 16, FontWeight.w500)),),*/
        ],
      ),
      body: Stack(
        alignment: Alignment.topCenter,
        children: [
          MapPicker(
            // pass icon widget
            iconWidget: SvgPicture.asset(
              "assets/images/location_icon.svg",
              height: 40,
            ),
            //add map picker controller
            mapPickerController: mapPickerController,
            child: GoogleMap(
              myLocationEnabled: true,
              zoomControlsEnabled: false,
              // hide location button
              myLocationButtonEnabled: false,
              mapType: MapType.normal,
              //  camera position
              initialCameraPosition: cameraPosition,
              onMapCreated: (GoogleMapController controller) {
                _controller.complete(controller);
              },
              onCameraMoveStarted: () {
                // notify map is moving
                mapPickerController.mapMoving!();
                textController.text = "checking ...";
              },
              onCameraMove: (cameraPosition) {
                this.cameraPosition = cameraPosition;
              },
              onCameraIdle: () async {
                // notify map stopped moving
                mapPickerController.mapFinishedMoving!();
                //get address name from camera position
                List<Placemark> placemarks = await placemarkFromCoordinates(
                  cameraPosition.target.latitude,
                  cameraPosition.target.longitude,
                );
                latString = cameraPosition.target.latitude.toString();
                longString = cameraPosition.target.longitude.toString();
                Placemark place = placemarks[0];
                locationaddress = place.subLocality.toString() +
                    '${place.subLocality.toString().length == 0 ? '' : ','}' +
                    place.locality.toString() +
                    '${place.locality.toString().length == 0 ? '' : ','}' +
                    place.postalCode.toString();
               // textController.text ='Your order will be delivered here\nMove pin to your exact location.'; //place.locality.toString()+'${place.locality.toString().length==0?'':','}'+place.subLocality.toString()+'${place.subLocality.toString().length==0?'':','}'+place.postalCode.toString();
                orderStringMethod(); 
                //Name:${place.name}, Street:${place.street}, sub locality:${place.subLocality}, locality:${place.locality}, postal code:${place.postalCode}
                // update the ui with the address
                // if(place.subLocality == ''){
                //   locationaddress = '${place.locality},${place.postalCode}';
                // // textController.text ='${place.locality},${place.postalCode}';
                // // locationaddress = '${place.subLocality},${place.locality},${place.postalCode}';//placemarks.first.street.toString() + "," + placemarks.first.locality.toString() + "," + placemarks.first.administrativeArea.toString() + "," + placemarks.first.postalCode.toString();
                // }
                // else if(place.locality == ''){
                // locationaddress = '${place.subLocality},${place.postalCode}';}
                // else if(place.postalCode == ''){
                // locationaddress = '${place.locality},${place.subLocality}';}
                // else (){};
              },
            ),
          ),
          Positioned(
              //top:40,
              child: InkWell(
                  onTap: () async {
                    var place = await PlacesAutocomplete.show(
                        context: context,
                        apiKey: googleApikey,
                        mode: Mode.overlay,
                        language: "in",
                        logo: const Text(
                          '',
                        ), //Text("Powered by Veramasa",textAlign: TextAlign.center,),//Text("Powered by Veramasa",textAlign: TextAlign.center,),
                        types: [],
                        strictbounds: false,
                        components: [Component(Component.country, 'in')],
                        onError: (err) {
                        });
                    if (place != null) {
                      setState(() {
                        locationaddress = place.description.toString();
                        //textController.text = locationaddress;
                        orderStringMethod();
                      });
                      final plist = GoogleMapsPlaces(
                        apiKey: googleApikey,
                        apiHeaders: await const GoogleApiHeaders().getHeaders(),
                      );
                      String placeid = place.placeId ?? "0";
                      final detail = await plist.getDetailsByPlaceId(placeid);
                      final geometry = detail.result.geometry!;
                      final lat = geometry.location.lat;
                      final lang = geometry.location.lng;
                      var newlatlang = LatLng(lat, lang);
                      latString = lat.toString();
                      longString = lang.toString();
                      /* var personInfoString = '$latString,$longString';
                      Util.addStringToSF('latlang', personInfoString, '');
                      Util.addStringToSF('latvalue', latString, '');
                      Util.addStringToSF('longvalue', longString, '');*/
                      //addressShow(lat,lang);
                      final GoogleMapController mapController =
                          await _controller.future;
                      mapController.animateCamera(
                          CameraUpdate.newCameraPosition(
                              CameraPosition(target: newlatlang, zoom: 20)));
                    }
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(0),
                    child: Card(
                      child: Container(
                          padding: const EdgeInsets.all(0),
                          width: MediaQuery.of(context).size.width - 40,
                          child: const ListTile(
                            title: Text(
                              'Search address',
                              style: TextStyle(fontSize: 18),
                            ),
                            // trailing: const Icon(Icons.search),
                            dense: true,
                          )),
                    ),
                  ))),
          Positioned(
            top: MediaQuery.of(context).viewPadding.top + 240,
            width: MediaQuery.of(context).size.width - 160,
            height: 42,
            child: TextFormField(
              maxLines: 3,
              textAlign: TextAlign.center,
              readOnly: true,
              style: Util.txt(Colors.white, 12, FontWeight.w500),
              decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.black,
                  contentPadding: EdgeInsets.zero,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0))),
              controller: textController,
            ),
          ),
          Positioned(
            bottom: 24,
            left: 24,
            right: 24,
            child: SizedBox(
              height: 50,
              child: TextButton(
                // ignore: sort_child_properties_last
                child: const Text(
                  "Confirm Location",
                  style: TextStyle(
                    fontWeight: FontWeight.w400,
                    fontStyle: FontStyle.normal,
                    color: Color(0xFFFFFFFF),
                    fontSize: 19,
                    // height: 19/19,
                  ),
                ),
                onPressed: () {
                  latString = cameraPosition.target.latitude.toString();
                  longString = cameraPosition.target.longitude.toString();
                  shipmentCheck();
                },
                style: ButtonStyle(
                  backgroundColor:
                      MaterialStateProperty.all<Color>(const Color(0xFF717D7E)),
                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  Future<void> getLocation() async {
    servicestatus = await Geolocator.isLocationServiceEnabled();
    if (!servicestatus) {
      Geolocator.openLocationSettings();
      /*ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Location services are disabled. Please enable the services')));*/
      return;
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
        Position res = await Geolocator.getCurrentPosition();
        latString = res.latitude.toString();
        longString = res.longitude.toString();
        List<Placemark> placemarks =
            await placemarkFromCoordinates(res.latitude, res.longitude);
        locationaddress = placemarks.first.street.toString() +
            "," +
            placemarks.first.locality.toString() +
            "," +
            placemarks.first.administrativeArea.toString() +
            "," +
            placemarks.first.postalCode.toString();
        /*var personInfoString = '$latString,$longString';
        Util.addStringToSF('latlang', personInfoString, '');
        Util.addStringToSF('latvalue', latString, '');
        Util.addStringToSF('longvalue', longString, '');*/
        final GoogleMapController mapController = await _controller.future;
        mapController.animateCamera(CameraUpdate.newCameraPosition(
            CameraPosition(
                target: LatLng(res.latitude, res.longitude), zoom: 20)));
        setState(() {});
      }
    } else {
    }
    //setState(() {});
  }
  void _getCurrentLocation() async {
    Position res = await Geolocator.getCurrentPosition();
    latString = res.latitude.toString();
    longString = res.longitude.toString();
    List<Placemark> placemarks =await placemarkFromCoordinates(res.latitude, res.longitude);
    locationaddress = placemarks.first.street.toString() +
        "," +
        placemarks.first.locality.toString() +
        "," +
        placemarks.first.administrativeArea.toString() +
        "," +
        placemarks.first.postalCode.toString();
    /* var personInfoString = '$latString,$longString';
        Util.addStringToSF('latlang', personInfoString, '');
        Util.addStringToSF('latvalue', latString, '');
        Util.addStringToSF('longvalue', longString, '');*/
    final GoogleMapController mapController = await _controller.future;
    mapController.animateCamera(CameraUpdate.newCameraPosition(
        CameraPosition(target: LatLng(res.latitude, res.longitude), zoom: 20)));
    setState(() {});
  }

  shipmentCheck() async {
    Util.showProgress(context);
    Util.logDebug('$latString,$longString');
    var personInfoString = '$latString,$longString';
    final shipCheck = http.MultipartRequest('POST', Uri.parse('${Util.baseurl}shipping/dunzo/quote.php'));
    shipCheck.fields['droplat'] = latString;
    shipCheck.fields['droplng'] = longString;
    var resu = await shipCheck.send();
    var response = await http.Response.fromStream(resu);
    try {
      if (response.statusCode == 200) {
        Util.dismissDialog(context);
        var dec = jsonDecode(response.body);
        Util.logDebug(dec);
        if (dec['success'] == true) {
          Util.addStringToSF('latlang', personInfoString, '');
          Util.addStringToSF('latvalue', latString, '');
          Util.addStringToSF('longvalue', longString, '');
          Util.addStringToSF('deliverto', 'Delivery to $locationaddress', '');
          Util.control.deliveryAdd.value = 'Delivery to $locationaddress';
          Navigator.push(context, MaterialPageRoute(builder: (context) => const HomeScreen()));
        } else {
          Util.customDialog('Info', dec['message'], context);
          //Util.showDog(_scaffoldKey.currentContext!, dec['message']);
        }
      } else {
        /* Util.dismissDialog(_scaffoldKey.currentContext!);
        Navigator.pop(_scaffoldKey.currentContext!);
        Util.showDog(_scaffoldKey.currentContext!, 'Try again');*/
      }
    } catch (e) {
      Util.logDebug(e);
    }
  }
  orderStringMethod() {
    textController.text ='Your order will be delivered here\nMove pin to your exact location.';
      Text.rich(
        TextSpan(
          children: [
            TextSpan(
              text: textController.text,
            ),
            /* TextSpan(
        text: 'second line',
        style: TextStyle(fontSize: 12.0),
      ),*/
          ],
        ),
      );
  }
}
