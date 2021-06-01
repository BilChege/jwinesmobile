
import 'package:json_annotation/json_annotation.dart';

part 'usermodels.g.dart';

@JsonSerializable()
class User{

  int id;
  int hrid;
  int custid;
  int pricelist;
  double balance;
  double creditLimit;
  double pdamount;
  double availableCredit;
  String fullName;
  String userName;
  String password;
  bool active;
  bool approved;
  String email;
  int costCenter;

  User({this.id,this.hrid,this.custid,this.pricelist,this.balance,this.creditLimit,this.pdamount,this.availableCredit,this.fullName,this.userName,this.password,this.active,this.approved,this.email,this.costCenter});

  factory User.fromJson(Map<String,dynamic> json) => _$UserFromJson(json);
  Map<String,dynamic> toJson() => _$UserToJson(this);

  @override
  String toString() {
    return 'User{id: $id, fullName: $fullName, userName: $userName, active: $active, approved: $approved, email: $email, costCenter: $costCenter}';
  }

}

@JsonSerializable()
class Customer{

  int custid;
  String custcode;
  String company;
  int pricelist;
  double balance;
  double pdamount;
  double creditlimit;
  double availcreditlimit;

  Customer({this.custid,this.custcode,this.company,this.pricelist,this.balance,this.pdamount,this.creditlimit,this.availcreditlimit});

  factory Customer.fromJson(Map<String,dynamic> json) => _$CustomerFromJson(json);
  Map<String,dynamic> toJson() => _$CustomerToJson(this);

  @override
  String toString() {
    return 'Customer{custid: $custid, custcode: $custcode, company: $company, pricelist: $pricelist}';
  }
}

@JsonSerializable()
class MonthlySale{

  String fromDate;
  String toDate;
  double totalSale;

  MonthlySale({this.toDate,this.fromDate,this.totalSale});
  factory MonthlySale.fromJson(Map<String,dynamic> json) => _$MonthlySaleFromJson(json);
  Map<String,dynamic> toJson() => _$MonthlySaleToJson(this);

  @override
  String toString() {
    return 'MonthlySale{fromDate: $fromDate, toDate: $toDate, totalSale: $totalSale}';
  }
}

class CompanySettings{

  String baseUrl;
  String imageName;

  CompanySettings({this.baseUrl,this.imageName});

}