import 'package:flutter/material.dart';

import 'campaign.dart';

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
                    onPressed: () {},
                    child: Text("Edit choice"),
                  ),
                  ElevatedButton(
                    onPressed: () {},
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
                      itemCount: campaign.getChoiceList().length,
                      itemBuilder: (_, index) => Container(
                        child: ListTile(
                          leading: Text((index + 1).toString()),
                          title:
                              Text(campaign.getChoiceList()[index].choiceName),
                        ),
                      ),
                    ),
                  ),
                  Container(
                    width: MediaQuery.of(context).size.width,
                    child: Text("data1"),
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
