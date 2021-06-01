import 'dart:convert';
import 'dart:io';

import 'package:dropdownfield/dropdownfield.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:jwines/database/sessionpreferences.dart';
import 'package:jwines/main.dart';
import 'package:jwines/models/inventorymodels.dart';
import 'package:jwines/models/usermodels.dart';
import 'package:jwines/screens/cartitems.dart';
import 'package:jwines/screens/itemdetails.dart';
import 'package:jwines/utils/Config.dart' as Config;
import 'package:progress_dialog/progress_dialog.dart';
import 'package:query_params/query_params.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MaterialRequisition extends StatefulWidget {
  @override
  _MaterialRequisitionState createState() => _MaterialRequisitionState();
}

class _MaterialRequisitionState extends State<MaterialRequisition> with RouteAware{

  List<InventoryItem> _items;
  List<MReqDetail> _reqItems = new List();
  InventoryItem _selectedItem;
  User _loggedInUser;
  BuildContext _context;
  String _searchString, _message = 'Loading ... ',_invClassDesc;
  bool _searchMode = false;
  double _itemQty;
  InvClass _invClass;
  List<InvClass> _invClasses;
  List<String> _invClassDescs = new List();
  TextEditingController _itemDescController = new TextEditingController();
  TextEditingController _selectedClassController = new TextEditingController();
  GlobalKey<FormState> _formKey = new GlobalKey<FormState>();
  GlobalKey<FormState> _criteriaFormKey = new GlobalKey();
  Color _background = Colors.blueGrey;

  @override
  Widget build(BuildContext context){
    _context = context;
    return WillPopScope(
      onWillPop: () async{
        if(_selectedItem != null){
          setState(() {
            _background = Colors.blueGrey;
            _selectedItem = null;
          });
          return false;
        } else if(_searchMode){
          if(_searchString != null){
            setState(() {
              _searchString = null;
            });
            return false;
          }
          setState(() {
            _searchMode = false;
          });
          return false;
        } else if(_items != null){
          setState(() {
            _items = null;
          });
          return false;
        }
        return true;
      },
      child: Scaffold(
        appBar: AppBar(title: !_searchMode ? Text('Material Requisition') : TextFormField(
          onChanged: (val){
            setState(() {
              _searchString = val;
            });
          },
        ),actions: <Widget>[Visibility(
          visible: !_searchMode,
          child: IconButton(icon: Icon(Icons.search), onPressed: (){
            setState(() {
              _searchMode = true;
            });
          }),
        )],),
        body: Container(
          color: _background,
          child: Column(
            children: <Widget>[
              Expanded(child: _body())
            ],
          ),
        ),
      ),
    );
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
  void initState() {
    SessionPreferences().getLoggedInUser().then((user){
      setState(() {
        _loggedInUser =user;
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
          _items = items;
        });
      });
    }
  }

  _body() {
    if(_selectedItem != null){
      return InventoryItemDetails(_selectedItem,Config.materialRequisition,enterReqItem: (item){
        double credLim = _loggedInUser.availableCredit;
        if(_reqItems.isNotEmpty){
          double tt = 0;
          _reqItems.forEach((itm){
            tt += itm.total;
          });
          tt += item.total;
          if(credLim >= tt){
            setState(() {
              _reqItems.add(item);
              _selectedItem = null;
            });
            Fluttertoast.showToast(msg: 'Item has been added');
          } else {
            showDialog(context: _context,builder: (ctx){
              return AlertDialog(
                title: Text('Credit Limit Exceeded'),
                content: Text('Total requisition amount must not exceed your credit limit'),
                actions: <Widget>[
                  FlatButton(onPressed: (){
                    Navigator.pop(ctx);
                  }, child: Text('Ok'))
                ],
              );
            });
          }
        } else {
          double tt = item.total;
          if(credLim >= tt){
            setState(() {
              _reqItems.add(item);
              _selectedItem = null;
            });
            Fluttertoast.showToast(msg: 'Item has been added');
          } else {
            showDialog(context: _context,builder: (ctx){
              return AlertDialog(
                title: Text('Credit Limit Exceeded'),
                content: Text('Total requisition amount must not exceed your credit limit'),
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
    if(_items != null){
      return Column(
        children: <Widget>[
          Expanded(
            child: _bodyItems(),
          ),
          Row(
            children: <Widget>[
              Expanded(child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: RaisedButton(child: Text('Cancel Requisition'), onPressed: (){
                  Navigator.pop(_context);
                },color: Colors.grey),
              )),
              Expanded(child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: RaisedButton(child: Text('View Items'), onPressed: (){
                  Navigator.push(_context, MaterialPageRoute(builder: (ctx)=> ViewCart(Config.materialRequisition,mReqDetails: _reqItems,)));
                },color: Colors.teal),
              ))
            ],
          )
        ],
      );
    }
    return Container(
      color: Colors.white70,
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
                _fetchInventoryItems(_invClass != null && _selectedClassController.text.isNotEmpty? _invClass.id.toString() : 'na',itemDesc.isNotEmpty ? itemDesc : 'na');
              }
            }))
          ],
        ),
      ),
    );
  }

  _checkItemQuantity(int itemId) async{
    String url = await Config.getBaseUrl();
    HttpClientResponse response = await Config.getRequestObject(url+'inventory/balance/$itemId?ccid=0&hq=true', Config.get);
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
              _itemQty = balance.roundToDouble();
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

  _bodyItems(){
    if(_searchString != null && _searchString.isNotEmpty){
      List<InventoryItem> searchResults = new List();
      _items.forEach((item){
        String descrip = item.description;
        if(descrip.toLowerCase().contains(_searchString)){
          searchResults.add(item);
        }
      });
      return _listViewBuilder(searchResults);
    }
    return _listViewBuilder(_items);
  }

  _listViewBuilder(List<InventoryItem> items){
    if(items.isEmpty){
      return Center(
        child: Text('There were no inventory items found'),
      );
    }
    return ListView.builder(itemBuilder: (ctx,i){
      InventoryItem inventoryItem = items.elementAt(i);
      String description = inventoryItem.description;
      String rPrice = inventoryItem.rprice.toString();
      return Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
          color: Colors.white70,
          child: ListTile(
            leading: Icon(Icons.star,color: Colors.green),
            title: Text(description),
            subtitle: Text(rPrice),
            onTap: (){
              _checkItemQuantity(inventoryItem.id);
              setState(() {
                _selectedItem = inventoryItem;
              });
            },
          ),
        ),
      );
    },itemCount: items.length);
  }
}
