import 'package:flutter/material.dart';
import '../../global_variable.dart';

class Voter {
  final String voterName;
  List<int> _ownerCampaigns = [];
  List<int> _votableCampaigns = [];
  bool _is_active = false;
  Voter({required this.voterName}) {}

  Future init() async {
    client
        .getTableRows(contractAccount, contractAccount, "voter",
            lower: voterName, upper: voterName)
        .then((data_temp) {
      _ownerCampaigns = data_temp[0]["owned_campaigns"];
      _votableCampaigns = data_temp[0]["votable_campaigns"];
      _is_active = data_temp[0]["is_active"];
    });
  }

  List<int> getVotableCampaigns() {
    return _votableCampaigns;
  }
}
