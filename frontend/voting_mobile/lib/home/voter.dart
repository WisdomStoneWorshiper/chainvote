import 'package:flutter/material.dart';
import '../../global_variable.dart';
import 'dart:async';
import './campaign.dart';

class VotingRecord {
  int campaignId;
  bool isVoted;
  VotingRecord({this.campaignId = -1, this.isVoted = false});

  void fromJson(dynamic json) {
    campaignId = json["campaign"];
    isVoted = json["is_vote"] == 0 ? false : true;
  }
}

class Voter {
  String voterName;
  List<int> _ownerCampaigns = [];
  List<VotingRecord> _votableCampaigns = [];

  bool is_active = false;
  Voter({required this.voterName});

  Future<bool> init() async {
    // List<Map<String, dynamic>> data_temp;
    var data_temp = await client.getTableRows(
        contractAccount, contractAccount, "voter",
        lower: voterName, upper: voterName);
    // print(data_temp);
    _ownerCampaigns = data_temp[0]["owned_campaigns"].cast<int>();
    _votableCampaigns = (data_temp[0]["votable_campaigns"] as List).map((temp) {
      VotingRecord tempV = new VotingRecord();
      tempV.fromJson(temp);
      return tempV;
    }).toList();
    is_active = (data_temp[0]["is_active"] == 0 ? false : true);
    // print(_ownerCampaigns);

    return Future<bool>.value(true);
  }

  Future<bool> test() {
    print("hi");
    return Future<bool>.value(true);
  }

  List<VotingRecord> getVotableCampaigns() {
    return _votableCampaigns;
  }
}
