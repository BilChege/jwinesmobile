import 'dart:convert';
import 'dart:io';

import 'package:blue_thermal_printer/blue_thermal_printer.dart' as printer;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart';
import 'package:intl/intl.dart';
import 'package:jwines/database/sessionpreferences.dart';
import 'package:jwines/main.dart';
import 'package:jwines/models/usermodels.dart';
import 'package:jwines/screens/customers.dart';
import 'package:jwines/screens/forgotpass.dart';
import 'package:jwines/screens/inventoryitems.dart';
import 'package:jwines/screens/invoiceHistory.dart';
import 'package:jwines/screens/materialrequisition.dart';
import 'package:jwines/screens/materialrequisitionhistory.dart';
import 'package:jwines/screens/newpass.dart';
import 'package:jwines/screens/orderHistory.dart';
import 'package:jwines/screens/savedOrders.dart';
import 'package:jwines/screens/selectcompany.dart';
import 'package:jwines/screens/thermalPrinter.dart';
import 'package:jwines/utils/Config.dart' as Config;
import 'package:package_info/package_info.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:query_params/query_params.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stack/stack.dart' as prefix1;
import 'package:store_redirect/store_redirect.dart';

class MyHomePage extends StatefulWidget{
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with RouteAware{

  String _pdBal = 'Loading ... ', _custBal = 'Loading ... ',_creditLimit = 'Loading ... ',_availableCredit = 'Loading ... ',_fromDate = 'Loading ...',_toDate = 'Loading ...',_imgFromSettings,_versionFromServer;
  List<Widget> _actions;
  prefix1.Stack<Widget> _pageStack = prefix1.Stack();
  PackageInfo _packageInfo;
  Widget _body;
  int _buildNumberFromServer;
  bool _loggedIn = false, _loggingIn = false, _showPass= true,pressedOnce = false,_setUpPrint = false,_supDialogShown = false,_companySettingsDone,_updateDialogShown = false;
  final _userNameInput = new TextEditingController();
  final _passWordInput = new TextEditingController();
  printer.BlueThermalPrinter _btp = printer.BlueThermalPrinter.instance;
  FlutterBlue _flutterBlue = FlutterBlue.instance;
  BuildContext _context;
  User _loggedInUser;
  double _monthlyTotal = 0;
  final _homeScaffoldKey = GlobalKey<ScaffoldState>();
  final _loginFormKey = GlobalKey<FormState>();

  @override
  void initState(){
    _loadImageFromSettings();
    _readVersionFromServer();
    PackageInfo.fromPlatform().then((value){
      setState(() {
        _packageInfo = value;
      });
    });
    SessionPreferences().getCompanySettings().then((settings){
      if(settings != null && settings.baseUrl != null){
        setState(() {
          _companySettingsDone = true;
        });
      } else {
        setState(() {
          _companySettingsDone = false;
        });
      }
    });
    SessionPreferences().getLoggedInStatus().then((loggedIn){
      if(loggedIn != null){
        setState((){
          _loggedIn = loggedIn;
        });
        if(loggedIn){
          _listenBtPrinterChange();
          SessionPreferences().getLoggedInUser().then((user){
            _updateBalances(user.custid);
            _updateMonthlySale(user.custid);
            setState((){
              _loggedInUser = user;
              _custBal = NumberFormat.currency(symbol: '').format(user.balance);
              _pdBal = NumberFormat.currency(symbol: '').format(user.pdamount);
              _creditLimit = user.creditLimit > 0 ? NumberFormat.currency(symbol: '').format(user.creditLimit) : 0.toString();
              _availableCredit = user.availableCredit > 0 ? NumberFormat.currency(symbol: '').format(user.availableCredit) : 0.toString();
            });
          });
          _btp.isConnected.then((connected){
            if(!connected){
              setState((){
                _setUpPrint = true;
              });
            }
          });
        }
      } else {
        setState(() {
          _loggedIn = false;
        });
      }
    });
    super.initState();
  }

  _readVersionFromServer() async{
    String baseUrl = await Config.getBaseUrl();
    HttpClientResponse response = await Config.getRequestObject(baseUrl+'appVersion', Config.get);
    if(response != null){
      response.transform(utf8.decoder).listen((data) {
        var jsonResponse = json.decode(data);
        setState((){
          _versionFromServer = jsonResponse['versionName'];
          _buildNumberFromServer = jsonResponse['versionCode'];
        });
      });
    }
  }

  @override
  Widget build(BuildContext context){
    _context = context;
    String appVersion = _packageInfo != null ? _packageInfo.version : 'Loading ... ';
    if(_packageInfo != null && _buildNumberFromServer != null && !_updateDialogShown){
      int buildNumber = int.parse(_packageInfo.buildNumber);
      print('App Build Number: ----------> $buildNumber');
      if(buildNumber < _buildNumberFromServer){
        WidgetsBinding.instance.addPostFrameCallback((_){
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (bc){
              return WillPopScope(
                onWillPop: () async{
                  return false;
                },
                child: AlertDialog(
                  title: Text('Update Required !'),
                  content: Text('A new version of the app is available on Google play store. You need to update to the new version. Press Ok below to update'),
                  actions: [
                    FlatButton(onPressed: (){
                      Navigator.pop(bc);
                      exit(0);
                    }, child: Text('Cancel')),
                    FlatButton(onPressed: (){
                      Navigator.pop(bc);
                      StoreRedirect.redirect();
                      exit(0);
                    }, child: Text('Ok'))
                  ],
                ),
              );
            }
          );
        });
      }
      _updateDialogShown = true;
    }
    if(_companySettingsDone != null){
      if(_companySettingsDone){
        if (_loggedIn){
          if(_setUpPrint && !_supDialogShown){
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
            _supDialogShown = true;
          }
          return WillPopScope(
            onWillPop: () async{
              if(_homeScaffoldKey.currentState.isDrawerOpen){
                Navigator.of(context).pop();
                return false;
              }
              return true;
            },
            child: Scaffold(
              key: _homeScaffoldKey,
              appBar: AppBar(title: Text('Home'),actions: <Widget>[
                IconButton(icon: Icon(Icons.refresh), onPressed: (){
                  ProgressDialog dial = new ProgressDialog(context);
                  dial.style(message: 'Refreshing dashboard data');
                  dial.show();
                  _updateBalances(_loggedInUser.custid);
                  _updateMonthlySale(_loggedInUser.custid,progressDialog: dial);
                  print('----------------> CALLS MADE !!!!!!!!!!!');
                  dial.hide();
                })
              ]),
              drawer: MediaQuery.removePadding(
                context: context,
                removeTop: true,
                child: Drawer(
                  child: ListView(
                    children: <Widget>[
                      Container(
                        color: Colors.teal,
                        child: DrawerHeader(child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Expanded(child: Container(
                              padding: EdgeInsets.fromLTRB(20.0, 40.0, 20.0, 20.0),
                              decoration: BoxDecoration(color: Colors.white70,shape: BoxShape.circle,image: DecorationImage(image: AssetImage('images/person2.png'),fit: BoxFit.contain)),
                            )),
                            Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: Text(_loggedInUser.fullName),
                            ),
                            Padding(
                              padding: EdgeInsets.all(10.0),
                              child: Text('App version: $appVersion'),
                            )
                          ],
                        )),
                      ),
                      ListTile(
                        leading: Icon(Icons.print),
                        title: Text('Thermal Printer'),
                        onTap: (){
                          Navigator.of(context).pop();
                          Navigator.push(_context, MaterialPageRoute(builder: (ctx)=> ThermalPrinter()));
                        },
                      ),
                      ListTile(
                        leading: Icon(Icons.list),
                        title: Text('Material requisition'),
                        onTap: (){
                          Navigator.of(context).pop();
                          Navigator.push(_context, MaterialPageRoute(builder: (ctx)=> MaterialRequisition()));
                        },
                      ),
                      ListTile(
                        leading: Icon(Icons.lock),
                        title: Text('Change Password'),
                        onTap: (){
                          Navigator.of(context).pop();
                          Navigator.push(_context, MaterialPageRoute(builder: (ctx)=> NewPass(Config.changePass)));
                        },
                      ),
//                      ListTile(
//                        leading: Icon(Icons.business),
//                        title: Text('Change Company'),
//                        onTap: (){
//                          Navigator.of(context).pop();
//                          showDialog(context: _context,builder: (ctx){
//                            return AlertDialog(
//                              title: Text('Log out?'),
//                              content: Text('Are you sure you want to change from this company?'),
//                              actions: <Widget>[
//                                FlatButton(child: Text('No'),onPressed: (){
//                                  Navigator.pop(ctx);
//                                }),
//                                FlatButton(onPressed: (){
//                                  Navigator.pop(ctx);
//                                  setState(() {
//                                    SessionPreferences().setLoggedInStatus(false);
//                                    _loggedIn = false;
//                                    _companySettingsDone = false;
//                                  });
//                                }, child: Text('Yes'))
//                              ],
//                            );
//                          });
//                        },
//                      ),
                      ListTile(
                        leading: Icon(Icons.save),
                        title: Text('Saved Orders'),
                        onTap: (){
                          Navigator.pop(context);
                          Navigator.push(context, MaterialPageRoute(builder: (bc){
                            return SavedOrders();
                          }));
                        },
                      ),
                      ListTile(
                        leading: Icon(Icons.exit_to_app),
                        title: Text('Log Out'),
                        onTap: (){
                          Navigator.of(context).pop();
                          showDialog(context: _context,builder: (ctx){
                            return AlertDialog(
                              title: Text('Log out?'),
                              content: Text('Are you sure you want to log out?'),
                              actions: <Widget>[
                                FlatButton(child: Text('No'),onPressed: (){
                                  Navigator.pop(ctx);
                                }),
                                FlatButton(onPressed: (){
                                  Navigator.pop(ctx);
                                  setState(() {
                                    SessionPreferences().setLoggedInStatus(false);
                                    _loggedIn = false;
                                  });
                                }, child: Text('Yes'))
                              ],
                            );
                          });
                        },
                      )
                    ],
                  ),
                ),
              ),
              body: Container(
                color: Colors.blueGrey,
                child: ListView(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: SizedBox(
                        height: 150,
                        child: Row(
                          children: <Widget>[
                            Expanded(
                              child: GestureDetector(
                                onTap: (){
                                  Navigator.push(_context, MaterialPageRoute(builder: (bc) => ShowCustomers()));
                                },
                                child: Card(child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: <Widget>[
                                    Expanded(child: Image(image: AssetImage('images/order.png'))),
                                    Padding(
                                      padding: const EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 10.0),
                                      child: Text('Sales Order'),
                                    )
                                  ],
                                ),elevation: 20.0,shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0))),
                              ),
                            ),
                            Expanded(
                              child: GestureDetector(
                                  onTap: (){
                                    Navigator.push(_context, MaterialPageRoute(builder: (ctx)=> InventoryItems(Config.invoice)));
                                  },
                                  child: Card(child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: <Widget>[
                                      Expanded(child: Image(image: AssetImage('images/invoice.png'),color: Colors.teal)),
                                      Padding(
                                        padding: const EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 10.0),
                                        child: Text('Invoice',style: TextStyle(fontSize: 20.0,color: Colors.teal)),
                                      )
                                    ],
                                  ),elevation: 20.0,shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)))
                              ),
                            ),
                            Expanded(
                              child: GestureDetector(
                                  onTap: (){
                                    Navigator.push(_context, MaterialPageRoute(builder: (ctx)=> MaterialRequisition()));
                                  },
                                  child: Card(child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: <Widget>[
                                      Expanded(child: Image(image: AssetImage('images/materialreq.png'),color: Colors.teal)),
                                      Padding(
                                        padding: const EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 10.0),
                                        child: Text('Material Req',style: TextStyle(fontSize: 13.0,color: Colors.teal)),
                                      )
                                    ],
                                  ),elevation: 20.0,shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)))
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                    Row(
                      children: <Widget>[
                        Expanded(child: Padding(
                          padding: const EdgeInsets.fromLTRB(10.0, 0.0, 10.0, 0.0),
                          child: Card(
                            elevation: 20.0,
                            child: Container(
                              padding: EdgeInsets.all(5),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text('Your Current Balance: \n$_custBal',style: TextStyle(fontStyle: FontStyle.italic)),
                                  Divider(),
                                  Text('Pd Cheque Balance : \n$_pdBal'),
                                  Divider(),
                                  Text('Your available credit: \n$_availableCredit'),
                                  Divider(),
                                  Text('Your credit limit : \n$_creditLimit'),
                                ],
                              ),
                            ),
                          ),
                        ))
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10.0),
                      child: Row(
                        children: <Widget>[
                          Expanded(child: Padding(
                            padding: const EdgeInsets.fromLTRB(10.0, 0.0, 10.0, 0.0),
                            child: Card(
                              elevation: 20.0,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                                  ListTile(
                                    title: Text('Monthly Sale: From $_fromDate'),
                                    subtitle: Text(NumberFormat.currency(symbol: '').format(_monthlyTotal)),
                                  ),
                                  ListTile(
                                    title: Text('Sales Invoice history'),
                                    subtitle: Text('Tap to view'),
                                    onTap: (){
                                      Navigator.push(_context, MaterialPageRoute(builder: (ctx){
                                        return InvoiceHistoryList();
                                      }));
                                    },
                                  ),
                                  ListTile(
                                    title: Text('Sales Order history'),
                                    subtitle: Text('Tap to view'),
                                    onTap: (){
                                      Navigator.push(_context, MaterialPageRoute(builder: (ctx){
                                        return OrderHistoryList();
                                      }));
                                    },
                                  ),
                                  ListTile(
                                    title: Text('Material Requisition History'),
                                    subtitle: Text('Tap to view'),
                                    onTap: (){
                                      Navigator.push(_context, MaterialPageRoute(builder: (ctx){
                                        return MaterialReqHistory();
                                      }));
                                    },
                                  )
                                ],
                              ),
                            ),
                          ))
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
          );
        }
        return Scaffold(
          body: Container(
            color: Colors.white70,
            child: Center(
              child: ListView(
                shrinkWrap: true,
                children: <Widget>[
                  Padding(
//                    child: Image(image: new AssetImage("images/depar.png"),width: 500,height: 200),
                    padding: const EdgeInsets.symmetric(vertical: 10.0),
                    child: _imgFromSettings == null ? Text('Loading Logo image ... ') : Image(image: new AssetImage("images/$_imgFromSettings"),width: 500,height: 200),
                  ),
                  FractionallySizedBox(
                    widthFactor: 0.8,
                    child: Card(
                      elevation: 20,
                      child: Form(
                        key: _loginFormKey,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text('Sales Rep Login',style: TextStyle(color: Colors.teal)),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: TextFormField(
                                controller: _userNameInput,
                                validator: (input){
                                  if(input.isEmpty){
                                    return 'Enter username';
                                  }
                                  return null;
                                },
                                decoration: InputDecoration(
                                    border: OutlineInputBorder(
                                        borderSide: BorderSide()
                                    ),
                                    labelText: 'Enter your username'
                                ),
                              ),
                            ),
                            Padding(
                                padding: const EdgeInsets.all(10.0),
                                child: TextFormField(
                                  controller: _passWordInput,
                                  validator: (input){
                                    if(input.isEmpty){
                                      return 'Enter password';
                                    }
                                    return null;
                                  },
                                  decoration: InputDecoration(
                                      border: OutlineInputBorder(
                                          borderSide: BorderSide()
                                      ),
                                      labelText: 'Enter your password',
                                      suffixIcon: IconButton(icon: _showPass ? Icon(Icons.visibility_off) : Icon(Icons.visibility), onPressed: (){
                                        setState(() {
                                          _showPass ^= true;
                                        });
                                      })
                                  ),
                                  obscureText: _showPass,
                                )
                            ),
                            FlatButton(onPressed: (){
                              Navigator.push(_context, MaterialPageRoute(builder: (ctx)=> CheckUser()));
                            }, child: Text('Forgot Password',style: TextStyle(color: Colors.blue))),
                            FlatButton(onPressed: (){
                              setState(() {
                                _companySettingsDone = false;
                              });
                            }, child: Text('Change Company',style: TextStyle(color: Colors.blue)))
                          ],
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(10.0, 20.0, 10.0, 0.0),
                    child: ButtonTheme(
                      height: 50,
                      child: CupertinoButton(onPressed: () async{
                        if(_loginFormKey.currentState.validate()){
                          setState(() {
                            _loggingIn = true;
                          });
                          String username = _userNameInput.text.trim();
                          String password = _passWordInput.text.trim();
                          var bytes = utf8.encode(password);
                          String encodedPassword = base64.encode(bytes);
                          HttpClient httpClient = new HttpClient();
                          httpClient.badCertificateCallback = (X509Certificate cert,String host,int port) => true;
                          URLQueryParams urqp = new URLQueryParams();
                          urqp.append('username', username);
                          urqp.append('password', encodedPassword);
                          String url = await Config.getBaseUrl();
                          Uri uri = Uri.parse(url+'mobileuser/login?'+urqp.toString());
                          print(uri);
                          HttpClientRequest request = await httpClient.getUrl(uri);
                          HttpClientResponse response;
                          String result;
                          try{
                            response = await request.close();
                          } on SocketException {
                            Fluttertoast.showToast(msg: 'You may be offline. Check your connection');
                          } on HandshakeException{
                            Fluttertoast.showToast(msg: 'Handshake exception occured');
                          }
                          if (response != null){
                            setState(() {
                              _loggingIn = false;
                            });
                            int statusCode = response.statusCode;
                            print('status code: $statusCode');
                            if(statusCode == 200){
                              response.transform(utf8.decoder).listen((contents){
                                print(contents);
                                if (contents != null){
                                  User user = User.fromJson(json.decode(contents));
                                  if (user.id > 0){
                                    if (user.active){
                                      if(user.hrid > 0){
                                        if(user.custid > 0){
                                          SessionPreferences().setLoggedInUser(user);
                                          SessionPreferences().setLoggedInStatus(true);
                                          _updateMonthlySale(user.custid);
                                          setState(() {
                                            _loggedIn = true;
                                            _loggedInUser = user;
                                            _custBal = NumberFormat.currency(symbol: '').format(user.balance);
                                            _pdBal = NumberFormat.currency(symbol: '').format(user.pdamount);
                                            _availableCredit = user.availableCredit > 0 ? NumberFormat.currency(symbol: '').format(user.availableCredit) : 0.toString();
                                            _creditLimit = NumberFormat.currency(symbol: '').format(user.creditLimit);
                                          });
                                          _listenBtPrinterChange();
                                          String username = user.userName;
                                          Fluttertoast.showToast(msg: 'Welcome $username');
                                          _btp.isConnected.then((connected){
                                            if(!connected){
                                              setState(() {
                                                _setUpPrint = true;
                                              });
                                            }
                                          });
                                        } else {
                                          showDialog(context: _context,builder: (BuildContext bc){
                                            return CupertinoAlertDialog(
                                              title: Text('Account Action Needed'),
                                              content: Text('Your user account is not attached to any Customer account. Please contact the administrator with this information'),
                                              actions: <Widget>[
                                                FlatButton(onPressed: (){
                                                  Navigator.pop(bc);
                                                }, child: Text('Ok'))
                                              ],
                                            );
                                          });
                                        }
                                      } else {
                                        showDialog(context: _context,builder: (BuildContext bc){
                                          return CupertinoAlertDialog(
                                            title: Text('Account Action Needed'),
                                            content: Text('Your user account is not attached to any Hr_Employee account. Please contact the administrator with this information'),
                                            actions: <Widget>[
                                              FlatButton(onPressed: (){
                                                Navigator.pop(bc);
                                              }, child: Text('Ok'))
                                            ],
                                          );
                                        });
                                      }
                                    } else {
                                      showDialog(context: _context,builder: (BuildContext bc){
                                        return CupertinoAlertDialog(
                                          title: Text('Account Action Needed'),
                                          content: Text('Am afraid your user account is inactive or has been de-activated. Contact the administrator'),
                                          actions: <Widget>[
                                            FlatButton(onPressed: (){
                                              Navigator.pop(bc);
                                            }, child: Text('Ok'))
                                          ],
                                        );
                                      });
                                    }
                                  } else if(user.id < 0){
                                    Fluttertoast.showToast(msg: 'The password you entered is incorrect',toastLength: Toast.LENGTH_LONG);
                                  } else {
                                    Fluttertoast.showToast(msg: 'User not found',toastLength: Toast.LENGTH_LONG);
                                  }
                                }
                              });
                            } else {
                              Fluttertoast.showToast(msg: 'Error $statusCode Occured');
                            }
                          } else {
                            setState(() {
                              _loggingIn = false;
                            });
                            Fluttertoast.showToast(msg: 'No response from the server');
                          }
                        }
                      },child: _loggingIn? Container(child: CircularProgressIndicator(backgroundColor: Colors.white),height: 20,width: 20) : Text('Login',style: TextStyle(color: Colors.white),), color: Colors.blueGrey),
                    ),
                  )
                ],
              ),
            ),
          ),
        );
      } else {
        return ChooseCompany((imgName){
          setState(() {
            _imgFromSettings = imgName;
            _companySettingsDone = true;
          });
        });
      }
    } else {
      return Scaffold(
        appBar: AppBar(title: Text('Load Company Settings')),
        body: Center(
          child: Text('Loading your settings. Please wait ... '),
        ),
      );
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    routeObserver.subscribe(this, ModalRoute.of(context));
  }

  void updateStatus(bool status) async{
    SharedPreferences shp = await SharedPreferences.getInstance();
    shp.setBool("orderdone", status);
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  void didPopNext() {
    _checkPosted();
    _checkFromFgPass();
  }

  void _updateBalances(int id,{ProgressDialog progressDialog}) async{
    String url = await Config.getBaseUrl();
    HttpClientResponse response = await Config.getRequestObject(url+'customer/customerById/$id', Config.get,dialog: progressDialog);
    if(response != null){
      response.transform(utf8.decoder).listen((data){
        Customer cust = Customer.fromJson(json.decode(data));
        double bal = cust.balance;
        double acL = cust.availcreditlimit;
        double cdL = cust.creditlimit;
        double pdBal = cust.pdamount;
        _loggedInUser.balance = bal;
        _loggedInUser.pdamount = pdBal;
        _loggedInUser.availableCredit = acL;
        _loggedInUser.creditLimit = cdL;
        SessionPreferences().setLoggedInUser(_loggedInUser);
        setState(() {
          _custBal = NumberFormat.currency(symbol: '').format(bal);
          _pdBal = NumberFormat.currency(symbol: '').format(pdBal);
          _availableCredit =acL > 0 ? NumberFormat.currency(symbol: '').format(acL) : 0.toString();
          _creditLimit = NumberFormat.currency(symbol: '').format(cdL);
        });
      });
    }
  }

  void _checkPosted() async{
    SharedPreferences shp = await SharedPreferences.getInstance();
    bool posted = shp.getBool("orderdone");
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
  }

  void _listenBtPrinterChange(){
    _btp.onStateChanged().listen((state){
      switch (state){
        case printer.BlueThermalPrinter.DISCONNECTED : {Fluttertoast.showToast(msg: 'Your printing device connection has been terminated',toastLength: Toast.LENGTH_LONG); break;}
        case printer.BlueThermalPrinter.CONNECTED : {Fluttertoast.showToast(msg: 'Your printing device has been Connected');break;}
      }
    });
  }

  void _updateMonthlySale(int custid,{ProgressDialog progressDialog}) async{
    String url = await Config.getBaseUrl();
    HttpClientResponse response = await Config.getRequestObject(url+'salesinvoice/monthlyfigure/$custid', Config.get,dialog: progressDialog);
    if(response != null){
      response.transform(utf8.decoder).listen((data){
        var jsonResponse = json.decode(data);
        MonthlySale monthlySale = MonthlySale.fromJson(jsonResponse);
        setState(() {
          _fromDate = monthlySale.fromDate;
          _toDate = monthlySale.toDate;
          _monthlyTotal = monthlySale.totalSale;
        });
      });
    }
  }

  void _checkFromFgPass() async{
    SharedPreferences sp = await SharedPreferences.getInstance();
    bool fromFgPass = sp.getBool('fromFgPass');
    if(fromFgPass != null && !fromFgPass){
      _updateBalances(_loggedInUser.custid);
      _updateMonthlySale(_loggedInUser.custid);
    }
  }

  void _loadImageFromSettings() async{
    CompanySettings settings = await SessionPreferences().getCompanySettings();
    setState(() {
      _imgFromSettings = settings.imageName;
    });
  }
}