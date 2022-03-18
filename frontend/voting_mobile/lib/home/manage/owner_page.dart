import 'dart:async';

import 'package:flutter/material.dart';
// import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../../../global_variable.dart';
import '../campaign.dart';
import '../voter.dart';
import '../home_view.dart';

class OwnerPage extends CampaignList {
  const OwnerPage(
      {required String itsc, required String eosAccountName, Key? key})
      : super(itsc: itsc, eosAccountName: eosAccountName);

  @override
  _OwnerPageState createState() =>
      _OwnerPageState(itsc: itsc, eosAccountName: eosAccountName);
}

class _OwnerPageState extends CampaignListState {
  _OwnerPageState({
    required String itsc,
    required String eosAccountName,
  }) : super(itsc: itsc, eosAccountName: eosAccountName);

  @override
  Future<List<Campaign>> init(String voterName) async {
    if (isReload == true && reloadResult.isNotEmpty) {
      print("no need init");
      isReload = false;
      return Future<List<Campaign>>.value(reloadResult);
    }

    user = Voter(voterName: eosAccountName);
    await user.init();
    List<Campaign> t = [];
    for (int vr in user.getOwnerCampaigns()) {
      print(vr.toString());
      Campaign c = Campaign(
        campaignId: vr,
        view: CampaignView.List,
        callback: _viewManageCampaign,
      );
      await c.init();
      t.add(c);
    }
    if (isReload == true) {
      reloadResult = t;
    }

    // print(t.length);
    return Future<List<Campaign>>.value(t);
  }

  void _viewManageCampaign(Campaign c) {
    Navigator.pushNamed(context, 'm', arguments: c);
  }
}
