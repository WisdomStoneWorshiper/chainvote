import 'package:flutter/material.dart';
import 'log_and_reg/log_and_reg.dart';
import 'log_and_reg/login/login.dart';
import 'log_and_reg/registration/register.dart';
import 'log_and_reg/registration/eosio_acc_create.dart';
import 'log_and_reg/registration/link_up.dart';

void main() {
  runApp(const votingApp());
}

class votingApp extends StatelessWidget {
  const votingApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: 'l&r',
      routes: {
        'l&r': (context) => const LogAndReg(),
        'l': (context) => const Login(),
        'r': (context) => Register(),
        'e': (context) => EOSIOAccCreate(),
        'lu': (context) => LinkUp(),
      },
    );
  }
}
