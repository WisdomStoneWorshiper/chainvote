import 'package:flutter/material.dart';
import './log_and_reg_btn.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';
import '../../home/navigation_bar_view.dart';

class LogAndReg extends StatefulWidget {
  const LogAndReg({Key? key}) : super(key: key);

  @override
  _LogAndRegState createState() => _LogAndRegState();
}

class _LogAndRegState extends State<LogAndReg> {
  final String _title = "CHAINVOTE";
  // const LogAndReg();

  // @override
  // void initState() async {
  //   final prefs = await SharedPreferences.getInstance();
  //   print(prefs.containsKey('itsc'));

  //   if (prefs.containsKey('itsc') && prefs.containsKey('eosName')) {
  //     HomeArg arg = HomeArg(prefs.getString('itsc') as String,
  //         prefs.getString('eosName') as String);

  //     Navigator.pushReplacementNamed(context, 'h', arguments: arg);
  //   }
  //   super.initState();
  // }

  // void _loginHander(BuildContext context) async {
  //   final prefs = await SharedPreferences.getInstance();
  //   print(prefs.containsKey('itsc'));

  //   if (prefs.containsKey('itsc') && prefs.containsKey('eosName')) {
  //     HomeArg arg = HomeArg(prefs.getString('itsc') as String,
  //         prefs.getString('eosName') as String);

  //     Navigator.pushReplacementNamed(context, 'h', arguments: arg);
  //   } else {
  //     Navigator.pushNamed(context, 'l');
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    var padding = MediaQuery.of(context).padding;
    double newHeight = height - padding.top - padding.bottom;
    //debugPrint('NEWHEIGHT IS  !!!!!!!!!: $newHeight');
    return Scaffold(
      appBar: AppBar(
        title: Text(_title),
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: Column(
          children: [
            SizedBox(
              height: (newHeight * 0.1), //height * 0.1,
            ),
            Image.asset(
              'assets/app_logo_largest_without_bg.png',
              height: newHeight * 0.39,
            ),
            // RichText(
            //   text: const TextSpan(
            //     text: 'Voting App',
            //     style: TextStyle(
            //         color: Colors.black,
            //         fontSize: 45.0,
            //         fontWeight: FontWeight.bold),
            //   ),
            // ),
            SizedBox(
              height: newHeight * 0.075,
            ),
            Container(
              height: newHeight * 0.3,
              width: double.infinity,
              child: Column(children: [
                RichText(
                  text: const TextSpan(
                    text: 'Already registered?',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 18.0,
                        fontWeight: FontWeight.normal), //bold),
                  ),
                ),
                LogAndRegButton("Login", Color(0xAA5FD423), () {
                  Navigator.pushNamed(context, 'l');
                  // _loginHander(context);
                  // final prefs = await SharedPreferences.getInstance();

                  // Navigator.pushNamed(context, 'l');
                }),
                SizedBox(height: newHeight * 0.05),
                RichText(
                  text: const TextSpan(
                    text: 'Create a new account?',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 18.0,
                        fontWeight: FontWeight.normal),
                  ),
                ),
                LogAndRegButton("Register", Color(0xF047C1CF), () {
                  Navigator.pushNamed(context, 'r');
                })
              ]),
            ),
          ],
        ),
      ),
    );
  }
}
