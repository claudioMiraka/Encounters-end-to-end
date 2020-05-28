import 'AuthService.dart';
import 'package:flutter/material.dart';

class AuthProvider extends InheritedWidget {
  AuthProvider({@required this.auth, @required this.child});

  final AuthBase auth;
  final Widget child;

  @override
  bool updateShouldNotify(InheritedWidget oldWidget) => oldWidget.child!=child;

  static AuthBase of(BuildContext context) {
    AuthProvider provider =
        context.dependOnInheritedWidgetOfExactType(aspect: AuthProvider);
    return provider.auth;
  }
}
