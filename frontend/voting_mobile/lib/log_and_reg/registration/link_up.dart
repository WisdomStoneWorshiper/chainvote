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

  void _submitLinpUpRequest() {
    if (_codeController.text.isEmpty ||
        _eosAccController.text.isEmpty ||
        (_needCreateEOSIO == true && _eosPublicKeyController.text.isEmpty)) {
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
    }
  }

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as LinkUpArg;
    _itsc = args.itsc;
    _needCreateEOSIO = args.needCreateEOSIO;
    _context = context;
    return Scaffold(
      appBar: AppBar(
        title: Text("Link up with your itsc"),
      ),
      body: Column(
        children: [
          Text("ITSC : " + _itsc),
          Row(
            children: [
              Text("Confirmation code: "),
              SizedBox(
                width: 100,
                height: 50,
                child: TextField(
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Please enter the code',
                  ),
                  controller: _codeController,
                ),
              )
            ],
          ),
          Row(
            children: [
              Text("EOSIO account name : "),
              SizedBox(
                width: 100,
                height: 50,
                child: TextField(
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Please enter the account name',
                  ),
                  controller: _eosAccController,
                ),
              )
            ],
          ),
          _needCreateEOSIO == true
              ? Row(
                  children: [
                    Text("EOSIO public key : "),
                    SizedBox(
                      width: 250,
                      height: 50,
                      child: TextField(
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Please enter the public key',
                        ),
                        controller: _eosPublicKeyController,
                      ),
                    )
                  ],
                )
              : Row(),
          ElevatedButton(onPressed: _submitLinpUpRequest, child: Text("Submit"))
        ],
      ),
    );
  }
}
