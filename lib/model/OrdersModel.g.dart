// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'OrdersModel.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OrderListModel _$OrderListModelFromJson(Map<String, dynamic> json) =>
    OrderListModel(
      json['orderid'] as String? ?? '',
      json['date'] as String? ?? '',
      json['amount'] as String? ?? '',
      json['status'] as String? ?? '',
      json['feedbackstatus'] as String? ?? '',
      json['feedbacktext'] as String? ?? '',
      json['deliverydate'] as String? ?? '',
      json['shippingstatus'] as String? ?? '',
      json['trackingid'] as String? ?? '',
      (json['itemslist'] as List<dynamic>)
          .map((e) => ItemsListModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$OrderListModelToJson(OrderListModel instance) =>
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
    };
