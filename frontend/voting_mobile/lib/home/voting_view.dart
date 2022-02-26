import 'package:flutter/material.dart';
import 'campaign.dart';

class VotingView extends StatelessWidget {
  final Campaign campaign;
  const VotingView({required this.campaign});

  @override
  Widget build(BuildContext context) {
    return Container(
        child: Align(
      alignment: Alignment.topLeft,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Campaign Name: " + campaign.getCampaignName()),
          Text("Owner: " + campaign.getOwner()),
          Text("Start: " + campaign.getStartTime().toLocal().toString()),
          Text("End: " + campaign.getEndTime().toLocal().toString()),
          ListView.builder(
            shrinkWrap: true,
            itemCount: campaign.getChoiceList().length,
            itemBuilder: (_, index) => Container(
              child: ListTile(
                leading: Text((index + 1).toString()),
                title: Text(campaign.getChoiceList()[index].choiceName),
                subtitle: Text("Result: " +
                    campaign.getChoiceList()[index].result.toString()),
              ),
            ),
          ),
        ],
      ),
    ));
  }
}
