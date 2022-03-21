import 'dart:async';

import 'package:flutter/material.dart';
// import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../../../global_variable.dart';
import '../campaign.dart';
import '../voter.dart';

class OwnerPage extends StatefulWidget {
  final String itsc;
  final String eosAccountName;
  const OwnerPage({required this.itsc, required this.eosAccountName, Key? key})
      : super(key: key);

  @override
  _OwnerPageState createState() =>
      _OwnerPageState(itsc: itsc, eosAccountName: eosAccountName);
}

class _OwnerPageState extends State<OwnerPage> {
  final String itsc;
  final String eosAccountName;

  late Voter user;

  _OwnerPageState({required this.itsc, required this.eosAccountName});

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
    for (int vr in user.getOwnerCampaigns()) {
      print(vr.toString());
      Campaign c = new Campaign(
        campaignId: vr,
        view: CampaignView.List,
        callback: _viewManageCampaign,
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

  void _viewManageCampaign(Campaign c) {
    Navigator.pushNamed(context, 'm', arguments: c);
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
          print("building");
          if (snapshot.hasData) {
            print("nani");
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
            print("why not here");
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
