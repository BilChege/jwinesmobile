import 'dart:convert';
import 'dart:io';

import 'package:blue_thermal_printer/blue_thermal_printer.dart' as printer;
import 'package:flutter/cupertino.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart' as pathProvider;
import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:jwines/database/orderDetailHelper.dart';
import 'package:jwines/database/salesOrderHelper.dart';
import 'package:jwines/database/sessionpreferences.dart';
import 'package:jwines/main.dart';
import 'package:jwines/models/inventorymodels.dart';
import 'package:jwines/models/salesmodels.dart';
import 'package:jwines/models/usermodels.dart';
import 'package:jwines/screens/editCartItem.dart';
import 'package:jwines/screens/thermalPrinter.dart';
import 'package:jwines/utils/Config.dart' as prefix0;
import 'package:progress_dialog/progress_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:social_share/social_share.dart';

// ignore: must_be_immutable
class ViewCart extends StatefulWidget {

  String purpose;
  List<OrderDetail> orderDetails;
  List<InvoiceDetails> invoiceDetails;
  List<MReqDetail> mReqDetails;
  int savedOrder;
  BluetoothDevice _savedDevice;
  ViewCart(this.purpose,{this.savedOrder,this.mReqDetails,this.orderDetails,this.invoiceDetails});

  @override
  _ViewCartState createState() => _ViewCartState();
}

class _ViewCartState extends State<ViewCart> with RouteAware{

  List<OrderDetail> _orderDetails = new List();
  printer.BlueThermalPrinter _btp = printer.BlueThermalPrinter.instance;
  List<InvoiceDetails> _invoiceDetails = new List();
  List<MReqDetail> _items = new List();
  User _loggedInUser;
  double _newOrderTT;
  var _selectedItem;
  String _message = 'Loading ...';
  Customer _selectedCustomer;
  final _ttPriceController = new TextEditingController();
  final _remarksController = new TextEditingController();
  BuildContext _context;
  double _newQty;
  SalesOrderProvider _salesOrderProvider;
  OrderDetailProvider _orderDetailProvider;
  DateFormat _format = new DateFormat('yyyy-MM-dd');
  bool _deviceConnected,_setPrintPromptdone = false,_toEdit = false;
  TextEditingController _orderQty = new TextEditingController();
  GlobalKey<FormState> _orderFormKey = new GlobalKey<FormState>();
  DateFormat _forDisplay = new DateFormat('d/MMMM/yyyy : HH:mm:ss');
  final _remarksKey = GlobalKey<FormState>();

  @override
  void initState(){
    _salesOrderProvider = new SalesOrderProvider();
    _orderDetailProvider = new OrderDetailProvider();
    if(widget.purpose == prefix0.salesOrder){
      _btp.isConnected.then((connected){
        setState(() {
          _deviceConnected = connected;
        });
      });
      SessionPreferences().getLoggedInUser().then((user){
        setState(() {
          _loggedInUser = user;
        });
        if(widget.savedOrder != null){
          _fetchCustomer(widget.savedOrder);
        } else {
          SessionPreferences().getSelectedCustomer().then((customer){
            setState((){
              _selectedCustomer = customer;
            });
          });
        }
      });
      setState((){
        _orderDetails = widget.orderDetails;
      });
    } else if(widget.purpose == prefix0.invoice){
      _btp.isConnected.then((connected){
        setState(() {
          _deviceConnected = connected;
        });
      });
      SessionPreferences().getLoggedInUser().then((user){
        setState(() {
          _loggedInUser = user;
        });
        _fetchCustomer(user.custid);
      });
      setState(() {
        _invoiceDetails = widget.invoiceDetails;
      });
    } else if(widget.purpose == prefix0.materialRequisition){
      SessionPreferences().getLoggedInUser().then((user){
        setState(() {
          _loggedInUser = user;
        });
        _fetchCustomer(user.custid);
      });
      setState(() {
        _items = widget.mReqDetails;
      });
    }
    super.initState();
  }


