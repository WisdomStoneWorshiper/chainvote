import 'dart:async';

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
  int highlightedIndex = -1;

  void _toBallot() {
    Navigator.pushNamed(context, 'b', arguments: campaign);
  }

  Map<String, double> _getVoteDistribution() {
    Map<String, double> result = {};
    if (campaign.getChoiceList().length == 0) {
      result["No choices given :("] = 0.0;
      _chartColor
          .add(Colors.primaries[Random().nextInt(Colors.primaries.length)]);
    }

    for (var c in campaign.getChoiceList()) {
      result[c.choiceName] = c.result.toDouble();

      _chartColor
          .add(Colors.primaries[Random().nextInt(Colors.primaries.length)]);
    }
    return result;
  }

  int getTotalBallots() {
    int totalBallots = 0;
    for (var c in campaign.getChoiceList()) {
      totalBallots += c.result;
    }
    return totalBallots;
  }

  Timer triggerResetHighlightTimer([int milliseconds = 500]) =>
      Timer(Duration(milliseconds: milliseconds), resetHighlight);

  void resetHighlight() {
    setState(() {
      highlightedIndex = -1;
    });
  }

  void changeHighlightedIndex(index) {
    setState(() {
      highlightedIndex = index;
    });
    triggerResetHighlightTimer();
  }

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as Campaign;
    campaign = args;
    campaign.setview(CampaignView.Voter);
    Color highlightColor = Colors.white;
    print("is voted: " + (campaign.isVoted.toString()));
    final theme = Theme.of(context);
    final oldTextTheme = theme.textTheme.headline3;
    List<ListItem> item = [];
    List<Color> colors =
        campaign.getChoiceList().isEmpty ? [defaultColorList[0]] : [];
    for (var i = 0; i < campaign.getChoiceList().length; ++i) {
      colors.add(i != highlightedIndex
          ? defaultColorList[i % defaultColorList.length]
          : highlightColor);
      item.add(ListItem(
          color: i != highlightedIndex
              ? defaultColorList[i % defaultColorList.length]
              : highlightColor,
          choice: campaign.getChoiceList()[i].choiceName,
          vote: campaign.getChoiceList()[i].result));
    }
    item.sort(((a, b) => b.vote.compareTo(a.vote)));

    final summaryTextTheme =
        oldTextTheme!.copyWith(fontWeight: FontWeight.bold);

    return Scaffold(
        appBar: AppBar(
          title: Text(
            campaign.getCampaignName(),
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25),
          ),
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
            Padding(
              padding: EdgeInsets.only(
                top: 15,
                left: MediaQuery.of(context).size.width * 0.04,
              ),
              child: Stack(
                children: [
                  Align(
                      alignment: Alignment.topLeft,
                      child: Row(children: [
                        Container(
                          height: 15,
                          width: campaign.getPercentVoted() == 0
                              ? 10
                              : MediaQuery.of(context).size.width *
                                  0.65 *
                                  campaign.getPercentVoted(),
                          color: Colors.green,
                        ),
                        Container(
                          height: 15,
                          width: MediaQuery.of(context).size.width *
                              0.65 *
                              (1.0 - campaign.getPercentVoted()),
                          color: Colors.red,
                        ),
                      ])),
                  Align(
                    alignment: Alignment.topRight,
                    child: Container(
                      width: 100,
                      color: Theme.of(context).backgroundColor,
                      padding: EdgeInsets.only(right: 15, left: 5),
                      child: Text(
                          campaign.getTotalVoted().toString() +
                              "/" +
                              campaign.getNumberOfVoters().toString() +
                              " Voted",
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: oldTextTheme.color)),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Column(
                children: [
                  Container(
                    padding: EdgeInsets.only(
                      top: MediaQuery.of(context).size.height * 0.03,
                      left: MediaQuery.of(context).size.width * 0.04,
                      bottom: MediaQuery.of(context).size.height * 0.03,
                    ),
                    child: Center(
                      child: PieChart(
                        colorList: colors,
                        chartRadius: MediaQuery.of(context).size.width * 0.5,
                        dataMap: _getVoteDistribution(),
                        chartType: ChartType.ring,
                        centerText:
                            "Total Ballot: " + getTotalBallots().toString(),
                        chartValuesOptions: ChartValuesOptions(
                          showChartValues: false,
                        ),
                      ),
                    ),
                  ),
                  Stack(
                    children: [
                      Align(
                        alignment: Alignment.topLeft,
                        child: Container(
                          padding: EdgeInsets.only(left: 30),
                          child: Text(
                            "Choice",
                            style: TextStyle(
                              fontSize: 25,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      Align(
                        alignment: Alignment.topRight,
                        child: Container(
                          padding: EdgeInsets.only(right: 30),
                          child: Text(
                            "Number of Votes",
                            style: TextStyle(
                              fontSize: 20,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: MediaQuery.of(context).size.width * 0.04,
                      ),
                      child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: campaign.getChoiceList().length,
                          itemBuilder: (_, index) {
                            return Container(
                              color: index == highlightedIndex
                                  ? Theme.of(context).primaryColor
                                  : null,
                              child: InkWell(
                                  onTap: () => changeHighlightedIndex(index),
                                  child: ListTile(
                                    minLeadingWidth: 10,
                                    leading: Container(
                                      width: MediaQuery.of(context).size.width *
                                          0.04,
                                      decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: item[index].color),
                                    ),
                                    title: Text(
                                      item[index].choice,
                                      style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w600),
                                    ),
                                    trailing: Text(
                                      item[index].vote.toString(),
                                      style: TextStyle(
                                          fontSize: 17,
                                          fontWeight: FontWeight.w400),
                                    ),
                                  )),
                            );
                          }),
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
        floatingActionButton:
            campaign.getCampaignStat() == CampaignStat.Ongoing &&
                    campaign.isVoted == CampaignVoteStat.No
                ? FloatingActionButton(
                    onPressed: _toBallot,
                    child: Icon(Icons.article_outlined),
                  )
                : null);
  }
}
