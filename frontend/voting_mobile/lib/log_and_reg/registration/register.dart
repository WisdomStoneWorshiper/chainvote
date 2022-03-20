import 'package:flutter/material.dart';

import './email_sent.dart';
import './itsc_getter.dart';

class Register extends StatefulWidget {
  const Register({Key? key}) : super(key: key);

  @override
  _RegisterState createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  final String _title = "Register";
  bool _isEmailSent = false;
  String _email = "";

  void _emailSentHandler(String email) {
    setState(() {
      _isEmailSent = true;
      this._email = email;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          title: Text(_title),
        ),
        body: _isEmailSent == false
            ? ITSCGetter(_emailSentHandler)
            : EmailSent(_email));
  }
}
