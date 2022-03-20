import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

import '../../global_variable.dart';
import '../../success_page.dart';

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
        if (response.statusCode == 200) {
          SuccessPageArg arg = new SuccessPageArg(
              message: 'Your Account Created Successfully', returnPage: 'l&r');
          Navigator.pushNamed(_context, 's', arguments: arg);
        }
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
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    var padding = MediaQuery.of(context).padding;
    double newHeight = height - padding.top - padding.bottom;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text("Link ITSC"),
      ),
      body: Column(
        children: [
          _needCreateEOSIO == true
              ? SizedBox(
                  height: newHeight * 0.075,
                )
              : SizedBox(
                  height: newHeight * 0.15,
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
          SizedBox(
            height: newHeight * 0.05,
          ),
          Column(
            children: [
              const Text(
                "Confirmation Code ",
                style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
              ),
              const SizedBox(
                height: 17.5,
              ),
              SizedBox(
                width: width * 0.78,
                height: 50,
                child: TextField(
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: "Confirmation Code",
                    hintText: 'Confirmation Code',
                  ),
                  controller: _codeController,
                ),
              )
            ],
          ),
          SizedBox(
            height: newHeight * 0.05,
          ),
          Column(
            children: [
              const Text(
                "EOSIO Account Name ",
                style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
              ),
              const SizedBox(
                height: 17.5,
              ),
              SizedBox(
                width: width * 0.78,
                height: 50,
                child: TextField(
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Account name',
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
                    SizedBox(
                      height: newHeight * 0.05,
                    ),
                    const Text(
                      "EOSIO Public Key ",
                      style: TextStyle(
                          fontSize: 18.0, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    SizedBox(
                      width: width * 0.78,
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
                    SizedBox(
                      height: newHeight * 0.075,
                    ),
                  ],
                )
              : Column(
                  children: [
                    SizedBox(
                      height: newHeight * 0.1,
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
              minimumSize: Size(width * 0.78, 42),
            ),
          )
        ],
      ),
    );
  }
}
