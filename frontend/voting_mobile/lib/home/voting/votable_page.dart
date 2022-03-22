import 'package:flutter/material.dart';
import 'package:pie_chart/pie_chart.dart';

import '../campaign.dart';
import 'dart:math';

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
    return Scaffold(
        appBar: AppBar(),
        body: Column(
          children: [
            Container(
              padding: EdgeInsets.only(
                left: MediaQuery.of(context).size.width * 0.04,
              ),
              alignment: Alignment.centerLeft,
              child: Text(
                "Summary",
                style: Theme.of(context).textTheme.headline3,
              ),
            ),
            Container(
              padding: EdgeInsets.only(
                left: MediaQuery.of(context).size.width * 0.04,
              ),
              alignment: Alignment.centerLeft,
              child: Text(
                "Result",
                style: Theme.of(context).textTheme.headline5,
              ),
            ),
            Container(
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).size.height * 0.05,
                left: MediaQuery.of(context).size.width * 0.04,
              ),
              child: Center(
                child: PieChart(
                  colorList: _chartColor,
                  chartRadius: MediaQuery.of(context).size.width * 0.5,
                  dataMap: _getVoteDistribution(),
                  chartType: ChartType.ring,
                  centerText: "Total Ballot: " + totalBallot.toString(),
                  chartValuesOptions: ChartValuesOptions(
                    showChartValues: true,
                    showChartValuesInPercentage: true,
                    decimalPlaces: 1,
                  ),
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: campaign.getChoiceList().length,
                itemBuilder: (_, index) => Container(
                  child: ListTile(
                    leading: Container(
                      width: MediaQuery.of(context).size.width * 0.04,
                      decoration: BoxDecoration(
                          shape: BoxShape.circle, color: _chartColor[index]),
                    ),
                    title: Text(campaign.getChoiceList()[index].choiceName),
                    trailing:
                        Text(campaign.getChoiceList()[index].result.toString()),
                  ),
                ),
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
