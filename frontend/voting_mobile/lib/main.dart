import 'package:flutter/material.dart';

import 'log_and_reg/log_and_reg.dart';
import 'log_and_reg/login/login.dart';
import 'log_and_reg/registration/register.dart';
import 'log_and_reg/registration/eosio_acc_create.dart';
import 'log_and_reg/registration/link_up.dart';
import 'home/voting/voter_page.dart';
import 'home/navigation_bar_view.dart';
import 'home/voting/votable_page.dart';
import 'home/voting/ballot.dart';
import 'success_page.dart';
import 'home/manage/manage_page.dart';

void main() {
  runApp(const VotingApp());
}

class VotingApp extends StatelessWidget {
  const VotingApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: 'l&r',
      routes: {
        'l&r': (context) => const LogAndReg(),
        'l': (context) => Login(),
        'r': (context) => Register(),
        'e': (context) => EOSIOAccCreate(),
        'lu': (context) => LinkUp(),
        'h': (context) => NavBarView(),
        'v': (context) => VotablePage(),
        'b': (context) => Ballot(),
        's': (context) => SuccessPage(),
        'm': (context) => ManagePage(),
      },
      // theme: ThemeData(
      //     // Define the default brightness and colors.
      //     brightness: Brightness.dark,
      //     primaryColor: Color.fromARGB(255, 67, 218, 155),
      //     buttonTheme: ButtonThemeData(
      //       buttonColor: Color.fromARGB(255, 116, 238, 92),
      //     ),
      //     elevatedButtonTheme: ElevatedButtonThemeData(
      //         style: ElevatedButton.styleFrom(
      //       primary: Color.fromARGB(255, 98, 245, 159),
      //     )))
      // // Define the default `TextTheme`. Use this to specify the default
      // text styling for headlines, titles, bodies of text, and more.
      // ,
    );
  }
}
