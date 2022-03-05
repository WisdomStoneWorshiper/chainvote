import 'package:flutter/material.dart';
import 'package:eosdart/eosdart.dart' as eos;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import '../campaign.dart';
import 'edit_page.dart';
import '../../success_page.dart';
import '../../global_variable.dart';

class ManagePage extends StatefulWidget {
  const ManagePage({Key? key}) : super(key: key);

  @override
  _ManagePageState createState() => _ManagePageState();
}

class _ManagePageState extends State<ManagePage> {
  late Campaign campaign;
  final TextEditingController _pkController = TextEditingController();

  void _errDialog(BuildContext context, String message) {
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

  void _requestKey(BuildContext context) {
    showDialog(
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
                  onPressed: () async {
                    showLoaderDialog(context, "Deleting");

                    _deleteCampaign(context, _pkController.text);
                  },
                  child: Text("Submit"),
                )
              ],
            ));
  }

  void _deleteCampaign(BuildContext context, String pk) async {
    eos.EOSClient voteClient = client;
    final prefs = await SharedPreferences.getInstance();

    final String eosName = prefs.getString('eosName') ?? "";
    // print(eosName);
    if (eosName != "") {
      try {
        voteClient.privateKeys = [pk];

        List<eos.Authorization> auth = [
          eos.Authorization()
            ..actor = eosName
            ..permission = 'active'
        ];

        Map data = {
          'owner': eosName,
          'campaign_id': campaign.campaignId.toString()
        };

        List<eos.Action> actions = [
          eos.Action()
            ..account = contractAccount
            ..name = 'deletecamp'
            ..authorization = auth
            ..data = data
        ];
        // print("on9");
        eos.Transaction transaction = eos.Transaction()..actions = actions;
        // print("on99");
        try {
          var response =
              await voteClient.pushTransaction(transaction, broadcast: true);
          // print(response);
          if (!response.containsKey('transaction_id')) {
            _errDialog(context, "Unknown Error");
          } else {
            String transHex = response["transaction_id"];
            SuccessPageArg arg = new SuccessPageArg(
                message:
                    'Campaign has been deleted successfully!\n Transaction hash: $transHex',
                returnPage: 'h');
            Navigator.pop(context);
            Navigator.pushNamed(context, 's', arguments: arg);
          }
        } catch (e) {
          print("hihi");
          print(e);
          Navigator.pop(context);
          Map error = json.decode(e as String);
          print(error);

          _errDialog(context, error["error"]["details"][0]["message"]);
        }
      } catch (e) {
        print(e);
        Navigator.pop(context);
        _errDialog(context, "Invalid Private Key format");
      }
    } else {
      Navigator.pop(context);
      _errDialog(context, "Haven't login");
    }
  }

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as Campaign;
    campaign = args;
    // campaign.setview(CampaignView.Owner);
    return Scaffold(
      appBar: AppBar(
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 10),
            child: GestureDetector(
              onTap: () {
                if (campaign.getCampaignStat() == CampaignStat.Coming) {
                  _requestKey(context);
                }
              },
              child: Icon(
                Icons.delete,
                color: campaign.getCampaignStat() == CampaignStat.Coming
                    ? Colors.white
                    : Colors.white.withOpacity(0.3),
              ),
            ),
          ),
        ],
      ),
      body: Container(
        child: Align(
          alignment: Alignment.topLeft,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Campaign Name: " + campaign.getCampaignName()),
              Text("Owner: " + campaign.getOwner()),
              Text("Start: " + campaign.getStartTime().toLocal().toString()),
              Text("End: " + campaign.getEndTime().toLocal().toString()),
              Row(
                children: [
                  ElevatedButton(
                    style: ButtonStyle(
                      backgroundColor:
                          MaterialStateProperty.resolveWith<Color?>(
                        (Set<MaterialState> states) {
                          if (campaign.getCampaignStat() != CampaignStat.Coming)
                            return Theme.of(context)
                                .colorScheme
                                .primary
                                .withOpacity(0.3);
                          return null; // Use the component's default.
                        },
                      ),
                    ),
                    onPressed: () {
                      if (campaign.getCampaignStat() == CampaignStat.Coming) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) {
                              return EditPage(
                                  campaignId: campaign.campaignId,
                                  editType: EditType.Choice,
                                  editingList: campaign
                                      .getChoiceList()
                                      .map((c) => c.choiceName)
                                      .toList());
                            },
                          ),
                        );
                      }
                    },
                    child: Text("Edit choice"),
                  ),
                  ElevatedButton(
                    style: ButtonStyle(
                      backgroundColor:
                          MaterialStateProperty.resolveWith<Color?>(
                        (Set<MaterialState> states) {
                          if (campaign.getCampaignStat() != CampaignStat.Coming)
                            return Theme.of(context)
                                .colorScheme
                                .primary
                                .withOpacity(0.3);
                          return null; // Use the component's default.
                        },
                      ),
                    ),
                    onPressed: () {
                      if (campaign.getCampaignStat() == CampaignStat.Coming) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) {
                              return EditPage(
                                  campaignId: campaign.campaignId,
                                  editType: EditType.Voter,
                                  editingList: campaign.getVoterList());
                            },
                          ),
                        );
                      }
                    },
                    child: Text("Edit voter"),
                  ),
                ],
              ),
              Expanded(
                  child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  Container(
                    width: MediaQuery.of(context).size.width,
                    child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: campaign.getChoiceList().length + 1,
                        itemBuilder: (_, index) {
                          if (index == 0) {
                            return Container(
                              child: ListTile(
                                title: Text("Choices"),
                              ),
                            );
                          }
                          return Container(
                            child: ListTile(
                              leading: Text((index).toString()),
                              title: Text(campaign
                                  .getChoiceList()[index - 1]
                                  .choiceName),
                            ),
                          );
                        }),
                  ),
                  Container(
                    width: MediaQuery.of(context).size.width,
                    child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: campaign.getVoterList().length + 1,
                        itemBuilder: (_, index) {
                          if (index == 0) {
                            return Container(
                              child: ListTile(
                                title: Text("Voters"),
                              ),
                            );
                          }
                          return Container(
                            child: ListTile(
                              leading: Text((index).toString()),
                              title: Text(campaign.getVoterList()[index - 1]),
                            ),
                          );
                        }),
                  ),
                ],
              ))
            ],
          ),
        ),
      ),
    );
  }
}
