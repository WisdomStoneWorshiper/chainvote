import 'package:flutter/material.dart';

class LogAndRegButton extends StatelessWidget {
  final String _labelText;
  final void Function() _callback;
  const LogAndRegButton(this._labelText, this._callback);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: ElevatedButton(
        child: Text(
          _labelText,
          style: TextStyle(fontSize: 25.0, fontWeight: FontWeight.bold),
        ),
        onPressed: _callback,
        style: ElevatedButton.styleFrom(
          //primary: Colors.blue,
          minimumSize: const Size(300, 42),
        ),
      ),
    );
  }
}