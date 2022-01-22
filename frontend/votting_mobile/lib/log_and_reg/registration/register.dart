import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/link.dart';
import 'package:dio/dio.dart';
import 'dart:async';

class Register extends StatelessWidget {
  final String _title = "Register";
  final String _keyPairURL =
      "https://eosauthority.com/generate_eos_private_key";
  Register();

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
    BaseOptions opt = BaseOptions(baseUrl: "http://localhost:3000");
    var dio = Dio(opt);
    Response response = await dio.post("/registration", data: {'itsc': itsc});
    print(response);
  }

  void _registerBtnHandler() {
    _sendRegistrationRequest(_itscFieldController.text);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(_title),
        ),
        body: Center(
          child: Column(
            children: [
              Row(
                children: [
                  Text("Step 1: Generate eosio key pair"),
                  ElevatedButton(
                    child: Text("Get Key Pair!"),
                    onPressed: _gotoKeyGen,
                  ),
                ],
              ),
              Row(
                children: [
                  Text("Step 2: Get verification code"),
                  Column(
                    children: [
                      SizedBox(
                        width: 100,
                        child: TextField(
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'itsc',
                          ),
                          onSubmitted: _sendRegistrationRequest,
                          controller: _itscFieldController,
                        ),
                      ),
                      ElevatedButton(
                          onPressed: _registerBtnHandler,
                          child: Text("Register"))
                    ],
                  ),
                ],
              )
            ],
          ),
        ));
  }
}
