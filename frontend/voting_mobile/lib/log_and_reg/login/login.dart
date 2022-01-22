import 'package:flutter/material.dart';

class Login extends StatelessWidget {
  final String _title = "Login";

  const Login();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_title),
      ),
      body: Text("this is login page"),
    );
  }
}
