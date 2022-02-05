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
        content: const Text("Please fill in all fields!"),
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
            const SizedBox(
              height: 150,
            ),
            const Text(
              "ITSC Account",
              style: TextStyle(fontSize: 22.0, fontWeight: FontWeight.bold),
            ),
            const SizedBox(
              height: 15,
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
            const SizedBox(
              height: 40,
            ),
            const Text(
              "EOSIO Public Key",
              style: TextStyle(fontSize: 22.0, fontWeight: FontWeight.bold),
            ),
            const SizedBox(
              height: 15,
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
            const SizedBox(
              height: 150,
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
