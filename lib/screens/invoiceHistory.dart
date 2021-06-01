import 'dart:convert';
import 'dart:io';

import 'package:blue_thermal_printer/blue_thermal_printer.dart';
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:jwines/database/sessionpreferences.dart';
import 'package:jwines/models/salesmodels.dart';
import 'package:jwines/models/usermodels.dart';
import 'package:jwines/screens/thermalPrinter.dart';
import 'package:jwines/utils/Config.dart';
import 'package:progress_dialog/progress_dialog.dart';

class InvoiceHistoryList extends StatefulWidget {
  @override
  _InvoiceHistoryListState createState() => _InvoiceHistoryListState();
}

class _InvoiceHistoryListState extends State<InvoiceHistoryList> {

  DateFormat _format = DateFormat('yyyy-MM-dd');
  DateFormat _forDisplay = new DateFormat('d/MMMM/yyyy');
  GlobalKey<FormState> _formKey = new GlobalKey<FormState>();
  TextEditingController _fromDateController = new TextEditingController();
  TextEditingController _toDateController = new TextEditingController();
  TextEditingController _grandTTController = new TextEditingController();
  TextEditingController _invTotalController = new TextEditingController();
  List<InvoiceHistory> _invoiceList;
  BlueThermalPrinter _printer = BlueThermalPrinter.instance;
  InvoiceHistoryObj _selectedInvoice;
  BuildContext _context;
  String _message = 'Specify a date range and press search';
  User _loggedInUser;


