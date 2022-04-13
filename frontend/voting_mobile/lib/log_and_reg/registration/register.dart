import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'dart:async';

import '../../global_variable.dart';
import '../../success_page.dart';
import '../../shared_dialog.dart';

class Register extends StatefulWidget {
  const Register({Key? key}) : super(key: key);

  @override
  _RegisterState createState() => _RegisterState();
}

class _RegisterState extends State<Register> with SharedDialog {
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
      Response response = await dio.post("/registration", data: {'itsc': itsc});
      print("itsc response");
      print(response);

      if (response.statusCode != 200) {
        print("fail");
        // failed_item.add(_addList[i]);
        errDialog(
            context, "Fail to register, Reason: " + response.data["message"]);
        return;
      }
    } catch (e) {
      DioError err = e as DioError;

      Map<String, dynamic> response = (err.response?.data);

      errDialog(context, "Fail to register, Reason: " + response["message"]!);

      return;
    }
    SuccessPageArg arg = SuccessPageArg(
        message: 'The code has been sent to \n ' + itsc + '@connect.ust.hk',
        returnPage: 'lu',
        arg: itsc);
    Navigator.pushNamed(_context, 's', arguments: arg);
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
                      top: MediaQuery.of(context).size.height * 0.04,
                      bottom: MediaQuery.of(context).size.height * 0.05,
                    ),
                    child: ElevatedButton(
                      onPressed: _registerBtnHandler,
                      child: Text(
                        "Send Code", //"Get verification code",
                        style: TextStyle(
                            fontSize: 24.0, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  Container(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Already have an account?",
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w400),
                        ),
                        TextButton(
                          child: Text(
                            "Login",
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                          ),
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
