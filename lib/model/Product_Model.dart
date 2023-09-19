import 'package:json_annotation/json_annotation.dart';

@JsonSerializable()
class ProductModel{
  final String uuid,name,image,price,rating,stock,weight;
   int count;
  ProductModel({required this.name,required this.image,required this.uuid,required this.count,required this.price,required this.rating,required this.stock,required this.weight});
}

@JsonSerializable()
class ProductItemModel{
  final String uuid,name,image,price,rating,stock,weight,description,discount,actualprice;
  int count;
  ProductItemModel({required this.name,required this.image,required this.uuid,required this.count,required this.price,required this.rating,required this.description,
    required this.stock,required this.weight,required this.discount,required this.actualprice});
}

@JsonSerializable()
class PromoCodeModel{
  final String code;
  final String amount;
  final String discount;
  PromoCodeModel({required this.code,required this.amount,required this.discount});
}

@JsonSerializable()
class SearchModel{
  final String uuid,name,image,price,weight,rating,stock;
   int count;
  SearchModel({required this.uuid,required this.name,required this.image,required this.price,required this.rating,required this.stock,required this.weight,required this.count});
}

@JsonSerializable()
class AddressModel{
  final String id,mobile,address,fn,ln,city,state,pincode,country,latitude,longitude;
  AddressModel({required this.id,required this.mobile,required this.address,required this.country,required this.pincode,required this.state,required this.city,required this.fn,required this.ln,required this.latitude,required this.longitude});
}

@JsonSerializable()
class ContactUsModel{
  final String email;
  final String mobile;
  final String address;
  ContactUsModel({required this.email,required this.mobile,required this.address});
}

@JsonSerializable()
class PaymentModel{
  final String keyId;
  final String keySecret;
  final String url;
  PaymentModel({required this.keyId,required this.keySecret,required this.url,});
}

@JsonSerializable()
class ProfileModel{
  final String email;
  final String mobile;
  final String address;
  final String name;
  final String image;
  ProfileModel({required this.email,required this.mobile,required this.address,required this.name, required this.image,});
}