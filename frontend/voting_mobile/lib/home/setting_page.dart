import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingPage extends StatelessWidget {
  const SettingPage({Key? key}) : super(key: key);

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
          )
        ],
      ),
    );
  }
}
