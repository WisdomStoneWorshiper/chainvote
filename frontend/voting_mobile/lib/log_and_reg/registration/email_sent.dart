import 'package:flutter/material.dart';

class EmailSent extends StatelessWidget {
  final String email;
  const EmailSent(this.email);

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    var padding = MediaQuery.of(context).padding;
    double newHeight = height - padding.top - padding.bottom;

    return Center(
      child: Column(
        children: [
          SizedBox(
            height: newHeight * 0.18,
          ),
          Icon(
            IconData(0xf588, fontFamily: 'MaterialIcons'),
            size: newHeight * 0.2,
            color: Theme.of(context).colorScheme.primary,
          ),
          SizedBox(
            height: newHeight * 0.045,
          ),
          RichText(
            text: const TextSpan(
              text: "The code has been sent to ",
              style: TextStyle(fontSize: 25.0, fontWeight: FontWeight.normal),
            ),
          ),
          SizedBox(
            height: newHeight * 0.025,
          ),
          RichText(
            text: TextSpan(
              text:
                  email + "@connect.ust.hk", // ADD CORRECT EMAIL VARIABLE HERE
              style: TextStyle(fontSize: 23.0, fontWeight: FontWeight.bold),
            ),
          ),
          SizedBox(
            height: newHeight * 0.055,
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
              minimumSize: Size(width * 0.78, 42),
            ),
          )
        ],
      ),
    );
  }
}
