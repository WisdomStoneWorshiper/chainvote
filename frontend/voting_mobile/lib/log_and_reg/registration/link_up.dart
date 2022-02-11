import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

import '../../global_variable.dart';

class LinkUpArg {
  final String itsc;
  final bool needCreateEOSIO;
  const LinkUpArg(this.itsc, this.needCreateEOSIO);
}

class LinkUp extends StatelessWidget {
  String _itsc = "";
  bool _needCreateEOSIO = true;
  TextEditingController _codeController = TextEditingController();
  TextEditingController _eosAccController = TextEditingController();
  TextEditingController _eosPublicKeyController = TextEditingController();
  late BuildContext _context;

  LinkUp({Key? key}) : super(key: key);

  void _submitLinpUpRequest() async {
    if (_codeController.text.isEmpty ||
        _eosAccController.text.isEmpty ||
        (_needCreateEOSIO == true && _eosPublicKeyController.text.isEmpty)) {
      final errBar = SnackBar(
        content: const Text("Please fill in all the fields!"),
        action: SnackBarAction(
          label: 'OK',
          onPressed: () {},
        ),
      );
      ScaffoldMessenger.of(_context).showSnackBar(errBar);
    } else {
      BaseOptions opt = BaseOptions(baseUrl: backendServerUrl);
      var dio = Dio(opt);
      try {
        Response response = await dio.post("/account/create", data: {
          'itsc': _itsc,
          'key': _codeController.text,
          'accname': _eosAccController.text,
          'pkey': _eosPublicKeyController.text
        });
        print(response);
      } catch (e) {
        print(e);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as LinkUpArg;
    _itsc =
        args.itsc; //args.itsc; UNCOMMENT LATER PLEASE ADD RIGHT EMAIL VARIABLE
    _needCreateEOSIO = args.needCreateEOSIO;
    _context = context;
    return Scaffold(
      appBar: AppBar(
        title: const Text("Link ITSC"),
      ),
      body: Column(
        children: [
          const SizedBox(
            height: 125,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "ITSC : ",
                style: TextStyle(fontSize: 15.0, fontWeight: FontWeight.bold),
              ),
              Text(
                _itsc,
                style: const TextStyle(
                    fontSize: 20.0, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(
            height: 45,
          ),
          Column(
            children: [
              const Text(
                "Confirmation Code ",
                style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
              ),
              const SizedBox(
                height: 15,
              ),
              SizedBox(
                width: 300,
                height: 50,
                child: TextField(
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: "Confirmation Code",
                    hintText: 'Please Enter the Code',
                  ),
                  controller: _codeController,
                ),
              )
            ],
          ),
          const SizedBox(
            height: 40,
          ),
          Column(
            children: [
              const Text(
                "EOSIO Account Name : ",
                style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
              ),
              const SizedBox(
                height: 15,
              ),
              SizedBox(
                width: 300,
                height: 50,
                child: TextField(
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Please enter the account name',
                    labelText: "Account Name",
                  ),
                  controller: _eosAccController,
                ),
              )
            ],
          ),
          _needCreateEOSIO == true
              ? Column(
                  children: [
                    const SizedBox(
                      height: 40,
                    ),
                    const Text(
                      "EOSIO Public Key : ",
                      style: TextStyle(
                          fontSize: 18.0, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    SizedBox(
                      width: 300,
                      height: 50,
                      child: TextField(
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: "Public Key",
                          hintText: 'Please enter the public key',
                        ),
                        controller: _eosPublicKeyController,
                      ),
                    ),
                    const SizedBox(
                      height: 80,
                    ),
                  ],
                )
              : Column(
                  children: [
                    const SizedBox(
                      height: 150,
                    ),
                  ],
                ),
          ElevatedButton(
            onPressed: _submitLinpUpRequest,
            child: const Text(
              "Submit",
              style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
            ),
            style: ElevatedButton.styleFrom(
              //primary: Colors.blue,
              minimumSize: const Size(300, 42),
            ),
          )
        ],
      ),
    );
  }
}
