import 'package:flutter/material.dart';

class LogAndRegButton extends StatelessWidget {
  final String _labelText;
  final void Function() _callback;
  const LogAndRegButton(this._labelText, this._callback);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: ElevatedButton(
        child: Text(_labelText),
        onPressed: _callback,
        style: ElevatedButton.styleFrom(
          primary: Colors.blue,
        ),
      ),
    );
  }
}