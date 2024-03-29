import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

import '../../global_variable.dart';
import 'campaign_list_view.dart';

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
  List<String> _voterList = [];

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

    BaseOptions opt = BaseOptions(baseUrl: backendServerUrl);
    var dio = Dio(opt);
    Response response = await dio
        .post("/contract/getITSC", data: {'accountName': data_temp["owner"]});
    if (response.statusCode == 200) {
      print(response.data);

      if (response.data["itsc"] != null) {
        _owner = response.data["itsc"];
      } else {
        _owner = data_temp["owner"];
      }
    } else {
      _owner = data_temp["owner"];
    }

    _startTime = DateTime.parse(data_temp["start_time"] + 'Z');

    _endTime = DateTime.parse(data_temp["end_time"] + 'Z');
    for (Map<String, dynamic>? temp in data_temp["choice_list"]) {
      _choiceList
          .add(Choice(choiceName: temp!["choice"], result: temp["result"]));
    }

    for (String temp in data_temp["voter_list"]) {
      Response response =
          await dio.post("/contract/getITSC", data: {'accountName': temp});
      if (response.statusCode == 200) {
        print(response.data);

        if (response.data["itsc"] != null) {
          _voterList.add(response.data["itsc"]);
        } else {
          _voterList.add(temp);
        }
      } else {
        _voterList.add(temp);
      }
    }

    _voterList.sort();

    // print(data_temp);
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

  List<String> getChoiceListNames() {
    List<String> choiceNames = [];
    for (var choice in _choiceList) {
      choiceNames.add(choice.choiceName);
    }
    return choiceNames;
  }

  List<String> getVoterList() {
    return _voterList;
  }

  void setview(CampaignView s) {
    view = s;
  }

  void setIsVoted(CampaignVoteStat s) {
    isVoted = s;
  }

  int getTotalVoted() {
    int total = 0;
    for (var c in _choiceList) {
      total += c.result;
    }
    return total;
  }

  int getNumberOfVoters() {
    return _voterList.length;
  }

  double getPercentVoted() {
    if (getNumberOfVoters() == 0) {
      return 0.0;
    }
    return (getTotalVoted().toDouble() / getNumberOfVoters().toDouble());
  }

  CampaignStat getCampaignStat() {
    // print("now:" + DateTime.now().toUtc().toString());
    // print("start:" + _startTime.toString());
    // print("end:" + _endTime.toString());
    if (DateTime.now().toUtc().isBefore(_startTime)) {
      return CampaignStat.Coming;
    } else if (DateTime.now().toUtc().isAfter(_endTime)) {
      return CampaignStat.Ended;
    } else {
      return CampaignStat.Ongoing;
    }
  }

  Color getTimeColor() {
    var time;
    if (getCampaignStat() == CampaignStat.Ended) {
      return Colors.grey;
    } else if (getCampaignStat() == CampaignStat.Coming) {
      time = _startTime;
    } else {
      time = _endTime;
    }
    print("called");
    var timeDiff = time.difference(DateTime.now().toUtc());
    if (timeDiff < Duration(hours: 1)) {
      print(timeDiff.toString());
      return Colors.red;
    } else if (timeDiff < Duration(days: 1)) {
      return Colors.amber;
    } else {
      return Colors.green;
    }
  }

  @override
  Widget build(BuildContext context) {
    return CampaignListView(
      campaign: this,
    );
  }
}
