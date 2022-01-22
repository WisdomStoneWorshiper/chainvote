import 'package:flutter/material.dart';
import './log_and_reg_btn.dart';

class LogAndReg extends StatelessWidget {
  final String _title = "Votting App";
  const LogAndReg();

  void temp() {}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_title),
      ),
      body: Center(
        child: Column(
          children: [
            LogAndRegButton("Login", () {
              Navigator.pushNamed(context, 'l');
            }),
            LogAndRegButton("Register", () {
              Navigator.pushNamed(context, 'r');
            })
          ],
        ),
      ),
    );
  }
}
