import 'package:flutter/material.dart';
import './link_up.dart';

class EOSIOAccCreate extends StatelessWidget {
  final String _title = "EOSIO Account ";
  late String _itsc;
  bool _haveEOSAcc = false;
  late BuildContext _context;
  EOSIOAccCreate({Key? key}) : super(key: key);

  void _linkUpHander() {
    LinkUpArg arg = LinkUpArg(_itsc, !_haveEOSAcc);
    Navigator.pushNamed(_context, 'lu', arguments: arg);
  }

  @override
  Widget build(BuildContext context) {
    _context = context;
    _itsc = ModalRoute.of(context)!.settings.arguments as String;
    return Scaffold(
        appBar: AppBar(
          title: Text(_title + _itsc),
        ),
        body: Center(
            child: Column(
          children: [
            const SizedBox(
              height: 225,
            ),
            const Text(
              "Already have an EOSIO account?",
              style: TextStyle(fontSize: 22.0, fontWeight: FontWeight.bold),
            ),
            const SizedBox(
              height: 10,
            ),
            ElevatedButton(
              onPressed: () {
                this._haveEOSAcc = true;
                _linkUpHander();
              },
              child: const Text(
                "Use Existing Account",
                style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                //primary: Colors.blue,
                minimumSize: const Size(300, 42),
              ),
            ),
            const SizedBox(
              height: 125,
            ),
            const Text(
              "Don't have an EOSIO account?",
              style: TextStyle(fontSize: 22.0, fontWeight: FontWeight.w500),
            ),
            const SizedBox(
              height: 10,
            ),
            ElevatedButton(
              onPressed: () {
                this._haveEOSAcc = false;
                _linkUpHander();
              },
              child: const Text(
                "Create an EOSIO Account",
                style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                //primary: Colors.blue,
                minimumSize: const Size(300, 42),
              ),
            )
          ],
        )));
  }
}
