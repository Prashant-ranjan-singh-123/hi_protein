
import 'package:json_annotation/json_annotation.dart';
import 'ItemsListModel.dart';
part 'orderdetails.g.dart';

@JsonSerializable(explicitToJson: true)
class OrderDetails{
  @JsonKey(defaultValue: '')
  String orderid,date,amount,status,feedbackstatus,feedbacktext,trackingid,deliverydate,shippingstatus;
  List<ItemsListModel> itemslist;
  List<Address> address;
  OrderDetails(this.orderid, this.address, this.date, this.amount, this.status, this.feedbackstatus, this.feedbacktext, this.itemslist,this.trackingid,this.shippingstatus,this.deliverydate);
  factory OrderDetails.fromJson(Map<String, dynamic> json) => _$OrderDetailsFromJson(json);
  Map<String, dynamic> toJson() => _$OrderDetailsToJson(this);
}

@JsonSerializable()
class Address{
  @JsonKey(defaultValue: '')
  String email,address,mobilenumber,first_name,last_name,city,pincode,state,country;
  Address(this.state,this.address,this.pincode,this.country,this.city,this.email,this.first_name,this.last_name,this.mobilenumber);
  factory Address.fromJson(Map<String, dynamic> json) => _$AddressFromJson(json);
  Map<String, dynamic> toJson() => _$AddressToJson(this);
}