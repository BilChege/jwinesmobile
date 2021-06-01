import 'dart:convert';
import 'dart:io';

import 'package:dropdownfield/dropdownfield.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart';
import 'package:intl/intl.dart';
import 'package:jwines/database/sessionpreferences.dart';
import 'package:jwines/main.dart';
import 'package:jwines/models/inventorymodels.dart';
import 'package:jwines/models/salesmodels.dart';
import 'package:jwines/models/usermodels.dart';
import 'package:jwines/screens/cartitems.dart';
import 'package:jwines/screens/itemdetails.dart';
import 'package:jwines/utils/Config.dart' as Config;
import 'package:progress_dialog/progress_dialog.dart';
import 'package:query_params/query_params.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ignore: must_be_immutable
class InventoryItems extends StatefulWidget {

  String purpose;
  InventoryItems(this.purpose);

  @override
  _InventoryItemsState createState() => _InventoryItemsState();
}

class _InventoryItemsState extends State<InventoryItems> with RouteAware{

  List<InventoryItem> _inventoryItems;
  String _message = 'Loading ... ',_searchString,_invClassDesc;
  BuildContext _context;
  InventoryItem _selectedItem;
  List<InvClass> _invClasses;
  List<String> _invClassDescs = new List();
  List<OrderDetail> _orderDetails = new List();
  List<InvoiceDetails> _invDetails =new List();
  TextEditingController _itemDescController = new TextEditingController();
  TextEditingController _selectedClassController = new TextEditingController();
  bool _searchmode = false;
  GlobalKey<FormState> _criteriaFormKey = new GlobalKey();
  User _loggedInUser;
  Customer _selectedCustomer;
  InvClass _invClass;

  @override
  void initState() {
    if(widget.purpose == Config.salesOrder){
      SessionPreferences().getSelectedCustomer().then((customer){
        setState(() {
          _selectedCustomer = customer;
        });
      });
    }
    SessionPreferences().getLoggedInUser().then((user){
      setState(() {
        _loggedInUser = user;
      });
    });
    _fetchInvClasses();
    super.initState();
  }

  _fetchInvClasses() async{
    String url = await Config.getBaseUrl();
    HttpClientResponse response = await Config.getRequestObject(url+'inventory/invclass/', Config.get);
    if(response != null){
      response.transform(utf8.decoder).listen((data){
        var jsonResponse = json.decode(data);
        var list = jsonResponse as List;
        List<InvClass> response = list.map<InvClass>((json){
          return InvClass.fromJson(json);
        }).toList();
        response.forEach((invc){
          _invClassDescs.add(invc.description);
        });
        setState(() {
          _invClasses = response;
        });
      });
    }
  }

  _fetchInventoryItems(String classId, String itemDesc) async{
    ProgressDialog dialog = new ProgressDialog(_context);
    dialog.style(message: 'Fetching items ... ');
    dialog.show();
    URLQueryParams urlQueryParams = new URLQueryParams();
    urlQueryParams.append('invclassid', classId);
    urlQueryParams.append('invname', itemDesc);
    String qParams = urlQueryParams.toString();
    String url = await Config.getBaseUrl();
    HttpClientResponse response = await Config.getRequestObject(url+'inventory/list/?$qParams',Config.get,dialog: dialog);
    if(response != null){
      response.transform(utf8.decoder).listen((data){
        print(data);
        var jsonResponse = json.decode(data);
        var list = jsonResponse as List;
        print(list);
        List<InventoryItem> items = list.map<InventoryItem>((json){
          return InventoryItem.fromJson(json);
        }).toList();
        setState(() {
          _inventoryItems = items;
        });
      });
    }
  }

  @override
  Widget build(BuildContext context){
    _context = context;
    return WillPopScope(
      onWillPop: () async{
        if(_selectedItem != null){
          setState(() {
            _selectedItem = null;
          });
          return false;
        } else if(_searchmode){
          setState(() {
            _searchmode = false;
            _searchString = null;
          });
          return false;
        } else if(_inventoryItems != null){
          setState(() {
            _inventoryItems = null;
          });
          return false;
        }else if(_orderDetails.isNotEmpty || _invDetails.isNotEmpty){
            bool result = false;
            showDialog(context: _context,builder: (bc){
              return AlertDialog(
                title: Text('Items Pending'),
                content: Text('When you exit you will lose all data associated with ongoing transaction.Continue?'),
                actions: <Widget>[
                  FlatButton(onPressed: (){
                    Navigator.pop(bc);
                    result = false;
                  }, child: Text('No')),
                  FlatButton(child: Text('Yes'),onPressed: (){
                    Navigator.pop(bc);
                    Navigator.pop(_context);
                    result = true;
                  })
                ],
              );
            });
            return result;
        }
        return true;
      },
      child: Scaffold(
        appBar: AppBar(title:_searchmode ? TextFormField(decoration: InputDecoration(hintText: 'Search item description'),onChanged: (value){
          setState(() {
            _searchString = value;
          });
        }) : Text('Inventory Items'),actions: <Widget>[Visibility(
          visible:_inventoryItems != null && !_searchmode,
          child: IconButton(icon: Icon(Icons.search), onPressed: (){
            setState(() {
              _searchmode = true;
            });
          }),
        )]),
        body: _body(),
      ),
    );
  }

