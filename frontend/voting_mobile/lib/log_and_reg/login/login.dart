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
    // NOTE REMOVE THE FIRST IF FOR UI/UX TESTING ONLY
    if (_itscFieldController.text == "mpsanghavia") {
      String eosName = "Mudit";
      // final prefs = await SharedPreferences.getInstance();
      // prefs.setString('eosName', eosName);
      // prefs.setString('itsc', _itscFieldController.text);
      HomeArg arg = HomeArg(_itscFieldController.text, eosName);
      Navigator.pop(_context);
      Navigator.pushReplacementNamed(_context, 'h', arguments: arg);
    } else {
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
  }

  @override
  Widget build(BuildContext context) {
    _context = context;
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    var padding = MediaQuery.of(context).padding;
    double newHeight = height - padding.top - padding.bottom;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text(_title),
      ),
      body: Center(
        child: Column(
          children: [
            SizedBox(
              height: newHeight * 0.15,
            ),
            const Text(
              "ITSC Account",
              style: TextStyle(fontSize: 22.0, fontWeight: FontWeight.bold),
            ),
            SizedBox(
              height: newHeight * 0.02,
            ),
            SizedBox(
              width: 300,
              child: TextField(
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: "ITSC",
                  hintText: 'ITSC Account',
                ),
                controller: _itscFieldController,
              ),
            ),
            SizedBox(
              height: newHeight * 0.05,
            ),
            const Text(
              "EOSIO Public Key",
              style: TextStyle(fontSize: 22.0, fontWeight: FontWeight.bold),
            ),
            SizedBox(
              height: newHeight * 0.02,
            ),
            SizedBox(
              width: 300,
              child: TextField(
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: "Public Key",
                  hintText: 'EOSIO Public Key',
                ),
                controller: _publicKeyFieldController,
              ),
            ),
            SizedBox(
              height: newHeight * 0.1,
            ),
            ElevatedButton(
              onPressed: _loginRequestHandler,
              child: const Text(
                "Login",
                style: TextStyle(fontSize: 25.0, fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                //primary: Colors.blue,
                minimumSize: const Size(300, 42),
              ),
            )
          ],
        ),
      ),
    );
  }
}
