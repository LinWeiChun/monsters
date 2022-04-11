import 'package:flutter/material.dart';
import 'package:monsters_front_end/pages/home.dart';
import 'package:monsters_front_end/pages/login.dart';
import 'package:monsters_front_end/routes.dart';

void main() {
  runApp(Monsters());
}

// ignore: use_key_in_widget_constructors
class Monsters extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '貘nsters',
      theme: ThemeData(
        primarySwatch: Colors.blueGrey,
      ),
      routes: {
        GitmeRebornRoutes.login: (context) => LoginPage(),
        GitmeRebornRoutes.home:(context) => MainPage(),
      },
      onGenerateRoute: (settings){
        switch (settings.name) {
          case GitmeRebornRoutes.root:
            return MaterialPageRoute(builder: (context) => LoginPage());
          default:
            return MaterialPageRoute(builder: (context) => LoginPage());
        }
      },
      debugShowCheckedModeBanner: false,  
    );
  }
}
