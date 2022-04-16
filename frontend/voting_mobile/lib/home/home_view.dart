import 'dart:async';

import 'package:flutter/material.dart';
import 'package:expandable/expandable.dart';

import '../../../global_variable.dart';
import 'campaign.dart';
import 'voter.dart';

abstract class CampaignList extends StatefulWidget {
  final String itsc;
  final String eosAccountName;
  final void Function(bool) refreshLock;
  const CampaignList(
      {required this.itsc,
      required this.eosAccountName,
      required this.refreshLock,
      Key? key})
      : super(key: key);
}

abstract class CampaignListState extends State<CampaignList>
    with TickerProviderStateMixin {
  final String itsc;
  final String eosAccountName;
  late AnimationController _loadingAnimationController;
  final void Function(bool) refreshLock;
  late TabController _tabController;

  List<Tab> _campaignTab = [
    Tab(
      child: Text("Ongoing"),
    ),
    Tab(
      child: Text("Upcoming"),
    ),
    Tab(
      child: Text("Ended"),
    ),
  ];

  late Voter user;

  CampaignListState(
      {required this.itsc,
      required this.eosAccountName,
      required this.refreshLock});

  @override
  void initState() {
    _loadingAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..repeat();
    _tabController = TabController(vsync: this, length: _campaignTab.length);
    super.initState();
  }

  @override
  void dispose() {
    _loadingAnimationController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  bool isReload = false;
  List<Campaign> reloadResult = [];

  Future<List<Campaign>> init(String voterName);

  Future _onRefresh() async {
    isReload = true;
    reloadResult = [];
    refreshLock(true);
    await init(eosAccountName);
    // return init(eosAccountName);
    setState(() {});
    refreshLock(false);
  }

  _expandView(String title, List<Widget> w) {
    final theme = Theme.of(context);
    final oldTextTheme = theme.textTheme.headline5;

    final newTextTheme =
        oldTextTheme!.copyWith(fontWeight: FontWeight.bold, fontSize: 30);
    return Container(
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).size.width * 0.03),
      child: ExpandablePanel(
        theme:
            ExpandableThemeData(iconColor: Color.fromARGB(185, 163, 214, 67)),
        header: Container(
          child: Text(
            title,
            style: newTextTheme,
          ),
        ),
        collapsed: Container(),
        expanded: Column(
          children: [for (var x in w) x],
        ),
      ),
    );
  }

  _getListView(List<Widget> w) {
    return RefreshIndicator(
        onRefresh: _onRefresh,
        child: ListView(
          children: [for (var x in w) x],
        ));
  }

  _noCampaignsToShow() {
    return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Image(
            height: MediaQuery.of(context).size.height * 0.25,
            image: AssetImage('assets/app_logo_transparent.png'),
          ),
          SizedBox(
            height: 20,
          ),
          Text("No campaigns to show",
              style: TextStyle(
                fontSize: 20,
              )),
          SizedBox(
            height: 50,
          ),
        ]);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: MediaQuery.of(context).size.width * 0.05,
        right: MediaQuery.of(context).size.width * 0.05,
      ),
      child: FutureBuilder(
        future: init(eosAccountName),
        builder: (context, snapshot) {
          List<Widget> ongoing = [];
          List<Widget> coming = [];
          List<Widget> ended = [];

          if (snapshot.hasData) {
            List<Campaign> tempList = snapshot.data as List<Campaign>;
            for (Campaign c in tempList) {
              if (c.getCampaignStat() == CampaignStat.Coming) {
                coming.add(c);
              } else if (c.getCampaignStat() == CampaignStat.Ended) {
                ended.add(c);
              } else {
                ongoing.add(c);
              }
            }
            print(ongoing.length);
            return Column(
              children: [
                TabBar(
                  controller: _tabController,
                  tabs: _campaignTab,
                ),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      ongoing.isNotEmpty
                          ? _getListView(ongoing)
                          : _noCampaignsToShow(),
                      coming.isNotEmpty
                          ? _getListView(coming)
                          : _noCampaignsToShow(),
                      ended.isNotEmpty
                          ? _getListView(ended)
                          : _noCampaignsToShow(),
                    ],
                  ),
                ),
              ],
            );

            ListView(
              children: [
                _expandView("Ongoing Campaign", ongoing),
                _expandView("Upcoming Campaign", coming),
                _expandView("Ended Campaign", ended),
              ],
            );
          } else {
            return Container(
              alignment: Alignment.center,
              child: Center(
                child: Column(
                  children: [
                    Container(
                      padding: EdgeInsets.only(
                          top: MediaQuery.of(context).size.height * 0.15,
                          bottom: MediaQuery.of(context).size.height * 0.1),
                      child: RotationTransition(
                        turns: Tween(begin: 0.0, end: 1.0)
                            .animate(_loadingAnimationController),
                        child: Image(
                          height: MediaQuery.of(context).size.height * 0.3,
                          image: AssetImage('assets/app_logo_transparent.png'),
                        ),
                      ),
                    ),
                    Text("Loading ... ",
                        style: TextStyle(
                          fontSize: 25,
                          fontWeight: FontWeight.bold,
                        )),
                  ],
                ),
              ),
            );
          }
        },
      ),
    );
  }
}
