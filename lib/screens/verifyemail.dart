import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:jwines/database/sessionpreferences.dart';
import 'package:jwines/screens/newpass.dart';
import 'package:jwines/utils/Config.dart';
import 'package:query_params/query_params.dart';

// ignore: must_be_immutable
class VerifyEmail extends StatefulWidget {

  BuildContext context;
  VerifyEmail(this.context);

  @override
  _VerifyEmailState createState() => _VerifyEmailState();
}

class _VerifyEmailState extends State<VerifyEmail> {

  String _verificationCode;
  BuildContext _context;
  TextEditingController _codeController = new TextEditingController();
  GlobalKey<FormState> _codeInput = new GlobalKey();


  @override
  void initState() {
    SessionPreferences().getLoggedInUser().then((user){
      _getCode(user.email);
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white70,
      padding: EdgeInsets.all(10.0),
      child: _body(),
    );
  }

  _getCode(String email) async{
    URLQueryParams queryParams = new URLQueryParams();
    queryParams.append('email', email);
    String url = await getBaseUrl();
    HttpClientResponse response = await getRequestObject(url+'mobileuser/getCode?email=$email', get);
    if(response != null){
      response.transform(utf8.decoder).listen((data){
        setState(() {
          _verificationCode = data;
        });
      });
    }
  }

  _body() {
    if(_verificationCode != null){
      return Form(
        key: _codeInput,
        child: ListView(
          children: <Widget>[
            Padding(padding: EdgeInsets.symmetric(vertical: 10),child: Text('A verification code has been sent to your email address. Enter the code here and press continue to finish changing your password',style: TextStyle(fontSize: 18,color: Colors.teal))),
            Padding(padding: EdgeInsets.symmetric(vertical: 10.0),child:TextFormField(
              controller: _codeController,
              validator: (value){
                if(value.isEmpty){
                  return 'Enter the code sent to email';
                } else {
                  if(_verificationCode == value){
                    return null;
                  } else {
                    return 'Wrong code';
                  }
                }
              },
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderSide: BorderSide()
                ),
                labelText: 'Enter the code'
              ),
              keyboardType: TextInputType.number,
            )),
            Padding(padding: EdgeInsets.symmetric(vertical: 10.0),child: CupertinoButton(color: Colors.blueGrey,child: Text('Continue'), onPressed: (){
              if(_codeInput.currentState.validate()){
                Navigator.push(widget.context, MaterialPageRoute(builder: (ctx){
                  return NewPass(forgotPass);
                }));
              }
            }))
          ],
        ),
      );
    }
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        CircularProgressIndicator(),
        Text('Getting verification code')
      ],
    );
  }

}
