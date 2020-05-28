import 'package:encounters/Screens/Signing/WelcomePage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'Providers/AuthServices/AuthProvider.dart';
import 'Providers/AuthServices/AuthService.dart';
import 'App.dart';
import 'GlobalVariables.dart' as global;
import 'Screens/Utils/LoadingScreen.dart';

void main() => runApp(Encounters());

class Encounters extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AuthProvider(
      auth: Auth(),
      child: EncountersApp(),
    );
  }
}

class EncountersApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final auth = AuthProvider.of(context);
    return StreamBuilder<User>(
      stream: auth.onAuthStateChanged,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.active ||
            snapshot.connectionState == ConnectionState.done) {
          if (snapshot.hasData && snapshot.data != null) {
            return App(uid: snapshot.data.uid);
          } else {
            return MaterialApp(
              home: WelcomePage(),
              title: "Encounters",
              theme: ThemeData(
                primaryColor: global.primaryThemeColor,
              ),
            );
          }
        }
        return LoadingScreen();
      },
    );
  }
}
