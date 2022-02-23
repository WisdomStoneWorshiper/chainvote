import 'package:flutter/material.dart';

class VoteSuccess extends StatelessWidget {
  const VoteSuccess({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Align(
        alignment: Alignment.center,
        child: Center(
          child: Column(
            children: [
              const Icon(
                Icons.check_circle_outline,
                color: Colors.green,
                size: 60,
              ),
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Text('Your Vote Submitted Successfully'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.popUntil(context, ModalRoute.withName('h'));
                },
                child: Text("Return to Home"),
              )
            ],
          ),
        ),
      ),
    );
  }
}
