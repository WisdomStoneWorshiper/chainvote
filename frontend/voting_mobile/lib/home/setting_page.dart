import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:biometric_storage/biometric_storage.dart';

import '../shared_dialog.dart';

class SettingPage extends StatelessWidget with SharedDialog {
  BiometricStorageFile? _pkStorage;

  SettingPage({Key? key}) : super(key: key);

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

  void _biometricHandler(BuildContext context) async {
    final response = await BiometricStorage().canAuthenticate();
    if (response == CanAuthenticateResponse.unsupported) {
      print("rip");
      errDialog(context, "This device do not support biometric");
      return;
    }
    _pkStorage = await BiometricStorage()
        .getStorage('pk', options: StorageFileInitOptions());
    _getPk(_pkStorage!);
  }

  void _getPk(BiometricStorageFile bs) async {
    print("hi");
    bs.write("test");
    String? test = await bs.read();
    print(test);
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
            onTap: () {
              _biometricHandler(context);
            },
          )
        ],
      ),
    );
  }
}
