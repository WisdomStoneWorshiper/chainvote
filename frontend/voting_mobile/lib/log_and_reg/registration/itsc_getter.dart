import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/link.dart';
import 'package:dio/dio.dart';
import 'dart:async';

import '../../global_variable.dart';

class ITSCGetter extends StatefulWidget {
  final void Function(String) emailSentCallback;

  ITSCGetter(this.emailSentCallback);

  @override
  State<ITSCGetter> createState() => _ITSCGetterState(emailSentCallback);
}

class _ITSCGetterState extends State<ITSCGetter>
    with SingleTickerProviderStateMixin {
  final void Function(String) emailSentCallback;

  final String _title = "Register";

  final String _keyPairURL =
      "https://eosauthority.com/generate_eos_private_key";

  late BuildContext _context;
  late AnimationController _controller;
  late Animation _animation;

  FocusNode _focusNode = FocusNode();

  TextEditingController _itscFieldController = TextEditingController();

  _ITSCGetterState(this.emailSentCallback);

  @override
  void dispose() {
    // _controller.dispose();
    _focusNode.dispose();

    super.dispose();
  }

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
      // print("itsc:" + itsc);
      // Response response = await dio.post("/registration", data: {'itsc': itsc});
      // print("itsc response");
      // print(response);
      widget.emailSentCallback(itsc);
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
    return Container(
      alignment: Alignment.center,
      child: Column(
        children: [
          Flexible(
            child: Container(
              // alignment: Alignment.center,
              child: FractionallySizedBox(
                alignment: Alignment.topCenter,
                heightFactor: 1,
                child: Column(
                  children: [
                    Expanded(flex: 10, child: Container()),
                    Expanded(
                      flex: 2,
                      child: RichText(
                        text: const TextSpan(
                          text: 'Step 1: Generate EOSIO key pair',
                          style: TextStyle(
                              fontSize: 18.0, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    Expanded(flex: 1, child: Container()),
                    // Flexible(
                    //   child: FractionallySizedBox(
                    //     heightFactor: 0.25,
                    //   ),
                    // ),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton(
                        child: Text(
                          "Get Key Pair!",
                          style: Theme.of(context).textTheme.button,
                        ),
                        onPressed: _gotoKeyGen,
                      ),
                    ),
                    Expanded(flex: 1, child: Container()),
                  ],
                ),
              ),
            ),
          ),
          Flexible(
            child: Container(
              // color: Colors.yellow,
              // alignment: Alignment.center,
              child: FractionallySizedBox(
                heightFactor: 1,
                child: Column(
                  children: [
                    Expanded(flex: 10, child: Container()),
                    Expanded(
                      flex: 10,
                      child: Text(
                        "Step 2: Get verification code",
                        style: TextStyle(
                            fontSize: 18.0, fontWeight: FontWeight.bold),
                      ),
                    ),
                    Expanded(
                        flex: 10,
                        child: Row(
                          children: [
                            Expanded(flex: 15, child: Container()),
                            Expanded(
                              flex: 70,
                              child: TextField(
                                decoration: InputDecoration(
                                  // border: OutlineInputBorder(),
                                  hintText: 'ITSC Account',
                                  suffixIcon: Icon(Icons.email),
                                ),
                                onSubmitted: _sendRegistrationRequest,
                                controller: _itscFieldController,
                                focusNode: _focusNode,
                              ),
                            ),
                            Expanded(flex: 15, child: Container()),
                          ],
                        )),
                    Expanded(flex: 10, child: Container()),
                    Expanded(
                      flex: 10,
                      child: ElevatedButton(
                        onPressed: _registerBtnHandler,
                        child: Text(
                          "Register",
                          style: Theme.of(context).textTheme.button,
                        ),
                      ),
                    ),
                    Expanded(flex: 50, child: Container()),
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
