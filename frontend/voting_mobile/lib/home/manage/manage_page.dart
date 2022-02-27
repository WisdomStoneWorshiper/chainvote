import 'package:flutter/material.dart';

import '../campaign.dart';
import 'edit_page.dart';

class ManagePage extends StatefulWidget {
  const ManagePage({Key? key}) : super(key: key);

  @override
  _ManagePageState createState() => _ManagePageState();
}

class _ManagePageState extends State<ManagePage> {
  late Campaign campaign;

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as Campaign;
    campaign = args;
    // campaign.setview(CampaignView.Owner);
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
