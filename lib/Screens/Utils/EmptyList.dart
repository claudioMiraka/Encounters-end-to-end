import 'package:flutter/cupertino.dart';

class EmptyList extends StatelessWidget{

  final String message;

  EmptyList({@required this.message, Key key}):super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(child: Text(this.message),);
  }
}