import 'package:json_annotation/json_annotation.dart';
import 'package:jwines/utils/Config.dart' as config;

part 'salesmodels.g.dart';

@JsonSerializable()
class Vat{
  int id;
  String code;
  double rate;

  Vat({this.id,this.code,this.rate});
  factory Vat.fromJson(Map<String,dynamic> json) => _$VatFromJson(json);
  Map<String,dynamic> toJson() => _$VatToJson(this);

  @override
  String toString() {
    return 'Vat{id: $id, code: $code, rate: $rate}';
  }
}

@JsonSerializable()
class OrderDetail{

  String invCode;
  String invDescrip;
  double invQty;
  double itemPrice;
  double itemQty;
  double originalPrice;
  double invDiscount;
  double invPrice;

  OrderDetail({this.invCode,this.originalPrice,this.invDescrip,this.invQty,this.invDiscount,this.itemQty,this.itemPrice,this.invPrice});
  factory OrderDetail.fromJson(Map<String,dynamic> json) => _$OrderDetailFromJson(json);
  Map<String,dynamic> toJson() => _$OrderDetailToJson(this);
  Map<String,dynamic> toMap(){
    var map = <String,dynamic>{
      config.invCode : invCode,
      config.invDescrip : invDescrip,
      config.invQty : invQty,
      config.itemPrice : itemPrice,
      config.itemQty : itemQty,
      config.originalPrice : originalPrice,
      config.invDiscount : invDiscount,
      config.invPrice : invPrice
    };
    return map;
  }

  OrderDetail.fromMap(Map<String,dynamic> map){
    invCode = map[config.invCode];
    invDescrip = map[config.invDescrip];
    invQty = map[config.invQty];
    itemPrice = map[config.itemPrice];
    itemQty = map[config.itemQty];
    originalPrice = map[config.originalPrice];
    invDiscount = map[config.invDiscount];
    invPrice = map[config.invPrice];
  }

  @override
  String toString() {
    return 'OrderDetail{invDescrip: $invDescrip, invQty: $invQty, invPrice: $invPrice}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is OrderDetail &&
              runtimeType == other.runtimeType &&
              invCode == other.invCode &&
              invDescrip == other.invDescrip &&
              invQty == other.invQty &&
              invPrice == other.invPrice;

  @override
  int get hashCode =>
      invCode.hashCode ^
      invDescrip.hashCode ^
      invQty.hashCode ^
      invPrice.hashCode;




}

@JsonSerializable(explicitToJson: true)
class SalesOrder{

  String custid;
  int orderid;
  String custName;
  String orderdate;
  String orderdocno;
  int ordervalidity;
  List<OrderDetail> orderDetails;

  SalesOrder({this.custid,this.orderid,this.custName,this.orderdate,this.orderdocno,this.ordervalidity,this.orderDetails});
  factory SalesOrder.fromJson(Map<String,dynamic> json) => _$SalesOrderFromJson(json);
  Map<String,dynamic> toJson() => _$SalesOrderToJson(this);
  Map<String,dynamic> toMap() {
    var map = <String,dynamic>{
      config.custid : custid,
      config.custname : custName,
      config.orderid : orderid,
      config.orderdocno : orderdocno,
      config.orderdate : orderdate,
      config.ordervalidity : ordervalidity
    };
    return map;
  }

  SalesOrder.fromMap(Map<String,dynamic> map){
    custid = map[config.custid];
    custName = map[config.custname];
    orderid = map[config.orderid];
    orderdocno = map[config.orderdocno];
    orderdate = map[config.orderdate];
    ordervalidity = map[config.ordervalidity];
  }

  @override
  String toString() {
    return 'SalesOrder{custid: $custid, orderid: $orderid, orderdate: $orderdate, orderdocno: $orderdocno, ordervalidity: $ordervalidity, orderDetails: $orderDetails}';
  }
}

@JsonSerializable()
class InvoiceDetails{
  int invid;
  String itemDesc;
  double vatRate;
  double vat;
  double itemQty;
  double discount;
  double qtysold;
  double discAmt;
  double originalPrice;
  double total;
  double rprice;

  InvoiceDetails({this.invid,this.originalPrice,this.discount,this.vatRate,this.itemDesc,this.vat,this.itemQty,this.qtysold,this.discAmt,this.total,this.rprice});
  factory InvoiceDetails.fromJson(Map<String,dynamic> json) => _$InvoiceDetailsFromJson(json);
  Map<String,dynamic> toJson() => _$InvoiceDetailsToJson(this);