  @override
  void initState() {
    SessionPreferences().getLoggedInUser().then((user){
      setState(() {
        _loggedInUser = user;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context){
    print('Widget Built');
    _context = context;
    String custname = _selectedInvoice != null ? _selectedInvoice.custname : '';
    double total = _selectedInvoice != null ? _selectedInvoice.totalAmount : 0;
    _invTotalController.text = total.toString();
    String dateOfInvoice = _selectedInvoice != null ? _selectedInvoice.invdate : '';
    List<InvoiceHistoryDetail> details = _selectedInvoice != null ? _selectedInvoice.invoiceDetails : [];
    return WillPopScope(
      onWillPop: () async{
        if(_selectedInvoice != null){
          setState(() {
            _selectedInvoice = null;
          });
          return false;
        } else if(_invoiceList != null){
          setState(() {
            _invoiceList = null;
          });
          return false;
        }
        return true;
      },
      child:Scaffold(
        appBar: AppBar(title: Text(_selectedInvoice != null ?'Selected Invoice' : 'Invoice History'),actions: [
          Visibility(child: IconButton(icon: Icon(Icons.print), onPressed: (){
            showDialog(context: context,builder: (ctx){
              return AlertDialog(title: Text('Print Invoice'),content: Text('Would you like to print this invoice?'),actions: [FlatButton(onPressed: (){
                Navigator.pop(ctx);
              }, child: Text('No')),FlatButton(onPressed: (){
                Navigator.pop(ctx);
                _printer.isConnected.then((connected){
                  DateTime dateProper = _format.parse(dateOfInvoice);
                  String dateDisplay = _forDisplay.format(dateProper);
                  if(connected){
                    _printer.printCustom('JWines Sale Invoice', 3, 1);
                    _printer.printCustom('Customer name : $custname', 3, 1);
                    _printer.printCustom('Date of Invoice : $dateDisplay', 3, 1);
                    _printer.printNewLine();
                    details.forEach((detail){
                      String desc = detail.itemname;
                      String qty = detail.qty.toString();
                      String itmPrice = detail.unitprice.toString();
                      String ttPrice = detail.totalprice.toString();
                      String discount = detail.discount.toStringAsFixed(2);
                      _printer.printCustom('$desc \nUnitPrice: $itmPrice Kshs\nQuantity bought: $qty \nDiscount: $discount Kshs\nTotal price: $ttPrice Kshs', 1, 1);
                      _printer.printNewLine();
                    });
                    _printer.printCustom("Total Sale Amount: $total Kshs", 1, 1);
                    _printer.printNewLine();
                    _printer.printNewLine();
                    _printer.paperCut();
                  } else {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => ThermalPrinter()));
                  }
                });
              }, child: Text('Yes'))]);
            });
          }),visible: _selectedInvoice != null)
        ],),
        body: _selectedInvoice != null ? Container(
          padding: EdgeInsets.all(15.0),
          child: Column(
            children: [
              Text('Customer Name: $custname'),
              Expanded(child: _listViewBuilder(details)),
              TextFormField(
                controller: _invTotalController,
                enabled: false,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderSide: BorderSide()
                  ),
                  labelText: 'Total Invoice Amount'
                ),
              )
            ],
          ),
        ) : Container(
          color: Colors.blueGrey,
          padding: EdgeInsets.all(15.0),
          child: Column(
            children: <Widget>[
              Form(
                key: _formKey,
                child: Container(
                  padding: EdgeInsets.all(10.0),
                  color: Colors.white70,
                  child: Row(
                    children: <Widget>[
                      Expanded(child: DateTimeField(decoration: InputDecoration(border: OutlineInputBorder(borderSide: BorderSide()),labelText: 'From Date'),format: _format, onShowPicker: (ctx,currVal){
                        return showDatePicker(context: ctx, initialDate: DateTime.now(), firstDate: DateTime(1900), lastDate: DateTime.now());
                      }, validator: (value){
                        if(value == null){
                          return 'Enter from Date';
                        }
                        return null;
                      },controller: _fromDateController,onChanged: (value){
                        if(value != null){
                          String toDate = _toDateController.text;
                          if(toDate.isNotEmpty){
                            DateTime toDt = _format.parse(toDate);
                            if(value.isAfter(toDt)){
                              setState(() {
                                _fromDateController.clear();
                              });
                              showDialog(context: context,builder: (ctx){
                                return AlertDialog(
                                  title: Text('Wrong input'),
                                  content: Text('From date cannot come after to date'),
                                  actions: <Widget>[FlatButton(onPressed: (){
                                    Navigator.pop(ctx);
                                  }, child: Text('Ok'))],
                                );
                              });
                            }
                          }
                        }
                      },)),
                      Expanded(child: DateTimeField(decoration: InputDecoration(border: OutlineInputBorder(borderSide: BorderSide()),labelText: 'To Date'),format: _format, onShowPicker: (ctx,currVal){
                        return showDatePicker(context: ctx, initialDate: DateTime.now(), firstDate: DateTime(1900), lastDate: DateTime.now());
                      }, validator: (value){
                        if(value == null){
                          return 'Enter to Date';
                        }
                        return null;
                      },controller: _toDateController,onChanged: (value){
                        if(value != null){
                          String fromDate = _fromDateController.text;
                          if(fromDate.isNotEmpty){
                            DateTime fmDt = _format.parse(fromDate);
                            if(value.isBefore(fmDt)){
                              setState(() {
                                _toDateController.clear();
                              });
                              showDialog(context: context,builder: (ctx){
                                return AlertDialog(
                                  title: Text('Wrong input'),
                                  content: Text('From date cannot come after to date'),
                                  actions: <Widget>[FlatButton(onPressed: (){
                                    Navigator.pop(ctx);
                                  }, child: Text('Ok'))],
                                );
                              });
                            }
                          }
                        }
                      }))
                    ],
                  ),
                ),
              ),
              Expanded(child: _itemsBody()),
              _baseView()
            ],
          ),
        )
      ),
    );
  }

