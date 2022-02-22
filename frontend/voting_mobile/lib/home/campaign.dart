import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../../global_variable.dart';

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
  List<Choice> _choiceList = [];

  Campaign({required this.campaignId, required this.isDetail});

  Future<bool> init() async {
    var data_temp = await client.getTableRow(
        contractAccount, contractAccount, "campaign",
        lower: campaignId.toString(), upper: campaignId.toString());
    _campaignName = data_temp!["campaign_name"];
    _owner = data_temp["owner"];
    _startTime = DateTime.parse(data_temp["start_time"]);
    _endTime = DateTime.parse(data_temp["end_time"]);
    for (Map<String, dynamic>? temp in data_temp["choice_list"]) {
      _choiceList
          .add(Choice(choiceName: temp!["choice"], result: temp["result"]));
    }
    print(data_temp);
    return Future<bool>.value(true);
  }

  Widget homeView() {
    return Container(
      padding: EdgeInsets.all(10.0),
      child: Material(
        elevation: 10,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(15),
          child: Column(
            children: [Text(_campaignName), Text("Owner :" + _owner)],
          ),
        ),
      ),
    );
    // return Material(
    //   elevation: 20,
    //   child: Container(
    //     padding: EdgeInsets.all(20.0),
    //     child: ClipRRect(
    //       borderRadius: BorderRadius.circular(25),
    //       child: Column(
    //         children: [Text(_campaignName), Text("Owner :" + _owner)],
    //       ),
    //     ),
    //   ),
    // );
  }

  Widget votingView() {
    return Container();
  }

  @override
  Widget build(BuildContext context) {
    return isDetail ? votingView() : homeView();
  }
}
