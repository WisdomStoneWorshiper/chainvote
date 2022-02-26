import 'package:flutter/material.dart';
import '../campaign.dart';

class VotablePage extends StatefulWidget {
  const VotablePage({Key? key}) : super(key: key);

  @override
  _VotablePageState createState() => _VotablePageState();
}

class _VotablePageState extends State<VotablePage> {
  late Campaign campaign;

  void _toBallot() {
    Navigator.pushNamed(context, 'b', arguments: campaign);
  }

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as Campaign;
    campaign = args;
    campaign.setview(CampaignView.Voter);
    return Scaffold(
        appBar: AppBar(),
        body: Column(
          children: [campaign],
        ),
        floatingActionButton:
            campaign.getCampaignStat() == CampaignStat.Ongoing &&
                    campaign.isVoted == false
                ? FloatingActionButton(
                    onPressed: _toBallot,
                    child: Icon(IconData(0xee93, fontFamily: 'MaterialIcons')),
                  )
                : null);
  }
}
