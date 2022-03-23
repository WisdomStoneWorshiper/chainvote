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
    with SingleTickerProviderStateMixin {
  final String itsc;
  final String eosAccountName;
  late AnimationController _loadingAnimationController;
  final void Function(bool) refreshLock;

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
    super.initState();
  }

  @override
  void dispose() {
    _loadingAnimationController.dispose();
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
    return ExpandablePanel(
      theme: ExpandableThemeData(iconColor: Colors.cyan),
      header: Container(
        alignment: Alignment.centerLeft,
        child: Text(
          title,
          style: Theme.of(context).textTheme.headline6,
        ),
      ),
      collapsed: Text("Total campaign: " + w.length.toString()),
      expanded: Column(
        children: [for (var x in w) x],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _onRefresh,
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
            return ListView(
              children: [
                _expandView("Ongoing Campaign", ongoing),
                _expandView("Upcoming Campaign", coming),
                _expandView("Ended Campaign", ended),
              ],
            );
          } else {
            // Widget loading = SizedBox(
            //   width: 200,
            //   height: 200,
            //   child: CircularProgressIndicator(),
            // );
            // ongoing = [loading];
            // ended = [loading];
            // coming = [loading];
            return Container(
              alignment: Alignment.center,
              child: Center(
                child: Column(
                  children: [
                    Container(
                      padding: EdgeInsets.only(
                          top: MediaQuery.of(context).size.height * 0.2,
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
                    Text("Loading ... "),
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
