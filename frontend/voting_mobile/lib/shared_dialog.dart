import 'package:flutter/material.dart';

class SharedDialog {
  final TextEditingController _pkController = TextEditingController();
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
      void Function(BuildContext b, String s) action, String loadingMsg) {
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
                    showLoaderDialog(context, loadingMsg);

                    action(context, _pkController.text);
                  },
                  child: Text("Submit"),
                )
              ],
            ));
  }
}
