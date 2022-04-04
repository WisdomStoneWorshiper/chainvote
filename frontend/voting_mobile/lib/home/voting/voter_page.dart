import 'dart:async';

import 'package:flutter/material.dart';
import 'package:expandable/expandable.dart';

import '../../../global_variable.dart';
import '../campaign.dart';
import '../voter.dart';
import '../home_view.dart';

class VoterPage extends CampaignList {
  const VoterPage(
      {required String itsc,
      required String eosAccountName,
      required void Function(bool) refreshLock,
      Key? key})
      : super(
            itsc: itsc,
            eosAccountName: eosAccountName,
            refreshLock: refreshLock);

  @override
  _VoterPageState createState() => _VoterPageState(
      itsc: itsc, eosAccountName: eosAccountName, refreshLock: refreshLock);
}

class _VoterPageState extends CampaignListState {
  _VoterPageState(
      {required String itsc,
      required String eosAccountName,
      required void Function(bool) refreshLock})
      : super(
            itsc: itsc,
            eosAccountName: eosAccountName,
            refreshLock: refreshLock);

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
    for (VotingRecord vr in user.getVotableCampaigns()) {
      Campaign c = Campaign(
        campaignId: vr.campaignId,
        view: CampaignView.List,
        callback: _viewVotableCampaign,
        isVoted:
            vr.isVoted == true ? CampaignVoteStat.Yes : CampaignVoteStat.No,
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

  void _viewVotableCampaign(Campaign c) {
    Navigator.pushNamed(context, 'v', arguments: c);
  }
}
