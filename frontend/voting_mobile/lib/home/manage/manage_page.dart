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

class _ManagePageState extends State<ManagePage>
    with SharedDialog, SingleTickerProviderStateMixin {
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

        eos.Transaction transaction = eos.Transaction()..actions = actions;

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

  Widget _buildViewInsideContainer(bool isChoice) {
    final List<String> values =
        isChoice ? campaign.getChoiceListNames() : campaign.getVoterList();

    return _buildListViewInsideContainer(values);
  }

  Widget _buildListViewInsideContainer(List<String> values) {
    return Container(
        padding: EdgeInsets.only(top: 5),
        height: MediaQuery.of(context).size.height * 0.50,
        child: Container(
            child: ListView.builder(
          shrinkWrap: true,
          itemCount: values.length,
          itemBuilder: (_, index) {
            return Container(
                color: index % 2 == 0
                    ? Theme.of(context).primaryColor
                    : Theme.of(context).colorScheme.surface.withOpacity(0.7),
                child: ListTile(
                    leading: Text(
                      "   " + (index + 1).toString(),
                      style: TextStyle(
                        fontSize: 20.0,
                        color: Colors.white,
                      ),
                    ),
                    title: Text(
                      values[index],
                      style: TextStyle(
                        fontSize: 20.0,
                      ),
                    )));
          },
        )));
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
        length: 2,
        child: Builder(builder: (BuildContext context) {
          final args = ModalRoute.of(context)!.settings.arguments as Campaign;
          campaign = args;

          final theme = Theme.of(context);
          final oldTextTheme = theme.textTheme.headline4;

          final campaignTextTheme = oldTextTheme!.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          );
          final dataTextTheme =
              TextStyle(fontSize: 18, fontWeight: FontWeight.w600);
          final listTitleTheme = oldTextTheme!.copyWith(
              fontSize: oldTextTheme.fontSize! * 0.75,
              fontWeight: FontWeight.bold);

          final TabController _tabController =
              DefaultTabController.of(context)!;

          final TextStyle styleOfPopItems =
              TextStyle(fontSize: 16, fontWeight: FontWeight.w600);
          return Scaffold(
            appBar: AppBar(
              actions: [
                PopupMenuButton(
                  icon: Icon(
                    Icons.manage_accounts,
                    size: 37.5,
                  ),
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
                      enabled:
                          campaign.getCampaignStat() == CampaignStat.Coming,
                      value: ItemType.Choice,
                      child: Text(
                        "Edit Choices",
                        style: styleOfPopItems,
                      ),
                    ),
                    PopupMenuItem(
                      enabled:
                          campaign.getCampaignStat() == CampaignStat.Coming,
                      value: ItemType.Voter,
                      child: Text(
                        "Edit Voters",
                        style: styleOfPopItems,
                      ),
                    ),
                    PopupMenuItem(
                      enabled:
                          campaign.getCampaignStat() == CampaignStat.Coming,
                      value: ItemType.Delete,
                      child: Text(
                        "Delete",
                        style: TextStyle(
                            color: campaign.getCampaignStat() ==
                                    CampaignStat.Coming
                                ? Colors.red
                                : null,
                            fontWeight: styleOfPopItems.fontWeight,
                            fontSize: styleOfPopItems.fontSize),
                      ),
                    ),
                  ],
                )
              ],
            ),
            body: SingleChildScrollView(
              child: Align(
                alignment: Alignment.topLeft,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: MediaQuery.of(context).size.width * 0.05),
                      child: Card(
                        color: Theme.of(context).backgroundColor,
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal:
                                MediaQuery.of(context).size.width * 0.01,
                            vertical: MediaQuery.of(context).size.height * 0.01,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: MediaQuery.of(context).size.width * 0.9,
                                padding: EdgeInsets.only(
                                  bottom:
                                      MediaQuery.of(context).size.height * 0.02,
                                ),
                                child: Text(
                                  campaign.getCampaignName(),
                                  style: campaignTextTheme,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Container(
                                padding: EdgeInsets.only(
                                  bottom: MediaQuery.of(context).size.height *
                                      0.003,
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      padding: EdgeInsets.only(
                                        right:
                                            MediaQuery.of(context).size.width *
                                                0.01,
                                      ),
                                      child: Icon(Icons.person),
                                    ),
                                    SizedBox(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.65,
                                        child: Text(
                                          campaign.getOwner(),
                                          style: dataTextTheme,
                                          overflow: TextOverflow.ellipsis,
                                        )),
                                  ],
                                ),
                              ),
                              Container(
                                padding: EdgeInsets.only(
                                  bottom: MediaQuery.of(context).size.height *
                                      0.003,
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      padding: EdgeInsets.only(
                                        right:
                                            MediaQuery.of(context).size.width *
                                                0.01,
                                      ),
                                      child: Icon(Icons.timer_outlined),
                                    ),
                                    Text(
                                        campaign
                                            .getStartTime()
                                            .toLocal()
                                            .toString(),
                                        style: dataTextTheme),
                                  ],
                                ),
                              ),
                              Row(
                                children: [
                                  Container(
                                    padding: EdgeInsets.only(
                                      right: MediaQuery.of(context).size.width *
                                          0.01,
                                    ),
                                    child: Icon(Icons.timer_off_outlined),
                                  ),
                                  Text(
                                      campaign
                                          .getEndTime()
                                          .toLocal()
                                          .toString(),
                                      style: dataTextTheme),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    campaign.getCampaignStat() != CampaignStat.Coming
                        ? InkWell(
                            onTap: () => {
                                  Navigator.pushNamed(context, 'v',
                                      arguments: campaign)
                                },
                            child: Container(
                                padding: EdgeInsets.only(top: 15, bottom: 15),
                                child: Text(
                                    campaign.getCampaignStat() ==
                                            CampaignStat.Ended
                                        ? 'View results?'
                                        : "Check current votecount?",
                                    style: TextStyle(
                                        fontSize: 18,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primary,
                                        fontWeight: FontWeight.bold))))
                        : Container(
                            height: 7.5,
                          ),
                    Container(
                        height: MediaQuery.of(context).size.height * 0.65,
                        width: MediaQuery.of(context).size.width * 0.9,
                        child: Column(children: [
                          TabBar(controller: _tabController, tabs: [
                            Container(
                                padding: EdgeInsets.only(top: 10, bottom: 10),
                                child: Text(
                                  "Choices",
                                  style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold),
                                )),
                            Container(
                                padding: EdgeInsets.only(top: 10, bottom: 10),
                                child: Text("Voters",
                                    style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold)))
                          ]),
                          Expanded(
                              child: TabBarView(
                                  controller: _tabController,
                                  children: [
                                _buildViewInsideContainer(true),
                                _buildViewInsideContainer(false),
                              ])),
                        ])),
                  ],
                ),
              ),
            ),
          );
        }));
  }
}
