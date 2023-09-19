// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'orderdetails.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************
OrderDetails _$OrderDetailsFromJson(Map<String, dynamic> json) => OrderDetails(
      json['orderid'] as String? ?? '',
      (json['address'] as List<dynamic>)
          .map((e) => Address.fromJson(e as Map<String, dynamic>))
          .toList(),
      json['date'] as String? ?? '',
      json['amount'] as String? ?? '',
      json['status'] as String? ?? '',
      json['feedbackstatus'] as String? ?? '',
      json['feedbacktext'] as String? ?? '',
      (json['itemslist'] as List<dynamic>)
          .map((e) => ItemsListModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      json['trackingid'] as String? ?? '',
      json['shippingstatus'] as String? ?? '',
      json['deliverydate'] as String? ?? '',
    );

Map<String, dynamic> _$OrderDetailsToJson(OrderDetails instance) =>
    <String, dynamic>{
      'orderid': instance.orderid,
      'date': instance.date,
      'amount': instance.amount,
      'status': instance.status,
      'feedbackstatus': instance.feedbackstatus,
      'feedbacktext': instance.feedbacktext,
      'trackingid': instance.trackingid,
      'deliverydate': instance.deliverydate,
      'shippingstatus': instance.shippingstatus,
      'itemslist': instance.itemslist.map((e) => e.toJson()).toList(),
      'address': instance.address.map((e) => e.toJson()).toList(),
    };

Address _$AddressFromJson(Map<String, dynamic> json) => Address(
      json['state'] as String? ?? '',
      json['address'] as String? ?? '',
      json['pincode'] as String? ?? '',
      json['country'] as String? ?? '',
      json['city'] as String? ?? '',
      json['email'] as String? ?? '',
      json['first_name'] as String? ?? '',
      json['last_name'] as String? ?? '',
      json['mobilenumber'] as String? ?? '',
    );

Map<String, dynamic> _$AddressToJson(Address instance) => <String, dynamic>{
      'email': instance.email,
      'address': instance.address,
      'mobilenumber': instance.mobilenumber,
      'first_name': instance.first_name,
      'last_name': instance.last_name,
      'city': instance.city,
      'pincode': instance.pincode,
      'state': instance.state,
      'country': instance.country,
    };
