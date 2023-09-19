
import 'package:json_annotation/json_annotation.dart';
import 'ItemsListModel.dart';
part 'OrdersModel.g.dart';
@JsonSerializable(explicitToJson: true)
class OrderListModel{
  @JsonKey(defaultValue: '')
  String orderid,date,amount,status,feedbackstatus,feedbacktext,trackingid,deliverydate,shippingstatus;
  List<ItemsListModel> itemslist;
  OrderListModel(this.orderid, this.date, this.amount, this.status, this.feedbackstatus, this.feedbacktext,this.deliverydate,this.shippingstatus,this.trackingid,this.itemslist);
  factory OrderListModel.fromJson(Map<String, dynamic> json) => _$OrderListModelFromJson(json);
  Map<String, dynamic> toJson() => _$OrderListModelToJson(this);
}