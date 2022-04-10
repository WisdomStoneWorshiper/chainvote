import 'package:flutter/material.dart';
import 'package:eosdart/eosdart.dart' as eos;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import '../campaign.dart';
import 'edit_page.dart';
import '../../success_page.dart';
import '../../global_variable.dart';
import '../../shared_dialog.dart';

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

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as Campaign;
    campaign = args;
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    var padding = MediaQuery.of(context).padding;
    double newHeight = height - padding.top - padding.bottom;

    // campaign.setview(CampaignView.Owner);
    DateTime endTime = campaign.getEndTime();
    DateTime startTime = campaign.getStartTime();
    String name = campaign.getCampaignName();
    ScrollController horizontalScrollController = new ScrollController();
    return Scaffold(
        appBar: AppBar(
          title: Text(
            name,
            style: TextStyle(
              fontSize: 22.0,
              fontWeight: FontWeight.bold,
              //color: Theme.of(context).colorScheme.primary,
            ),
          ),
          actions: [
            Padding(
              padding: EdgeInsets.only(right: 10),
              child: GestureDetector(
                onTap: () {
                  if (campaign.getCampaignStat() != CampaignStat.Ongoing) {
                    requestKey(context, _deleteCampaign, "Deleting");
                  }
                },
                child: Icon(
                  Icons.delete,
                  color: campaign.getCampaignStat() != CampaignStat.Ongoing
                      ? Colors.white
                      : Colors.white.withOpacity(0.3),
                ),
              ),
            ),
          ],
        ),
        body: Container(
            alignment: Alignment.topCenter,
            child: Column(children: [
              SizedBox(
                height: 0.05 * newHeight,
              ),
              RichText(
                text: TextSpan(
                  text:
                      "${startTime.day.toString().padLeft(2, '0')}-${startTime.month.toString().padLeft(2, '0')}-${startTime.year.toString().padLeft(2, '0')}  (${startTime.hour.toString().padLeft(2, '0')}:${startTime.minute.toString().padLeft(2, '0')}:${startTime.second.toString().padLeft(2, '0')})\n                       -\n${endTime.day.toString().padLeft(2, '0')}-${endTime.month.toString().padLeft(2, '0')}-${endTime.year.toString().padLeft(2, '0')}  (${endTime.hour.toString().padLeft(2, '0')}:${endTime.minute.toString().padLeft(2, '0')}:${endTime.second.toString().padLeft(2, '0')})",
                  style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontSize: 23.0,
                      fontWeight: FontWeight.bold),
                  // children: <TextSpan>[
                  //   TextSpan(
                  //     text:
                  //         "", //"\n End Date: ${endTime.day.toString().padLeft(2, '0')}-${endTime.month.toString().padLeft(2, '0')}-${endTime.year.toString().padLeft(2, '0')}",
                  //     style: TextStyle(
                  //         color: Colors.red,
                  //         fontSize: 20.0,
                  //         fontWeight: FontWeight.bold),
                  //   )
                  // ]
                ),
              ),
              SizedBox(
                height: 0.05 * newHeight,
              ),
              Container(
                height: newHeight * 0.57,
                width: width * 0.9,
                //color: Colors.orange,
                child: ListView(
                    controller: horizontalScrollController,
                    //shrinkWrap: true,
                    scrollDirection: Axis.horizontal,
                    physics: ClampingScrollPhysics(),
                    children: [
                      SizedBox(
                        height: newHeight * 0.5,
                        width: width * 0.9,
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Stack(children: [
                                Align(
                                  child: Text(
                                    "Choices",
                                    style: TextStyle(
                                        fontSize: 25,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                                Positioned(
                                    right: 0,
                                    height: 30,
                                    child: ElevatedButton(
                                        onPressed: () {
                                          horizontalScrollController
                                              .jumpTo(width * 0.9);
                                        },
                                        style: ElevatedButton.styleFrom(
                                          //primary: Colors.blue,
                                          // minimumSize: Size(20, 30),
                                          // maximumSize: Size(20, 30),

                                          primary: Theme.of(context)
                                              .colorScheme
                                              .background,
                                          shadowColor: Theme.of(context)
                                              .colorScheme
                                              .background,
                                          elevation: 0,
                                        ),
                                        child: Icon(
                                          Icons.arrow_forward_ios,
                                          size: 30,
                                        )))
                              ]),
                              SizedBox(height: 10),
                              Container(
                                  height: newHeight * 0.42,
                                  child: Container(
                                      child: ListView.builder(
                                    shrinkWrap: true,
                                    physics: ClampingScrollPhysics(),
                                    itemCount:
                                        campaign.getChoiceList().length, //10,
                                    itemBuilder: (_, index) {
                                      return Container(
                                          color: index % 2 == 0
                                              ? Theme.of(context)
                                                  .colorScheme
                                                  .secondary
                                              : Theme.of(context)
                                                  .colorScheme
                                                  .primary,
                                          child: ListTile(
                                              leading: Text(
                                                "   " + (index + 1).toString(),
                                                style: TextStyle(
                                                  fontSize: 20.0,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors
                                                      .white, //Theme.of(context).colorScheme.secondary,
                                                ),
                                              ),
                                              title: Text(
                                                //"Number ${index}",
                                                campaign
                                                    .getChoiceList()[index]
                                                    .choiceName,
                                                //"LONG ASSS STRINGGGGGGG!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!",
                                                style: TextStyle(
                                                  fontSize: 22.0,
                                                  fontWeight: FontWeight.bold,
                                                  //color:CO
                                                  // color: Theme.of(context)
                                                  //     .colorScheme
                                                  //     .secondary,
                                                ),
                                              )

                                              // Row(
                                              //     crossAxisAlignment:
                                              //         CrossAxisAlignment.center,
                                              //     children: [
                                              //   Text(
                                              //     "${index}",
                                              //     style: TextStyle(
                                              //       fontSize: 22.0,
                                              //       fontWeight: FontWeight.bold,
                                              //       color: Theme.of(context)
                                              //           .colorScheme
                                              //           .secondary,
                                              //     ),
                                              //   ),
                                              //   Text(
                                              //     campaign
                                              //         .getChoiceList()[index]
                                              //         .choiceName,
                                              //     style: TextStyle(
                                              //       fontSize: 22.0,
                                              //       fontWeight: FontWeight.bold,
                                              //       color: Theme.of(context)
                                              //           .colorScheme
                                              //           .secondary,
                                              //     ),
                                              //   ),
                                              //   // tileColor: index % 2 == 0
                                              //   //     ? Theme.of(context)
                                              //   //         .colorScheme
                                              //   //         .primary
                                              //   //     : Theme.of(context)
                                              //   //         .colorScheme
                                              //   //         .secondary,
                                              // ]),
                                              )); //);
                                    },
                                  ))),
                              SizedBox(
                                height: 15,
                                width: width * 0.9,
                                //child: Container(color: Colors.red)),
                              ),
                              ElevatedButton(
                                // style: ButtonStyle(
                                //backgroundColor: Colors.white,
                                //   MaterialStateProperty.resolveWith<Color?>(
                                // (Set<MaterialState> states) {
                                //   if (campaign.getCampaignStat() !=
                                //       CampaignStat.Coming)
                                //     return Theme.of(context)
                                //         .colorScheme
                                //         .primary
                                //         .withOpacity(0.3);
                                //   return null; // Use the component's default.
                                // },
                                // ),
                                style: campaign.getCampaignStat() ==
                                        CampaignStat.Coming
                                    ? null
                                    : ElevatedButton.styleFrom(
                                        primary: Theme.of(context)
                                            .colorScheme
                                            .surface,
                                      ),
                                onPressed: () {
                                  if (campaign.getCampaignStat() ==
                                      CampaignStat.Coming) {
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
                                  } else {
                                    final wrongSnackbar = SnackBar(
                                        content: Text(campaign
                                                    .getCampaignStat() ==
                                                CampaignStat.Ended
                                            ? "Campaign has already ended"
                                            : "Cannot make changes to ongoing campaign"),
                                        action: SnackBarAction(
                                          label: 'OK',
                                          onPressed: () {},
                                        ));
                                    ScaffoldMessenger.of(context)
                                        .showSnackBar(wrongSnackbar);
                                  }
                                },
                                child: Text(
                                  "Edit Choices",
                                  style: TextStyle(
                                      fontSize: 18.0,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            ]),
                      ),
                      SizedBox(
                          height: newHeight * 0.5,
                          width: width * 0.9,
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Stack(children: [
                                  Align(
                                    child: Text(
                                      "Voters",
                                      style: TextStyle(
                                          fontSize: 25,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  Positioned(
                                      left: 0,
                                      height: 30,
                                      child: ElevatedButton(
                                          onPressed: () {
                                            horizontalScrollController
                                                .jumpTo(0);
                                          },
                                          style: ElevatedButton.styleFrom(
                                            //primary: Colors.blue,
                                            // minimumSize: Size(20, 30),
                                            // maximumSize: Size(20, 30),

                                            primary: Theme.of(context)
                                                .colorScheme
                                                .background,
                                            shadowColor: Theme.of(context)
                                                .colorScheme
                                                .background,
                                            elevation: 0,
                                          ),
                                          child: Icon(
                                            Icons.arrow_back_ios,
                                            size: 30,
                                          ))),
                                ]),
                                SizedBox(height: 10),
                                Container(
                                    height: newHeight * 0.42,
                                    child: Container(
                                        child: ListView.builder(
                                      shrinkWrap: true,
                                      physics: ClampingScrollPhysics(),
                                      itemCount:
                                          campaign.getVoterList().length, //10,
                                      itemBuilder: (_, index) {
                                        return Container(
                                            color: index % 2 == 0
                                                ? Theme.of(context)
                                                    .colorScheme
                                                    .secondary
                                                : Theme.of(context)
                                                    .colorScheme
                                                    .primary,
                                            child: ListTile(
                                                leading: Text(
                                                  "   " +
                                                      (index + 1).toString(),
                                                  style: TextStyle(
                                                    fontSize: 20.0,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors
                                                        .white, //Theme.of(context).colorScheme.secondary,
                                                  ),
                                                ),
                                                title: Text(
                                                  //"Number ${index}",
                                                  campaign
                                                      .getVoterList()[index],

                                                  //"LONG ASSS STRINGGGGGGG!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!",
                                                  style: TextStyle(
                                                    fontSize: 22.0,
                                                    fontWeight: FontWeight.bold,
                                                    //color:CO
                                                    // color: Theme.of(context)
                                                    //     .colorScheme
                                                    //     .secondary,
                                                  ),
                                                )

                                                // Row(
                                                //     crossAxisAlignment:
                                                //         CrossAxisAlignment.center,
                                                //     children: [
                                                //   Text(
                                                //     "${index}",
                                                //     style: TextStyle(
                                                //       fontSize: 22.0,
                                                //       fontWeight: FontWeight.bold,
                                                //       color: Theme.of(context)
                                                //           .colorScheme
                                                //           .secondary,
                                                //     ),
                                                //   ),
                                                //   Text(
                                                //     campaign
                                                //         .getChoiceList()[index]
                                                //         .choiceName,
                                                //     style: TextStyle(
                                                //       fontSize: 22.0,
                                                //       fontWeight: FontWeight.bold,
                                                //       color: Theme.of(context)
                                                //           .colorScheme
                                                //           .secondary,
                                                //     ),
                                                //   ),
                                                //   // tileColor: index % 2 == 0
                                                //   //     ? Theme.of(context)
                                                //   //         .colorScheme
                                                //   //         .primary
                                                //   //     : Theme.of(context)
                                                //   //         .colorScheme
                                                //   //         .secondary,
                                                // ]),
                                                )); //);
                                      },
                                    ))),
                                SizedBox(
                                  height: 15,
                                  width: width * 0.9,
                                  //child: Container(color: Colors.red)),
                                ),
                                ElevatedButton(
                                  // style: ButtonStyle(
                                  //backgroundColor: Colors.white,
                                  //   MaterialStateProperty.resolveWith<Color?>(
                                  // (Set<MaterialState> states) {
                                  //   if (campaign.getCampaignStat() !=
                                  //       CampaignStat.Coming)
                                  //     return Theme.of(context)
                                  //         .colorScheme
                                  //         .primary
                                  //         .withOpacity(0.3);
                                  //   return null; // Use the component's default.
                                  // },
                                  // ),
                                  style: campaign.getCampaignStat() ==
                                          CampaignStat.Coming
                                      ? null
                                      : ElevatedButton.styleFrom(
                                          primary: Theme.of(context)
                                              .colorScheme
                                              .surface,
                                        ),
                                  onPressed: () {
                                    if (campaign.getCampaignStat() ==
                                        CampaignStat.Coming) {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) {
                                            return EditPage(
                                                campaignId: campaign.campaignId,
                                                editType: EditType.Voter,
                                                editingList:
                                                    campaign.getVoterList());
                                          },
                                        ),
                                      );
                                    } else {
                                      final wrongSnackbar = SnackBar(
                                          content: Text(campaign
                                                      .getCampaignStat() ==
                                                  CampaignStat.Ended
                                              ? "Campaign has already ended"
                                              : "Cannot make changes to ongoing campaign"),
                                          action: SnackBarAction(
                                            label: 'OK',
                                            onPressed: () {},
                                          ));
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(wrongSnackbar);
                                    }
                                  },
                                  child: Text(
                                    "Edit Voters",
                                    style: TextStyle(
                                        fontSize: 18.0,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ])),
                    ]),
              ),
            ])));

    //

    // Column(
    //                         crossAxisAlignment: CrossAxisAlignment.center,
    //                         children: [
    //                           Stack(children: [
    //                             Align(
    //                               child: Text(
    //                                 "Choices",
    //                                 style: TextStyle(
    //                                     fontSize: 25,
    //                                     fontWeight: FontWeight.bold),
    //                               ),
    //                             ),
    //                             Positioned(
    //                                 right: 0,
    //                                 height: 30,
    //                                 child: ElevatedButton(
    //                                     onPressed: () {
    //                                       horizontalScrollController
    //                                           .jumpTo(width * 0.9);
    //                                     },
    //                                     style: ElevatedButton.styleFrom(
    //                                       //primary: Colors.blue,
    //                                       // minimumSize: Size(20, 30),
    //                                       // maximumSize: Size(20, 30),

    //                                       primary: Theme.of(context)
    //                                           .colorScheme
    //                                           .background,
    //                                       shadowColor: Theme.of(context)
    //                                           .colorScheme
    //                                           .background,
    //                                       elevation: 0,
    //                                     ),
    //                                     child: Icon(
    //                                       Icons.arrow_forward_ios,
    //                                       size: 30,
    //                                     )))
    //                           ]),

    // return Scaffold(
    //     appBar: AppBar(
    //       title: Text(campaign.getCampaignName()),
    //       actions: [
    //         Padding(
    //           padding: EdgeInsets.only(right: 10),
    //           child: GestureDetector(
    //             onTap: () {
    //               if (campaign.getCampaignStat() != CampaignStat.Ongoing) {
    //                 requestKey(context, _deleteCampaign, "Deleting");
    //               }
    //             },
    //             child: Icon(
    //               Icons.delete,
    //               color: campaign.getCampaignStat() != CampaignStat.Ongoing
    //                   ? Colors.white
    //                   : Colors.white.withOpacity(0.3),
    //             ),
    //           ),
    //         ),
    //       ],
    //     ),
    //     body: Container(
    //       child: Align(
    //         alignment: Alignment.center,
    //         child: Center(
    //           child: Column(
    //             // crossAxisAlignment: CrossAxisAlignment.center,
    //             // mainAxisAlignment: MainAxisAlignment.center,
    //             children: [
    //               //Text("Owner: " + campaign.getOwner()),
    //               // //Text(campaign.getStartTime().toLocal().toString() +
    //               //     "  -  " +
    //               //     campaign.getEndTime().toLocal().toString()),
    //               SizedBox(height: newHeight * 0.05),
    //               RichText(
    //                 text: TextSpan(
    //                     text:
    //                         "${startTime.day.toString().padLeft(2, '0')}-${startTime.month.toString().padLeft(2, '0')}-${startTime.year.toString().padLeft(2, '0')}  (${startTime.hour.toString().padLeft(2, '0')}:${startTime.minute.toString().padLeft(2, '0')}:${startTime.second.toString().padLeft(2, '0')})\n                       -\n${endTime.day.toString().padLeft(2, '0')}-${endTime.month.toString().padLeft(2, '0')}-${endTime.year.toString().padLeft(2, '0')}  (${endTime.hour.toString().padLeft(2, '0')}:${endTime.minute.toString().padLeft(2, '0')}:${endTime.second.toString().padLeft(2, '0')})",
    //                     style: TextStyle(
    //                         // color: Colors
    //                         //     .white, //Theme.of(context).colorScheme.secondary,
    //                         fontSize: 20.0,
    //                         fontWeight: FontWeight.bold),
    //                     children: <TextSpan>[
    //                       TextSpan(
    //                         text:
    //                             "", //"\n End Date: ${endTime.day.toString().padLeft(2, '0')}-${endTime.month.toString().padLeft(2, '0')}-${endTime.year.toString().padLeft(2, '0')}",
    //                         style: TextStyle(
    //                             color: Colors.red,
    //                             fontSize: 20.0,
    //                             fontWeight: FontWeight.bold),
    //                       )
    //                     ]),
    //               ),
    //               SizedBox(
    //                 height: 0.05 * newHeight,
    //               ),
    //               SizedBox(
    //                 height: 0.5 * newHeight,
    //                 child: //Expanded(child:
    //                     ListView(
    //                   scrollDirection: Axis.horizontal,
    //                   children: [
    //                     SizedBox(
    //                         height: 50,
    //                         child: Container(
    //                             //alignment: Alignment.topCenter,
    //                             width: MediaQuery.of(context).size.width,
    //                             height: 50,
    //                             child: Container(
    //                               alignment: Alignment.topCenter,
    //                               child: ListView.builder(
    //                                   shrinkWrap: true,
    //                                   physics: AlwaysScrollableScrollPhysics(),
    //                                   itemCount:
    //                                       campaign.getChoiceList().length + 1,
    //                                   itemBuilder: (_, index) {
    //                                     if (index == 0) {
    //                                       return Container(
    //                                         alignment: Alignment.center,
    //                                         child: ListTile(
    //                                           title: Text(
    //                                             "", //"Choices",
    //                                             style: TextStyle(
    //                                                 fontSize: 18.0,
    //                                                 fontWeight:
    //                                                     FontWeight.bold),
    //                                           ),
    //                                         ),
    //                                       );
    //                                     }
    //                                     return Container(
    //                                       child: ListTile(
    //                                         leading: Text((index).toString()),
    //                                         title: Text(
    //                                           campaign
    //                                               .getChoiceList()[index - 1]
    //                                               .choiceName,
    //                                           style: TextStyle(
    //                                               fontSize: 18.0,
    //                                               fontWeight: FontWeight.bold),
    //                                         ),
    //                                         tileColor: index % 2 == 0
    //                                             ? Theme.of(context)
    //                                                 .colorScheme
    //                                                 .primary
    //                                             : Theme.of(context)
    //                                                 .colorScheme
    //                                                 .secondary,
    //                                       ),
    //                                     );
    //                                   }),
    //                             ))),
    //                     Container(
    //                       width: MediaQuery.of(context).size.width,
    //                       child: ListView.builder(
    //                           shrinkWrap: true,
    //                           itemCount: campaign.getVoterList().length + 1,
    //                           itemBuilder: (_, index) {
    //                             if (index == 0) {
    //                               return Container(
    //                                 child: ListTile(
    //                                   title: Text(
    //                                     "", //"Voters",
    //                                     style: TextStyle(
    //                                         fontSize: 18.0,
    //                                         fontWeight: FontWeight.bold),
    //                                   ),
    //                                 ),
    //                               );
    //                             }
    //                             return Container(
    //                               child: ListTile(
    //                                 leading: Text((index).toString()),
    //                                 title: Text(
    //                                   campaign.getVoterList()[index - 1],
    //                                   style: TextStyle(
    //                                       fontSize: 18.0,
    //                                       fontWeight: FontWeight.bold),
    //                                 ),
    //                                 tileColor: index % 2 == 0
    //                                     ? Theme.of(context).colorScheme.primary
    //                                     : Theme.of(context)
    //                                         .colorScheme
    //                                         .secondary,
    //                               ),
    //                             );
    //                           }),
    //                     ),
    //                   ],
    //                 ), //),
    //               ),

    //               Row(
    //                 mainAxisAlignment: MainAxisAlignment.center,
    //                 children: [
    //                   ElevatedButton(
    //                     // style: ButtonStyle(
    //                     //backgroundColor: Colors.white,
    //                     //   MaterialStateProperty.resolveWith<Color?>(
    //                     // (Set<MaterialState> states) {
    //                     //   if (campaign.getCampaignStat() !=
    //                     //       CampaignStat.Coming)
    //                     //     return Theme.of(context)
    //                     //         .colorScheme
    //                     //         .primary
    //                     //         .withOpacity(0.3);
    //                     //   return null; // Use the component's default.
    //                     // },
    //                     // ),
    //                     onPressed: () {
    //                       if (campaign.getCampaignStat() ==
    //                           CampaignStat.Coming) {
    //                         Navigator.push(
    //                           context,
    //                           MaterialPageRoute(
    //                             builder: (context) {
    //                               return EditPage(
    //                                   campaignId: campaign.campaignId,
    //                                   editType: EditType.Choice,
    //                                   editingList: campaign
    //                                       .getChoiceList()
    //                                       .map((c) => c.choiceName)
    //                                       .toList());
    //                             },
    //                           ),
    //                         );
    //                       }
    //                     },
    //                     child: Text(
    //                       "Edit choice",
    //                       style: TextStyle(
    //                           fontSize: 18.0, fontWeight: FontWeight.bold),
    //                     ),
    //                   ),
    //                   SizedBox(
    //                     width: 0.075 * width,
    //                   ),
    //                   ElevatedButton(
    //                     // style: ButtonStyle(
    //                     //   backgroundColor:
    //                     //       MaterialStateProperty.resolveWith<Color?>(
    //                     //     (Set<MaterialState> states) {
    //                     //       if (campaign.getCampaignStat() !=
    //                     //           CampaignStat.Coming)
    //                     //         return Theme.of(context)
    //                     //             .colorScheme
    //                     //             .primary
    //                     //             .withOpacity(0.3);
    //                     //       return null; // Use the component's default.
    //                     //     },
    //                     //   ),
    //                     // ),

    //                     onPressed: () {
    //                       if (campaign.getCampaignStat() ==
    //                           CampaignStat.Coming) {
    //                         Navigator.push(
    //                           context,
    //                           MaterialPageRoute(
    //                             builder: (context) {
    //                               return EditPage(
    //                                   campaignId: campaign.campaignId,
    //                                   editType: EditType.Voter,
    //                                   editingList: campaign.getVoterList());
    //                             },
    //                           ),
    //                         );
    //                       }
    //                     },
    //                     child: Text(
    //                       "Edit voter",
    //                       style: TextStyle(
    //                           fontSize: 18.0, fontWeight: FontWeight.bold),
    //                     ),
    //                   ),
    //                 ],
    //               ),
    //             ],
    //           ),
    //         ),
    //       ),
    //     ));
  }
}
