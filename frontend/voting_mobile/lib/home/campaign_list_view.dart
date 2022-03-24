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
    final theme = Theme.of(context);
    final oldTextTheme = theme.textTheme.headline5;

    // TextStyle newHeadline5 = ;
    // newHeadline5.fontWeight = FontWeight.bold;
    // print(oldTextTheme!.fontSize);
    final compaignTextTheme =
        oldTextTheme!.copyWith(fontWeight: FontWeight.bold, fontSize: 27);

    return Container(
      padding: EdgeInsets.symmetric(
        vertical: MediaQuery.of(context).size.height * 0.01,
      ),
      child: Container(
        // alignment: Alignment.topLeft,
        width: MediaQuery.of(context).size.width,
        child: Card(
          child: ElevatedButton(
            child: Container(
              padding: EdgeInsets.symmetric(
                vertical: MediaQuery.of(context).size.height * 0.01,
                horizontal: MediaQuery.of(context).size.width * 0.01,
              ),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  padding: EdgeInsets.only(
                      bottom: MediaQuery.of(context).size.height * 0.01),
                  child: Row(
                    children: [
                      Container(
                        // height: double.infinity,
                        width: MediaQuery.of(context).size.width * 0.01,
                        color: Color.fromARGB(255, 244, 54, 54),
                      ),
                      Column(
                        // mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Icon(Icons.now_widgets),
                          Text(
                            campaignName,
                            style: compaignTextTheme,
                          ),

                          Container(
                            padding: EdgeInsets.only(
                              top: MediaQuery.of(context).size.height * 0.03,
                              bottom: MediaQuery.of(context).size.height * 0.01,
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: EdgeInsets.only(
                                      right: MediaQuery.of(context).size.width *
                                          0.03),
                                  child: campaign.getCampaignStat() ==
                                          CampaignStat.Coming
                                      ? Text("Start: " +
                                          DateFormat("yyyy-MM-dd kk:mm:ss")
                                              .format(campaign
                                                  .getStartTime()
                                                  .toLocal()))
                                      : Text("End: " +
                                          DateFormat("yyyy-MM-dd kk:mm:ss")
                                              .format(campaign
                                                  .getEndTime()
                                                  .toLocal())),
                                ),
                                campaign.getCampaignStat() ==
                                        CampaignStat.Ongoing
                                    ? Container(
                                        child: Text("Total Voted: " +
                                            campaign
                                                .getTotalVoted()
                                                .toString()),
                                      )
                                    : Container()
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
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
