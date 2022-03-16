import 'package:flutter/material.dart';

class SuccessPageArg {
  String message;
  String returnPage;
  Object? arg;
  SuccessPageArg({required this.message, required this.returnPage, this.arg});
}

class SuccessPage extends StatelessWidget {
  const SuccessPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as SuccessPageArg;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
      ),
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
                child: Text(args.message),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushNamedAndRemoveUntil(
                      context, args.returnPage, (r) => false,
                      arguments: args.arg);
                },
                child: Text("OK"),
              )
            ],
          ),
        ),
      ),
    );
  }
}
