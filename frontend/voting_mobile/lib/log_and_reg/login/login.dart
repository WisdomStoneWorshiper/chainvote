import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../global_variable.dart';
import '../../home/navigation_bar_view.dart';

class Login extends StatelessWidget {
  final String _title = "Login";
  TextEditingController _itscFieldController = TextEditingController();
  TextEditingController _publicKeyFieldController = TextEditingController();
  late BuildContext _context;

  Login();

  void _loginRequestHandler() async {
    if (_itscFieldController.text.isEmpty ||
        _publicKeyFieldController.text.isEmpty) {
      final errBar = SnackBar(
        content: const Text("Please fill in all fields!"),
        action: SnackBarAction(
          label: 'OK',
          onPressed: () {},
        ),
      );
      ScaffoldMessenger.of(_context).showSnackBar(errBar);
    } else {
      final wrongInputErrBar = SnackBar(
        content: const Text("Incorrect ITSC or EOSIO Public Key"),
        action: SnackBarAction(
          label: 'OK',
          onPressed: () {},
        ),
      );

      BaseOptions opt = BaseOptions(baseUrl: backendServerUrl);
      var dio = Dio(opt);

      final prefs = await SharedPreferences.getInstance();
      print(_itscFieldController.text);
      print(_publicKeyFieldController.text);
      Response response = await dio.post("/contract/login", data: {
        'itsc': _itscFieldController.text,
        'publicKey': _publicKeyFieldController.text
      });
      // print(response.data);
      if (response.statusCode == 200) {
        print(response.data);

        if (response.data["accountName"] != null) {
          String eosName = response.data["accountName"];
          prefs.setString('eosName', eosName);
          prefs.setString('itsc', _itscFieldController.text);
          HomeArg arg = HomeArg(_itscFieldController.text, eosName);
          Navigator.pop(_context);
          Navigator.pushReplacementNamed(_context, 'h', arguments: arg);
        } else {
          ScaffoldMessenger.of(_context).showSnackBar(wrongInputErrBar);
        }
      } else {
        ScaffoldMessenger.of(_context).showSnackBar(wrongInputErrBar);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    _context = context;
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        body: SafeArea(
          child: SingleChildScrollView(
            child: Container(
              margin: EdgeInsets.only(
                top: MediaQuery.of(context).size.height * 0.1,
                left: MediaQuery.of(context).size.width * 0.1,
                bottom: MediaQuery.of(context).size.height * 0.1,
                right: MediaQuery.of(context).size.width * 0.1,
              ),
              child: Column(
                children: [
                  Image(
                    height: MediaQuery.of(context).size.height * 0.15,
                    image: AssetImage('assets/app_logo_transparent.png'),
                  ),

                  Container(
                    margin: EdgeInsets.only(
                      top: MediaQuery.of(context).size.height * 0.15,
                    ),
                    child: TextField(
                      decoration: InputDecoration(
                        // border: OutlineInputBorder(),
                        labelText: 'ITSC',
                        hintText: 'ITSC Account',
                        suffixIcon: Icon(Icons.person),
                      ),
                      controller: _itscFieldController,
                    ),
                  ),

                  Container(
                    margin: EdgeInsets.only(
                      top: MediaQuery.of(context).size.height * 0.05,
                    ),
                    child: TextField(
                      obscureText: true,
                      decoration: InputDecoration(
                        // border: OutlineInputBorder(),
                        labelText: 'EOSIO Public Key',
                        hintText: 'EOSIO Public Key',
                        suffixIcon: Icon(Icons.key),
                      ),
                      controller: _publicKeyFieldController,
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(
                      top: MediaQuery.of(context).size.height * 0.05,
                    ),
                    child: ElevatedButton(
                      onPressed: _loginRequestHandler,
                      child: const Text(
                        "Login",
                        style: TextStyle(
                            fontSize: 25.0, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  // Expanded(flex: 2, child: Container()),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("New to Chainvote? "),
                      TextButton(
                        child: Text("Join us!"),
                        onPressed: () {
                          Navigator.pushNamed(context, 'r');
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
