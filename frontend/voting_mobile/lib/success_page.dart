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
        title: Text(
          "Confirmed",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Align(
        alignment: Alignment.center,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Icon(
                Icons.check_circle_outline,
                color: Colors.green,
                size: 180,
              ),
              Padding(
                padding: const EdgeInsets.only(top: 16, left: 30, right: 30),
                child: Text(
                  args.message,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              SizedBox(height: 30),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushNamedAndRemoveUntil(
                      context, args.returnPage, (r) => false,
                      arguments: args.arg);
                },
                child: Text("OK"),
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(100, 40),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
