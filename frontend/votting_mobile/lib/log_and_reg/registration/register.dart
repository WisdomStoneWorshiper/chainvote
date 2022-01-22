import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/link.dart';

import 'dart:async';

class Register extends StatelessWidget {
  final String _title = "Register";
  final String _keyPairURL =
      "https://eosauthority.com/generate_eos_private_key";
  const Register();

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
              )
            ],
          ),
        ));
  }
}
