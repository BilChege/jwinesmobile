import 'dart:convert';
import 'dart:io';

import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:jwines/database/sessionpreferences.dart';
import 'package:jwines/models/salesmodels.dart';
import 'package:jwines/models/usermodels.dart';
import 'package:jwines/utils/Config.dart';
import 'package:progress_dialog/progress_dialog.dart';

class OrderHistoryList extends StatefulWidget {
  @override
  _OrderHistoryState createState() => _OrderHistoryState();
}

class _OrderHistoryState extends State<OrderHistoryList> {

  List<OrderHistory> _items;
  User _loggedInUser;
  GlobalKey<FormState> _formKey = new GlobalKey<FormState>();
  String _message = 'Specify date range and press search below';
  DateFormat _format = new DateFormat('yyyy-MM-dd');
  TextEditingController _fromDate = new TextEditingController();
  TextEditingController _toDate = new TextEditingController();
  TextEditingController _grantTotalController = new TextEditingController();

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
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async{
        if(_items != null){
          setState(() {
            _items = null;
          });
          return false;
        }
        return true;
      },
      child: Scaffold(
        appBar: AppBar(title: Text('Order History')),
        body: Container(
          color: Colors.blueGrey,
          padding: EdgeInsets.all(15.0),
          child: Column(
            children: <Widget>[
              Form(key: _formKey,child: Container(
                padding: EdgeInsets.all(10.0),
                color: Colors.white70,
                child: Row(
                  children: <Widget>[
                    Expanded(child: DateTimeField(format: _format,
                        onChanged: (value){
                      if(value != null){
                        String toDate = _toDate.text;
                        if(toDate.isNotEmpty){
                          DateTime tdt = _format.parse(toDate);
                          if(value.isAfter(tdt)){
                            setState(() {
                              _fromDate.clear();
                            });
                            showDialog(context: context,builder: (bc){
                              return AlertDialog(
                                title: Text('Wrong input'),
                                content: Text('From date cannot come after to date'),
                                actions: <Widget>[
                                  FlatButton(onPressed: (){
                                    Navigator.pop(bc);
                                  }, child: Text('Ok'))
                                ],
                              );
                            });
                          }
                        }
                      }
                        },
                        onShowPicker: (ctx,val){
                          return showDatePicker(context: ctx, initialDate: DateTime.now(), firstDate: DateTime(1900), lastDate: DateTime.now());
                        },validator: (value){
                      if(value == null){
                        return 'specify from date';
                      }
                      return null;
                    }, controller: _fromDate,decoration: InputDecoration(border: OutlineInputBorder(borderSide: BorderSide()),labelText: 'From Date'))),
                    Expanded(child: DateTimeField(controller: _toDate,format: _format, onShowPicker: (ctx,val){
                      return showDatePicker(context: ctx, initialDate: DateTime.now(), firstDate: DateTime(1900), lastDate: DateTime.now());
                    },validator: (value){
                      if(value == null){
                        return 'Specify to date';
                      }
                      return null;
                    },onChanged: (value){
                      if(value != null){
                        String fromDate = _fromDate.text;
                        if(fromDate.isNotEmpty){
                          DateTime frdt = _format.parse(fromDate);
                          if(frdt.isAfter(value)){
                            setState(() {
                              _toDate.clear();
                            });
                            showDialog(context: context,builder: (ctx){
                              return AlertDialog(
                                title: Text('Wrong input'),
                                content: Text('From date cannot come after to Date'),
                                actions: <Widget>[
                                  FlatButton(onPressed: (){
                                    Navigator.pop(ctx);
                                  }, child: Text('Ok'))
                                ],
                              );
                            });
                          }
                        }
                      }
                    },decoration: InputDecoration(border: OutlineInputBorder(borderSide: BorderSide()),labelText: 'Todate'),))
                  ],
                ),
              )),
              Expanded(child: _body()),
              _baseView()
            ],
          ),
        ),
      ),
    );
  }

  _body() {
    if(_items != null){
      return Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListView.builder(itemBuilder: (ctx,i){
          OrderHistory item = _items.elementAt(i);
          String date = item.date;
          String customer = item.custname;
          double amt = item.amount;
          return Container(
            color: Colors.white70,
            child: Column(
              children: <Widget>[
                ListTile(
                  title: Text('Customer : $customer'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text('Date : $date'),
                      Text('Total Order amount: $amt'),
                    ],
                  ),
                ),
                Divider()
              ],
            ),
          );
        },itemCount: _items.length),
      );
    }
    return Center(
      child: Text(_message),
    );
  }

  _baseView() {
    if(_items != null && _items.isNotEmpty){
      return TextFormField(
        controller: _grantTotalController,
        enabled: false,
        decoration: InputDecoration(
          border: OutlineInputBorder(
            borderSide: BorderSide()
          ),
          labelText: 'Total order amount for time period'
        ),
      );
    }
    return CupertinoButton(color: Colors.blue,child: Text('Search'), onPressed: () async{
      if(_formKey.currentState.validate()){
        String fromDate = _fromDate.text;
        String toDate = _toDate.text;
        int hrid = _loggedInUser.hrid;
        ProgressDialog d = new ProgressDialog(context);
        d.style(message: 'Fetching items');
        d.show();
        String url = await getBaseUrl();
//                HttpClientResponse response = await getRequestObject(, get,dialog: d);
        http.Response resp = await getSimpleRequestObject(url+'salesorder/list/$hrid?from=$fromDate&to=$toDate', get,dialog: d);
        d.hide();
        if(resp != null){
          var jsonResponse = json.decode(resp.body);
          var list = jsonResponse as List;
          List<OrderHistory> items = list.map<OrderHistory>((json){
            return OrderHistory.fromJson(json);
          }).toList();
          if(items.isNotEmpty){
            print('Not empty');
            double tt = 0;
            items.forEach((item){
              tt += item.amount;
            });
            setState(() {
              _items = items;
              _grantTotalController.text = NumberFormat.currency(symbol: '').format(tt);
            });
          } else {
            print('empty');
            setState(() {
              _message = 'There were no order items found for the date range specified';
            });
          }
//                  resp.transform(utf8.decoder).listen((data){
//                    var jsonResponse = json.decode(data);
//                    var list = jsonResponse as List;
//                    List<OrderHistory> items = list.map<OrderHistory>((json){
//                      return OrderHistory.fromJson(json);
//                    }).toList();
//                    if(items.isNotEmpty){
//                      print('Not empty');
//                      double tt = 0;
//                      items.forEach((element) {
//                        tt += element.amount;
//                      });
//                      setState(() {
//                        _items = items;
//                        _grantTotalController.text = NumberFormat.currency(symbol: '').format(tt);
//                      });
//                    } else {
//                      print('empty');
//                      setState(() {
//                        _message = 'There were no order items found for the date range specified';
//                      });
//                    }
//                  });
        }
      }
    });
  }
}
