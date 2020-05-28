import 'package:flutter/material.dart';
import '../../GlobalVariables.dart' as global;
import '../../Languages/Languages.dart';

class LoadingScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primaryColor: global.primaryThemeColor,
      ),
      home: Scaffold(
        body: Container(
          decoration: global.appBackground,
          child: SafeArea(
            child: Container(
              width: double.infinity,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  CircularProgressIndicator(
                    backgroundColor: Colors.white,
                  ),
                  const SizedBox(height: 10.0),
                  Text(
                    Languages.dictionary[global.countryCode]['loading'],
                    style: global.styleText,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