  _body() {
    if(_selectedItem != null){
      return InventoryItemDetails(_selectedItem,widget.purpose,enterOrderDetail: (orderDetail){
        double creditLimit = _selectedCustomer.availcreditlimit;
        if(_orderDetails.isNotEmpty){
          double total = 0;
          _orderDetails.forEach((detail){
            total += detail.invPrice;
          });
          total += orderDetail.invPrice;
          if(creditLimit >= total){
            setState(() {
              _orderDetails.add(orderDetail);
              _selectedItem = null;
            });
            Fluttertoast.showToast(msg: 'Item has been added');
          } else {
            showDialog(context: _context,builder: (ctx){
              return AlertDialog(
                title: Text('Credit Limit Exceeded'),
                content: Text('Total order amount should not exceed the customer\'s credit Limit'),
                actions: <Widget>[
                  FlatButton(onPressed: (){
                    Navigator.pop(ctx);
                  }, child: Text('Ok'))
                ],
              );
            });
          }
        } else {
          double orderedAmt = orderDetail.invPrice;
          if(creditLimit >= orderedAmt){
            setState(() {
              _orderDetails.add(orderDetail);
              _selectedItem = null;
            });
            Fluttertoast.showToast(msg: 'Item has been added');
          } else {
            showDialog(context: _context,builder: (ctx){
              return AlertDialog(
                title: Text('Credit Limit Exceeded'),
                content: Text('Total order amount should not exceed the customer\'s credit Limit'),
                actions: <Widget>[
                  FlatButton(onPressed: (){
                    Navigator.pop(ctx);
                  }, child: Text('Ok'))
                ],
              );
            });
          }
        }
      },enterInvoiceDetail: (invoiceDetail){
        double crdLim = _loggedInUser.availableCredit;
          double tt = 0;
          if(_invDetails.isNotEmpty){
            _invDetails.forEach((id){
              tt += id.total;
            });
            tt += invoiceDetail.total;
            if(crdLim >= tt){
              setState(() {
                _invDetails.add(invoiceDetail);
                _selectedItem = null;
              });
              Fluttertoast.showToast(msg: 'Item has been added');
            } else {
              showDialog(context: _context,builder: (ctx){
                return AlertDialog(
                  title: Text('Credit Limit Exceeded'),
                  content: Text('Total invoice amount should not exceed your credit Limit'),
                  actions: <Widget>[
                    FlatButton(onPressed: (){
                      Navigator.pop(ctx);
                    }, child: Text('Ok'))
                  ],
                );
              });
            }
          } else {
            double tt = invoiceDetail.total;
            if(crdLim >= tt){
              setState(() {
                _invDetails.add(invoiceDetail);
                _selectedItem = null;
              });
              Fluttertoast.showToast(msg: 'Item has been added');
            } else {
              showDialog(context: _context,builder: (ctx){
                return AlertDialog(
                  title: Text('Credit Limit Exceeded'),
                  content: Text('Total invoice amount should not exceed your credit Limit'),
                  actions: <Widget>[
                    FlatButton(onPressed: (){
                      Navigator.pop(ctx);
                    }, child: Text('Ok'))
                  ],
                );
              });
            }
          }
      });
    }
    if(_inventoryItems != null){
      return Container(
        color: Colors.blueGrey,
        child: Column(
          children: <Widget>[
            Expanded(
              child: _bodyItems(),
            ),
            Row(
              children: <Widget>[
                Expanded(child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: RaisedButton(child: Text(widget.purpose == Config.salesOrder ? 'Cancel Order' : 'Cancel invoice'), onPressed: (){
                    Navigator.pop(_context);
                  },color: Colors.grey),
                )),
                Expanded(child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: RaisedButton(child: Text('View Cart'), onPressed: (){
                    Navigator.push(_context, MaterialPageRoute(builder: (bc){
                      return ViewCart(widget.purpose,orderDetails: _orderDetails,invoiceDetails: _invDetails);
                    }));
                  },color: Colors.teal),
                ))
              ],
            )
          ],
        ),
      );
    }
    return Container(
      padding: EdgeInsets.all(10.0),
      child: Form(
        key: _criteriaFormKey,
        child: ListView(
          children: <Widget>[
            Padding(padding: EdgeInsets.symmetric(vertical: 5),child: TextFormField(
              controller: _itemDescController,
              validator: (desc){
                if(_selectedClassController.text.isEmpty && desc.isEmpty){
                  return 'Select criteria for search';
                } else {
                  if(desc.isNotEmpty){
                    if(desc.length >= 3){
                      return null;
                    } else {
                      return 'Input shouldn\'t be less than 3 characters';
                    }
                  }
                  return null;
                }
              },
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderSide: BorderSide()
                ),
                labelText: 'Search item description'
              ),
            )),
            Padding(padding: EdgeInsets.symmetric(vertical: 5),child:_invClasses == null ? Text(_message) :_invClasses.isNotEmpty ? DropDownField(
              controller: _selectedClassController,
              value: _invClassDesc,
              required: false,
              items: _invClassDescs,
              labelText: 'Inventory Class',
              onValueChanged: (value){
                print(' --------- > Value changed $value');
                InvClass invClass;
                if(value != null){
                  for(InvClass inv in _invClasses){
                    if(inv.description == value){
                      invClass = inv;
                    }
                  }
                  setState(() {
                    _invClass = invClass;
                    _invClassDesc = value;
                  });
                } else {
                  setState(() {
                    _invClass = null;
                    _invClassDesc = null;
                  });
                }
              },
            ) : Text('There were no inventory classes found')),
            Padding(padding: EdgeInsets.symmetric(vertical: 5),child: CupertinoButton(color: Colors.blueGrey,child: Text('Get Items'), onPressed: (){
              if(_criteriaFormKey.currentState.validate()){
                String itemDesc = _itemDescController.text.trim();
                _fetchInventoryItems(_invClass != null && _selectedClassController.text.isNotEmpty ? _invClass.id.toString() : 'na',itemDesc.isNotEmpty ? itemDesc : 'na');
              }
            }))
          ],
        ),
      ),
    );
  }

  _bodyItems(){
    if(_searchString != null && _searchString.isNotEmpty){
      List<InventoryItem> searchResults = new List();
      _inventoryItems.forEach((item){
        String descrip = item.description;
        if(descrip.toLowerCase().contains(_searchString)){
          searchResults.add(item);
        }
      });
      return _listViewBuilder(searchResults);
    }
    return _listViewBuilder(_inventoryItems);
  }

  _listViewBuilder(List<InventoryItem> items){
    if(items.isEmpty){
      return Center(
        child: Text('There were no inventory items found')
      );
    }
    return ListView.builder(itemBuilder: (ctx,i){
      InventoryItem inventoryItem = items.elementAt(i);
      String description = inventoryItem.description;
      String rPrice = NumberFormat.currency(symbol: '').format(inventoryItem.rprice);
      return Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
          color: Colors.white70,
          child: ListTile(
            leading: Icon(Icons.star,color: Colors.green),
            title: Text(description),
            subtitle: Text(rPrice),
            onTap: (){
              setState(() {
                _selectedItem = inventoryItem;
              });
            },
          ),
        ),
      );
    },itemCount: items.length);
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
  void didPopNext() {
    _checkPosted();
  }

  void _checkPosted() async{
    SharedPreferences sp = await SharedPreferences.getInstance();
    bool orderDone = sp.getBool("orderdone");
    if(orderDone != null){
      if (orderDone){
        Navigator.pop(_context);
      }
    }
  }

  _getInvClasses(String description) {
    List<InvClass> filtered = new List();
    _invClasses.forEach((invclass){
      if(invclass.description.toLowerCase().contains(description)){
        filtered.add(invclass);
      }
    });
    return filtered;
  }

  _getItems() {
    List<DropdownMenuItem<InvClass>> items = new List();
    _invClasses.forEach((invCls){
      items.add(DropdownMenuItem<InvClass>(
        value: invCls,
        child: ListTile(
          title: Text(invCls.description),
          leading: Icon(Icons.category,color: Colors.teal),
        ),
      ));
    });
    return items;
  }

}