  @override
  String toString() {
    return 'InvoiceDetails{qtysold: $qtysold, total: $total, rprice: $rprice}';
  }
}

@JsonSerializable(explicitToJson: true)
class SalesInvoice{
  int custid;
  int salesrep;
  int costcenter;
  String invdate;
  String remarks;
  double subtotal;
  double granddiscount;
  double vat;
  double grandtotal;
  List<InvoiceDetails> invDetails;

  SalesInvoice({this.custid,this.granddiscount,this.salesrep,this.costcenter,this.invdate,this.subtotal,this.vat,this.remarks,this.grandtotal,this.invDetails});
  factory SalesInvoice.fromJson(Map<String,dynamic> json) => _$SalesInvoiceFromJson(json);
  Map<String,dynamic> toJson() => _$SalesInvoiceToJson(this);

  @override
  String toString() {
    return 'SalesInvoice{custid: $custid, salesrep: $salesrep, costcenter: $costcenter, invdate: $invdate, vat: $vat, grandtotal: $grandtotal, invDetails: $invDetails}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is SalesInvoice &&
              runtimeType == other.runtimeType &&
              custid == other.custid &&
              salesrep == other.salesrep &&
              costcenter == other.costcenter &&
              invdate == other.invdate &&
              subtotal == other.subtotal &&
              vat == other.vat &&
              grandtotal == other.grandtotal &&
              invDetails == other.invDetails;

  @override
  int get hashCode =>
      custid.hashCode ^
      salesrep.hashCode ^
      costcenter.hashCode ^
      invdate.hashCode ^
      subtotal.hashCode ^
      vat.hashCode ^
      grandtotal.hashCode ^
      invDetails.hashCode;



}

@JsonSerializable()
class RecieptObj{
  int custid;
  int salesrepid;
  int costcenter;
  String paymode;
  String paydate;
  double total;

  RecieptObj({this.custid,this.salesrepid,this.costcenter,this.paymode,this.paydate,this.total});
  factory RecieptObj.fromJson(Map<String,dynamic> json) => _$RecieptObjFromJson(json);
  Map<String,dynamic> toJson() => _$RecieptObjToJson(this);

}

@JsonSerializable()
class InvoiceHistory{

  int id;
  String date;
  String custname;
  double amount;

  InvoiceHistory({this.id,this.date,this.custname,this.amount});
  factory InvoiceHistory.fromJson(Map<String,dynamic> json) => _$InvoiceHistoryFromJson(json);
  Map<String,dynamic> toJson() => _$InvoiceHistoryToJson(this);

}

@JsonSerializable(explicitToJson: true)
class InvoiceHistoryObj{

  int id;
  double totalAmount;
  String invdate;
  String custname;
  double vatAmount;
  double subtotalAmount;
  List<InvoiceHistoryDetail> invoiceDetails;

  InvoiceHistoryObj({this.id, this.totalAmount, this.invdate, this.custname,
      this.vatAmount, this.subtotalAmount, this.invoiceDetails});
  factory InvoiceHistoryObj.fromJson(Map<String,dynamic> json) => _$InvoiceHistoryObjFromJson(json);
  Map<String,dynamic> toJson() => _$InvoiceHistoryObjToJson(this);
}

@JsonSerializable()
class InvoiceHistoryDetail{

  String itemname;
  double totalprice;
  double qty;
  double discount;
  double unitprice;

  InvoiceHistoryDetail({this.itemname, this.totalprice, this.qty, this.discount, this.unitprice});
  factory InvoiceHistoryDetail.fromJson(Map<String,dynamic> json) => _$InvoiceHistoryDetailFromJson(json);
  Map<String,dynamic> toJson() => _$InvoiceHistoryDetailToJson(this);
}

@JsonSerializable()
class OrderHistory{

  int id;
  String date;
  String custname;
  double amount;

  OrderHistory({this.id,this.date,this.custname,this.amount});
  factory OrderHistory.fromJson(Map<String,dynamic> json) => _$OrderHistoryFromJson(json);
  Map<String,dynamic> toJson() => _$OrderHistoryToJson(this);

}

@JsonSerializable(explicitToJson: true)
class ReqHistory{

  int id;
  String date;
  List<ReqDetHistory> mrdetails;

  ReqHistory(this.id, this.date, this.mrdetails);
  factory ReqHistory.fromJson(Map<String,dynamic> json) => _$ReqHistoryFromJson(json);
  Map<String,dynamic> toJson() => _$ReqHistoryToJson(this);

}

@JsonSerializable()
class ReqDetHistory{

  String item;
  double qty;

  ReqDetHistory(this.item, this.qty);
  factory ReqDetHistory.fromJson(Map<String,dynamic> json) => _$ReqDetHistoryFromJson(json);
  Map<String,dynamic> toJson() => _$ReqDetHistoryToJson(this);

}