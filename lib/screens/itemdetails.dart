import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:jwines/database/sessionpreferences.dart';
import 'package:jwines/models/inventorymodels.dart';
import 'package:jwines/models/salesmodels.dart';
import 'package:jwines/models/usermodels.dart';
import 'package:jwines/utils/Config.dart' as Config;

// ignore: must_be_immutable
class InventoryItemDetails extends StatefulWidget {

  InventoryItem _item;
  String purpose;
  void Function(OrderDetail) enterOrderDetail;
  void Function(InvoiceDetails) enterInvoiceDetail;
  void Function(MReqDetail) enterReqItem;
  InventoryItemDetails(this._item,this.purpose,{this.enterOrderDetail,this.enterInvoiceDetail,this.enterReqItem});

  @override
  _InventoryItemDetailsState createState() => _InventoryItemDetailsState();
}

class _InventoryItemDetailsState extends State<InventoryItemDetails> {

  InventoryItem _selectedItem;
  double _vatRate;
  double _itemQty;
  double _discountPrice;
  double _discount;
  double _specifiedQty;
  double _sellingPrice;
  User _loggedInUser;
  TextEditingController _quantityController = new TextEditingController();
  TextEditingController _ttAmtController = new TextEditingController();
  TextEditingController _discountController = new TextEditingController();
  final _qtyState = GlobalKey<FormState>();

  @override
  void initState() {
    setState(() {
      _selectedItem = widget._item;
    });
    if(widget.purpose != null){
      if(widget.purpose == Config.salesOrder){
        SessionPreferences().getSelectedCustomer().then((customer){
          _fetchPriceForCustomer(customer.pricelist, _selectedItem.id.toString());
        });
      }
    }
    SessionPreferences().getLoggedInUser().then((user){
      setState(() {
        _loggedInUser = user;
      });
      if(widget.purpose == Config.invoice || widget.purpose == Config.materialRequisition){
        _fetchPriceForCustomer(user.pricelist, _selectedItem.id.toString());
      }
      _checkItemQuantity(_selectedItem.id);
    });
    _fetchVatForItem(_selectedItem.vat);
    super.initState();
  }

  _checkItemQuantity(int itemId) async{
    print(_loggedInUser);
    String cc =widget.purpose == Config.salesOrder || widget.purpose == Config.materialRequisition? '0' : _loggedInUser.costCenter.toString();
    String checkHq = widget.purpose == Config.salesOrder || widget.purpose == Config.materialRequisition ? 'true' : 'false';
    String url = await Config.getBaseUrl();
    HttpClientResponse response = await Config.getRequestObject(url+'inventory/balance/$itemId?ccid=$cc&hq=$checkHq', Config.get);
    if(response != null){
      response.transform(utf8.decoder).listen((data){
        Map<String,dynamic> jsonResponse = json.decode(data);
        print('---------------> Json Response Map $jsonResponse');
        if(jsonResponse.isNotEmpty){
          print('-------------> Not empty');
          int balance = jsonResponse['bal'];
          print('------> BALANCE: $balance');
          if(balance != null){
            setState(() {
              _itemQty = balance > 0 ? balance.roundToDouble() : 0;
            });
          } else {
            setState(() {
              _itemQty = 0;
            });
          }
        }else {
          setState(() {
            _itemQty = 0;
          });
        }
      });
    }
  }

  _fetchVatForItem(int itemId) async{
    String url = await Config.getBaseUrl();
    HttpClientResponse response = await Config.getRequestObject(url+'vat/$itemId',Config.get);
    if(response != null){
      response.transform(utf8.decoder).listen((data){
        var jsonResponse = json.decode(data);
        Vat vat = Vat.fromJson(jsonResponse);
        setState(() {
          _vatRate = vat.rate;
        });
      });
    }
  }

  _fetchPriceForCustomer(int priceList, String inventory) async{
    String url = await Config.getBaseUrl();
    HttpClientResponse response = await Config.getRequestObject(url+'customer/pricelist/inventory/$priceList?invid=$inventory',Config.get);
    if(response != null){
      response.transform(utf8.decoder).listen((data){
        var jsonResponse = json.decode(data);
        PriceListDetail price = PriceListDetail.fromJson(jsonResponse);
        setState((){
          _sellingPrice = price.sellingprice;
        });
      });
    }
  }

