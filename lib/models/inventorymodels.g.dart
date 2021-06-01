// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'inventorymodels.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

InventoryItem _$InventoryItemFromJson(Map<String, dynamic> json) {
  return InventoryItem(
    id: json['id'] as int,
    description: json['description'] as String,
    invCode: json['invCode'] as String,
    vat: json['vat'] as int,
    rprice: (json['rprice'] as num)?.toDouble(),
    currqty: (json['currqty'] as num)?.toDouble(),
  );
}

Map<String, dynamic> _$InventoryItemToJson(InventoryItem instance) =>
    <String, dynamic>{
      'id': instance.id,
      'description': instance.description,
      'invCode': instance.invCode,
      'vat': instance.vat,
      'rprice': instance.rprice,
      'currqty': instance.currqty,
    };

InvClass _$InvClassFromJson(Map<String, dynamic> json) {
  return InvClass(
    id: json['id'] as int,
    description: json['description'] as String,
  );
}

Map<String, dynamic> _$InvClassToJson(InvClass instance) => <String, dynamic>{
      'id': instance.id,
      'description': instance.description,
    };

PriceListDetail _$PriceListDetailFromJson(Map<String, dynamic> json) {
  return PriceListDetail(
    id: json['id'] as int,
    pricelist: json['pricelist'] as int,
    inventory: json['inventory'] as int,
    sellingprice: (json['sellingprice'] as num)?.toDouble(),
    discount: (json['discount'] as num)?.toDouble(),
  );
}

Map<String, dynamic> _$PriceListDetailToJson(PriceListDetail instance) =>
    <String, dynamic>{
      'id': instance.id,
      'pricelist': instance.pricelist,
      'inventory': instance.inventory,
      'sellingprice': instance.sellingprice,
      'discount': instance.discount,
    };

MReqDetail _$MReqDetailFromJson(Map<String, dynamic> json) {
  return MReqDetail(
    invid: json['invid'] as int,
    desc: json['desc'] as String,
    rprice: (json['rprice'] as num)?.toDouble(),
    itemQty: (json['itemQty'] as num)?.toDouble(),
    qty: (json['qty'] as num)?.toDouble(),
    total: (json['total'] as num)?.toDouble(),
  );
}

Map<String, dynamic> _$MReqDetailToJson(MReqDetail instance) =>
    <String, dynamic>{
      'invid': instance.invid,
      'desc': instance.desc,
      'qty': instance.qty,
      'rprice': instance.rprice,
      'itemQty': instance.itemQty,
      'total': instance.total,
    };

MReqObject _$MReqObjectFromJson(Map<String, dynamic> json) {
  return MReqObject(
    costcenter: json['costcenter'] as int,
    remarks: json['remarks'] as String,
    reqDetails: (json['reqDetails'] as List)
        ?.map((e) =>
            e == null ? null : MReqDetail.fromJson(e as Map<String, dynamic>))
        ?.toList(),
  );
}

Map<String, dynamic> _$MReqObjectToJson(MReqObject instance) =>
    <String, dynamic>{
      'costcenter': instance.costcenter,
      'remarks': instance.remarks,
      'reqDetails': instance.reqDetails?.map((e) => e?.toJson())?.toList(),
    };
