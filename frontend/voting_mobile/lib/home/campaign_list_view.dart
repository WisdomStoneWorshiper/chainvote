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

    final compaignTextTheme =
        oldTextTheme!.copyWith(fontWeight: FontWeight.bold, fontSize: 27);

    return Container(
      padding: EdgeInsets.symmetric(
        vertical: MediaQuery.of(context).size.height * 0.01,
      ),
      child: Container(
        child: Card(
          elevation: 10,
          child: SizedBox(
            height: 101,
            child: InkWell(
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
                          width: 25,
                          color: campaign.getTimeColor(),
                        ),
                        Container(
                          padding: EdgeInsets.only(
                            top: 7.36,
                            bottom: 10.72,
                            left: 20,
                            right: 4.14,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: MediaQuery.of(context).size.width * 0.7,
                                child: Text(
                                  campaignName,
                                  overflow: TextOverflow.ellipsis,
                                  style: compaignTextTheme,
                                ),
                              ),
                              //fix the total voted look
                              Container(
                                padding: campaign.getCampaignStat() !=
                                        CampaignStat.Coming
                                    ? EdgeInsets.only(
                                        top: 10.08,
                                      )
                                    : EdgeInsets.only(
                                        top: 22.08,
                                        bottom: 7.36,
                                      ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      padding: EdgeInsets.only(
                                          right: 22.08, bottom: 4),
                                      child: campaign.getCampaignStat() ==
                                              CampaignStat.Coming
                                          ? Text(
                                              "Starts On: " +
                                                  DateFormat(
                                                          "yyyy-MM-dd kk:mm:ss")
                                                      .format(campaign
                                                          .getStartTime()
                                                          .toLocal()),
                                              style: TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.bold),
                                            )
                                          : campaign.getCampaignStat() ==
                                                  CampaignStat.Ended
                                              ? Text(
                                                  "Ended On: " +
                                                      DateFormat(
                                                              "yyyy-MM-dd kk:mm:ss")
                                                          .format(campaign
                                                              .getEndTime()
                                                              .toLocal()),
                                                  style: TextStyle(
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                )
                                              : Text(
                                                  "Ends On: " +
                                                      DateFormat(
                                                              "yyyy-MM-dd kk:mm:ss")
                                                          .format(campaign
                                                              .getEndTime()
                                                              .toLocal()),
                                                  style: TextStyle(
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                    ),
                                    (campaign.getCampaignStat() !=
                                            CampaignStat.Coming)
                                        ? Row(children: [
                                            Container(
                                              height: 10,
                                              width: campaign
                                                          .getPercentVoted() ==
                                                      0
                                                  ? 10
                                                  : MediaQuery.of(context)
                                                          .size
                                                          .width *
                                                      0.45 *
                                                      campaign
                                                          .getPercentVoted(),
                                              color: Colors.green,
                                            ),
                                            Container(
                                              height: 10,
                                              width: campaign
                                                          .getPercentVoted() ==
                                                      0
                                                  ? (MediaQuery.of(context)
                                                              .size
                                                              .width *
                                                          0.45) -
                                                      10
                                                  : MediaQuery.of(context)
                                                          .size
                                                          .width *
                                                      0.45 *
                                                      (1.0 -
                                                          campaign
                                                              .getPercentVoted()),
                                              color: Colors.red,
                                            ),
                                            Container(
                                              height: 10,
                                              width: 10,
                                            ),
                                            Text(campaign
                                                    .getTotalVoted()
                                                    .toString() +
                                                "/" +
                                                campaign
                                                    .getNumberOfVoters()
                                                    .toString() +
                                                " Voted"),
                                          ])
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
