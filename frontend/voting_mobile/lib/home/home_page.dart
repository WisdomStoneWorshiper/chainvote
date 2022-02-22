import 'package:flutter/material.dart';
import '../../global_variable.dart';
import './campaign.dart';
import './voter.dart';

class HomePage extends StatefulWidget {
  final String itsc;
  final String eosAccountName;
  const HomePage({required this.itsc, required this.eosAccountName, Key? key})
      : super(key: key);

  @override
  _HomePageState createState() =>
      _HomePageState(itsc: itsc, eosAccountName: eosAccountName);
}

class _HomePageState extends State<HomePage> {
  final String itsc;
  final String eosAccountName;

  late Voter user;

  _HomePageState({required this.itsc, required this.eosAccountName});

  Future<List<Campaign>> init(String voterName) async {
    user = Voter(voterName: eosAccountName);
    await user.init();
    List<Campaign> t = [];
    for (VotingRecord vr in user.getVotableCampaigns()) {
      Campaign c = new Campaign(
        campaignId: vr.campaignId,
        isDetail: false,
      );
      await c.init();
      t.add(c);
    }
    print(t.length);
    return Future<List<Campaign>>.value(t);
  }

  @override
  Widget build(BuildContext context) {
    // itsc = args.itsc;
    // print(itsc);
    // eosAccountName = args.eosAccountName;

    // user = Voter(voterName: eosAccountName);

    return FutureBuilder(
      future: init(eosAccountName),
      builder: (context, snapshot) {
        List<Widget> children;
        if (snapshot.hasData) {
          children = snapshot.data as List<Campaign>;
        } else {
          children = [
            SizedBox(
              width: 200,
              height: 200,
              child: CircularProgressIndicator(),
            ),
          ];
        }
        return Center(
            child: CustomScrollView(
          slivers: [
            SliverAppBar(
              title: Text("Coming Campaign"),
              pinned: true,
            ),
            SliverList(
              delegate: SliverChildListDelegate(children),
            )
          ],
        ));
      },
    );
  }
}