  @override
  void didPopNext() {
    if(!_toEdit){
      _btp.isConnected.then((connected){
        setState(() {
          _deviceConnected = connected;
        });
        if(!connected){
          showDialog(context: _context,builder: (bc){
            return AlertDialog(
              title: Text('No device connected'),
              content: Text('Your mobile device is not connected to any bluetooth printing device'),
              actions: <Widget>[
                FlatButton(onPressed: (){
                  Navigator.pop(bc);
                }, child: Text('Ok'))
              ],
            );
          });
        }
      });
    } else {
      if(widget.purpose == prefix0.salesOrder){
        SessionPreferences().getOrderItemEdited().then((item){
          setState((){
            _orderDetails.add(item);
          });
        });
      } else if(widget.purpose == prefix0.invoice){
        SessionPreferences().getInvoiceItemEdited().then((item){
          setState(() {
            _invoiceDetails.add(item);
          });
        });
      } else if(widget.purpose == prefix0.materialRequisition){
        SessionPreferences().getMreqItemEdited().then((mreqitem){
          setState((){
            _items.add(mreqitem);
          });
        });
      }
    }
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
  Widget build(BuildContext context){
      if(_deviceConnected != null &&!_deviceConnected){
        if(!_setPrintPromptdone){
          WidgetsBinding.instance.addPostFrameCallback((_){
            showModalBottomSheet(context: context, builder: (ctx){
              return Container(
                padding: EdgeInsets.all(10.0),
                child: Wrap(
                  children: <Widget>[
                    Text('You have not set up a bluetooth printing device'),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10.0),
                      child: ListTile(title: Text('Set up a device'),onTap: (){
                        Navigator.pop(ctx);
                        Navigator.push(context, MaterialPageRoute(builder: (context) => ThermalPrinter()));
                      },),
                    )
                  ],
                ),
              );
            });
          });
          _setPrintPromptdone = true;
        }
      }
    _context = context;
    return WillPopScope(
      onWillPop: () async{
        if(_selectedItem != null){
          setState(() {
            _selectedItem = null;
          });
          return false;
        }
        return true;
      },
      child: Scaffold(
        appBar: AppBar(title: Text(widget.purpose == prefix0.materialRequisition? 'View Items':'View Cart'),backgroundColor: Colors.blueGrey,actions: <Widget>[
          Visibility(
            visible: widget.purpose == prefix0.salesOrder || widget.purpose == prefix0.invoice,
            child: IconButton(icon: Icon(Icons.print), onPressed: (){
              _btp.isConnected.then((connected){
                if(connected){
                  showDialog(context: _context,builder: (ctx){
                    return AlertDialog(
                      title: Text('Connection found'),
                      content: Text('Your printer is already connected to this mobile device'),
                      actions: <Widget>[
                        FlatButton(onPressed: (){
                          Navigator.pop(ctx);
                        }, child: Text('Ok'))
                      ],
                    );
                  });
                } else {
                  showModalBottomSheet(context: context, builder: (ctx){
                    return Container(
                      padding: EdgeInsets.all(10.0),
                      child: Wrap(
                        children: <Widget>[
                          Text('You have not set up a bluetooth printing device'),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10.0),
                            child: ListTile(title: Text('Set up a device'),onTap: (){
                              Navigator.pop(ctx);
                              Navigator.push(context, MaterialPageRoute(builder: (context) => ThermalPrinter()));
                            },),
                          )
                        ],
                      ),
                    );
                  });
                }
              });
            }),
          ),
          Visibility(visible: widget.purpose == prefix0.salesOrder && _orderDetails.isNotEmpty,child: IconButton(icon: Icon(Icons.save), onPressed: (){
            showDialog(context: context,builder: (bc){
              return AlertDialog(
                title: Text('Save?'),
                content: Text('Would you like to save this order? You could post it another time'),
                actions: <Widget>[
                  FlatButton(onPressed: (){
                    Navigator.pop(bc);
                  }, child: Text('No')),
                  FlatButton(onPressed: () async{
                    Navigator.pop(bc);
                    ProgressDialog di = new ProgressDialog(context);
                    di.style(message: 'Saving sales order ... ');
                    di.show();
                    Directory directory = await pathProvider.getApplicationDocumentsDirectory();
                    String pathStr = path.join(directory.path,prefix0.dbPath);
                    _salesOrderProvider.open(pathStr).then((x){
                      _salesOrderProvider.insert(SalesOrder(
                        custid: _selectedCustomer.custid.toString(),
                        custName: _selectedCustomer.company,
                        ordervalidity: 30,
                        orderid: 0,
                        orderdate: _format.format(DateTime.now()),
                        orderdocno: ''
                      )).then((id){
                        _orderDetailProvider.open(pathStr).then((x){
                          _orderDetails.forEach((oD){
                              _orderDetailProvider.insert(oD, id);
                          });
                          di.hide();
                          Fluttertoast.showToast(msg: 'Sales Order has been saved');
                          _orderDetails.clear();
                          Navigator.pop(_context);
                        });
                      });
                    });
                  }, child: Text('Yes'))
                ],
              );
            });
          })),
          Visibility(visible: (widget.purpose == prefix0.salesOrder && _orderDetails.isNotEmpty) || (widget.purpose == prefix0.invoice && _invoiceDetails.isNotEmpty),child: IconButton(icon: Icon(Icons.forward), onPressed: (){
            String message = "Hi there, here is a quotation for Jwines products you are interested in: \n\n";
            double grandTotal = 0;
            if(widget.purpose == prefix0.salesOrder){
              _orderDetails.forEach((element) {
                String desc = element.invDescrip;
                int qty = element.invQty.floor();
                double unitPrice = element.invPrice;
                double discTotal = element.invQty * element.invPrice;
                double origTotal = element.invQty * element.originalPrice;
                double discount = origTotal - discTotal;
                String formattedPrice = NumberFormat.currency(symbol: '').format(unitPrice);
                String formattedTotal = NumberFormat.currency(symbol: '').format(discTotal);
                grandTotal += discTotal;
                message += "$desc\nQuantity : $qty\nSelling price : $formattedPrice Kshs\nTotal price : $formattedTotal Kshs\n\n";
              });
            } else if (widget.purpose == prefix0.invoice){
              _invoiceDetails.forEach((element) {
                String desc = element.itemDesc;
                int qty = element.qtysold.floor();
                double sellingPrice = element.rprice;
                double total = element.total;
                String formattedPrice = NumberFormat.currency(symbol: '').format(sellingPrice);
                String formattedTotal = NumberFormat.currency(symbol: '').format(total);
                grandTotal += total;
                message += "$desc\nQuantity : $qty\nSelling price : $formattedPrice Kshs\nTotal price : $formattedTotal Kshs\n\n";
              });
            }
            String formattedGrandTotal = NumberFormat.currency(symbol: '').format(grandTotal);
            message += 'Grand Total : $formattedGrandTotal Kshs';
            showModalBottomSheet(context: context, builder: (bc){
              return Container(
                child: Wrap(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Text('Send Quotation'),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: ListTile(leading: Image(image: AssetImage('images/whatsapp.png')),title: Text('Share via whatsapp'),onTap: (){
                        SocialShare.shareWhatsapp(message);
                      }),
                    ),
//                    ListTile(leading: Image(image: AssetImage('images/sms.png')),title: Text('Share via sms'),onTap: (){
//                      SocialShare.shareSms(message);
//                    })
                  ],
                ),
              );
            });
          }))
        ],),
        body: _orderDetails.isEmpty && _invoiceDetails.isEmpty && _items.isEmpty? Container(
          color: Colors.blueGrey,
          child: Center(
            child: Text('No data found'),
      ),
        ) : Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Text(_selectedCustomer != null ? 'Customer:'+_selectedCustomer.company : _message,style: TextStyle(fontSize: 20.0,color: Colors.black54,fontStyle: FontStyle.italic)),
            ),
            Expanded(child: _listViewBuilder()),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Visibility(
                visible: widget.purpose != prefix0.materialRequisition,
                child: TextFormField(
                  controller: _ttPriceController,
                  enabled: false,
                  decoration: InputDecoration(
                      border: OutlineInputBorder(
                          borderSide: BorderSide()
                      ),
                      labelText: 'Total order price'
                  ),
                ),
              ),
            ),
            Form(
              key: _remarksKey,
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Visibility(
                  visible: widget.purpose == prefix0.invoice,
                  child: TextFormField(
                    controller: _remarksController,
                    validator: (input){
                      if(input.isEmpty){
                        return 'Enter the remarks';
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderSide: BorderSide()
                      ),
                      labelText: 'Remarks'
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: CupertinoButton(color: Colors.teal,child: Text(widget.purpose == prefix0.salesOrder ?'Post Order' : widget.purpose == prefix0.invoice ? 'Post Invoice' : 'Make Requisition'), onPressed: _selectedCustomer != null ? () async{
                if(_remarksKey.currentState.validate()){
                  showDialog(context: _context,builder: (bc){
                    return AlertDialog(
                      title: Text('Confirm Submission'),
                      content: Text('Would you like to forward the data for processing?'),
                      actions: <Widget>[
                        FlatButton(onPressed: (){
                          Navigator.pop(bc);
                        }, child: Text('No')),
                        FlatButton(onPressed: () async{
                          Navigator.pop(bc);
                          ProgressDialog dialog = new ProgressDialog(context);
                          dialog.style(message: 'Please wait ... ');
                          dialog.show();
                          DateTime current = DateTime.now();
                          String formatted = _format.format(current);
                          String url = await prefix0.getBaseUrl();
                          if(widget.purpose == prefix0.salesOrder){
                            String jsonData = json.encode(SalesOrder(
                                custid: _selectedCustomer.custcode,
                                orderid: 0,
                                orderdate: formatted,
                                orderdocno: '',
                                ordervalidity: 30,
                                orderDetails: _orderDetails
                            ));
                            HttpClientResponse response = await prefix0.getRequestObject(url+'salesorder/incoming',prefix0.post,body: jsonData,dialog: dialog);
                            if(response != null){
                              response.transform(utf8.decoder).listen((data) async{
                                var jsonResponse = json.decode(data);
                                int resultCode = int.parse(jsonResponse['ResultCode']);
                                print('Result code $resultCode');
                                String orderNum = jsonResponse['Ref'];
                                if(resultCode != null){
                                  if(resultCode == 0){
                                    String customerName = _selectedCustomer.company;
                                    _btp.isConnected.then((connected) async{
                                      if(connected){
                                        String dateDisplay = _forDisplay.format(DateTime.now());
                                        _btp.printCustom('JWines Customer order', 3, 1);
                                        _btp.printCustom('Customer Name: $customerName ',3,1);
                                        _btp.printCustom('Order Number : $orderNum', 3, 1);
                                        _btp.printCustom('Date ordered: $dateDisplay', 3 , 1);
                                        _btp.printNewLine();
                                        double total = 0;
                                        _orderDetails.forEach((detail){
                                          String desc = detail.invDescrip;
                                          String qty = detail.invQty.toString();
                                          String itmPrice = detail.originalPrice.toString();
                                          String ttPrice = (double.parse(qty) * detail.itemPrice).toString();
                                          double discount = ((detail.originalPrice * double.parse(qty)) - double.parse(ttPrice));
                                          String disc = discount.toStringAsFixed(2);
                                          total += double.parse(ttPrice);
                                          int qtyDisplay = detail.invQty.round();
                                          _btp.printCustom('$desc \nUnitPrice: $itmPrice Kshs\nQuantity ordered: $qtyDisplay \nDiscount amount: $disc Ksh\nTotal price: $ttPrice Kshs', 1, 1);
                                          _btp.printNewLine();
                                        });
                                        _btp.printCustom("Total Order Amount: $total Kshs", 1, 1);
                                        _btp.printNewLine();
                                        _btp.printNewLine();
                                        _btp.paperCut();
                                      } else {
                                        Fluttertoast.showToast(msg: 'You are not connected to a printing device',toastLength: Toast.LENGTH_LONG);
                                      }
                                      SharedPreferences shp = await SharedPreferences.getInstance();
                                      shp.setBool("orderdone", true);
                                      Navigator.pop(_context);
                                    });
                                  } else if(resultCode < 0){
                                    String error = jsonResponse['Error'];
                                    Fluttertoast.showToast(msg: 'Error occured: $error',toastLength: Toast.LENGTH_LONG);
                                  }
                                }
                              });
                            }
                          } else if(widget.purpose == prefix0.invoice){
                            double vatVal = 0;
                            double grandDiscount = 0;
                            _invoiceDetails.forEach((item){
                              vatVal += item.vat;
                              grandDiscount += item.discAmt;
                            });
                            double total = double.parse(_ttPriceController.text);
                            double subtotal = total - vatVal;
                            DateTime current = DateTime.now();
                            String jsonData = json.encode(
                                SalesInvoice(
                                    custid: _selectedCustomer.custid,
                                    salesrep: _loggedInUser.hrid,
                                    costcenter: _loggedInUser.costCenter,
                                    invdate: _format.format(current),
                                    subtotal: subtotal,
                                    vat: vatVal,
                                    granddiscount: grandDiscount,
                                    grandtotal: total,
                                    invDetails: _invoiceDetails,
                                    remarks: _remarksController.text
                                )
                            );
                            print('Body:-> $jsonData');
                            HttpClientResponse response = await prefix0.getRequestObject(url+'salesinvoice/',prefix0.post,body: jsonData,dialog: dialog);
                            if(response != null){
                              response.transform(utf8.decoder).listen((data) async{
                                String dateInvoiced = _forDisplay.format(DateTime.now());
                                if(data != null){
                                  _btp.isConnected.then((connected) async{
                                    print('Printer connected: $connected');
                                    if(connected){
                                      _btp.printCustom('JWines Sale Invoice', 3, 1);
                                      _btp.printCustom('Invoice Number : $data', 3, 1);
                                      _btp.printCustom('Date of Invoice : $dateInvoiced', 3, 1);
                                      _btp.printNewLine();
                                      double total = 0;
                                      _invoiceDetails.forEach((detail){
                                        String desc = detail.itemDesc;
                                        String qty = detail.qtysold.toString();
                                        String itmPrice = detail.originalPrice.toString();
                                        String ttPrice = detail.total.toString();
                                        String discount = ((detail.originalPrice * double.parse(qty)) - double.parse(ttPrice)).toStringAsFixed(2);
                                        total += double.parse(ttPrice);
                                        _btp.printCustom('$desc \nUnitPrice: $itmPrice Kshs\nQuantity bought: $qty \nDiscount: $discount Kshs\nTotal price: $ttPrice Kshs', 1, 1);
                                        _btp.printNewLine();
                                      });
                                      _btp.printCustom("Total Sale Amount: $total Kshs", 1, 1);
                                      _btp.printNewLine();
                                      _btp.printNewLine();
                                      _btp.paperCut();
                                    } else {
                                      Fluttertoast.showToast(msg: 'You are not connected to a bluetooth printer',toastLength: Toast.LENGTH_LONG);
                                    }
                                    SharedPreferences shp = await SharedPreferences.getInstance();
                                    shp.setBool("orderdone", true);
                                    Navigator.pop(_context);
                                  });
                                }
                              });
                            }
                          } else if(widget.purpose == prefix0.materialRequisition){
                            String jsonData = json.encode(MReqObject(
                                costcenter: _loggedInUser.costCenter,
                                remarks: '',
                                reqDetails: _items
                            ));
                            HttpClientResponse response = await prefix0.getRequestObject(url+'materialreq/', prefix0.post,body: jsonData,dialog: dialog);
                            if(response != null){
                              response.transform(utf8.decoder).listen((data) async{
                                if(data == 'Done'){
                                  Fluttertoast.showToast(msg: 'Material requisition successfully done');
                                  SharedPreferences shp = await SharedPreferences.getInstance();
                                  shp.setBool("orderdone", true);
                                  Navigator.pop(_context);
                                } else {
                                  Fluttertoast.showToast(msg: data);
                                }
                              });
                            }
                          }
                        }, child: Text('Yes'))
                      ],
                    );
                  });
                }
              } : null),
            )
          ],
        ),
      ),
    );
  }

  _listViewBuilder() {
    if(_orderDetails.isNotEmpty){
      double ttOrderPrice = 0;
      _orderDetails.forEach((item){
        ttOrderPrice += item.itemPrice * item.invQty;
      });
      String totalOrderPrice = NumberFormat.currency(symbol: '').format(ttOrderPrice);
      _ttPriceController.text = totalOrderPrice;
      return Container(
        color: Colors.white70,
        child: ListView.builder(itemBuilder: (ctx,i){
          OrderDetail orderDetail = _orderDetails.elementAt(i);
          String description = orderDetail.invDescrip;
          String quantity = orderDetail.invQty.toString();
          String ttPrice = NumberFormat.currency(symbol: '').format(orderDetail.itemPrice * orderDetail.invQty);
          return Padding(padding: EdgeInsets.all(10.0),child: GestureDetector(
            onTap: (){
              SessionPreferences().setOrderItemToEdit(orderDetail).then((x){
                setState(() {
                  _orderDetails.remove(orderDetail);
                  _toEdit = true;
                });
                double currentTT = 0;
                _orderDetails.forEach((od){
                  currentTT += od.invPrice;
                });
                Navigator.push(_context, MaterialPageRoute(builder: (bc){
                  return CartItem(prefix0.salesOrder, currentTT);
                }));
              });
            },
            child: Card(elevation: 15.0,child: Container(
              padding: EdgeInsets.symmetric(vertical: 10.0),
              color: Colors.blueGrey,
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Text('Item description: $description',style: TextStyle(fontSize: 15)),
                        Text('Ordered quantity: $quantity',style: TextStyle(fontSize: 15)),
                        Text('Total Price: $ttPrice',style: TextStyle(fontSize: 15))
                      ],
                    ),
                  ),
                  IconButton(icon: Icon(Icons.close), onPressed: (){
                    showDialog(context: _context,builder: (bc){
                      return AlertDialog(
                        title: Text('Remove item?'),
                        content: Text('Are you sure you want to remove this item from the cart?'),
                        actions: <Widget>[
                          FlatButton(onPressed: (){
                            Navigator.pop(bc);
                          }, child: Text('No')),
                          FlatButton(onPressed: (){
                            Navigator.pop(bc);
                            setState(() {
                              _orderDetails.remove(orderDetail);
                            });
                          }, child: Text('Yes'))
                        ],
                      );
                    });
                  })
                ],
              ),
            )),
          ));
        },itemCount: _orderDetails.length),
      );
    } else if(_invoiceDetails.isNotEmpty){
      double ttInvoiceAmt = 0;
      _invoiceDetails.forEach((invoice){
        ttInvoiceAmt += invoice.total;
      });
      _ttPriceController.text = ttInvoiceAmt.toStringAsFixed(2);
      return Container(
        color: Colors.white70,
        child: ListView.builder(itemBuilder: (bc,i){
          InvoiceDetails invDet = _invoiceDetails.elementAt(i);
          String description = invDet.itemDesc;
          String qty = invDet.qtysold.toString();
          String ttPrice = NumberFormat.currency(symbol: '').format(invDet.total);
          return Padding(padding: EdgeInsets.all(10.0),child: Container(
            padding: EdgeInsets.all(10.0),
            color: Colors.blueGrey,
            child: GestureDetector(
              onTap: (){
                SessionPreferences().setInvoiceItemToEdit(invDet).then((x){
                  setState(() {
                    _invoiceDetails.remove(invDet);
                    _toEdit = true;
                  });
                  double tt = 0;
                  _invoiceDetails.forEach((id){
                    tt += id.total;
                  });
                  Navigator.push(_context, MaterialPageRoute(builder: (bc){
                    return CartItem(prefix0.invoice, tt);
                  }));
                });
              },
              child: Card(elevation: 15.0,child: Row(
                children: <Widget>[
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Text('Item description: $description'),
                        Text('Ordered quantity: $qty'),
                        Text('Total Price: $ttPrice')
                      ],
                    ),
                  ),
                  IconButton(icon: Icon(Icons.clear), onPressed: (){
                    showDialog(context: _context,builder: (bc){
                      return AlertDialog(
                        title: Text('Remove item?'),
                        content: Text('Are you sure you want to remove this item from the cart?'),
                        actions: <Widget>[
                          FlatButton(onPressed: (){
                            Navigator.pop(bc);
                          }, child: Text('No')),
                          FlatButton(onPressed: (){
                            Navigator.pop(bc);
                            setState(() {
                              _invoiceDetails.remove(invDet);
                            });
                          }, child: Text('Yes'))
                        ],
                      );
                    });
                  })
                ],
              )),
            ),
          ));
        },itemCount: _invoiceDetails.length),
      );
    } else if(_items.isNotEmpty){
      return Container(
        color: Colors.white70,
        child: ListView.builder(itemBuilder: (bc,i){
          MReqDetail det = _items.elementAt(i);
          String description = det.desc;
          String qty = det.qty.toString();
          return Padding(padding: EdgeInsets.all(10.0),child: Container(
            padding: EdgeInsets.all(10.0),
            color: Colors.blueGrey,
            child: GestureDetector(
              onTap: (){
                SessionPreferences().setRequisitionItemToEdit(det).then((x){
                  setState(() {
                    _items.remove(det);
                    _toEdit = true;
                  });
                  double currentTotal = 0;
                  _items.forEach((item){
                    currentTotal += item.total;
                  });
                  Navigator.push(_context, MaterialPageRoute(builder: (bc){
                    return CartItem(prefix0.materialRequisition,currentTotal);
                  }));
                });
              },
              child: Card(elevation: 15.0,child: Row(
                children: <Widget>[
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Text('Item description: $description'),
                        Text('Ordered quantity: $qty'),
                      ],
                    ),
                  ),
                  IconButton(icon: Icon(Icons.clear), onPressed: (){
                    showDialog(context: _context,builder: (bc){
                      return AlertDialog(
                        title: Text('Remove item?'),
                        content: Text('Are you sure you want to remove this item from the cart?'),
                        actions: <Widget>[
                          FlatButton(onPressed: (){
                            Navigator.pop(bc);
                          }, child: Text('No')),
                          FlatButton(onPressed: (){
                            Navigator.pop(bc);
                            setState(() {
                              _items.remove(det);
                            });
                          }, child: Text('Yes'))
                        ],
                      );
                    });
                  })
                ],
              )),
            ),
          ));
        },itemCount: _items.length),
      );
    }
  }

  _fetchCustomer(int id) async{
    String url = await prefix0.getBaseUrl();
    HttpClientResponse response = await prefix0.getRequestObject(url+'customer/customerById/$id', prefix0.get);
    if(response != null){
      response.transform(utf8.decoder).listen((data){
        Customer customer = Customer.fromJson(json.decode(data));
        setState(() {
          _selectedCustomer = customer;
        });
      });
    }
  }
}