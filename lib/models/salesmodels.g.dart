// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'salesmodels.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Vat _$VatFromJson(Map<String, dynamic> json) {
  return Vat(
    id: json['id'] as int,
    code: json['code'] as String,
    rate: (json['rate'] as num)?.toDouble(),
  );
}

Map<String, dynamic> _$VatToJson(Vat instance) => <String, dynamic>{
      'id': instance.id,
      'code': instance.code,
      'rate': instance.rate,
    };

OrderDetail _$OrderDetailFromJson(Map<String, dynamic> json) {
  return OrderDetail(
    invCode: json['invCode'] as String,
    originalPrice: (json['originalPrice'] as num)?.toDouble(),
    invDescrip: json['invDescrip'] as String,
    invQty: (json['invQty'] as num)?.toDouble(),
    invDiscount: (json['invDiscount'] as num)?.toDouble(),
    itemQty: (json['itemQty'] as num)?.toDouble(),
    itemPrice: (json['itemPrice'] as num)?.toDouble(),
    invPrice: (json['invPrice'] as num)?.toDouble(),
  );
}

Map<String, dynamic> _$OrderDetailToJson(OrderDetail instance) =>
    <String, dynamic>{
      'invCode': instance.invCode,
      'invDescrip': instance.invDescrip,
      'invQty': instance.invQty,
      'itemPrice': instance.itemPrice,
      'itemQty': instance.itemQty,
      'originalPrice': instance.originalPrice,
      'invDiscount': instance.invDiscount,
      'invPrice': instance.invPrice,
    };

SalesOrder _$SalesOrderFromJson(Map<String, dynamic> json) {
  return SalesOrder(
    custid: json['custid'] as String,
    orderid: json['orderid'] as int,
    custName: json['custName'] as String,
    orderdate: json['orderdate'] as String,
    orderdocno: json['orderdocno'] as String,
    ordervalidity: json['ordervalidity'] as int,
    orderDetails: (json['orderDetails'] as List)
        ?.map((e) =>
            e == null ? null : OrderDetail.fromJson(e as Map<String, dynamic>))
        ?.toList(),
  );
}

Map<String, dynamic> _$SalesOrderToJson(SalesOrder instance) =>
    <String, dynamic>{
      'custid': instance.custid,
      'orderid': instance.orderid,
      'custName': instance.custName,
      'orderdate': instance.orderdate,
      'orderdocno': instance.orderdocno,
      'ordervalidity': instance.ordervalidity,
      'orderDetails': instance.orderDetails?.map((e) => e?.toJson())?.toList(),
    };

InvoiceDetails _$InvoiceDetailsFromJson(Map<String, dynamic> json) {
  return InvoiceDetails(
    invid: json['invid'] as int,
    originalPrice: (json['originalPrice'] as num)?.toDouble(),
    discount: (json['discount'] as num)?.toDouble(),
    vatRate: (json['vatRate'] as num)?.toDouble(),
    itemDesc: json['itemDesc'] as String,
    vat: (json['vat'] as num)?.toDouble(),
    itemQty: (json['itemQty'] as num)?.toDouble(),
    qtysold: (json['qtysold'] as num)?.toDouble(),
    discAmt: (json['discAmt'] as num)?.toDouble(),
    total: (json['total'] as num)?.toDouble(),
    rprice: (json['rprice'] as num)?.toDouble(),
  );
}

Map<String, dynamic> _$InvoiceDetailsToJson(InvoiceDetails instance) =>
    <String, dynamic>{
      'invid': instance.invid,
      'itemDesc': instance.itemDesc,
      'vatRate': instance.vatRate,
      'vat': instance.vat,
      'itemQty': instance.itemQty,
      'discount': instance.discount,
      'qtysold': instance.qtysold,
      'discAmt': instance.discAmt,
      'originalPrice': instance.originalPrice,
      'total': instance.total,
      'rprice': instance.rprice,
    };

SalesInvoice _$SalesInvoiceFromJson(Map<String, dynamic> json) {
  return SalesInvoice(
    custid: json['custid'] as int,
    granddiscount: (json['granddiscount'] as num)?.toDouble(),
    salesrep: json['salesrep'] as int,
    costcenter: json['costcenter'] as int,
    invdate: json['invdate'] as String,
    subtotal: (json['subtotal'] as num)?.toDouble(),
    vat: (json['vat'] as num)?.toDouble(),
    remarks: json['remarks'] as String,
    grandtotal: (json['grandtotal'] as num)?.toDouble(),
    invDetails: (json['invDetails'] as List)
        ?.map((e) => e == null
            ? null
            : InvoiceDetails.fromJson(e as Map<String, dynamic>))
        ?.toList(),
  );
}

Map<String, dynamic> _$SalesInvoiceToJson(SalesInvoice instance) =>
    <String, dynamic>{
      'custid': instance.custid,
      'salesrep': instance.salesrep,
      'costcenter': instance.costcenter,
      'invdate': instance.invdate,
      'remarks': instance.remarks,
      'subtotal': instance.subtotal,
      'granddiscount': instance.granddiscount,
      'vat': instance.vat,
      'grandtotal': instance.grandtotal,
      'invDetails': instance.invDetails?.map((e) => e?.toJson())?.toList(),
    };

