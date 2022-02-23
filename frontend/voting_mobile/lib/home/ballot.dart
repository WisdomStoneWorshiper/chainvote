import 'package:flutter/material.dart';
import 'campaign.dart';
import 'vote_success.dart';

class Ballot extends StatefulWidget {
  Ballot({Key? key}) : super(key: key);

  @override
  _BallotState createState() => _BallotState();
}

class _BallotState extends State<Ballot> {
  late Campaign campaign;

  int _selected = -1;

  TextEditingController _pkController = new TextEditingController();

  void _confirmBallot() {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: Text("Confirm your ballot"),
              content: Column(
                children: [
                  Text("Campaign :" + campaign.getCampaignName()),
                  Text("Choice: " +
                      campaign.getChoiceList()[_selected].choiceName)
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text("Cancel"),
                ),
                TextButton(
                  onPressed: () {
                    _requestKey();
                  },
                  child: Text("Vote"),
                )
              ],
            ));
  }

  void _requestKey() => showDialog(
      context: context,
      builder: (context) => AlertDialog(
            title: Text("Please input your EOSIO account Private Key"),
            content: TextField(
              decoration: InputDecoration(hintText: "Private Key"),
              controller: _pkController,
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text("Cancel"),
              ),
              TextButton(
                onPressed: () {
                  _vote(_pkController.text);
                },
                child: Text("Submit"),
              )
            ],
          ));

  void _vote(String pk) {
    Navigator.pushNamed(context, 'vs');
  }

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as Campaign;
    campaign = args;

    return Scaffold(
      appBar: AppBar(),
      body: Container(
        child: Align(
          alignment: Alignment.topLeft,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Campaign Name: " + campaign.getCampaignName()),
              Text("Owner: " + campaign.getOwner()),
              ListView.builder(
                shrinkWrap: true,
                itemCount: campaign.getChoiceList().length,
                itemBuilder: (_, index) => Container(
                  child: ListTile(
                    leading: Text((index + 1).toString()),
                    title: Text(campaign.getChoiceList()[index].choiceName),
                    tileColor: _selected == index
                        ? Colors.blue.withOpacity(0.5)
                        : null,
                    onTap: () {
                      setState(() {
                        _selected = index;
                      });
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: _selected != -1
          ? FloatingActionButton(
              onPressed: () {
                _confirmBallot();
              },
              child: Icon(IconData(0xf118, fontFamily: 'MaterialIcons')),
            )
          : null,
    );
  }
}
