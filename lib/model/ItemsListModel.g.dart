// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ItemsListModel.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ItemsListModel _$ItemsListModelFromJson(Map<String, dynamic> json) =>
    ItemsListModel(
      json['id'] as String,
      json['email'] as String,
      json['mobilenumber'] as String,
      json['Rpayorderid'] as String,
      json['itemcategory'] as String,
      json['name'] as String,
      json['image'] as String,
      json['description'] as String,
      json['count'] as String,
      json['price'] as String,
      json['itemcode'] as String,
    );

Map<String, dynamic> _$ItemsListModelToJson(ItemsListModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'email': instance.email,
      'mobilenumber': instance.mobilenumber,
      'Rpayorderid': instance.Rpayorderid,
      'itemcategory': instance.itemcategory,
      'name': instance.name,
      'image': instance.image,
      'description': instance.description,
      'count': instance.count,
      'price': instance.price,
      'itemcode': instance.itemcode,
    };
