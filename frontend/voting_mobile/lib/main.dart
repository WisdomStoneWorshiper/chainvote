import 'package:flutter/material.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';

import 'log_and_reg/login/login.dart';
import 'log_and_reg/registration/register.dart';
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
      theme: ThemeData(
        brightness: Brightness.dark,
        colorScheme: ColorScheme(
          brightness: Brightness.dark,
          primary: Color.fromARGB(255, 83, 198, 211),
          onPrimary: Colors.white,
          secondary: Color(0xAA5FD423),
          onSecondary: Colors.yellow,
          surface: Color.fromARGB(255, 27, 79, 97),
          onSurface: Colors.white,
          background: Color(0xFF133642),
          onBackground: Colors.purple,
          error: Colors.red,
          onError: Colors.orange,
        ),
        primaryColor: Color.fromARGB(255, 14, 43, 52),
        backgroundColor: Color(0xFF133642),
        scaffoldBackgroundColor: Color(0xFF133642),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            primary: Color(0xAA5FD423),
            onSurface: Color(0xFF47C1CF),
          ),
        ),
      ),
      initialRoute: 'sp',
      routes: {
        'l': (context) => Login(),
        'r': (context) => Register(),
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
