import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/link.dart';
import 'package:dio/dio.dart';
import 'dart:async';

import '../../global_variable.dart';

class ITSCGetter extends StatelessWidget {
  final String _title = "Register";
  final String _keyPairURL =
      "https://eosauthority.com/generate_eos_private_key";
  final void Function(String) emailSentCallback;
  late BuildContext _context;

  ITSCGetter(this.emailSentCallback);

  TextEditingController _itscFieldController = TextEditingController();
  void _gotoKeyGen() async {
    if (!await launch(
      _keyPairURL,
      forceSafariVC: true,
      forceWebView: true,
      headers: <String, String>{'my_header_key': 'my_header_value'},
    )) {
      throw 'Could not launch $_keyPairURL';
    }
  }

  void _sendRegistrationRequest(String itsc) async {
    if (_itscFieldController.text.isEmpty) {
      final errBar = SnackBar(
        content: Text("Please fill in all the fields!"),
        action: SnackBarAction(
          label: 'OK',
          onPressed: () {},
        ),
      );
      ScaffoldMessenger.of(_context).showSnackBar(errBar);
      return;
    }
    BaseOptions opt = BaseOptions(baseUrl: backendServerUrl);
    var dio = Dio(opt);
    try {
      print("itsc:" + itsc);
      Response response = await dio.post("/registration", data: {'itsc': itsc});
      print("itsc response");
      print(response);
      emailSentCallback(itsc);
    } catch (e) {
      print(e);
    }
  }

  void _registerBtnHandler() {
    _sendRegistrationRequest(_itscFieldController.text);
  }

  @override
  Widget build(BuildContext context) {
    _context = context;
    return Center(
      child: Column(
        children: [
          const SizedBox(
            height: 200,
          ),
          Column(
            children: [
              RichText(
                text: const TextSpan(
                  text: 'Step 1: Generate EOSIO key pair',
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              ElevatedButton(
                child: const Text(
                  "Get Key Pair!",
                  style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
                ),
                onPressed: _gotoKeyGen,
                style: ElevatedButton.styleFrom(
                  //primary: Colors.blue,
                  minimumSize: const Size(300, 42),
                ),
              ),
            ],
          ),
          const SizedBox(
            height: 75,
          ),
          Column(
            children: [
              const Text(
                "Step 2: Get verification code",
                style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
              ),
              const SizedBox(
                height: 20,
              ),
              Column(
                children: [
                  SizedBox(
                    width: 275,
                    child: TextField(
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'ITSC Account',
                      ),
                      onSubmitted: _sendRegistrationRequest,
                      controller: _itscFieldController,
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  ElevatedButton(
                    onPressed: _registerBtnHandler,
                    child: const Text(
                      "Register",
                      style: TextStyle(
                          fontSize: 20.0, fontWeight: FontWeight.bold),
                    ),
                    style: ElevatedButton.styleFrom(
                      //primary: Colors.blue,
                      minimumSize: const Size(300, 45),
                    ),
                  )
                ],
              ),
            ],
          )
        ],
      ),
    );
  }
}
