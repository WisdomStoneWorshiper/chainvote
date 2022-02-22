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

  bool isUserLoaded = false;
  bool isCampaignLoader = false;
  late Voter user;

  void _getUserDataFinish() {
    setState(() {
      isUserLoaded = true;
    });
  }

  void _getCampaignDataFinish() {
    setState(() {
      isCampaignLoader = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as HomePageArg;
    _itsc = args.itsc;
    print(_itsc);
    _eosAccountName = args.eosAccountName;

    Voter user =
        Voter(voterName: _eosAccountName, callback: _getUserDataFinish);

    return Scaffold(
      appBar: AppBar(
        title: Text("Voting App"),
      ),
      body: FutureBuilder(
        future: user.init(),
        builder: (context, snapshot) {
          List<Widget> children;
          if (snapshot.hasData) {
            print(snapshot.data);
            children = [
              ...(user.getVotableCampaigns()).map((c) {
                return Campaign(campaignId: c.campaignId, isDetail: false);
              })
              // Text("done")
            ];
          } else {
            children = [
              SizedBox(
                width: 60,
                height: 60,
                child: CircularProgressIndicator(),
              )
            ];
          }
          return Center(
              child: CustomScrollView(
            slivers: [
              SliverList(
                // delegate: SliverChildListDelegate([
                //   ...(user.getVotableCampaigns()).map((id) {
                //     return Campaign(campaignId: id, isDetail: false);
                //   })
                delegate: SliverChildListDelegate(children),
              )
            ],
          ));
        },
      ),
    );
  }
}

// Center(
//           child: CustomScrollView(
//         slivers: [
//           SliverList(
//             // delegate: SliverChildListDelegate([
//             //   ...(user.getVotableCampaigns()).map((id) {
//             //     return Campaign(campaignId: id, isDetail: false);
//             //   })
//             delegate: SliverChildListDelegate([
//               Text("111"),
//             ]),
//           )
//         ],
//       ))

// class HomePage extends StatelessWidget {
//   String _itsc = '';
//   String _eosAccountName = '';
//   HomePage({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     final args = ModalRoute.of(context)!.settings.arguments as HomePageArg;
//     _itsc = args.itsc;
//     _eosAccountName = args.eosAccountName;
//     Voter user = Voter(voterName: _eosAccountName);
//     user.init();

//     return Scaffold(
//       appBar: AppBar(
//         title: Text("Voting App"),
//       ),
//       body: Center(
//           child: CustomScrollView(
//         slivers: [
//           SliverList(
//             delegate: SliverChildListDelegate([
//               ...(user.getVotableCampaigns()).map((id) {
//                 return Campaign(campaignId: id, isDetail: false);
//               })
//             ]),
//           )
//         ],
//       )),
//     );
//   }
// }
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
