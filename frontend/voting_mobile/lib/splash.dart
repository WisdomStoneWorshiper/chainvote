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
      Navigator.pushReplacementNamed(context, 'l&r');
    }
  }

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(seconds: 4), () {
      init();
    });
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    var padding = MediaQuery.of(context).padding;
    double newHeight = height - padding.top - padding.bottom;
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/app_logo_largest_without_bg.png',
              height: newHeight * 0.39,
            ),
          ],
        ),
      ),
    );
  }
}
