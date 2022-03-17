import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

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
      padding: EdgeInsets.symmetric(
          vertical: MediaQuery.of(context).size.height * 0.01),
      child: Container(
        // alignment: Alignment.topLeft,
        width: MediaQuery.of(context).size.width,
        child: Card(
          child: ElevatedButton(
            child: Align(
              alignment: Alignment.centerLeft,
              child: Container(
                padding: EdgeInsets.only(
                    bottom: MediaQuery.of(context).size.height * 0.01),
                child: Row(
                  children: [
                    Container(
                      padding: EdgeInsets.only(
                          right: MediaQuery.of(context).size.width * 0.05),
                      child: Icon(
                        Icons.person,
                        size: MediaQuery.of(context).size.height * 0.1,
                      ),
                    ),
                    Column(
                      // mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Icon(Icons.now_widgets),
                        Text(
                          campaignName,
                          style: Theme.of(context).textTheme.headline5,
                        ),

                        Container(
                          padding: EdgeInsets.symmetric(
                              vertical:
                                  MediaQuery.of(context).size.height * 0.01),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8.0),
                            child: Container(
                              color: Colors.blue,
                              child: campaign.getCampaignStat() ==
                                      CampaignStat.Coming
                                  ? Text("Start: " +
                                      DateFormat("yyyy-MM-dd kk:mm:ss").format(
                                          campaign.getStartTime().toLocal()))
                                  : Text("End: " +
                                      DateFormat("yyyy-MM-dd kk:mm:ss").format(
                                          campaign.getEndTime().toLocal())),
                            ),
                          ),
                        ),
                        campaign.getCampaignStat() == CampaignStat.Ongoing
                            ? Container(
                                child: ClipRRect(
                                    borderRadius: BorderRadius.circular(8.0),
                                    child: Container(
                                      color: Colors.blue,
                                      child: Text("Total Voted: " +
                                          campaign.getTotalVoted().toString()),
                                    )),
                              )
                            : Container()
                      ],
                    ),
                  ],
                ),
              ),
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
