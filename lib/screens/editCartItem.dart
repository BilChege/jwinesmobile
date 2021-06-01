import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:jwines/database/sessionpreferences.dart';
import 'package:jwines/models/inventorymodels.dart';
import 'package:jwines/models/salesmodels.dart';
import 'package:jwines/models/usermodels.dart';
import 'package:jwines/utils/Config.dart';

// ignore: must_be_immutable
class CartItem extends StatefulWidget {

  String purpose;
  double currentTotal;
  CartItem(this.purpose,this.currentTotal);

  @override
  _CartItemState createState() => _CartItemState();
}

class _CartItemState extends State<CartItem> {

  User _loggedInUser;
  Customer _selectedCustomer;
  String _itemDescription;
  double _remainingQty;
  double _rPrice;
  OrderDetail _orderDetail;
  InvoiceDetails _invoiceDetails;
  MReqDetail _mReqDetail;
  double _originalPrice;
  double _currQty;
  double _currDiscount;
  TextEditingController _qtyController = new TextEditingController();
  TextEditingController _discountController = new TextEditingController();
  TextEditingController _ttController = new TextEditingController();
  GlobalKey<FormState> _formKey = new GlobalKey<FormState>();
  BuildContext _context;

  @override
  void initState() {
    SessionPreferences().getLoggedInUser().then((user){
      setState(() {
        _loggedInUser = user;
      });
    });
    if(widget.purpose == salesOrder){
      SessionPreferences().getSelectedCustomer().then((customer){
        setState(() {
          _selectedCustomer = customer;
        });
      });
      SessionPreferences().getOrderItemEdited().then((orderItem){
        setState(() {
          _orderDetail = orderItem;
          _itemDescription = orderItem.invDescrip;
          _remainingQty = orderItem.itemQty;
          _rPrice = orderItem.originalPrice;
          _originalPrice = orderItem.originalPrice;
          _currQty = orderItem.invQty;
          _currDiscount = orderItem.invDiscount;
        });
      });
    } else if (widget.purpose == invoice){
      SessionPreferences().getInvoiceItemEdited().then((invoiceItem){
        setState(() {
          _invoiceDetails = invoiceItem;
          _itemDescription = invoiceItem.itemDesc;
          _remainingQty = invoiceItem.itemQty;
          _rPrice = invoiceItem.originalPrice;
          _originalPrice = invoiceItem.originalPrice;
          _currQty = invoiceItem.qtysold;
          _currDiscount = invoiceItem.discount;
        });
      });
    } else if (widget.purpose == materialRequisition){
      SessionPreferences().getMreqItemEdited().then((mReqItem){
        setState(() {
          _mReqDetail = mReqItem;
          _itemDescription = mReqItem.desc;
          _remainingQty = mReqItem.itemQty;
          _rPrice = mReqItem.rprice;
          _currQty = mReqItem.qty;
          _currDiscount = 0;
        });
      });
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    _context = context;
    _ttController.text = _currQty != null && _rPrice != null ? (_currQty * _rPrice).toString() : '';
    return Scaffold(
      appBar: AppBar(title: Text('Edit Cart item')),
      body: Container(
        padding: EdgeInsets.all(10.0),
        color: Colors.white70,
        child: ListView(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 5),
              child: Text(_itemDescription != null ? 'Item Description: $_itemDescription' : '',style: TextStyle(fontSize: 20)),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 5),
              child: Text(_remainingQty != null ? 'Remaining quantity: $_remainingQty' : '',style: TextStyle(fontSize: 20)),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 5),
              child: Text(_rPrice != null ? 'Item Unit Price: $_rPrice' : '',style: TextStyle(fontSize: 20)),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 5),
              child: Form(
                key: _formKey,
                child: TextFormField(
                  controller: _qtyController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(border: OutlineInputBorder(borderSide: BorderSide()),labelText: 'Specify quantity'),
                  validator: (value){
                    if(value.isEmpty){
                      return 'Quantity cannot be empty';
                    } else {
                      double qty = double.parse(value);
                      if(qty > _remainingQty){
                        return 'Quantity cannot be greater than remaining';
                      } else {
                        return null;
                      }
                    }
                  },onChanged: (value){
                    if(_formKey.currentState.validate()){
                      double entered = double.parse(value);
                      setState(() {
                        _currQty = entered;
                      });
                    }
                },
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 5),
              child: TextFormField(
                enabled: widget.purpose != materialRequisition,
                controller: _discountController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(border: OutlineInputBorder(borderSide: BorderSide()),labelText: 'Discount (Optional)'),
                onChanged: (value){
                  if(_formKey.currentState.validate()){
                    if(value.isNotEmpty){
                      double prcDisc = double.parse(value);
                      double newRprice = _rPrice - (_rPrice * prcDisc)/100;
                      setState(() {
                        _rPrice = newRprice;
                      });
                    } else {
                      setState(() {
                        _rPrice = _originalPrice;
                      });
                    }
                  }
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 5),
              child: TextFormField(
                enabled: false,
                controller: _ttController,
                decoration: InputDecoration(border: OutlineInputBorder(borderSide: BorderSide()),labelText: 'Total Amount'),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 5),
              child: CupertinoButton(color: Colors.blue,child: Text('Save'), onPressed: (){
                if(_formKey.currentState.validate()){
                  if(widget.purpose == salesOrder){
                    _orderDetail.itemPrice = _rPrice;
                    _orderDetail.invQty = _currQty;
                    _orderDetail.invDiscount = _discountController.text.isNotEmpty ? double.parse(_discountController.text) : 0;
                    double tt = double.parse(_ttController.text);
                    _orderDetail.invPrice = tt;
                    double creditLim = _selectedCustomer.availcreditlimit;
                    double currentTotal = widget.currentTotal + tt;
                    if(creditLim >= currentTotal){
                      SessionPreferences().setOrderItemToEdit(
                          _orderDetail
                      ).then((x){
                        Fluttertoast.showToast(msg: 'Item has been edited');
                        Navigator.pop(_context);
                      });
                    } else {
                      showDialog(context: _context,builder: (bc){
                        return AlertDialog(
                          title: Text('Credit Limit Exceeded'),
                          content: Text('Your total order amount should not exceed your credit Limit'),
                          actions: <Widget>[
                            FlatButton(
                              onPressed: (){
                                Navigator.pop(bc);
                              },child: Text('Ok')
                            )
                          ],
                        );
                      });
                    }
                  } else if (widget.purpose == invoice){
                    _invoiceDetails.rprice = _rPrice;
                    _invoiceDetails.qtysold = _currQty;
                    _invoiceDetails.discount = _discountController.text.isNotEmpty ? double.parse(_discountController.text) : 0;
                    double tt = double.parse(_ttController.text);
                    _invoiceDetails.total = tt;
                    double creditLimit = _loggedInUser.creditLimit;
                    double currentTotal = tt + widget.currentTotal;
                    if(creditLimit >= currentTotal){
                      SessionPreferences().setInvoiceItemToEdit(_invoiceDetails).then((x){
                        Fluttertoast.showToast(msg: 'Item has been edited');
                        Navigator.pop(_context);
                      });
                    } else {
                      showDialog(context: _context,builder: (bc){
                        return AlertDialog(
                          title: Text('Credit Limit Exceeded'),
                          content: Text('Your total invoice amount should not exceed your credit Limit'),
                          actions: <Widget>[
                            FlatButton(
                                onPressed: (){
                                  Navigator.pop(bc);
                                },child: Text('Ok')
                            )
                          ],
                        );
                      });
                    }
                  } else if(widget.purpose == materialRequisition){
                    _mReqDetail.qty = _currQty;
                    double tt = double.parse(_ttController.text);
                    _mReqDetail.total = tt;
                    double creditLim = _loggedInUser.creditLimit;
                    double currentTotal = widget.currentTotal + tt;
                    if(creditLim >= currentTotal){
                      SessionPreferences().setRequisitionItemToEdit(_mReqDetail).then((x){
                        Fluttertoast.showToast(msg: 'Item has been edited');
                        Navigator.pop(_context);
                      });
                    } else {
                      showDialog(context: _context,builder: (bc){
                        return AlertDialog(
                          title: Text('Credit Limit Exceeded'),
                          content: Text('Your total requisition amount should not exceed your credit Limit'),
                          actions: <Widget>[
                            FlatButton(
                                onPressed: (){
                                  Navigator.pop(bc);
                                },child: Text('Ok')
                            )
                          ],
                        );
                      });
                    }
                  }
                }
              }),
            )
          ],
        ),
      ),
    );
  }
}
