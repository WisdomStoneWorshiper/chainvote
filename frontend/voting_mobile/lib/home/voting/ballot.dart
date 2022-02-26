import 'package:eosdart/eosdart.dart' as eos;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import '../campaign.dart';
import '../../success_page.dart';
import '../../global_variable.dart';

class Ballot extends StatefulWidget {
  Ballot({Key? key}) : super(key: key);

  @override
  _BallotState createState() => _BallotState();
}

class _BallotState extends State<Ballot> {
  late Campaign campaign;

  int _selected = -1;

  TextEditingController _pkController = new TextEditingController();

  void _errDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Error"),
        content: Text(message),
        actions: [
          TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text("ok"))
        ],
      ),
    );
  }

  void showLoaderDialog(BuildContext context, String loadingMsg) {
    AlertDialog alert = AlertDialog(
      content: new Row(
        children: [
          CircularProgressIndicator(),
          Container(
            margin: EdgeInsets.only(left: 7),
            child: Text(loadingMsg + "..."),
          ),
        ],
      ),
    );
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  void _confirmBallot() {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: Text("Confirm your ballot"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
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
                  showLoaderDialog(context, "Posting transaction");
                  _vote(context, _pkController.text);
                },
                child: Text("Submit"),
              )
            ],
          ));

  void _vote(BuildContext context, String pk) async {
    eos.EOSClient voteClient = client;
    final prefs = await SharedPreferences.getInstance();

    final String eosName = prefs.getString('eosName') ?? "";

    if (eosName != "") {
      try {
        voteClient.privateKeys = [pk];

        List<eos.Authorization> auth = [
          eos.Authorization()
            ..actor = eosName
            ..permission = 'active'
        ];

        Map data = {
          'campaign_id': campaign.campaignId.toString(),
          'voter': eosName,
          'choice_idx': _selected.toString()
        };

        List<eos.Action> actions = [
          eos.Action()
            ..account = contractAccount
            ..name = 'vote'
            ..authorization = auth
            ..data = data
        ];
        eos.Transaction transaction = eos.Transaction()..actions = actions;

        try {
          var response =
              await voteClient.pushTransaction(transaction, broadcast: true);

          if (response.containsKey('transaction_id')) {
            campaign.setIsVoted(CampaignVoteStat.Yes);
            String transHex = response["transaction_id"];
            SuccessPageArg arg = new SuccessPageArg(
                message:
                    'Your Vote Submitted Successfully \n Transaction hash: $transHex',
                returnPage: 'h');
            Navigator.pop(context);
            Navigator.pushNamed(context, 's', arguments: arg);
          } else {
            print(response);
            Navigator.pop(context);
            _errDialog("Unknown Error");
          }
        } catch (e) {
          Navigator.pop(context);
          Map error = json.decode(e as String);
          print(error);
          // print(error["error"]["details"][0]["message"]);
          // print(e.runtimeType);
          _errDialog(error["error"]["details"][0]["message"]);
        }
      } catch (e) {
        Navigator.pop(context);
        // print(e);
        _errDialog("Invalid Private Key format");
      }
    } else {
      Navigator.pop(context);
      _errDialog("Haven't login");
    }
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
