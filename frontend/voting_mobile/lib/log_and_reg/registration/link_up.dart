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
    BaseOptions opt = BaseOptions(baseUrl: backendServerUrl);
    var dio = Dio(opt);
    try {
      var response;
      if (_needCreateEOSIO) {
        print("create");
        response = await dio.post("/account/create", data: {
          'itsc': _itsc,
          'key': _codeController.text,
          'accname': _eosAccController.text,
          'pkey': _eosPublicKeyController.text
        });
      } else {
        print("confirm");
        response = await dio.post("/account/confirm", data: {
          'itsc': _itsc,
          'key': _codeController.text,
          'accname': _eosAccController.text
        });
      }

      if (response.statusCode != 200) {
        errDialog(context, "Fail to create, Reason: " + response["message"]!);
      }
      print(response);
    } catch (e) {
      DioError err = e as DioError;

      Map<String, dynamic> response = (err.response?.data);

      errDialog(context, "Fail to create, Reason: " + response["message"]!);

      return;
    }
    SuccessPageArg arg = SuccessPageArg(
        message: 'Your Account Created Successfully', returnPage: 'l');
    Navigator.pushNamed(_context, 's', arguments: arg);
  }

  void showAlertBox() async {
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
      showDialog(
          context: context,
          builder: (BuildContext context) => AlertDialog(
                title: const Text('Alert'),
                content: const Text('Did you save your key pair successfully?'),
                actions: <Widget>[
                  TextButton(
                    onPressed: () => Navigator.pop(context, 'Cancel'),
                    child: const Text('Cancel'),
                  ),
                  ElevatedButton(
                    onPressed: () =>
                        {Navigator.pop(context, 'Yes'), _submitLinpUpRequest()},
                    child: const Text('Yes'),
                  ),
                ],
              ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    final args = ModalRoute.of(context)!.settings.arguments as String;
    _itsc = args;
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
                    height: MediaQuery.of(context).size.height * 0.2,
                    image: AssetImage('assets/app_logo_transparent.png'),
                  ),
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
                      bottom: 15,
                    ),
                    child: TextField(
                      decoration: InputDecoration(
                        labelText: 'EOS Account Name',
                        hintText: 'EOS Account Name',
                        suffixIcon: Icon(Icons.account_box),
                      ),
                      controller: _eosAccController,
                    ),
                  ),
                  Row(
                    children: [
                      Text(
                        "I need to create EOSIO account.",
                        style: TextStyle(
                          fontSize: 16,
                        ),
                      ),
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
                            Padding(
                              padding: EdgeInsets.only(
                                top: 10,
                              ),
                              child: ElevatedButton(
                                child: Text(
                                  "Get Key pair",
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500),
                                ),
                                onPressed: _gotoKeyGen,
                              ),
                            ),
                            Container(
                              margin: EdgeInsets.only(
                                top: MediaQuery.of(context).size.height * 0.01,
                                bottom:
                                    MediaQuery.of(context).size.height * 0.02,
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
                            Text(
                              "Remember to save your key pair!",
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.w500),
                            )
                          ],
                        )
                      : Container(),
                  Padding(
                      padding: EdgeInsets.only(top: 20),
                      child: ElevatedButton(
                        child: Text(
                          "Register",
                          style: TextStyle(
                              fontSize: 24, fontWeight: FontWeight.w700),
                        ),
                        onPressed: () => showAlertBox(),

                        //_submitLinpUpRequest,
                      )),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
