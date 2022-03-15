import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'dart:async';

import './email_sent.dart';
import './itsc_getter.dart';
import '../../global_variable.dart';

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
      Navigator.pushNamed(context, 'es', arguments: itsc);
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
          child: Center(
            child: Container(
              // alignment: Alignment.center,
              child: Column(
                children: [
                  Expanded(flex: 2, child: Container()),
                  Expanded(
                    flex: 2,
                    child: Image(
                      image: AssetImage('assets/app_logo_largest.png'),
                    ),
                  ),
                  Expanded(flex: 1, child: Container()),
                  Expanded(
                    flex: 2,
                    child: Row(
                      children: [
                        Expanded(flex: 2, child: Container()),
                        Expanded(
                          flex: 6,
                          child: TextField(
                            decoration: InputDecoration(
                              // border: OutlineInputBorder(),
                              hintText: 'ITSC Account',
                              suffixIcon: Icon(Icons.email),
                            ),
                            onSubmitted: _sendRegistrationRequest,
                            controller: _itscFieldController,
                            // focusNode: _focusNode,
                          ),
                        ),
                        Expanded(flex: 2, child: Container()),
                      ],
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: ElevatedButton(
                      onPressed: _registerBtnHandler,
                      child: Text(
                        "Get verification code",
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Row(
                      children: [
                        Expanded(flex: 20, child: Container()),
                        Expanded(
                          flex: 60,
                          child: Row(
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
                        Expanded(flex: 20, child: Container()),
                      ],
                    ),
                  ),
                  Expanded(flex: 4, child: Container()),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