RecieptObj _$RecieptObjFromJson(Map<String, dynamic> json) {
  return RecieptObj(
    custid: json['custid'] as int,
    salesrepid: json['salesrepid'] as int,
    costcenter: json['costcenter'] as int,
    paymode: json['paymode'] as String,
    paydate: json['paydate'] as String,
    total: (json['total'] as num)?.toDouble(),
  );
}

Map<String, dynamic> _$RecieptObjToJson(RecieptObj instance) =>
    <String, dynamic>{
      'custid': instance.custid,
      'salesrepid': instance.salesrepid,
      'costcenter': instance.costcenter,
      'paymode': instance.paymode,
      'paydate': instance.paydate,
      'total': instance.total,
    };

InvoiceHistory _$InvoiceHistoryFromJson(Map<String, dynamic> json) {
  return InvoiceHistory(
    id: json['id'] as int,
    date: json['date'] as String,
    custname: json['custname'] as String,
    amount: (json['amount'] as num)?.toDouble(),
  );
}

Map<String, dynamic> _$InvoiceHistoryToJson(InvoiceHistory instance) =>
    <String, dynamic>{
      'id': instance.id,
      'date': instance.date,
      'custname': instance.custname,
      'amount': instance.amount,
    };

InvoiceHistoryObj _$InvoiceHistoryObjFromJson(Map<String, dynamic> json) {
  print('------------> Deserializer invoked');
  return InvoiceHistoryObj(
    id: json['id'] as int,
    totalAmount: (json['totalAmount'] as num)?.toDouble(),
    invdate: json['invdate'] as String,
    custname: json['custname'] as String,
    vatAmount: (json['vatAmount'] as num)?.toDouble(),
    subtotalAmount: (json['subtotalAmount'] as num)?.toDouble(),
    invoiceDetails: (json['invoiceDetails'] as List)
        ?.map((e) => e == null
            ? null
            : InvoiceHistoryDetail.fromJson(e as Map<String, dynamic>))
        ?.toList(),
  );
}

Map<String, dynamic> _$InvoiceHistoryObjToJson(InvoiceHistoryObj instance) =>
    <String, dynamic>{
      'id': instance.id,
      'totalAmount': instance.totalAmount,
      'invdate': instance.invdate,
      'custname': instance.custname,
      'vatAmount': instance.vatAmount,
      'subtotalAmount': instance.subtotalAmount,
      'invoiceDetails':
          instance.invoiceDetails?.map((e) => e?.toJson())?.toList(),
    };

InvoiceHistoryDetail _$InvoiceHistoryDetailFromJson(Map<String, dynamic> json) {
  return InvoiceHistoryDetail(
    itemname: json['itemname'] as String,
    totalprice: (json['totalprice'] as num)?.toDouble(),
    qty: (json['qty'] as num)?.toDouble(),
    discount: (json['discount'] as num)?.toDouble(),
    unitprice: (json['unitprice'] as num)?.toDouble(),
  );
}

Map<String, dynamic> _$InvoiceHistoryDetailToJson(
        InvoiceHistoryDetail instance) =>
    <String, dynamic>{
      'itemname': instance.itemname,
      'totalprice': instance.totalprice,
      'qty': instance.qty,
      'discount': instance.discount,
      'unitprice': instance.unitprice,
    };

OrderHistory _$OrderHistoryFromJson(Map<String, dynamic> json) {
  return OrderHistory(
    id: json['id'] as int,
    date: json['date'] as String,
    custname: json['custname'] as String,
    amount: (json['amount'] as num)?.toDouble(),
  );
}

Map<String, dynamic> _$OrderHistoryToJson(OrderHistory instance) =>
    <String, dynamic>{
      'id': instance.id,
      'date': instance.date,
      'custname': instance.custname,
      'amount': instance.amount,
    };

ReqHistory _$ReqHistoryFromJson(Map<String, dynamic> json) {
  return ReqHistory(
    json['id'] as int,
    json['date'] as String,
    (json['mrdetails'] as List)
        ?.map((e) => e == null
            ? null
            : ReqDetHistory.fromJson(e as Map<String, dynamic>))
        ?.toList(),
  );
}

Map<String, dynamic> _$ReqHistoryToJson(ReqHistory instance) =>
    <String, dynamic>{
      'id': instance.id,
      'date': instance.date,
      'mrdetails': instance.mrdetails?.map((e) => e?.toJson())?.toList(),
    };

ReqDetHistory _$ReqDetHistoryFromJson(Map<String, dynamic> json) {
  return ReqDetHistory(
    json['item'] as String,
    (json['qty'] as num)?.toDouble(),
  );
}

Map<String, dynamic> _$ReqDetHistoryToJson(ReqDetHistory instance) =>
    <String, dynamic>{
      'item': instance.item,
      'qty': instance.qty,
    };
