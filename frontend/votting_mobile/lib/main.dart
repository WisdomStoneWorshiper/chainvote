import 'package:flutter/material.dart';
import 'log_and_reg/log_and_reg.dart';
import 'log_and_reg/login/login.dart';
import 'log_and_reg/registration/register.dart';

void main() {
  runApp(const VottingApp());
}

class VottingApp extends StatelessWidget {
  const VottingApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: 'l&r',
      routes: {
        'l&r': (context) => const LogAndReg(),
        'l': (context) => const Login(),
        'r': (context) => const Register(),
      },
    );
  }
}
