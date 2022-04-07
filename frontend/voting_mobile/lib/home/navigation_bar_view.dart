import 'package:flutter/material.dart';
import 'voting/voter_page.dart';
import 'manage/owner_page.dart';
import 'voting/votable_page.dart';
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

  bool _refreshLock = false;

  void _setRefreshLock(bool val) {
    _refreshLock = val;
  }

  static List<String> _tabName = [
    'Voting',
    'Manage Campaign',
    'Settings',
  ];

  static List<BottomNavigationBarItem> _barItem = <BottomNavigationBarItem>[
    BottomNavigationBarItem(
      icon: Icon(IconData(0xe32c, fontFamily: 'MaterialIcons')),
      label: _tabName[0],
      backgroundColor: Color.fromARGB(255, 36, 48, 65),
    ),
    BottomNavigationBarItem(
      icon: Icon(IconData(0xe04e, fontFamily: 'MaterialIcons')),
      label: _tabName[1],
      backgroundColor: Color.fromARGB(255, 36, 48, 65),
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.settings),
      label: _tabName[2],
      backgroundColor: Color.fromARGB(255, 36, 48, 65),
    ),
  ];

  void _onItemTapped(int index) {
    if (_refreshLock == false) {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as HomeArg;
    if (!_isInit) {
      _pageOpts.add(VoterPage(
        itsc: args.itsc,
        eosAccountName: args.eosAccountName,
        refreshLock: _setRefreshLock,
      ));
      _pageOpts.add(OwnerPage(
        itsc: args.itsc,
        eosAccountName: args.eosAccountName,
        refreshLock: _setRefreshLock,
      ));
      _pageOpts.add(SettingPage());
      _isInit = true;
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(_tabName[_selectedIndex]),
        // Row(
        //   mainAxisAlignment: MainAxisAlignment.center,
        //   children: [
        //     Container(
        //       padding: EdgeInsets.only(
        //           right: MediaQuery.of(context).size.width * 0.02),
        //       child: Image(
        //         height: MediaQuery.of(context).size.height * 0.05,
        //         image: AssetImage('assets/app_logo_transparent.png'),
        //       ),
        //     ),
        //     Text("Chainvote")
        //   ],
        // ),
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
      floatingActionButton: _selectedIndex == 1
          ? FloatingActionButton(
              onPressed: () {
                Navigator.pushNamed(context, 'c');
              },
              child: Icon(Icons.add),
            )
          : null,
    );
  }
}
