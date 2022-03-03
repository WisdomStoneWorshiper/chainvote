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
          children: [Text("This is splash")],
        ),
      ),
    );
  }
}
