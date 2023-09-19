import 'package:get/get.dart';

class Controller extends GetxController{
  var nav = 0.obs,cart=0.obs,carouselMan=0.obs;
  RxDouble totalAmount= 0.0.obs,checkOutPrice=0.0.obs,charges=0.0.obs;
  RxBool promo = true.obs;
  RxString isfirstname=''.obs,islastname=''.obs,iscity=''.obs,isstate=''.obs,ispincode=''.obs,delAddress=''.obs,delMobile=''.obs,deliveryAdd='Check Delivery Availability'.obs,latitude=''.obs,longitude=''.obs;
}