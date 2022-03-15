import 'package:flutter/material.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';

import 'log_and_reg/log_and_reg.dart';
import 'log_and_reg/login/login.dart';
import 'log_and_reg/registration/register.dart';
import 'log_and_reg/registration/eosio_acc_create.dart';
import 'log_and_reg/registration/link_up.dart';
import 'home/navigation_bar_view.dart';
import 'home/voting/votable_page.dart';
import 'home/voting/ballot.dart';
import 'success_page.dart';
import 'home/manage/manage_page.dart';
import 'splash.dart';
import 'home/manage/create_page.dart';

void main() {
  runApp(const VotingApp());
}

class VotingApp extends StatelessWidget {
  const VotingApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.from(
        colorScheme: const ColorScheme.dark(
          primary: Color(0xe02a2940),
          background: Color(0xcf222233),
        ),
        textTheme: const TextTheme(
          headline1: TextStyle(
            color: Color(0x4da5a4b7),
            fontSize: 23.0,
            fontWeight: FontWeight.normal,
          ),
          headline2: TextStyle(
            color: Color(0xfce4e280),
            fontSize: 45.0,
            fontWeight: FontWeight.bold,
          ),
          button: TextStyle(
            color: Color.fromARGB(255, 165, 164, 183),
            fontSize: 22.0,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      initialRoute: 'sp',
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
        'sp': (context) => SplashScreen(),
        'c': (context) => CreatePage(),
      },
    );
  }
}
