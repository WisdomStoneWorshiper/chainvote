import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../../global_variable.dart';

enum CampaignStat { Coming, Ongoing, Ended }

class Choice {
  String choiceName;
  int result;
  Choice({required this.choiceName, required this.result});
}

class Campaign extends StatelessWidget {
  bool isDetail;
  final int campaignId;
  late String _campaignName;
  late String _owner;
  late DateTime _startTime;
  late DateTime _endTime;
  bool isVoted;
  List<Choice> _choiceList = [];

  void Function(Campaign) callback;

  Campaign(
      {required this.campaignId,
      required this.isDetail,
      required this.callback,
      required this.isVoted});

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

  void setIsDetail(bool s) {
    isDetail = s;
  }

  void setIsVoted(bool s) {
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

  Widget homeView() {
    return Container(
      padding: EdgeInsets.all(10.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Material(
          elevation: 10,
          child: ElevatedButton(
            child: Column(
              children: [Text(_campaignName), Text("Owner :" + _owner)],
            ),
            onPressed: () {
              callback(this);
            },
          ),
        ),
      ),
    );
  }

  Widget votingView() {
    return Container(
        child: Align(
      alignment: Alignment.topLeft,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Campaign Name: " + _campaignName),
          Text("Owner: " + _owner),
          Text("Start: " + _startTime.toLocal().toString()),
          Text("End: " + _endTime.toLocal().toString()),
          ListView.builder(
            shrinkWrap: true,
            itemCount: _choiceList.length,
            itemBuilder: (_, index) => Container(
              child: ListTile(
                leading: Text((index + 1).toString()),
                title: Text(_choiceList[index].choiceName),
                subtitle:
                    Text("Result: " + _choiceList[index].result.toString()),
              ),
            ),
          ),
        ],
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return isDetail ? votingView() : homeView();
  }
}
