import 'package:flutter/material.dart';

class EmailSent extends StatelessWidget {
  final String email;
  const EmailSent(this.email);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          Icon(IconData(0xf588, fontFamily: 'MaterialIcons')),
          Text("The code has sent to " + email),
          ElevatedButton(
              onPressed: () {
                Navigator.popAndPushNamed(context, 'r');
                Navigator.pushNamed(context, 'e', arguments: email);
              },
              child: Text("Enter code"))
        ],
      ),
    );
  }
}
