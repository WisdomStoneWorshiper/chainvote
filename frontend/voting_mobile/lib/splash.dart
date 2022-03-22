import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'home/navigation_bar_view.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  Future init() async {
    final prefs = await SharedPreferences.getInstance();
    print(prefs.containsKey('itsc'));

    if (prefs.containsKey('itsc') && prefs.containsKey('eosName')) {
      HomeArg arg = HomeArg(prefs.getString('itsc') as String,
          prefs.getString('eosName') as String);

      Navigator.pushReplacementNamed(context, 'h', arguments: arg);
    } else {
      Navigator.pushReplacementNamed(context, 'l');
    }
  }

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(seconds: 1), () {
      init();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image(
              height: MediaQuery.of(context).size.height * 0.6,
              image: AssetImage('assets/app_logo_transparent.png'),
            ),
          ],
        ),
      ),
    );
  }
}
