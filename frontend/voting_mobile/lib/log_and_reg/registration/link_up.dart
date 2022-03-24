import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../global_variable.dart';
import '../../success_page.dart';
import '../../shared_dialog.dart';

class LinkUpArg {
  final String itsc;
  final bool needCreateEOSIO;
  const LinkUpArg(this.itsc, this.needCreateEOSIO);
}

class LinkUp extends StatefulWidget {
  LinkUp({Key? key}) : super(key: key);

  @override
  State<LinkUp> createState() => _LinkUpState();
}

class _LinkUpState extends State<LinkUp> with SharedDialog {
  String _itsc = "";

  bool _needCreateEOSIO = false;

  TextEditingController _itscController = TextEditingController();

  TextEditingController _codeController = TextEditingController();

  TextEditingController _eosAccController = TextEditingController();

  TextEditingController _eosPublicKeyController = TextEditingController();

  late BuildContext _context;

  void _gotoKeyGen() async {
    if (!await launch(
      keyPairURL,
      forceSafariVC: true,
      forceWebView: true,
      headers: <String, String>{'my_header_key': 'my_header_value'},
    )) {
      throw 'Could not launch $keyPairURL';
    }
  }

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
        if (response.statusCode != 200) {
          // errDialog(context, "Fail to create, Reason: " + response["message"]!);
        }
        print(response);
      } catch (e) {
        DioError err = e as DioError;

        Map<String, dynamic> response = (err.response?.data);

        errDialog(context, "Fail to create, Reason: " + response["message"]!);

        return;
      }
      SuccessPageArg arg = SuccessPageArg(
          message: 'Your Account Created Successfully', returnPage: 'l&r');
      Navigator.pushNamed(_context, 's', arguments: arg);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    final args = ModalRoute.of(context)!.settings.arguments as String;
    _itsc = args; //args.itsc; UNCOMMENT LATER PLEASE ADD RIGHT EMAIL VARIABLE
    _itscController.text = _itsc;
    _context = context;
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        body: SafeArea(
          child: SingleChildScrollView(
            child: Container(
              margin: EdgeInsets.only(
                top: MediaQuery.of(context).size.height * 0.05,
                left: MediaQuery.of(context).size.width * 0.1,
                bottom: MediaQuery.of(context).size.height * 0.1,
                right: MediaQuery.of(context).size.width * 0.1,
              ),
              child: Column(
                children: [
                  Image(
                    height: MediaQuery.of(context).size.height * 0.1,
                    image: AssetImage('assets/app_logo_transparent.png'),
                  ),
                  // Expanded(flex: 1, child: Container()),

                  Container(
                    margin: EdgeInsets.only(
                      top: MediaQuery.of(context).size.height * 0.07,
                    ),
                    child: TextField(
                      enabled: false,
                      decoration: InputDecoration(
                        labelText: "ITSC",
                        suffixIcon: Icon(Icons.person),
                      ),
                      controller: _itscController,
                      // focusNode: _focusNode,
                    ),
                  ),

                  Container(
                    margin: EdgeInsets.only(
                      top: MediaQuery.of(context).size.height * 0.05,
                    ),
                    child: TextField(
                      decoration: InputDecoration(
                        labelText: "Verification Code",
                        hintText: 'Verification Code',
                        suffixIcon: Icon(Icons.key),
                      ),
                      controller: _codeController,
                    ),
                  ),

                  Container(
                    margin: EdgeInsets.only(
                      top: MediaQuery.of(context).size.height * 0.05,
                    ),
                    child: TextField(
                      decoration: InputDecoration(
                        labelText: 'EOS Account Name',
                        hintText: 'EOS Account Name',
                        suffixIcon: Icon(Icons.account_box),
                      ),
                      controller: _codeController,
                      // focusNode: _focusNode,
                    ),
                  ),

                  Row(
                    children: [
                      Text("I need to create EOSIO account."),
                      Switch(
                          value: _needCreateEOSIO,
                          onChanged: (bool val) {
                            _needCreateEOSIO = val;

                            setState(() {
                              // print(MediaQuery.of(context).size.height);
                            });
                          })
                    ],
                  ),

                  _needCreateEOSIO
                      ? Column(
                          children: [
                            ElevatedButton(
                              child: Text("Get Key pair"),
                              onPressed: _gotoKeyGen,
                            ),
                            Container(
                              margin: EdgeInsets.only(
                                top: MediaQuery.of(context).size.height * 0.01,
                                bottom:
                                    MediaQuery.of(context).size.height * 0.01,
                              ),
                              child: TextField(
                                decoration: InputDecoration(
                                  labelText: 'EOS Public Key',
                                  hintText: 'EOS Public Key',
                                  suffixIcon: Icon(Icons.key_sharp),
                                ),
                                controller: _eosPublicKeyController,
                                // focusNode: _focusNode,
                              ),
                            ),
                            Text("Remember save your key pair before Register")
                          ],
                        )
                      : Container(),

                  ElevatedButton(
                    child: Text("Register"),
                    onPressed: _submitLinpUpRequest,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
