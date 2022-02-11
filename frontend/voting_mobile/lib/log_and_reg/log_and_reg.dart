import 'package:flutter/material.dart';
import './log_and_reg_btn.dart';

class LogAndReg extends StatelessWidget {
  final String _title = "Voting App";
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
            const SizedBox(
              height: 150,
            ),
            Column(children: [
              RichText(
                text: const TextSpan(
                  text: 'Welcome to our Blockchain based',
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: 23.0,
                      fontWeight: FontWeight.normal),
                ),
              ),
              RichText(
                text: const TextSpan(
                  text: 'Voting App',
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: 45.0,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ]),
            const SizedBox(
              height: 200,
            ),
            Column(children: [
              RichText(
                text: const TextSpan(
                  text: 'Already registered?',
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold),
                ),
              ),
              LogAndRegButton("Login", () {
                Navigator.pushNamed(context, 'l');
              }),
            ]),
            const SizedBox(
              height: 80,
            ),
            Column(children: [
              RichText(
                text: const TextSpan(
                  text: 'Create a new account?',
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: 18.0,
                      fontWeight: FontWeight.normal),
                ),
              ),
              LogAndRegButton("Register", () {
                Navigator.pushNamed(context, 'r');
              })
            ]),
          ],
        ),
      ),
    );
  }
}
