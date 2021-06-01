// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'usermodels.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

User _$UserFromJson(Map<String, dynamic> json) {
  return User(
    id: json['id'] as int,
    hrid: json['hrid'] as int,
    custid: json['custid'] as int,
    pricelist: json['pricelist'] as int,
    balance: (json['balance'] as num)?.toDouble(),
    creditLimit: (json['creditLimit'] as num)?.toDouble(),
    pdamount: (json['pdamount'] as num)?.toDouble(),
    availableCredit: (json['availableCredit'] as num)?.toDouble(),
    fullName: json['fullName'] as String,
    userName: json['userName'] as String,
    password: json['password'] as String,
    active: json['active'] as bool,
    approved: json['approved'] as bool,
    email: json['email'] as String,
    costCenter: json['costCenter'] as int,
  );
}

Map<String, dynamic> _$UserToJson(User instance) => <String, dynamic>{
      'id': instance.id,
      'hrid': instance.hrid,
      'custid': instance.custid,
      'pricelist': instance.pricelist,
      'balance': instance.balance,
      'creditLimit': instance.creditLimit,
      'pdamount': instance.pdamount,
      'availableCredit': instance.availableCredit,
      'fullName': instance.fullName,
      'userName': instance.userName,
      'password': instance.password,
      'active': instance.active,
      'approved': instance.approved,
      'email': instance.email,
      'costCenter': instance.costCenter,
    };

Customer _$CustomerFromJson(Map<String, dynamic> json) {
  return Customer(
    custid: json['custid'] as int,
    custcode: json['custcode'] as String,
    company: json['company'] as String,
    pricelist: json['pricelist'] as int,
    balance: (json['balance'] as num)?.toDouble(),
    pdamount: (json['pdamount'] as num)?.toDouble(),
    creditlimit: (json['creditlimit'] as num)?.toDouble(),
    availcreditlimit: (json['availcreditlimit'] as num)?.toDouble(),
  );
}

Map<String, dynamic> _$CustomerToJson(Customer instance) => <String, dynamic>{
      'custid': instance.custid,
      'custcode': instance.custcode,
      'company': instance.company,
      'pricelist': instance.pricelist,
      'balance': instance.balance,
      'pdamount': instance.pdamount,
      'creditlimit': instance.creditlimit,
      'availcreditlimit': instance.availcreditlimit,
    };

MonthlySale _$MonthlySaleFromJson(Map<String, dynamic> json) {
  return MonthlySale(
    toDate: json['toDate'] as String,
    fromDate: json['fromDate'] as String,
    totalSale: (json['totalSale'] as num)?.toDouble(),
  );
}

Map<String, dynamic> _$MonthlySaleToJson(MonthlySale instance) =>
    <String, dynamic>{
      'fromDate': instance.fromDate,
      'toDate': instance.toDate,
      'totalSale': instance.totalSale,
    };
