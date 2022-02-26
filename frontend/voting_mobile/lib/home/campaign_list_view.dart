import 'package:flutter/material.dart';
import 'campaign.dart';

class CampaignListView extends StatelessWidget {
  final Campaign campaign;
  late String campaignName;
  late String owner;
  late void Function(Campaign) callback;
  CampaignListView({required this.campaign}) {
    campaignName = campaign.getCampaignName();
    owner = campaign.getOwner();
    callback = campaign.callback;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(10.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Material(
          elevation: 10,
          child: ElevatedButton(
            child: Column(
              children: [Text(campaignName), Text("Owner :" + owner)],
            ),
            onPressed: () {
              callback(campaign);
            },
          ),
        ),
      ),
    );
  }
}