  _itemsBody() {
    if(_invoiceList != null){
      if(_invoiceList.isNotEmpty){
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: ListView.builder(itemBuilder: (ctx,i){
            InvoiceHistory item = _invoiceList.elementAt(i);
            int id = item.id;
            String date = item.date;
            double amt = item.amount;
            String customer = item.custname;
            return Container(
              color: Colors.white70,
              child: Column(
                children: <Widget>[
                  ListTile(
                    title: Text('Customer: $customer'),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text('Date invoiced: $date'),
                        Text('Total amount invoiced: '+amt.toString()),
                      ],
                    ),
                    onTap: () async{
                      ProgressDialog dialog = new ProgressDialog(_context);
                      dialog.style(message: 'Loading invoice ... ');
                      dialog.show();
                      String url = await getBaseUrl();
                      HttpClientResponse response = await getRequestObject(url+'salesinvoice/invoicedetail/$id', get, dialog: dialog);
                      if(response != null){
                        response.transform(utf8.decoder).listen((data){
                          var jsonResponse = json.decode(data);
                          var list = jsonResponse as List;
                          List<InvoiceHistoryObj> objs = list.map<InvoiceHistoryObj>((json){
                            return InvoiceHistoryObj.fromJson(json);
                          }).toList();
                          print('Data fetched: -> $jsonResponse');
                          InvoiceHistoryObj invObj = objs.first;
                          setState(() {
                            _selectedInvoice = invObj;
                          });
                        });
                      }
                    },
                  ),
                  Divider()
                ],
              ),
            );
          },itemCount: _invoiceList.length),
        );
      } else {
        _message = 'No transactions found for the date range specified';
      }
    }
    return Center(
      child: Text(_message),
    );
  }

  _baseView(){
    if(_invoiceList != null && _invoiceList.isNotEmpty){
      return Padding(
        padding: const EdgeInsets.all(10.0),
        child: TextFormField(
          controller: _grandTTController,
          enabled: false,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderSide: BorderSide()
            ),
            labelText: 'Total invoice for time period'
          ),
        ),
      );
    }
    return CupertinoButton(color: Colors.blue,child: Text('Search'), onPressed: () async{
      int salesRepId = _loggedInUser.hrid;
      if(_formKey.currentState.validate()){
        String fromDate = _fromDateController.text;
        String toDate = _toDateController.text;
        ProgressDialog d = new ProgressDialog(context);
        d.style(message: 'Fetching items ... ');
        d.show();
        String url = await getBaseUrl();
//                HttpClientResponse response = await getRequestObject(baseUrl+'salesinvoice/list/$salesRepId?from=$fromDate&to=$toDate', get,dialog: d);
        http.Response resp = await getSimpleRequestObject(url+'salesinvoice/list/$salesRepId?from=$fromDate&to=$toDate', get);
        d.hide();
        if(resp != null){
          var jsonResponse = json.decode(resp.body);
          var list = jsonResponse as List;
          List<InvoiceHistory> items = list.map<InvoiceHistory>((json){
            return InvoiceHistory.fromJson(json);
          }).toList();
          double tt = 0;
          items.forEach((item){
            tt += item.amount;
          });
          setState(() {
            _invoiceList = items;
            _grandTTController.text = NumberFormat.currency(symbol: '').format(tt);
          });
//                  resp.transform(utf8.decoder).listen((data){
//                    var jsonResponse = json.decode(data);
//                    var list = jsonResponse as List;
//                    List<InvoiceHistory> items = list.map<InvoiceHistory>((json){
//                      return InvoiceHistory.fromJson(json);
//                    }).toList();
//                    double tt = 0;
//                    items.forEach((element) {
//                      tt += element.amount;
//                    });
//                    setState(() {
//                      _invoiceList = items;
//                      _grandTTController.text = NumberFormat.currency(symbol: '').format(tt);
//                    });
//                  });
        }
      }
    });
  }

  _listViewBuilder(List<InvoiceHistoryDetail> details) {
    return Container(
      color: Colors.white70,
      child: ListView.builder(itemBuilder: (ctx,i){
        InvoiceHistoryDetail detail = details.elementAt(i);
        String ttPrice = NumberFormat.currency(symbol: '').format(detail.totalprice);
        String unitPrice = NumberFormat.currency(symbol: '').format(detail.unitprice);
        double qty = detail.qty;
        String itemName = detail.itemname;
        double discount = detail.discount;
        return Padding(padding: EdgeInsets.all(10.0),child: Card(elevation: 15.0,child: Container(
          padding: EdgeInsets.symmetric(vertical: 10.0),
          color: Colors.blueGrey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text('Item description: $itemName',style: TextStyle(fontSize: 15)),
              Text('Unit Price: $unitPrice',style: TextStyle(fontSize: 15)),
              Text('Ordered quantity: $qty',style: TextStyle(fontSize: 15)),
              Text('Discount amount: $discount',style: TextStyle(fontSize: 15)),
              Text('Total Price: $ttPrice',style: TextStyle(fontSize: 15))
            ],
          ),
        )));
      },itemCount: details.length),
    );
  }
}
