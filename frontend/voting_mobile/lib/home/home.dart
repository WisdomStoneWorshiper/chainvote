import 'package:flutter/material.dart';
import '../../global_variable.dart';
import './campaign.dart';
import './voter.dart';

class HomePageArg {
  final String itsc;
  final String eosAccountName;
  const HomePageArg(this.itsc, this.eosAccountName);
}

class HomePage extends StatelessWidget {
  String _itsc = '';
  String _eosAccountName = '';
  HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as HomePageArg;
    _itsc = args.itsc;
    _eosAccountName = args.eosAccountName;
    Voter user = new Voter(voterName: _eosAccountName);
    await user.init();

    return Scaffold(
      appBar: AppBar(
        title: Text("Voting App"),
      ),
      body: Center(
        child: CustomScrollView(
          slivers: [
            SliverList(
              delegate: SliverChildListDelegate([
                ...(user.getVotableCampaigns()).map((id) {
                  return Campaign(campaignId: id, isDetail: false);
                })
              ]),
            )
          ],
        ),
      ),
    );
  }
}
// body: Center(
//         // child: const Text(
//         //   "We are still developing the homepage",
//         //   style: TextStyle(fontSize: 25.0, fontWeight: FontWeight.bold),
//         // ),
//         child: RichText(
//           text: const TextSpan(
//             text: 'Home Page',
//             style: TextStyle(
//                 color: Colors.black,
//                 fontSize: 30.0,
//                 fontWeight: FontWeight.bold),
//           ),
//         ),
//       ),
