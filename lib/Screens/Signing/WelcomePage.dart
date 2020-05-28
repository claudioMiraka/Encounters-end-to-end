import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../Utils/CustomSnackbar.dart';
import '../../GlobalVariables.dart' as global;
import '../../Providers/AuthServices/AuthProvider.dart';
import '../../Languages/Languages.dart';

class WelcomePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _WelcomePage();
}

class _WelcomePage extends State<WelcomePage> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  TextEditingController usernameController;
  bool isLoading = false;

  @override
  void initState() {
    usernameController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    usernameController.dispose();
    super.dispose();
  }

  void validateForm() async {
    final form = formKey.currentState;
    if (!isLoading) {
      setState(() {
        isLoading = true;
      });
      if (form.validate()) {
        SystemChannels.textInput.invokeMethod('TextInput.hide');
        String errorMessage =
            await AuthProvider.of(context).signUp(usernameController.text);
        if (errorMessage != null)
          CustomSnackbar(
                  message: Languages.dictionary[global.countryCode]['error'],
                  context: context)
              .show();
      }
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: global.appBackground,
        child: Theme(
          data: ThemeData(
            primaryColor: global.secondThemeColor,
          ),
          child: Center(
            child: ListView(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(40.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      SizedBox(
                        height: 200.0,
                        child: Image.asset(
                          "assets/winkLogo.png",
                          fit: BoxFit.contain,
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(40.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        Languages.dictionary[global.countryCode]['welcome']
                            ['title'],
                        style: global.styleText,
                      ),
                      Text(
                        Languages.dictionary[global.countryCode]['welcome']
                            ['description'],
                        style: global.styleText.copyWith(fontSize: 15),
                      ),
                    ],
                  ),
                ),
                Form(
                  key: formKey,
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: TextFormField(
                          obscureText: false,
                          controller: usernameController,
                          validator: (val) {
                            if (usernameController.text.length < 5)
                              return Languages.dictionary[global.countryCode]
                                  ['welcome']['username_too_short'];
                            if (usernameController.text.length > 50)
                              return Languages.dictionary[global.countryCode]
                                  ['welcome']['username_too_long'];
                            return null;
                          },
                          style: global.styleText,
                          maxLines: 1,
                          keyboardType: TextInputType.emailAddress,
                          autofocus: false,
                          decoration: InputDecoration(
                              contentPadding:
                                  EdgeInsets.fromLTRB(5.0, 7.5, 5.0, 7.5),
                              hintText: "Username",
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10.0))),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
                        child: Material(
                          elevation: 5.0,
                          borderRadius: BorderRadius.circular(10.0),
                          color: global.primaryThemeColor,
                          child: MaterialButton(
                            minWidth: MediaQuery.of(context).size.width,
                            padding: EdgeInsets.fromLTRB(10.0, 7.5, 10.0, 7.5),
                            onPressed: () async {
                              validateForm();
                            },
                            child: isLoading
                                ? CircularProgressIndicator(
                                    strokeWidth: 1.0,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.grey),
                                  )
                                : Text(
                                    Languages.dictionary[global.countryCode]
                                        ['welcome']['create_account'],
                                    //ripara
                                    textAlign: TextAlign.center,
                                    style: global.styleText.copyWith(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
