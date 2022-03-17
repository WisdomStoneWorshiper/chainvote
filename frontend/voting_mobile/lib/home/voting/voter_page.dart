import 'dart:async';

import 'package:flutter/material.dart';
import 'package:expandable/expandable.dart';
// import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../../../global_variable.dart';
import '../campaign.dart';
import '../voter.dart';

class VoterPage extends StatefulWidget {
  final String itsc;
  final String eosAccountName;
  const VoterPage({required this.itsc, required this.eosAccountName, Key? key})
      : super(key: key);

  @override
  _VoterPageState createState() =>
      _VoterPageState(itsc: itsc, eosAccountName: eosAccountName);
}

class _VoterPageState extends State<VoterPage> {
  final String itsc;
  final String eosAccountName;

  late Voter user;

  _VoterPageState({required this.itsc, required this.eosAccountName});

  bool _isReload = false;
  List<Campaign> _reloadResult = [];

  Future<List<Campaign>> init(String voterName) async {
    if (_isReload == true && _reloadResult.isNotEmpty) {
      print("no need init");
      _isReload = false;
      return Future<List<Campaign>>.value(_reloadResult);
    }
    user = Voter(voterName: eosAccountName);
    await user.init();
    List<Campaign> t = [];
    for (VotingRecord vr in user.getVotableCampaigns()) {
      Campaign c = new Campaign(
        campaignId: vr.campaignId,
        view: CampaignView.List,
        callback: _viewVotableCampaign,
        isVoted:
            vr.isVoted == true ? CampaignVoteStat.Yes : CampaignVoteStat.No,
      );
      await c.init();
      t.add(c);
    }
    if (_isReload == true) {
      _reloadResult = t;
    }
    // print(t.length);
    return Future<List<Campaign>>.value(t);
  }

  Future _onRefresh() async {
    _isReload = true;
    _reloadResult = [];
    await init(eosAccountName);
    // return init(eosAccountName);
    setState(() {});
  }

  void _viewVotableCampaign(Campaign c) {
    Navigator.pushNamed(context, 'v', arguments: c);
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
