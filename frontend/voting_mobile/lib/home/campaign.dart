import 'package:flutter/material.dart';
import '../../global_variable.dart';

class Campaign extends StatelessWidget {
  final bool isDetail;
  final int campaignId;
  Campaign({required this.campaignId, required this.isDetail}) {
    // client
    //     .getTableRow(contractAccount, contractAccount, "campaign",
    //         lower: campaignId.toString(), upper: campaignId.toString())
    //     .then((value) => null);
  }

  Widget homeView() {
    return Container(
      padding: EdgeInsets.all(8.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(25),
        child: Column(
          children: [Text("Owner: ")],
        ),
      ),
    );
  }

  Widget votingView() {
    return Container();
  }

  @override
  Widget build(BuildContext context) {
    return isDetail ? votingView() : homeView();
  }
}
