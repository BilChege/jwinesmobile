import 'dart:collection';
import 'dart:convert';

import 'package:app_settings/app_settings.dart';
import 'package:blue_thermal_printer/blue_thermal_printer.dart' as printer;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart';
import 'package:jwines/database/sessionpreferences.dart';
import 'package:progress_dialog/progress_dialog.dart';

class ThermalPrinter extends StatefulWidget {
  @override
  _ThermalPrinterState createState() => _ThermalPrinterState();
}

class _ThermalPrinterState extends State<ThermalPrinter> with WidgetsBindingObserver{

  printer.BlueThermalPrinter _btp = printer.BlueThermalPrinter.instance;
  FlutterBlue _flutterBlue = FlutterBlue.instance;
  BuildContext _context;
  List<printer.BluetoothDevice> _devices = new List();
  printer.BluetoothDevice _savedDevice;
  bool _promptBt = false,_connected = false;
  String _message = 'No devices found yet. Loading ... ';

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    _flutterBlue.isOn.then((isOn){
      if(!isOn){
        AppSettings.openBluetoothSettings();
      } else {
        _printerListen();
      }
    });
    _btStateListen();
    super.initState();
  }

  bool contains(Iterable<BluetoothDevice> devices,BluetoothDevice device){
    return devices.contains(device);
  }


  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if(state == AppLifecycleState.resumed){
      _flutterBlue.isOn.then((isOn){
        if(isOn){
          _printerListen();
          _btStateListen();
        } else {
          showDialog(context: _context,builder: (bc){
            return AlertDialog(
              title: Text('Bluetooth has not been turned on'),
              content: Text('You need to turn on bluetooth to connect to your bluetooth printer'),
              actions: <Widget>[
                FlatButton(onPressed: (){
                  Navigator.pop(bc);
                }, child: Text('Ok'))
              ],
            );
          });
          _btStateListen();
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    _context = context;
    return Scaffold(
      appBar: AppBar(title: Text('Set up printer')),
        body: Container(
          child: _body()
        ));
  }

  _body() {
    if(_devices.isNotEmpty){
      String name = '',address = '';
      if (_savedDevice != null){
        name = _savedDevice.name;
        address = _savedDevice.address;
      }
      return Column(
        children: <Widget>[
          Visibility(
            visible: _savedDevice != null,
            child: Padding(padding: EdgeInsets.all(8.0),child: Card(
              child: Container(padding: EdgeInsets.all(10.0),child: Text('Saved device Name : $name \n Saved device Address: $address')),
            )),
          ),
          Expanded(
            child: ListView.builder(itemBuilder: (ctx,i){
              printer.BluetoothDevice device = _devices.elementAt(i);
              String deviceName = device.name;
              String address = device.address;
              return ListTile(
                title: Text(deviceName),
                subtitle: Text(address),
                trailing: RaisedButton(onPressed: (){
                  ProgressDialog d = new ProgressDialog(_context);
                  d.style(message: 'Connecting ... ');
                  d.show();
                  _btp.connect(device).then((val){
                    d.hide();
                    if(val != null){
                      bool connected = val as bool;
                      if(connected){
                        Navigator.pop(_context);
                      }
                    }
                  }).timeout(Duration(seconds: 40),onTimeout: (){
                    d.hide();
                    Fluttertoast.showToast(msg: 'Connection attempt timed out!');
                  }).catchError((e){
                    d.hide();
                    Fluttertoast.showToast(msg: 'An error occurred while trying to connect');
                    print(e);
                  });
                },child: Text('Connect')),
              );
            },itemCount: _devices.length),
          ),
        ],
      );
    }
    return Center(
      child: Text(_message),
//          child: StreamBuilder<List<bt_printer.BluetoothDevice>>(stream: _printer.scanResults,initialData: [],builder: (c,snapshot){
//            return ListView(
//              children: snapshot.data.map((device){
//                String name = device.name;
//                String address = device.address;
//                return ListTile(
//                  title: Text(name),
//                  subtitle: Text(address),
//                  trailing: RaisedButton(onPressed: (){
//                    Fluttertoast.showToast(msg: 'Device has been saved');
//                    SessionPreferences().setUpPrint(json.encode(device));
//                    Navigator.pop(context);
//                  },child: Text('Save')),
//                );
//              }).toList(),
//            );
//          })
    );
  }

  @override
  void dispose(){
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  void _printerListen() {
    _btp.getBondedDevices().then((devices){
      print('Devices found: $devices');
      if(devices != null && devices.isNotEmpty){
        setState(() {
          _devices = devices;
        });
      } else {
        setState(() {
          _message = 'There were no bluetooth paired devices found';
        });
      }
    });
  }

  void _btStateListen() {
    _flutterBlue.state.listen((state){
      if(state == BluetoothState.on){
        _printerListen();
      } else if(state == BluetoothState.off){
        setState(() {
          _devices.clear();
          _message = 'Bluetooth has been turned off';
        });
      }
    });
  }

}
