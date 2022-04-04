import 'package:flutter/material.dart';
import 'package:eosdart/eosdart.dart' as eos;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:card_swiper/card_swiper.dart';

import '../campaign.dart';
import 'edit_page.dart';
import '../../success_page.dart';
import '../../global_variable.dart';
import '../../shared_dialog.dart';
import '../navigation_bar_view.dart';

enum ItemType { Choice, Voter, Delete }

class ManagePage extends StatefulWidget {
  const ManagePage({Key? key}) : super(key: key);

  @override
  _ManagePageState createState() => _ManagePageState();
}

class _ManagePageState extends State<ManagePage> with SharedDialog {
  late Campaign campaign;
  final TextEditingController _pkController = TextEditingController();

  void _deleteCampaign(BuildContext context, String pk) async {
    eos.EOSClient voteClient = client;
    final prefs = await SharedPreferences.getInstance();

    final String eosName = prefs.getString('eosName') ?? "";
    final String itsc = prefs.getString('itsc') ?? "";
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
            errDialog(context, "Unknown Error");
          } else {
            String transHex = response["transaction_id"];
            HomeArg homeArg = HomeArg(itsc, eosName);
            SuccessPageArg arg = SuccessPageArg(
                message:
                    'Campaign has been deleted successfully!\n Transaction hash: $transHex',
                returnPage: 'h',
                arg: homeArg);
            Navigator.pop(context);
            Navigator.pushNamed(context, 's', arguments: arg);
          }
        } catch (e) {
          print("hihi");
          print(e);
          Navigator.pop(context);
          Map error = json.decode(e as String);
          print(error);

          errDialog(context, error["error"]["details"][0]["message"]);
        }
      } catch (e) {
        print(e);
        Navigator.pop(context);
        errDialog(context, "Invalid Private Key format");
      }
    } else {
      Navigator.pop(context);
      errDialog(context, "Haven't login");
    }
  }

  Widget _getList(String title, List<String> list, var tilteTheme) {
    return Container(
      width: MediaQuery.of(context).size.width,
      padding: EdgeInsets.symmetric(
          horizontal: MediaQuery.of(context).size.width * 0.04),
      child: ListView.builder(
          shrinkWrap: true,
          itemCount: list.length + 1,
          itemBuilder: (_, index) {
            if (index == 0) {
              return Container(
                child: ListTile(
                  title: Text(
                    title,
                    style: tilteTheme,
                  ),
                ),
              );
            }
            return Container(
              child: ListTile(
                leading: Text((index).toString()),
                title: Text(list[index - 1]),
              ),
            );
          }),
    );
  }

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as Campaign;
    campaign = args;

    final theme = Theme.of(context);
    final oldTextTheme = theme.textTheme.headline4;

    final campaignTextTheme =
        oldTextTheme!.copyWith(fontWeight: FontWeight.bold);

    final listTitleTheme = oldTextTheme!.copyWith(
        fontSize: oldTextTheme.fontSize! * 0.75, fontWeight: FontWeight.bold);

    List<Widget> bigList = [
      _getList(
          "Choices",
          [for (Choice c in campaign.getChoiceList()) c.choiceName],
          listTitleTheme),
      _getList("Voters", campaign.getVoterList(), listTitleTheme),
    ];
    // campaign.setview(CampaignView.Owner);
    return Scaffold(
      appBar: AppBar(
        actions: [
          PopupMenuButton(
            onSelected: ((value) {
              switch (value) {
                case ItemType.Choice:
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
                  break;
                case ItemType.Voter:
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
                  break;
                case ItemType.Delete:
                  requestKey(context, _deleteCampaign, "Deleting");
                  break;
                default:
                  break;
              }
            }),
            itemBuilder: (context) => [
              PopupMenuItem(
                enabled: campaign.getCampaignStat() == CampaignStat.Coming,
                value: ItemType.Choice,
                child: Text("Edit choice"),
              ),
              PopupMenuItem(
                enabled: campaign.getCampaignStat() == CampaignStat.Coming,
                value: ItemType.Voter,
                child: Text("Edit voter"),
              ),
              PopupMenuItem(
                enabled: campaign.getCampaignStat() == CampaignStat.Coming,
                value: ItemType.Delete,
                child: Text("Delete"),
              ),
            ],
          )
        ],
      ),
      body: Container(
        child: Align(
          alignment: Alignment.topLeft,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.symmetric(
                    horizontal: MediaQuery.of(context).size.width * 0.05),
                child: Card(
                  color: Color.fromARGB(255, 2, 21, 27),
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: MediaQuery.of(context).size.width * 0.01,
                      vertical: MediaQuery.of(context).size.height * 0.01,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: EdgeInsets.only(
                            bottom: MediaQuery.of(context).size.height * 0.02,
                          ),
                          child: Text(
                            campaign.getCampaignName(),
                            style: campaignTextTheme,
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.only(
                            bottom: MediaQuery.of(context).size.height * 0.003,
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: EdgeInsets.only(
                                  right:
                                      MediaQuery.of(context).size.width * 0.01,
                                ),
                                child: Icon(Icons.person),
                              ),
                              Text(campaign.getOwner()),
                            ],
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.only(
                            bottom: MediaQuery.of(context).size.height * 0.003,
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: EdgeInsets.only(
                                  right:
                                      MediaQuery.of(context).size.width * 0.01,
                                ),
                                child: Icon(Icons.timer_outlined),
                              ),
                              Text(
                                  campaign.getStartTime().toLocal().toString()),
                            ],
                          ),
                        ),
                        Row(
                          children: [
                            Container(
                              padding: EdgeInsets.only(
                                right: MediaQuery.of(context).size.width * 0.01,
                              ),
                              child: Icon(Icons.timer_off_outlined),
                            ),
                            Text(campaign.getEndTime().toLocal().toString()),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Swiper(
                  itemCount: 2,
                  pagination: SwiperPagination(),
                  control: SwiperControl(),
                  loop: false,
                  itemBuilder: (context, index) {
                    return bigList[index];
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
