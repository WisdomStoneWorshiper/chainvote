import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Voting App"),
      ),
      body: Center(
        // child: const Text(
        //   "We are still developing the homepage",
        //   style: TextStyle(fontSize: 25.0, fontWeight: FontWeight.bold),
        // ),
        child: RichText(
          text: const TextSpan(
            text: 'Home Page',
            style: TextStyle(
                color: Colors.black,
                fontSize: 30.0,
                fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}
