import 'package:flutter/material.dart';
import 'home_page.dart';
import 'owner_page.dart';
import 'voter_page.dart';
import 'setting_page.dart';

class HomeArg {
  final String itsc;
  final String eosAccountName;
  const HomeArg(this.itsc, this.eosAccountName);
}

class NavBarView extends StatefulWidget {
  const NavBarView({Key? key}) : super(key: key);

  @override
  _NavBarViewState createState() => _NavBarViewState();
}

class _NavBarViewState extends State<NavBarView> {
  bool _isInit = false;

  int _selectedIndex = 0;

  List<Widget> _pageOpts = <Widget>[];

  static const List<BottomNavigationBarItem> _barItem =
      <BottomNavigationBarItem>[
    BottomNavigationBarItem(
      icon: Icon(IconData(0xe32c, fontFamily: 'MaterialIcons')),
      label: 'Voting',
      backgroundColor: Colors.red,
    ),
    BottomNavigationBarItem(
      icon: Icon(IconData(0xe04e, fontFamily: 'MaterialIcons')),
      label: 'Manage Campaign',
      backgroundColor: Colors.green,
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.settings),
      label: 'Settings',
      backgroundColor: Colors.pink,
    ),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as HomeArg;
    if (!_isInit) {
      _pageOpts.add(HomePage(
        itsc: args.itsc,
        eosAccountName: args.eosAccountName,
      ));
      _pageOpts.add(OwnerPage());
      _pageOpts.add(SettingPage());
      _isInit = true;
    }
    return Scaffold(
      appBar: AppBar(
        title: Text("Voting App"),
      ),
      body: Center(
        child: _pageOpts.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: _barItem,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Colors.amber[800],
        backgroundColor: _barItem[_selectedIndex].backgroundColor,
      ),
    );
  }
}
