import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:jwines/database/sessionpreferences.dart';
import 'package:jwines/models/usermodels.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';


final String localUrl = 'https://192.168.43.89:8181/AnchorERP/fused/api/';
final String qaUrl = 'https://erpqa.netrixbiz.com/AnchorERP/fused/api/';
final String jwinesUrl = 'https://erp.jwines.co.ke/AnchorERP/fused/api/';
final String shobolUrl = 'https://shobolerp.jwines.co.ke/AnchorERP/fused/api/';
final String expressoUrl = 'https://expressoerp.jwines.co.ke/AnchorERP/fused/api/';
final String COMPANY_SETTINGS = 'COMPANY_SETTINGS';
final String get = 'GET';
final String post = 'POST';
final String put = 'PUT';
final String materialRequisition = 'materialRequisition';
final String salesOrder = 'salesOrder';
final String invoice = 'invoice';
final String changePass = 'changePass';
final String forgotPass = 'forgotPass';
final String tbSalesOrder = 'tbSalesOrder';
final String tbOrderDetail = 'tbOrderDetail';
final String invCode = 'invCode';
final String invDescrip = 'invDescrip';
final String invQty = 'invQty';
final String itemPrice = 'itemPrice';
final String itemQty = 'itemQty';
final String id = 'id';
final String originalPrice = 'originalPrice';
final String invDiscount = 'invDiscount';
final String invPrice = 'invPrice';
final String custid = 'custid';
final String custname = 'custname';
final String dbPath = 'jwines_db.db';
final String orderid = 'orderid';
final String orderdocno = 'orderdocno';
final String orderdate = 'orderdate';
final String ordervalidity = 'ordervalidity';

Future<String> getBaseUrl() async{
  CompanySettings settings = await SessionPreferences().getCompanySettings();
  return settings.baseUrl;
}

Future<String> readResponse(HttpClientResponse response){
  var completer = new Completer();
  var contents = new StringBuffer();
  response.transform(utf8.decoder).listen((data){
    contents.write(data);
  }, onDone: () => completer.complete(contents.toString()));
  return completer.future;
}

Future<http.Response> getSimpleRequestObject(String url,String requestMethod,{String body,ProgressDialog dialog}) async{
  http.Response response;
  Uri uri = Uri.parse(url);
  print(uri);
  if(requestMethod == get){
    response = await http.get(url);
  } else if (requestMethod == post){
    if(body != null){
      response = await http.post(url,body: body);
    } else {
      response = await http.post(url);
    }
  }
  if(response != null){
    int statusCode = response.statusCode;
    if(statusCode == 200){
      return response;
    } else {
      Fluttertoast.showToast(msg: "Error $statusCode occurred");
    }
  } else {
    Fluttertoast.showToast(msg: 'There was no response from the server');
  }
  return null;
}

Future<HttpClientResponse> getRequestObject(String url,String requestMethod,{String body,ProgressDialog dialog}) async{
  HttpClient httpClient = new HttpClient();
  httpClient.badCertificateCallback = (X509Certificate cert,String host,int port) => true;
  Uri uri = Uri.parse(url);
  print(uri);
  HttpClientRequest request;
  if(requestMethod == get){
    request = await httpClient.getUrl(uri);
  } else if(requestMethod == post){
    request = await httpClient.postUrl(uri);
    if(body != null){
      request.headers.set('content-type', 'application/json');
      request.add(utf8.encode(body));
      print(request.toString());
    }
  } else if(requestMethod == put){
    request = await httpClient.putUrl(uri);
    if(body != null){
      request.headers.set('content-type', 'application/json');
      request.add(utf8.encode(body));
    }
  }
  HttpClientResponse response;
  try{
    response = await request.close();
    if(dialog != null && dialog.isShowing()){
      dialog.hide();
    }
  } catch (e){
    if(dialog != null && dialog.isShowing()){
      dialog.hide();
    }
    Fluttertoast.showToast(msg: 'Exception caught on mobile');
    print(e);
  }
  if (response != null){
    int statusCode = response.statusCode;
    if(statusCode == 200){
      return response;
    } else {
      if(dialog != null && dialog.isShowing()){
        dialog.hide();
      }
      Fluttertoast.showToast(msg: 'Error $statusCode occurred');
    }
  } else {
    if(dialog != null && dialog.isShowing()){
      dialog.hide();
    }
    Fluttertoast.showToast(msg: 'There was no response from the server');
  }
  return null;
}