import 'package:flutter/material.dart';
import '../../global_variable.dart';
import './campaign.dart';
import './voter.dart';

class HomePageArg {
  final String itsc;
  final String eosAccountName;
  const HomePageArg(this.itsc, this.eosAccountName);
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _itsc = '';
  String _eosAccountName = '';

  late Voter user;

  Future<List<Campaign>> init(String voterName) async {
    user = Voter(voterName: _eosAccountName);
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
    final args = ModalRoute.of(context)!.settings.arguments as HomePageArg;
    _itsc = args.itsc;
    print(_itsc);
    _eosAccountName = args.eosAccountName;

    // user = Voter(voterName: _eosAccountName);

    return Scaffold(
      appBar: AppBar(
        title: Text("Voting App"),
      ),
      body: FutureBuilder(
        future: init(_eosAccountName),
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
              SliverList(
                delegate: SliverChildListDelegate(children),
              )
            ],
          ));
        },
      ),
    );
  }
}
