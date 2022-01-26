import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

import '../../global_variable.dart';

class Login extends StatelessWidget {
  final String _title = "Login";
  TextEditingController _itscFieldController = TextEditingController();
  TextEditingController _publicKeyFieldController = TextEditingController();
  late BuildContext _context;

  Login();

  void _loginRequestHandler() {
    if (_itscFieldController.text.isEmpty ||
        _publicKeyFieldController.text.isEmpty) {
      final errBar = SnackBar(
        content: Text("Please fillin all field!"),
        action: SnackBarAction(
          label: 'OK',
          onPressed: () {},
        ),
      );
      ScaffoldMessenger.of(_context).showSnackBar(errBar);
    } else {
      BaseOptions opt = BaseOptions(baseUrl: backendServerUrl);
      var dio = Dio(opt);

      Navigator.pop(_context);
      Navigator.pushReplacementNamed(_context, 'h');
    }
  }

  @override
  Widget build(BuildContext context) {
    _context = context;
    return Scaffold(
      appBar: AppBar(
        title: Text(_title),
      ),
      body: Center(
        child: Column(
          children: [
            Text("itsc"),
            SizedBox(
              width: 100,
              child: TextField(
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'itsc',
                ),
                controller: _itscFieldController,
              ),
            ),
            Text("EOSIO Public Key"),
            SizedBox(
              width: 100,
              child: TextField(
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Public Key',
                ),
                controller: _publicKeyFieldController,
              ),
            ),
            ElevatedButton(
                onPressed: _loginRequestHandler, child: Text("Login"))
          ],
        ),
      ),
    );
  }
}
