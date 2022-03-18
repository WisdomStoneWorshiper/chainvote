import 'dart:async';

import 'package:flutter/material.dart';
import 'package:expandable/expandable.dart';

import '../../../global_variable.dart';
import 'campaign.dart';
import 'voter.dart';

abstract class CampaignList extends StatefulWidget {
  final String itsc;
  final String eosAccountName;
  const CampaignList(
      {required this.itsc, required this.eosAccountName, Key? key})
      : super(key: key);
}

abstract class CampaignListState extends State<CampaignList> {
  final String itsc;
  final String eosAccountName;

  late Voter user;

  CampaignListState({required this.itsc, required this.eosAccountName});

  bool isReload = false;
  List<Campaign> reloadResult = [];

  Future<List<Campaign>> init(String voterName);

  Future _onRefresh() async {
    isReload = true;
    reloadResult = [];
    await init(eosAccountName);
    // return init(eosAccountName);
    setState(() {});
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
      collapsed: Text("test"),
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
          } else {
            Widget loading = SizedBox(
              width: 200,
              height: 200,
              child: CircularProgressIndicator(),
            );
            ongoing = [loading];
            ended = [loading];
            coming = [loading];
          }
          print(ongoing.length);
          return ListView(
            children: [
              _expandView("Ongoing Campaign", ongoing),
              _expandView("Upcoming Campaign", coming),
              _expandView("Ended Campaign", ended),
            ],
          );
        },
      ),
    );
  }
}
