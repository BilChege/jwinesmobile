import 'dart:io';

import 'package:flutter/material.dart';
import 'package:jwines/database/orderDetailHelper.dart';
import 'package:jwines/database/salesOrderHelper.dart';
import 'package:jwines/main.dart';
import 'package:jwines/models/salesmodels.dart';
import 'package:jwines/screens/cartitems.dart';
import 'package:jwines/utils/Config.dart' as config;
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart' as pathProvider;
import 'package:progress_dialog/progress_dialog.dart';

class SavedOrders extends StatefulWidget {
  @override
  _SavedOrdersState createState() => _SavedOrdersState();
}

class _SavedOrdersState extends State<SavedOrders> with RouteAware{

  SalesOrderProvider _salesOrderProvider = new SalesOrderProvider();
  OrderDetailProvider _orderDetailProvider = new OrderDetailProvider();
  BuildContext _context;
  Directory _directory;
  List<SalesOrder> _orders;
  String _message = 'Reading from storage ... ';


  @override
  void initState() {
    _initData();
    super.initState();
  }


  @override
  void didChangeDependencies() {
    routeObserver.subscribe(this, ModalRoute.of(context));
    super.didChangeDependencies();
  }


  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _context = context;
    return Scaffold(
      appBar: AppBar(title: Text('Saved sales orders')),
      body: _body(),
    );
  }

  @override
  void didPopNext() {
    _initData();
  }

  _body() {
    if (_orders != null){
      if(_orders.isNotEmpty){
        return Container(
          padding: EdgeInsets.all(10.0),
          color: Colors.white70,
          child: ListView.builder(itemBuilder: (builder,i){
            SalesOrder salesOrder = _orders.elementAt(i);
            String custName = salesOrder.custName;
            String dateSaved = salesOrder.orderdate;
            return Column(
              children: <Widget>[
                ListTile(
                  leading: Image(image: AssetImage('images/person2.png')),
                  title: Text(custName),
                  subtitle: Text('Date saved : $dateSaved'),
                  onTap: () async{
                    showDialog(context: _context,builder: (bc){
                      return AlertDialog(
                        title: Text('Go to Cart?'),
                        content: Text('This record will be removed from storage. To retain it, you will have to press save on the cart page. Continue?'),
                        actions: <Widget>[
                          FlatButton(onPressed: (){
                            Navigator.pop(bc);
                          }, child: Text('No')),
                          FlatButton(onPressed: () async{
                            Navigator.pop(bc);
                            Directory directory = await pathProvider.getApplicationDocumentsDirectory();
                            String pathStr = path.join(directory.path,config.dbPath);
                            _orderDetailProvider.open(pathStr).then((value){
                              Map<String,dynamic> criteria = {
                                config.orderid: salesOrder.orderid
                              };
                              _orderDetailProvider.findByCriteria(criteria).then((orderDetails){
//                        di.update(message: 'Recording changes ... ');
                                _salesOrderProvider.open(pathStr).then((value) async{
                                  _salesOrderProvider.delete(salesOrder.orderid).then((value){
                                    print('-------------> DELETED WITH ID : $value');
//                            di.hide();
                                    Navigator.push(_context, MaterialPageRoute(builder: (bc){
                                      return ViewCart(config.salesOrder,orderDetails: orderDetails);
                                    }));
                                  });
                                });
                              });
                            });
                          }, child: Text('Yes'))
                        ],
                      );
                    });
                  },
                ),
                Divider()
              ],
            );
          },itemCount: _orders.length),
        );
      } else {
        _message = 'There were no saved orders found';
      }
    }
    return Center(child: Text(_message));
  }

  void _initData() async{
    Directory directory = await pathProvider.getApplicationDocumentsDirectory();
    String pathStr = path.join(directory.path,config.dbPath);
    _salesOrderProvider.open(pathStr).then((value){
      _salesOrderProvider.findAll().then((salesOrders){
        setState(() {
          _orders = salesOrders;
        });
      });
    });
  }

}
