import 'package:flutter/material.dart';
import './link_up.dart';

class EOSIOAccCreate extends StatelessWidget {
  final String _title = "Welcome, ";
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
        body: Column(
          children: [
            Text("Have an EOSIO account?"),
            ElevatedButton(
                onPressed: () {
                  this._haveEOSAcc = true;
                  _linkUpHander();
                },
                child: Text("Use my own account")),
            Text("Don't have an EOSIO account?"),
            ElevatedButton(
                onPressed: () {
                  this._haveEOSAcc = false;
                  _linkUpHander();
                },
                child: Text("Create a EOSIO account"))
          ],
        ));
  }
}
