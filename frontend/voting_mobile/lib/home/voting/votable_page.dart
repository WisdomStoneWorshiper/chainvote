import 'package:flutter/material.dart';
import 'package:pie_chart/pie_chart.dart';
import 'package:pie_chart/src/utils.dart';
import 'package:intl/intl.dart';

import '../campaign.dart';
import 'dart:math';

class ListItem {
  Color color;
  String choice;
  int vote;
  ListItem({required this.color, required this.choice, required this.vote});
}

class VotablePage extends StatefulWidget {
  const VotablePage({Key? key}) : super(key: key);

  @override
  _VotablePageState createState() => _VotablePageState();
}

class _VotablePageState extends State<VotablePage> {
  late Campaign campaign;
  int totalBallot = 0;
  List<Color> _chartColor = [];

  void _toBallot() {
    Navigator.pushNamed(context, 'b', arguments: campaign);
  }

  Map<String, double> _getVoteDistribution() {
    Map<String, double> result = {};
    for (var c in campaign.getChoiceList()) {
      result[c.choiceName] = c.result.toDouble();
      totalBallot += c.result;
      _chartColor
          .add(Colors.primaries[Random().nextInt(Colors.primaries.length)]);
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as Campaign;
    campaign = args;
    campaign.setview(CampaignView.Voter);
    print("is voted: " + (campaign.isVoted.toString()));
    final theme = Theme.of(context);
    final oldTextTheme = theme.textTheme.headline3;
    List<ListItem> item = [];
    for (var i = 0; i < campaign.getChoiceList().length; ++i) {
      item.add(ListItem(
          color: defaultColorList[i],
          choice: campaign.getChoiceList()[i].choiceName,
          vote: campaign.getChoiceList()[i].result));
    }
    item.sort(((a, b) => b.vote.compareTo(a.vote)));
    // TextStyle newHeadline5 = ;
    // newHeadline5.fontWeight = FontWeight.bold;
    // print(oldTextTheme!.fontSize);
    final summaryTextTheme =
        oldTextTheme!.copyWith(fontWeight: FontWeight.bold);

    return Scaffold(
        appBar: AppBar(
          title: Text(campaign.getCampaignName()),
        ),
        body: Column(
          children: [
            Container(
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).size.height * 0.01,
                left: MediaQuery.of(context).size.width * 0.04,
              ),
              alignment: Alignment.centerLeft,
              child: Text(
                "Summary",
                style: summaryTextTheme,
              ),
            ),
            Container(
              padding: EdgeInsets.only(
                left: MediaQuery.of(context).size.width * 0.04,
              ),
              alignment: Alignment.centerLeft,
              child: Text(
                campaign.getCampaignStat() == CampaignStat.Coming
                    ? "Start: " +
                        DateFormat("yyyy-MM-dd kk:mm:ss")
                            .format(campaign.getStartTime().toLocal())
                    : "End: " +
                        DateFormat("yyyy-MM-dd kk:mm:ss")
                            .format(campaign.getEndTime().toLocal()),
                style: Theme.of(context).textTheme.headline5,
              ),
            ),
            Container(
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).size.height * 0.03,
                left: MediaQuery.of(context).size.width * 0.04,
                bottom: MediaQuery.of(context).size.height * 0.03,
              ),
              child: Center(
                child: PieChart(
                  // colorList: _chartColor,
                  chartRadius: MediaQuery.of(context).size.width * 0.5,
                  dataMap: _getVoteDistribution(),
                  chartType: ChartType.ring,
                  centerText: "Total Ballot: " + totalBallot.toString(),
                  chartValuesOptions: ChartValuesOptions(
                    showChartValues: false,
                  ),
                ),
              ),
            ),
            Expanded(
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: MediaQuery.of(context).size.width * 0.04,
                ),
                child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: campaign.getChoiceList().length + 1,
                    itemBuilder: (_, index) {
                      if (index == 0) {
                        return ListTile(
                          minLeadingWidth: 10,
                          leading: Container(
                            width: MediaQuery.of(context).size.width * 0.04,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.transparent,
                            ),
                          ),
                          title: Text("Choice"),
                          trailing: Text("Number of Vote"),
                        );
                      }
                      return Container(
                        child: ListTile(
                          minLeadingWidth: 10,
                          leading: Container(
                            width: MediaQuery.of(context).size.width * 0.04,
                            decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: item[index - 1].color),
                          ),
                          title: Text(item[index - 1].choice),
                          trailing: Text(item[index - 1].vote.toString()),
                        ),
                      );
                    }),
              ),
            ),
          ],
        ),
        floatingActionButton:
            campaign.getCampaignStat() == CampaignStat.Ongoing &&
                    campaign.isVoted == CampaignVoteStat.No
                ? FloatingActionButton(
                    onPressed: _toBallot,
                    child: Icon(IconData(0xee93, fontFamily: 'MaterialIcons')),
                  )
                : null);
  }
}
