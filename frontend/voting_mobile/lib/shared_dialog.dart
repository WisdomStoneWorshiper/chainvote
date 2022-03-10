import 'package:flutter/material.dart';
import 'biometric_encrypt.dart';

class SharedDialog {
  final TextEditingController _pkController = TextEditingController();
  final BiometricEncrypt _bio = BiometricEncrypt();
  void errDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Error"),
        content: Text(message),
        actions: [
          TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text("ok"))
        ],
      ),
    );
  }

  void showLoaderDialog(BuildContext context, String loadingMsg) {
    AlertDialog alert = AlertDialog(
      content: new Row(
        children: [
          CircularProgressIndicator(),
          Container(
            margin: EdgeInsets.only(left: 7),
            child: Text(loadingMsg + "..."),
          ),
        ],
      ),
    );
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  void requestKey(BuildContext context,
      void Function(BuildContext b, String s) action, String loadingMsg,
      {bool needLoading = true}) async {
    var isStored = await _bio.isStored("pk");
    if (isStored == false) {
      showDialog(
          context: context,
          builder: (context) => AlertDialog(
                title: Text("Please input your EOSIO account Private Key"),
                content: TextField(
                  decoration: InputDecoration(hintText: "Private Key"),
                  controller: _pkController,
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text("Cancel"),
                  ),
                  TextButton(
                    onPressed: () async {
                      if (needLoading == true)
                        showLoaderDialog(context, loadingMsg);

                      action(context, _pkController.text);
                      _pkController.clear();
                    },
                    child: Text("Submit"),
                  )
                ],
              ));
    } else {
      var pk = await _bio.read("pk", "Please unlock the private key");
      print(pk);
      if (needLoading == true) showLoaderDialog(context, loadingMsg);
      action(context, pk!);
    }
  }
}
