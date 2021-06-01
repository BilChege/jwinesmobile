import 'package:blue_thermal_printer/blue_thermal_printer.dart';
import 'package:jwines/models/inventorymodels.dart';
import 'package:jwines/models/salesmodels.dart';
import 'package:jwines/models/usermodels.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SessionPreferences{

  final String _userId = 'userId';
  final String _hrId = 'hrId';
  final String _fullName = 'fullName';
  final String _userName = 'userName';
  final String _userPriceList = 'userPriceList';
  final String _active = 'active';
  final String _approved = 'approved';
  final String _email = 'email';
  final String _balance = 'balance';
  final String _availableCredit = 'availableCredit';
  final String _creditLimit = 'creditLimit';
  final String _costCenter = 'costCenter';
  final String _loggedIn = 'loggedIn';
  final String _custId = 'custid';
  final String _userCust = 'userCust';
  final String _custCode = 'custcode';
  final String _company = 'company';
  final String _count = 'count';
  final String _priceList = 'pricelist';
  final String _invDescrip = 'invDescrip';
  final String _invQty = 'invQty';
  final String _invPrice = 'invPrice';
  final String _thermoPrint = 'thermoPrint';
  final String _btdAddress = 'btdAddress';
  final String _btdName = 'btdName';
  final String _custBalance = 'custBalance';
  final String _custAvailableCredit = 'custAvailableCredit';
  final String _custCreditLimit = 'custCreditLimit';
  final String _odInvCode = 'odInvCode';
  final String _odOriginalPrice = 'odOriginalPrice';
  final String _odInvDescrip = 'odInvDescrip';
  final String _odInvQty = 'odInvQty';
  final String _odInvPrice = 'odInvPrice';
  final String _odItemQty = 'odItemQty';
  final String _odInvDiscount = 'odInvDiscount';
  final String _odItemPrice = 'odItemPrice';
  final String _idInvId = 'idInvId';
  final String _idOriginalPrice = 'idOriginalPrice';
  final String _idItemDesc = 'idItemDesc';
  final String _idVat = 'idVat';
  final String _idDiscount = 'idDiscount';
  final String _idQtySold = 'idQtySold';
  final String _idTotal = 'idTotal';
  final String _pdamount = 'pdamount';
  final String _idRprice = 'idRprice';
  final String _idItemQty = 'idItemQty';
  final String _mrdInvid = 'mrdInvid';
  final String _mrdDesc = 'mrdDesc';
  final String _mrdQty = 'mrdQty';
  final String _mrdItemQty = 'mrdItemQty';
  final String _mrdTotal = 'mrdTotal';
  final String _mrdRprice = 'mrdRprice';
  final String _liveUrl = 'liveUrl';
  final String _imageSelection = 'imageSelection';

  Future<void> setCompanySettings(CompanySettings settings) async{
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences.setString(_liveUrl, settings.baseUrl);
    sharedPreferences.setString(_imageSelection, settings.imageName);
  }

  Future<CompanySettings> getCompanySettings() async{
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    return CompanySettings(
      baseUrl: sharedPreferences.getString(_liveUrl),
      imageName: sharedPreferences.getString(_imageSelection)
    );
  }

  Future<void> setLoggedInUser(User user) async{
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences.setInt(_userId, user.id);
    sharedPreferences.setInt(_hrId, user.hrid);
    sharedPreferences.setInt(_userPriceList, user.pricelist);
    sharedPreferences.setString(_email, user.email);
    sharedPreferences.setDouble(_pdamount, user.pdamount);
    sharedPreferences.setDouble(_balance, user.balance);
    sharedPreferences.setDouble(_availableCredit, user.availableCredit);
    sharedPreferences.setDouble(_creditLimit, user.creditLimit);
    sharedPreferences.setInt(_userCust, user.custid);
    sharedPreferences.setString(_fullName, user.fullName);
    sharedPreferences.setString(_userName, user.userName);
    sharedPreferences.setBool(_active, user.active);
    sharedPreferences.setBool(_approved, user.approved);
    sharedPreferences.setInt(_costCenter, user.costCenter);
  }

  Future<User> getLoggedInUser() async{
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    return User(
      id: sharedPreferences.getInt(_userId),
      hrid: sharedPreferences.getInt(_hrId),
      pricelist: sharedPreferences.getInt(_userPriceList),
      fullName: sharedPreferences.getString(_fullName),
      userName: sharedPreferences.getString(_userName),
      active: sharedPreferences.getBool(_active),
      pdamount: sharedPreferences.getDouble(_pdamount),
      approved: sharedPreferences.getBool(_approved),
      email: sharedPreferences.getString(_email),
      costCenter: sharedPreferences.getInt(_costCenter),
      custid: sharedPreferences.getInt(_userCust),
      balance: sharedPreferences.getDouble(_balance),
      creditLimit: sharedPreferences.getDouble(_creditLimit),
      availableCredit: sharedPreferences.getDouble(_availableCredit)
    );
  }

  Future<void> setOrderItemToEdit(OrderDetail od) async{
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences.setString(_odInvCode, od.invCode);
    sharedPreferences.setString(_odInvDescrip, od.invDescrip);
    sharedPreferences.setDouble(_odInvQty, od.invQty);
    sharedPreferences.setDouble(_odOriginalPrice, od.originalPrice);
    sharedPreferences.setDouble(_odItemPrice, od.itemPrice);
    sharedPreferences.setDouble(_odItemQty, od.itemQty);
    sharedPreferences.setDouble(_odInvDiscount, od.invDiscount);
    sharedPreferences.setDouble(_odInvPrice, od.invPrice);
  }

  Future<OrderDetail> getOrderItemEdited() async{
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    return OrderDetail(
      invCode: sharedPreferences.getString(_odInvCode),
      invDescrip: sharedPreferences.getString(_odInvDescrip),
      invQty: sharedPreferences.getDouble(_odInvQty),
      itemPrice: sharedPreferences.getDouble(_odItemPrice),
      itemQty: sharedPreferences.getDouble(_odItemQty),
      originalPrice: sharedPreferences.getDouble(_odOriginalPrice),
      invDiscount: sharedPreferences.getDouble(_odInvDiscount),
      invPrice: sharedPreferences.getDouble(_odInvPrice)
    );
  }

  Future<void> setInvoiceItemToEdit(InvoiceDetails id) async{
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences.setInt(_idInvId, id.invid);
    sharedPreferences.setString(_idItemDesc, id.itemDesc);
    sharedPreferences.setDouble(_idVat, id.vat);
    sharedPreferences.setDouble(_idOriginalPrice, id.originalPrice);
    sharedPreferences.setDouble(_idItemQty, id.itemQty);
    sharedPreferences.setDouble(_idDiscount, id.discount);
    sharedPreferences.setDouble(_idQtySold, id.qtysold);
    sharedPreferences.setDouble(_idTotal, id.total);
    sharedPreferences.setDouble(_idRprice, id.rprice);
  }

  Future<InvoiceDetails> getInvoiceItemEdited() async{
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    return InvoiceDetails(
      invid: sharedPreferences.getInt(_idInvId),
      itemDesc: sharedPreferences.getString(_idItemDesc),
      itemQty: sharedPreferences.getDouble(_idItemQty),
      vat: sharedPreferences.getDouble(_idVat),
      discount: sharedPreferences.getDouble(_idDiscount),
      qtysold: sharedPreferences.getDouble(_idQtySold),
      originalPrice: sharedPreferences.getDouble(_idOriginalPrice),
      total: sharedPreferences.getDouble(_idTotal),
      rprice: sharedPreferences.getDouble(_idRprice)
    );
  }

  Future<void> setRequisitionItemToEdit(MReqDetail mrd) async{
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences.setInt(_mrdInvid, mrd.invid);
    sharedPreferences.setString(_mrdDesc, mrd.desc);
    sharedPreferences.setDouble(_mrdQty, mrd.qty);
    sharedPreferences.setDouble(_mrdRprice, mrd.rprice);
    sharedPreferences.setDouble(_mrdItemQty, mrd.itemQty);
    sharedPreferences.setDouble(_mrdTotal, mrd.total);
  }

  Future<MReqDetail> getMreqItemEdited() async{
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    return MReqDetail(
      invid: sharedPreferences.getInt(_mrdInvid),
      desc: sharedPreferences.getString(_mrdDesc),
      rprice: sharedPreferences.getDouble(_mrdRprice),
      itemQty: sharedPreferences.getDouble(_mrdItemQty),
      qty: sharedPreferences.getDouble(_mrdQty),
      total: sharedPreferences.getDouble(_mrdTotal)
    );
  }

  void setUpPrint(BluetoothDevice printer) async{
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences.setString(_btdName, printer.name);
    sharedPreferences.setString(_btdAddress, printer.address);
  }

  Future<BluetoothDevice> getThermoPrinter() async{
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    return BluetoothDevice(sharedPreferences.getString(_btdName), sharedPreferences.getString(_btdAddress));
  }

  void setSelectedCustomer(Customer customer) async{
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences.setInt(_custId, customer.custid);
    sharedPreferences.setString(_custCode, customer.custcode);
    sharedPreferences.setString(_company, customer.company);
    sharedPreferences.setInt(_priceList, customer.pricelist);
    sharedPreferences.setDouble(_custBalance, customer.balance);
    sharedPreferences.setDouble(_custAvailableCredit, customer.availcreditlimit);
    sharedPreferences.setDouble(_custCreditLimit, customer.creditlimit);
  }

  Future<Customer> getSelectedCustomer() async{
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    return Customer(
      custid: sharedPreferences.getInt(_custId),
      custcode: sharedPreferences.getString(_custCode),
      company: sharedPreferences.getString(_company),
      pricelist: sharedPreferences.getInt(_priceList),
      balance: sharedPreferences.getDouble(_custBalance),
      availcreditlimit: sharedPreferences.getDouble(_custAvailableCredit),
      creditlimit: sharedPreferences.getDouble(_custCreditLimit)
    );
  }

  void setLoggedInStatus(bool loggedIn) async{
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences.setBool(_loggedIn, loggedIn);
  }

  Future<bool> getLoggedInStatus() async{
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    return sharedPreferences.getBool(_loggedIn);
  }

  void setItemCount(int count) async{
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences.setInt(_count, count);
  }

  Future<int> getItemCount() async{
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    return sharedPreferences.getInt(_count);
  }

  Future<int> enterOrderItem(OrderDetail orderDetail,int currentCount) async{
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences.setString('$_invDescrip$currentCount' , orderDetail.invDescrip);
    sharedPreferences.setDouble('$_invQty$currentCount', orderDetail.invQty);
    sharedPreferences.setDouble('$_invPrice$currentCount', orderDetail.invPrice);
    return currentCount + 1;
  }

  Future<List<OrderDetail>> getOrderDetails(int count) async{
    List<OrderDetail> response = new List();
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    for(var i = 0; i < count;i++){
      response.add(
        OrderDetail(
          invDescrip: sharedPreferences.getString('$_invDescrip$i'),
          invQty: sharedPreferences.getDouble('$_invQty$i'),
          invPrice: sharedPreferences.getDouble('$_invPrice$i')
        )
      );
    }
    return response;
  }

}