  @override
  Widget build(BuildContext context){
    _ttAmtController.text = _discountPrice != null && _specifiedQty != null ? (_discountPrice * _specifiedQty).toStringAsFixed(2) : _specifiedQty != null ? (_sellingPrice * _specifiedQty).toStringAsFixed(2) : '';
    String description = _selectedItem.description;
    String price;
    if(_discountPrice != null){
      price = _discountPrice.toStringAsFixed(2);
    } else {
      price = _sellingPrice != null ? _sellingPrice.toStringAsFixed(2) : 'Loading ... ';
    }
    String availableQty = 'Loading ...';
    if(_itemQty != null){
      availableQty = _itemQty.toString();
    }
    return Container(
      color: Colors.white70,
      child: ListView(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Text('Item description: $description',style: TextStyle(fontSize: 18)),
          ),
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Text('Item price: $price Kshs',style: TextStyle(fontSize: 18)),
          ),
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Text('Available quantity: $availableQty',style: TextStyle(fontSize: 18)),
          ),
          Form(
            key: _qtyState,
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Visibility(
                visible: _itemQty != null && _sellingPrice != null,
                child: TextFormField(
                  controller: _quantityController,
                  onChanged: (value){
                    if(_qtyState.currentState.validate()){
                      double qty = double.parse(value);
                      setState(() {
                        _specifiedQty = qty;
                      });
                    }
                  },
                  validator: (value){
                    if(value.isEmpty){
                      return 'Please specify the quantity';
                    } else{
                      double qty = double.parse(value);
                      if(qty > 0){
                        double currQty = _itemQty;
                        if(currQty >= qty){
                          return null;
                        } else {
                          return 'The amount specified is greater than the current quantity';
                        }
                      } else {
                        return 'You need to specify an amount greater than zero';
                      }
                    }
                  },
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderSide: BorderSide()
                    ),
                    labelText: 'Specify the quantity',
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(10.0),
            child: Visibility(
              visible: widget.purpose != Config.materialRequisition && _itemQty != null && _sellingPrice != null,
              child: TextFormField(
                controller: _discountController,
                decoration: InputDecoration(border: OutlineInputBorder(borderSide: BorderSide()),labelText: 'Discount (Optional)',hintText: 'Percentage'),
                keyboardType: TextInputType.number,
                onChanged: (value){
                  String qtyVal = _quantityController.text;
                  if(value.isNotEmpty){
                    double val = double.parse(value);
                    if(qtyVal.isNotEmpty){
                      if(val <= 100){
                        double originalPrice = _sellingPrice;
                        double discount = (val * originalPrice)/100;
                        print(' --------------------> Discount $discount');
                        double discPrice = originalPrice - discount;
                        setState(() {
                          _discount = val;
                          _discountPrice = discPrice;
                        });
                      } else {
                        setState(() {
                          _discountController.clear();
                        });
                        Fluttertoast.showToast(msg: 'Value cannot be greater than 100%');
                      }
                    } else {
                      setState(() {
                        _discountController.clear();
                      });
                      Fluttertoast.showToast(msg: 'Specify quantity first');
                    }
                  } else {
                    setState(() {
                      _discount = null;
                      _discountPrice = null;
                    });
                  }
                },
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Visibility(
              visible: _itemQty != null && _sellingPrice != null,
              child: TextFormField(
                controller: _ttAmtController,
                enabled: false,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderSide: BorderSide()
                  ),
                  labelText: 'Total Order Amount'
                ),
              ),
            ),
          ),
          ButtonTheme(
            height: 50.0,
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: CupertinoButton(child: Text('Add to Cart'), onPressed: (){
                if(_qtyState.currentState.validate()){
                  double qty = double.parse(_quantityController.text);
                  double ttAmt = double.parse(_ttAmtController.text);
                  if(widget.purpose == Config.salesOrder){
                    widget.enterOrderDetail(
                        OrderDetail(
                          invCode: _selectedItem.invCode,
                          invDescrip: description,
                          originalPrice: _sellingPrice,
                          invDiscount: _discount != null ? _discount : 0,
                          itemQty: _itemQty,
                          invQty: qty,
                          itemPrice: double.parse(price),
                          invPrice:_sellingPrice
                        )
                    );
                  } else if(widget.purpose == Config.materialRequisition){
                    widget.enterReqItem(
                      MReqDetail(
                        invid: _selectedItem.id,
                        itemQty: _itemQty,
                        rprice: _sellingPrice,
                        desc: _selectedItem.description,
                        qty: double.parse(_quantityController.text),
                        total: double.parse(_ttAmtController.text)
                      )
                    );
                  } else {
                    double taxed = qty * _selectedItem.rprice;
                    double untaxed = (100 * taxed)/(100+_vatRate);
                    double vatValue = taxed - untaxed;
                    String pDiscVal = _discountController.text;
                    widget.enterInvoiceDetail(
                      InvoiceDetails(
                        invid: _selectedItem.id,
                        itemDesc: _selectedItem.description,
                        itemQty: _itemQty,
                        originalPrice: _sellingPrice,
                        discAmt: _discountPrice != null ? (_sellingPrice - _discountPrice) * qty : 0,
                        vat: vatValue,
                        discount: pDiscVal.isNotEmpty ? double.parse(pDiscVal) : 0,
                        qtysold: qty,
                        total: ttAmt,
                        rprice: _sellingPrice
                      )
                    );
                  }
                }
              },color: Colors.blueAccent),
            ),
          )
        ],
      ),
    );
  }

}