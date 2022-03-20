import 'package:flutter/material.dart';

class LogAndRegButton extends StatelessWidget {
  final String _labelText;
  final void Function() _callback;
  final Color _bgColor;
  const LogAndRegButton(this._labelText, this._bgColor, this._callback);

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
          minimumSize: Size(MediaQuery.of(context).size.width * 0.75, 42),
          primary: _bgColor,
        ),
      ),
    );
  }
}
