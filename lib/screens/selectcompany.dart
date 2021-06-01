import 'package:flutter/material.dart';
import 'package:jwines/database/sessionpreferences.dart';
import 'package:jwines/models/usermodels.dart';
import 'package:jwines/utils/Config.dart';

// ignore: must_be_immutable
class ChooseCompany extends StatefulWidget {

  void Function(String) companySelected;
  ChooseCompany(this.companySelected);

  @override
  _ChooseCompanyState createState() => _ChooseCompanyState();
}

class _ChooseCompanyState extends State<ChooseCompany> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Select your current Company')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: ListView(
          children: <Widget>[
            Card(
              elevation: 20,
              child: ListTile(
                onTap: (){
                  String imgName = 'jwines.png';
                  SessionPreferences().setCompanySettings(CompanySettings(
                      baseUrl: jwinesUrl,
                      imageName: imgName
                  )).then((value){
                    widget.companySelected(imgName);
                  });
                },leading: Image(image: AssetImage('images/jwines.png')),
                title: Text('JWines'),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Card(
                elevation: 20,
                child: ListTile(
                  onTap: (){
                    String imgName = 'shoboh.jpg';
                    SessionPreferences().setCompanySettings(CompanySettings(
                        baseUrl: shobolUrl,
                        imageName: imgName
                    )).then((value){
                      widget.companySelected(imgName);
                    });
                  },leading: Image(image: AssetImage('images/shoboh.jpg')),
                  title: Text('Shoboh'),
                ),
              ),
            ),
            Card(
              elevation: 20,
              child: ListTile(
                onTap: (){
                  String imgName = 'expresso.jpg';
                  SessionPreferences().setCompanySettings(CompanySettings(
                      baseUrl: expressoUrl,
                      imageName: imgName
                  )).then((value){
                    widget.companySelected(imgName);
                  });
                },
                leading: Image(image: AssetImage('images/expresso.jpg')),
                title: Text('Expresso'),
              ),
            )
          ],
        ),
      ),
    );
  }
}