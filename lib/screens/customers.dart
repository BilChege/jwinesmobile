import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart';
import 'package:intl/intl.dart';
import 'package:jwines/database/sessionpreferences.dart';
import 'package:jwines/main.dart';
import 'package:jwines/models/usermodels.dart';
import 'package:jwines/screens/inventoryitems.dart';
import 'package:jwines/utils/Config.dart' as Config;
import 'package:shared_preferences/shared_preferences.dart';

class ShowCustomers extends StatefulWidget {
  @override
  _ShowCustomersState createState() => _ShowCustomersState();
}

class _ShowCustomersState extends State<ShowCustomers> with RouteAware{

  User _loggedInUser;
  List<Customer> _customers;
  String _message = 'Loading ... ';
  BuildContext _context;
  String _searchString;
  bool _searchmode = false;
  TextEditingController _searchController = new TextEditingController();

  @override
  void initState(){
    SessionPreferences().getLoggedInUser().then((user){
      setState(() {
        _loggedInUser = user;
      });
      _fetchCustomers(user.hrid);
    });
    super.initState();
  }

  _fetchCustomers(int hrid) async{
    String url = await Config.getBaseUrl();
    HttpClientResponse response = await Config.getRequestObject(url+'customer/$hrid',Config.get);
    if(response != null){
      response.transform(utf8.decoder).listen((data){
        var jsonResponse = json.decode(data);
        var list = jsonResponse as List;
        print(list);
        List<Customer> result = list.map<Customer>((json){
          return Customer.fromJson(json);
        }).toList();
        if(result.isNotEmpty){
          setState(() {
            _customers = result;
          });
        } else {
          setState(() {
            _message = 'You have not been assigned any customers';
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    _context = context;
    return WillPopScope(
      onWillPop: () async{
        if(_searchmode){
          setState(() {
            _searchmode = false;
            _searchString = null;
          });
          return false;
        }
        return true;
      },
      child: Scaffold(
        appBar: AppBar(title:_searchmode ? TextFormField(controller: _searchController,decoration: InputDecoration(hintText: 'Search customer name'),onChanged: (value){
          setState(() {
            _searchString = value;
          });
        }) : Text('Select Customer'),actions: <Widget>[Visibility(
          visible: !_searchmode,
          child: IconButton(icon: Icon(Icons.search), onPressed: (){
            setState(() {
              _searchmode = true;
            });
          }),
        )],),
        body: Container(
          color: Colors.blueGrey,
          child: _body(),
        ),
      ),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    routeObserver.subscribe(this, ModalRoute.of(context));
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  void didPopNext(){
    isOrderPosted().then((posted){
      if(posted != null){
        if(posted){
          updateStatus(false);
          showDialog(context: _context,builder: (bc){
            return CupertinoAlertDialog(
              title: Text('Success'),
              content: Text('Your data has been uploaded successfully'),
              actions: <Widget>[
                FlatButton(onPressed: (){
                  Navigator.pop(bc);
                }, child: Text('Ok'))
              ],
            );
          });
        }
      }
    });
  }

  void updateStatus(bool status) async{
    SharedPreferences shp = await SharedPreferences.getInstance();
    shp.setBool("orderdone", status);
  }

  Future<bool> isOrderPosted() async {
    SharedPreferences shp = await SharedPreferences.getInstance();
    return shp.getBool("orderdone");
  }

  _body(){
    if(_customers != null && _customers.isNotEmpty){
      if(_searchString != null && _searchString.isNotEmpty){
        List<Customer> searchResults = new List();
        _customers.forEach((customer){
          String company = customer.company;
          String code = customer.custcode;
          if(company.toLowerCase().contains(_searchString)){
            searchResults.add(customer);
          }
        });
        return _listViewBuilder(searchResults);
      }
      return _listViewBuilder(_customers);
    }
    return Center(
      child: Text(_message),
    );
  }

  _listViewBuilder(List<Customer> data){
    return ListView.builder(itemBuilder: (bc,i){
      Customer customer = data.elementAt(i);
      String company = customer.company;
      String code = customer.custcode;
      double balance = customer.balance;
      double pdamount = customer.pdamount;
      String bal = NumberFormat.currency(symbol: '').format(balance);
      String pdBal = NumberFormat.currency(symbol: '').format(pdamount);
      String creditLimit = customer.availcreditlimit >= 0 ? NumberFormat.currency(symbol: '').format(customer.availcreditlimit) : 0.toString();
      return Padding(
        padding: const EdgeInsets.all(10.0),
        child: Container(
          color: Colors.white70,
          child: ListTile(
            leading: Icon(Icons.person),
            title: Text(company),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(code != null ? 'Customer code: $code' : 'Customer code: Undefined'),
                Text('Customer balance: $bal'),
                Text('PDCheque balance: $pdBal'),
                Text('Available Credit: $creditLimit')
              ],
            ),
            onTap: (){
              if(code != null){
                SessionPreferences().setSelectedCustomer(customer);
                Navigator.push(_context, MaterialPageRoute(builder: (bc){
                  return InventoryItems(Config.salesOrder);
                }));
              } else {
                showDialog(context: _context,builder: (bc){
                  return AlertDialog(
                    title: Text('Error'),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Icon(Icons.error,color: Colors.red),
                        Text('This customer does not have a code')
                      ],
                    ),
                    actions: <Widget>[
                      FlatButton(onPressed: (){
                        Navigator.pop(bc);
                      }, child: Text('Ok'))
                    ],
                  );
                });
              }
            },
          ),
        ),
      );
    },itemCount: data.length);
  }

}