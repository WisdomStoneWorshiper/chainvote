import 'package:flutter/material.dart';
import './log_and_reg_btn.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../home/navigation_bar_view.dart';

class LogAndReg extends StatefulWidget {
  const LogAndReg({Key? key}) : super(key: key);

  @override
  _LogAndRegState createState() => _LogAndRegState();
}

class _LogAndRegState extends State<LogAndReg> {
  final String _title = "Voting App";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Column(
            children: [
              const SizedBox(
                height: 150,
              ),
              Column(children: [
                RichText(
                  text: TextSpan(
                    text: 'Welcome to our Blockchain based',
                    style: Theme.of(context).textTheme.headline1,
                  ),
                ),
                RichText(
                  text: TextSpan(
                    text: 'Voting App',
                    style: Theme.of(context).textTheme.headline2,
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
                  ),
                ),
                LogAndRegButton("Login", () {
                  Navigator.pushNamed(context, 'l');
                  // _loginHander(context);
                  // final prefs = await SharedPreferences.getInstance();

                  // Navigator.pushNamed(context, 'l');
                }),
              ]),
              const SizedBox(
                height: 80,
              ),
              Column(children: [
                RichText(
                  text: const TextSpan(
                    text: 'Create a new account?',
                  ),
                ),
                LogAndRegButton("Register", () {
                  Navigator.pushNamed(context, 'r');
                })
              ]),
            ],
          ),
        ),
      ),
    );
  }
}
