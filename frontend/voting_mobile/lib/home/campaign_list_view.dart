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
    // print("h: " + MediaQuery.of(context).size.height.toString());
    // print("w: " + MediaQuery.of(context).size.width.toString());
    final compaignTextTheme =
        oldTextTheme!.copyWith(fontWeight: FontWeight.bold, fontSize: 27);

    return Container(
      padding: EdgeInsets.symmetric(
        vertical: MediaQuery.of(context).size.height * 0.01,
      ),
      child: Container(
        // alignment: Alignment.topLeft,
        // width: MediaQuery.of(context).size.width,
        child: Card(
          elevation: 10,
          child: SizedBox(
            height: 101,
            child: InkWell(
              // borderRadius: BorderRadius.circular(25.0),
              splashColor: Colors.blue.withAlpha(30),
              child: Container(
                color: Color.fromARGB(255, 36, 48, 65),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          // alignment: Alignment.centerLeft,
                          width: 25,
                          // height: double.infinity,
                          // width: MediaQuery.of(context).size.width * 0.01,
                          color: campaign.getTimeColor(),
                          // child: FractionallySizedBox(),
                        ),
                        Container(
                          padding: EdgeInsets.only(
                            top: 7.36,
                            bottom: 14.72,
                            left: 20,
                            right: 4.14,
                          ),
                          child: Column(
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
                                  top: 22.08,
                                  bottom: 7.36,
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      padding: EdgeInsets.only(right: 22.08),
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
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              onTap: () {
                callback(campaign);
              },
            ),
          ),
        ),
      ),
    );
  }
}
