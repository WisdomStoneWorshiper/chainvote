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
  // late TabController _tabController;

  // @override
  // void initState() {
  //   _tabController = TabController(vsync: this, length: 2);
  //   super.initState();
  // }

  // @override
  // void dispose() {
  //   _tabController.dispose();
  //   super.dispose();
  // }

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

  Widget _buildViewInsideContainer(bool isChoice) {
    final List<String> values =
        isChoice ? campaign.getChoiceListNames() : campaign.getVoterList();

    // late ElevatedButton button;

    // if (isChoice) {
    //   button = ElevatedButton(
    //     style: campaign.getCampaignStat() == CampaignStat.Coming
    //         ? null
    //         : ElevatedButton.styleFrom(
    //             primary: Theme.of(context).colorScheme.surface,
    //           ),
    //     onPressed: () {
    //       if (campaign.getCampaignStat() == CampaignStat.Coming) {
    //         Navigator.push(
    //           context,
    //           MaterialPageRoute(
    //             builder: (context) {
    //               return EditPage(
    //                   campaignId: campaign.campaignId,
    //                   editType: EditType.Choice,
    //                   editingList: campaign
    //                       .getChoiceList()
    //                       .map((c) => c.choiceName)
    //                       .toList());
    //             },
    //           ),
    //         );
    //       } else {
    //         final wrongSnackbar = SnackBar(
    //             content: Text(campaign.getCampaignStat() == CampaignStat.Ended
    //                 ? "Campaign has already ended"
    //                 : "Cannot make changes to ongoing campaign"),
    //             action: SnackBarAction(
    //               label: 'OK',
    //               onPressed: () {},
    //             ));
    //         ScaffoldMessenger.of(context).showSnackBar(wrongSnackbar);
    //       }
    //     },
    //     child: Text(
    //       "Edit Choices",
    //       style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
    //     ),
    //   );
    // } else {
    //   button = ElevatedButton(
    //     style: campaign.getCampaignStat() == CampaignStat.Coming
    //         ? null
    //         : ElevatedButton.styleFrom(
    //             primary: Theme.of(context).colorScheme.surface,
    //           ),
    //     onPressed: () {
    //       if (campaign.getCampaignStat() == CampaignStat.Coming) {
    //         Navigator.push(
    //           context,
    //           MaterialPageRoute(
    //             builder: (context) {
    //               return EditPage(
    //                   campaignId: campaign.campaignId,
    //                   editType: EditType.Voter,
    //                   editingList: campaign.getVoterList());
    //             },
    //           ),
    //         );
    //       } else {
    //         final wrongSnackbar = SnackBar(
    //             content: Text(campaign.getCampaignStat() == CampaignStat.Ended
    //                 ? "Campaign has already ended"
    //                 : "Cannot make changes to ongoing campaign"),
    //             action: SnackBarAction(
    //               label: 'OK',
    //               onPressed: () {},
    //             ));
    //         ScaffoldMessenger.of(context).showSnackBar(wrongSnackbar);
    //       }
    //     },
    //     child: Text(
    //       "Edit Voters",
    //       style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
    //     ),
    //   );
    // }

    // return Column(children: [
    //   _buildListViewInsideContainer(values),
    //   SizedBox(
    //     height: 12.5,
    //   ),
    //   button
    // ]);

    // List<String> values = [];
    // for (int i = 0; i < 50; i++) {
    //   values.add("Choice " + (i + 1).toString());
    // }

    return _buildListViewInsideContainer(
        values); //Expanded(child: _buildListViewInsideContainer(values));
  }

  Widget _buildListViewInsideContainer(List<String> values) {
    return Container(
        //color: Colors.orange,
        padding: EdgeInsets.only(top: 5),
        height: MediaQuery.of(context).size.height * 0.50,
        child: Container(
            child: ListView.builder(
          shrinkWrap: true,
          //physics: ClampingScrollPhysics(),
          itemCount: values.length,
          itemBuilder: (_, index) {
            return Container(
                color: index % 2 == 0
                    ? Theme.of(context).primaryColor //colorScheme.secondary
                    : Theme.of(context)
                        .colorScheme
                        .surface
                        .withOpacity(0.7), //colorScheme.primary,
                child: ListTile(
                    leading: Text(
                      "   " + (index + 1).toString(),
                      style: TextStyle(
                        fontSize: 20.0,
                        //fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    title: Text(
                      values[index],
                      style: TextStyle(
                        fontSize: 20.0,
                        //fontWeight: FontWeight.bold,
                      ),
                    )));
          },
        )));
  }

  @override
  Widget build(BuildContext context) {
    //TabController _tabController = new TabController(length: 2, vsync: this);
    //final horizontalScrollController = new ScrollController();

    // List<Widget> bigList = [
    //   _getList(
    //       "Choices",
    //       [for (Choice c in campaign.getChoiceList()) c.choiceName],
    //       listTitleTheme),
    //   _getList("Voters", campaign.getVoterList(), listTitleTheme),
    // ];
    // campaign.setview(CampaignView.Owner);
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
          final dataTextTheme = TextStyle(
              fontSize: 18,
              //color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.w600
              //
              );
          final listTitleTheme = oldTextTheme!.copyWith(
              fontSize: oldTextTheme.fontSize! * 0.75,
              fontWeight: FontWeight.bold);

          final TabController _tabController =
              DefaultTabController.of(context)!;

          final TextStyle styleOfPopItems =
              TextStyle(fontSize: 16, fontWeight: FontWeight.w600);
          return Scaffold(
            appBar: AppBar(
              // actions: [
              //   Padding(
              //     padding: EdgeInsets.only(right: 10),
              //     child: GestureDetector(
              //       onTap: () {
              //         if (campaign.getCampaignStat() == CampaignStat.Coming) {
              //           requestKey(context, _deleteCampaign, "Deleting");
              //         }
              //       },
              //       child: Icon(
              //         Icons.delete,
              //         color: campaign.getCampaignStat() == CampaignStat.Coming
              //             ? Colors.white
              //             : Colors.white.withOpacity(0.3),
              //       ),
              //     ),
              //   ),
              // ],
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
                      child: //Row(children: [
                          Text(
                        "Delete",
                        style: TextStyle(
                            color: campaign.getCampaignStat() ==
                                    CampaignStat.Coming
                                ? Colors.red
                                : null,
                            fontWeight: styleOfPopItems.fontWeight,
                            fontSize: styleOfPopItems.fontSize),
                      ),
                      //Icon(Icons.delete)
                      //]),
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
                        //color: Theme.of(context).colorScheme.primary,
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
                    // Expanded(
                    //   child: Swiper(
                    //     itemCount: 2,
                    //     pagination: SwiperPagination(),
                    //     control: SwiperControl(),
                    //     loop: false,
                    //     itemBuilder: (context, index) {
                    //       return bigList[index];
                    //     },
                    //   ),
                    // ),
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
                                        //Theme.of(context).colorScheme.primary, //Colors.blue,
                                        fontWeight: FontWeight.bold))))
                        : Container(
                            height: 7.5,
                          ),

                    Container(
                        // color: Colors.blue,
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
