import 'dart:async';

import 'package:flutter/material.dart';
import 'package:jwines/screens/home.dart';
import 'package:sentry/io_client.dart';

final sentry = SentryClient(dsn: "http://d91f1691603e46568bad9e872911cbb7@207.154.215.74:9000/3");

void main() {
  runZonedGuarded(() => runApp(MyApp()), (err,stk) async{
    await sentry.captureException(exception: err,stackTrace: stk);
  });
}

final RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();

class MyApp extends StatelessWidget{
  // This widget is the root of your application.

  @override
  Widget build(BuildContext context){
    return MaterialApp(
      title: 'Flutter Demo',
      navigatorObservers: [routeObserver],
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blueGrey,
      ),
      home: MyHomePage(),
    );
  }
}