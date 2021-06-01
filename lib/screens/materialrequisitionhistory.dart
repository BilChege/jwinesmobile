import 'dart:convert';
import 'dart:io';

import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:intl/intl.dart';
import 'package:jwines/database/sessionpreferences.dart';
import 'package:jwines/models/salesmodels.dart';
import 'package:jwines/models/usermodels.dart';
import 'package:jwines/utils/Config.dart' as Config;
import 'package:progress_dialog/progress_dialog.dart';

class MaterialReqHistory extends StatefulWidget {
  @override
  _MaterialReqHistoryState createState() => _MaterialReqHistoryState();
}

class _MaterialReqHistoryState extends State<MaterialReqHistory> {

  GlobalKey<FormState> _formkey = new GlobalKey();
  List<ReqHistory> _reqHistories = new List();
  ReqHistory _selectedItem;
  String _message = 'Select from date and to date and press search';
  User _loggedInuser;
  DateFormat _dateFormat = new DateFormat('yyyy-MM-dd');
  TextEditingController _fromDate = new TextEditingController();
  TextEditingController _toDate = new TextEditingController();
  BuildContext _context;

  @override
  void initState() {
    SessionPreferences().getLoggedInUser().then((user){
      setState(() {
        _loggedInuser = user;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    _context = context;
    return Scaffold(
      appBar: AppBar(title: Text('Material Requisition History')),
      body: _selectedItem != null ? Container(
        color: Colors.blueGrey,
        child: Column(
          children: <Widget>[
            Text('Date of requisition: '+_selectedItem.date),
            Expanded(child: ListView.builder(itemBuilder: (ctx,i){
              ReqDetHistory reqDHst = _selectedItem.mrdetails.elementAt(i);
              String itemDesc = reqDHst.item;
              double  qty = reqDHst.qty;
              return ListTile(
                title: Text('Item Name: $itemDesc'),
                subtitle: Text('Quantity needed: $qty'),
              );
            },itemCount: _selectedItem.mrdetails.length))
          ],
        ),
      ) : Container(
        color: Colors.blueGrey,
        padding: EdgeInsets.all(20.0),
        child: Column(
          children: <Widget>[
            Form(
              key: _formkey,
              child: Container(
                padding: EdgeInsets.all(10.0),
                color: Colors.white70,
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: DateTimeField(format: _dateFormat, onShowPicker: (ctx,val){
                        return showDatePicker(context: ctx, initialDate: DateTime.now(), firstDate: DateTime(1900), lastDate: DateTime.now());
                      },controller: _fromDate,validator: (value){
                        if(value == null){
                          return 'Select From Date';
                        }
                        return null;
                      },onChanged: (value){
                        if(value != null){
                          String toDate = _toDate.text;
                          if(toDate.isNotEmpty){
                            DateTime tdt = _dateFormat.parse(toDate);
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
                      },decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderSide: BorderSide()
                        ),
                        labelText: 'From Date'
                      )),
                    ),
                    Expanded(
                      child: DateTimeField(format: _dateFormat, controller: _toDate,onShowPicker: (ctx,val){
                        return showDatePicker(context: ctx, initialDate: DateTime.now(), firstDate: DateTime(1900), lastDate: DateTime.now());
                      },onChanged: (value){
                        if(value != null){
                          String fromDate = _fromDate.text;
                          if(fromDate.isNotEmpty){
                            DateTime frdt = _dateFormat.parse(fromDate);
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
                      },decoration: InputDecoration(
                        labelText: 'To Date',
                        border: OutlineInputBorder(
                          borderSide: BorderSide()
                        )
                      ),validator: (val){
                        if(val == null){
                          return 'Select To Date';
                        }
                        return null;
                      },)
                    )
                  ],
                ),
              ),
            ),
            Expanded(child: _itemsView()),
            _baseView()
          ],
        ),
      ),
    );
  }

  _baseView(){
    return CupertinoButton(color: Colors.blue,child: Text('Search'), onPressed: () async{
      if(_formkey.currentState.validate()){
        String fromDate = _fromDate.text;
        String toDate = _toDate.text;
        int costCenter = _loggedInuser.costCenter;
        ProgressDialog _dialog = new ProgressDialog(context);
        _dialog.style(message: 'Fetching data ... ');
        _dialog.show();
        String baseUrl = await Config.getBaseUrl();
        Response response = await Config.getSimpleRequestObject(baseUrl+'materialreq/list/$costCenter?from=$fromDate&to=$toDate', Config.get, dialog: _dialog);
        _dialog.hide();
        if(response != null){
//          response.transform(utf8.decoder).listen((data){
            var jsonResponse = json.decode(response.body);
            var list = jsonResponse as List;
            List<ReqHistory> reqHistories = list.map<ReqHistory>((e) => ReqHistory.fromJson(e)).toList();
            if(reqHistories.isNotEmpty){
              setState(() {
                _reqHistories = reqHistories;
              });
            } else {
              setState(() {
                _message = 'There were no results for the date range specified';
              });
            }
//          });
        } else {
          setState(() {
            _message = 'An error occurred while processing request';
          });
        }
      }
    });
  }

  _itemsView(){
    if(_reqHistories.isNotEmpty){
      return ListView.builder(itemBuilder: (ctx,i){
        ReqHistory reqHistory = _reqHistories.elementAt(i);
        String date = reqHistory.date;
        return ListTile(
          title: Text('Date of Requisition: $date'),
          subtitle: Text('Tap to view details'),
          onTap: (){
            setState(() {
              _selectedItem = reqHistory;
            });
          },
        );
      },itemCount: _reqHistories.length);
    }
    return Center(
      child: Text(_message),
    );
  }
}
