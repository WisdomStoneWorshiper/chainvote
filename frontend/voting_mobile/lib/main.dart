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
      // theme: FlexThemeData.dark(scheme: FlexScheme.blumineBlue),
      // darkTheme: FlexThemeData.dark(scheme: FlexScheme.blumineBlue),
      // themeMode: ThemeMode.system,
      theme: ThemeData(
        brightness: Brightness.dark,
        colorScheme: ColorScheme(
          brightness: Brightness.dark,
          primary: Color.fromARGB(255, 36, 48, 65),
          onPrimary: Colors.white,
          secondary: Color(0xAA5FD423),
          onSecondary: Colors.yellow,
          surface: Color.fromARGB(255, 27, 79, 97),
          onSurface: Colors.white, //Color.fromARGB(255, 83, 198, 211),
          background: Color(0xFF133642),
          onBackground: Colors.purple,
          error: Colors.red,
          onError: Colors.orange,
        ),
        textButtonTheme: TextButtonThemeData(
            style: TextButton.styleFrom(primary: Colors.amber)),
        // primaryColor: Color(0xFF133642),
        // backgroundColor: Color(0xFF133642),
        scaffoldBackgroundColor: Color.fromARGB(255, 2, 21, 27),
        // elevatedButtonTheme: ElevatedButtonThemeData(
        //   style: ElevatedButton.styleFrom(
        //     primary: Color(0xAA5FD423),
        //     onSurface: Color(0xFF47C1CF),
        //   ),
        // ),
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
