import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

import '../../global_variable.dart';
import 'campaign_list_view.dart';
import 'voting_view.dart';

enum CampaignStat { Coming, Ongoing, Ended }

enum CampaignVoteStat { Yes, No, NA }

enum CampaignView { List, Voter }

class Choice {
  String choiceName;
  int result;
  Choice({required this.choiceName, required this.result});
}

class Campaign extends StatelessWidget {
  CampaignView view;
  final int campaignId;
  late String _campaignName;
  late String _owner;
  late DateTime _startTime;
  late DateTime _endTime;
  CampaignVoteStat isVoted;
  List<Choice> _choiceList = [];

  void Function(Campaign) callback;

  Campaign(
      {required this.campaignId,
      this.view = CampaignView.List,
      required this.callback,
      this.isVoted = CampaignVoteStat.NA});

  Future<bool> init() async {
    var data_temp = await client.getTableRow(
        contractAccount, contractAccount, "campaign",
        lower: campaignId.toString(), upper: campaignId.toString());
    _campaignName = data_temp!["campaign_name"];
    _owner = data_temp["owner"];
    _startTime = DateTime.parse(data_temp["start_time"] + 'Z');

    _endTime = DateTime.parse(data_temp["end_time"] + 'Z');
    for (Map<String, dynamic>? temp in data_temp["choice_list"]) {
      _choiceList
          .add(Choice(choiceName: temp!["choice"], result: temp["result"]));
    }
    print(data_temp);
    return Future<bool>.value(true);
  }

  DateTime getStartTime() {
    return _startTime;
  }

  DateTime getEndTime() {
    return _endTime;
  }

  String getCampaignName() {
    return _campaignName;
  }

  String getOwner() {
    return _owner;
  }

  List<Choice> getChoiceList() {
    return _choiceList;
  }

  void setview(CampaignView s) {
    view = s;
  }

  void setIsVoted(CampaignVoteStat s) {
    isVoted = s;
  }

  CampaignStat getCampaignStat() {
    print("now:" + DateTime.now().toUtc().toString());
    print("start:" + _startTime.toString());
    print("end:" + _endTime.toString());
    if (DateTime.now().toUtc().isBefore(_startTime)) {
      return CampaignStat.Coming;
    } else if (DateTime.now().toUtc().isAfter(_endTime)) {
      return CampaignStat.Ended;
    } else {
      return CampaignStat.Ongoing;
    }
  }

  @override
  Widget build(BuildContext context) {
    switch (view) {
      case CampaignView.List:
        {
          return CampaignListView(
            campaign: this,
          );
        }
        break;
      case CampaignView.Voter:
        {
          return VotingView(campaign: this);
        }
        break;

      default:
        {
          return CampaignListView(
            campaign: this,
          );
        }
        break;
    }
  }
}
