import 'package:flutter/material.dart';
import 'campaign.dart';

class VoterPage extends StatefulWidget {
  const VoterPage({Key? key}) : super(key: key);

  @override
  _VoterPageState createState() => _VoterPageState();
}

class _VoterPageState extends State<VoterPage> {
  late Campaign campaign;

  void _toBallot() {
    Navigator.pushNamed(context, 'b', arguments: campaign);
  }

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as Campaign;
    campaign = args;
    campaign.setIsDetail(true);
    return Scaffold(
        appBar: AppBar(),
        body: Column(
          children: [campaign],
        ),
        floatingActionButton: campaign.getCampaignStat() == CampaignStat.Ongoing
            ? FloatingActionButton(
                onPressed: _toBallot,
                child: Icon(IconData(0xee93, fontFamily: 'MaterialIcons')),
              )
            : null);
  }
}
