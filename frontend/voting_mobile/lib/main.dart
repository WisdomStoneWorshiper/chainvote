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
import 'log_and_reg/registration/email_sent.dart';

void main() {
  runApp(const VotingApp());
}

class VotingApp extends StatelessWidget {
  const VotingApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: FlexThemeData.dark(scheme: FlexScheme.blumineBlue),
      darkTheme: FlexThemeData.dark(scheme: FlexScheme.blumineBlue),
      themeMode: ThemeMode.system,
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
        'es': (context) => EmailSent(),
      },
    );
  }
}
