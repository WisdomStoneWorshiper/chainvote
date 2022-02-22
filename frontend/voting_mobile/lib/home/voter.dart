import 'package:flutter/material.dart';
import '../../global_variable.dart';
import 'dart:async';

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
  void Function() callback;
  Voter({required this.voterName, required this.callback});

  // Future<bool> init() {
  //   client
  //       .getTableRows(contractAccount, contractAccount, "voter",
  //           lower: voterName, upper: voterName)
  //       .then((data_temp) {
  //     _ownerCampaigns = data_temp[0]["owned_campaigns"].cast<int>();
  //     _votableCampaigns = data_temp[0]["votable_campaigns"].cast<int>();
  //     is_active = (data_temp[0]["is_active"] == 0 ? false : true);
  //     return true;
  //   });

  //   // _ownerCampaigns = data_temp[0]["owned_campaigns"].cast<int>();
  //   // _votableCampaigns = data_temp[0]["votable_campaigns"].cast<int>();
  //   // is_active = (data_temp[0]["is_active"] == 0 ? false : true);
  //   // callback();
  // }

  Future<List<Map<String, dynamic>>> init() {
    // List<Map<String, dynamic>> data_temp;
    var data_temp = client.getTableRows(
        contractAccount, contractAccount, "voter",
        lower: voterName, upper: voterName);
    data_temp.then((d) {
      // print(d[0]["votable_campaigns"].runtimeType);
      _ownerCampaigns = d[0]["owned_campaigns"].cast<int>();
      _votableCampaigns = (d[0]["votable_campaigns"] as List).map((temp) {
        VotingRecord tempV = new VotingRecord();
        tempV.fromJson(temp);
        return tempV;
      }).toList();
      print(_votableCampaigns);
      is_active = (d[0]["is_active"] == 0 ? false : true);
    });
    return data_temp;
  }

  List<VotingRecord> getVotableCampaigns() {
    return _votableCampaigns;
  }
}
