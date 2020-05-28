library my_prj.globals;

import 'package:flutter/material.dart';

final Color secondThemeColor = Colors.blue[300];

final Color primaryThemeColor = Colors.orange[300];

final TextStyle styleText = TextStyle(fontFamily: 'Montserrat', fontSize: 20.0);

final appBarBackgroundColor = Colors.orange[200];

final countryCode = 'en';

String userId;
int initialTab;

BoxDecoration appBackground = BoxDecoration(
  gradient: LinearGradient(
    begin: Alignment.topRight,
    end: Alignment.bottomLeft,
    colors: [Colors.orange[100], Colors.blue[100]],
  ),
);
