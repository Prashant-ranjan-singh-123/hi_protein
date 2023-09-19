
import 'package:json_annotation/json_annotation.dart';
part 'ItemsListModel.g.dart';
@JsonSerializable()
class ItemsListModel{
  String id,email,mobilenumber,Rpayorderid,itemcategory,name,image,description,count,price,itemcode;
  ItemsListModel(this.id, this.email, this.mobilenumber, this.Rpayorderid, this.itemcategory, this.name, this.image, this.description, this.count, this.price,this.itemcode);
  factory ItemsListModel.fromJson(Map<String, dynamic> json) => _$ItemsListModelFromJson(json);
  Map<String, dynamic> toJson() => _$ItemsListModelToJson(this);
}