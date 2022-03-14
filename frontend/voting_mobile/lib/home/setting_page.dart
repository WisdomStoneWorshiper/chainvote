import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:async';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';

import '../shared_dialog.dart';
import '../biometric_encrypt.dart';

class SettingPage extends StatefulWidget {
  SettingPage({Key? key}) : super(key: key);

  @override
  State<SettingPage> createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> with SharedDialog {
  // BiometricStorageFile? _pkStorage;
  final LocalAuthentication auth = LocalAuthentication();
  bool _isBio = false;
  final BiometricEncrypt _bio = BiometricEncrypt();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    _bio.isStored("pk").then((value) {
      setState(() {
        _isBio = value;
      });
    });
  }

  void _logoutHandler(BuildContext context) async {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: Text("Are you sure to logout?"),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text("Cancel"),
                ),
                TextButton(
                  onPressed: () async {
                    await _bio.delete("pk");
                    _isBio = false;
                    final prefs = await SharedPreferences.getInstance();
                    prefs.remove('itsc');
                    prefs.remove('eosName');
                    Navigator.pushReplacementNamed(context, 'l&r');
                  },
                  child: Text("Logout"),
                )
              ],
            ));
  }

  void _savePK(BuildContext context, String pk) async {
    try {
      await _bio.write("pk", pk, "Please lock your private key");
      print(pk);
      _isBio = true;
      Navigator.pop(context);
      setState(() {});
    } on PlatformException catch (e) {
      // print("no");
    }
  }

  void _biometricPKHandler(BuildContext context) async {
    if (_isBio == true) {
      await _bio.delete("pk");
      _isBio = false;
      setState(() {});
    } else {
      requestKey(context, _savePK, "", needLoading: false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: ListView(
        children: [
          ListTile(
            title: Text("Logout"),
            onTap: () {
              _logoutHandler(context);
            },
          ),
          ListTile(
            title: Text("Use biometric to save private key"),
            trailing: Switch(
              value: _isBio,
              onChanged: (bool) async {
                var canBio = await _bio.supportBiometric();
                if (canBio) _biometricPKHandler(context);
              },
            ),
          )
        ],
      ),
    );
  }
}
