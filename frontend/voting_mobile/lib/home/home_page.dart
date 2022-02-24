import 'dart:async';

import 'package:flutter/material.dart';
// import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../../global_variable.dart';
import './campaign.dart';
import './voter.dart';

class HomePage extends StatefulWidget {
  final String itsc;
  final String eosAccountName;
  const HomePage({required this.itsc, required this.eosAccountName, Key? key})
      : super(key: key);

  @override
  _HomePageState createState() =>
      _HomePageState(itsc: itsc, eosAccountName: eosAccountName);
}

class _HomePageState extends State<HomePage> {
  final String itsc;
  final String eosAccountName;

  late Voter user;

  _HomePageState({required this.itsc, required this.eosAccountName});

  bool _isLoad = false;
  Future<List<Campaign>> init(String voterName) async {
    user = Voter(voterName: eosAccountName);
    await user.init();
    List<Campaign> t = [];
    for (VotingRecord vr in user.getVotableCampaigns()) {
      Campaign c = new Campaign(
        campaignId: vr.campaignId,
        isDetail: false,
        callback: _viewVotableCampaign,
        isVoted: vr.isVoted,
      );
      await c.init();
      t.add(c);
    }
    _isLoad = true;
    // print(t.length);
    return Future<List<Campaign>>.value(t);
  }

  Future<void> _onRefresh() async {
    _isLoad = false;
    setState(() {});
    await Future.doWhile(() async {
      if (_isLoad == true) {
        return true;
      } else {
        return false;
      }
    });
    // return Future.delayed(Duration(seconds: 2));
  }

  void _viewVotableCampaign(Campaign c) {
    Navigator.pushNamed(context, 'v', arguments: c);
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
          return Center(
              child: CustomScrollView(
            slivers: [
              SliverAppBar(
                title: Text("Ongoing Campaign"),
                pinned: true,
              ),
              SliverList(
                delegate: SliverChildListDelegate(ongoing),
              ),
              SliverAppBar(
                title: Text("Coming Campaign"),
                pinned: true,
              ),
              SliverList(
                delegate: SliverChildListDelegate(coming),
              ),
              SliverAppBar(
                title: Text("Ended Campaign"),
                pinned: true,
              ),
              SliverList(
                delegate: SliverChildListDelegate(ended),
              )
            ],
          ));
        },
      ),
    );
  }
}
