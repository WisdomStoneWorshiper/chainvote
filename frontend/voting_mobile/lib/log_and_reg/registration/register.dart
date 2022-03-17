import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'dart:async';

import '../../global_variable.dart';
import '../../success_page.dart';

class Register extends StatefulWidget {
  const Register({Key? key}) : super(key: key);

  @override
  _RegisterState createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  late BuildContext _context;
  TextEditingController _itscFieldController = TextEditingController();
  final String _title = "Register";
  bool _isEmailSent = false;
  String _email = "";

  void _emailSentHandler(String email) {
    setState(() {
      _isEmailSent = true;
      this._email = email;
    });
  }

  void _sendRegistrationRequest(String itsc) async {
    if (_itscFieldController.text.isEmpty) {
      final errBar = SnackBar(
        content: Text("Please fill in all the fields!"),
        action: SnackBarAction(
          label: 'OK',
          onPressed: () {},
        ),
      );
      ScaffoldMessenger.of(_context).showSnackBar(errBar);
      return;
    }
    BaseOptions opt = BaseOptions(baseUrl: backendServerUrl);
    var dio = Dio(opt);
    try {
      // print("itsc:" + itsc);
      // Response response = await dio.post("/registration", data: {'itsc': itsc});
      // print("itsc response");
      // print(response);

      SuccessPageArg arg = SuccessPageArg(
          message: 'The code has been sent to \n ' + itsc + '@connect.ust.hk',
          returnPage: 'lu',
          arg: itsc);
      Navigator.pushNamed(_context, 's', arguments: arg);

      // Navigator.pushNamed(context, 'es', arguments: itsc);
    } catch (e) {
      print(e);
    }
  }

  void _registerBtnHandler() {
    _sendRegistrationRequest(_itscFieldController.text);
  }

  @override
  Widget build(BuildContext context) {
    _context = context;
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        body: SafeArea(
          child: SingleChildScrollView(
            child: Container(
              margin: EdgeInsets.only(
                top: MediaQuery.of(context).size.height * 0.1,
                left: MediaQuery.of(context).size.width * 0.1,
                bottom: MediaQuery.of(context).size.height * 0.1,
                right: MediaQuery.of(context).size.width * 0.1,
              ),
              child: Column(
                children: [
                  Image(
                    height: MediaQuery.of(context).size.height * 0.15,
                    image: AssetImage('assets/app_logo_transparent.png'),
                  ),
                  Container(
                    margin: EdgeInsets.only(
                      top: MediaQuery.of(context).size.height * 0.2,
                    ),
                    child: TextField(
                      decoration: InputDecoration(
                        labelText: 'ITSC Account',
                        hintText: 'ITSC Account',
                        suffixIcon: Icon(Icons.email),
                      ),
                      onSubmitted: _sendRegistrationRequest,
                      controller: _itscFieldController,
                      // focusNode: _focusNode,
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(
                      top: MediaQuery.of(context).size.height * 0.1,
                    ),
                    child: ElevatedButton(
                      onPressed: _registerBtnHandler,
                      child: Text(
                        "Get verification code",
                        style: TextStyle(
                            fontSize: 25.0, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  Container(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("I have an account. "),
                        TextButton(
                          child: Text("Login"),
                          onPressed: () {
                            Navigator.pop(context);
                          },
                        ),
                      ],
                    ),
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
