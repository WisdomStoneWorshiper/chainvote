import 'package:flutter/material.dart';

class EmailSent extends StatelessWidget {
  final String email;
  const EmailSent(this.email);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          const SizedBox(
            height: 150,
          ),
          const Icon(
            IconData(0xf588, fontFamily: 'MaterialIcons'),
            size: 200,
          ),
          const SizedBox(
            height: 25,
          ),
          RichText(
            text: const TextSpan(
              text: "The code has been sent to ",
              style: TextStyle(
                  color: Colors.black,
                  fontSize: 25.0,
                  fontWeight: FontWeight.normal),
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          RichText(
            text: TextSpan(
              text:
                  email + "@connect.ust.hk", // ADD CORRECT EMAIL VARIABLE HERE
              style: TextStyle(
                  color: Colors.black,
                  fontSize: 23.0,
                  fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(
            height: 75,
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.popAndPushNamed(context, 'r');
              Navigator.pushNamed(context, 'e', arguments: email);
            },
            child: const Text(
              "Enter Code",
              style: TextStyle(fontSize: 25.0, fontWeight: FontWeight.bold),
            ),
            style: ElevatedButton.styleFrom(
              //primary: Colors.blue,
              minimumSize: const Size(300, 42),
            ),
          )
        ],
      ),
    );
  }
}
