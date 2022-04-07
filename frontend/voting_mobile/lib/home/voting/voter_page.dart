import 'dart:async';

import 'package:flutter/material.dart';
// import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../../../global_variable.dart';
import '../campaign.dart';
import '../voter.dart';

class VoterPage extends StatefulWidget {
  final String itsc;
  final String eosAccountName;
  const VoterPage({required this.itsc, required this.eosAccountName, Key? key})
      : super(key: key);

  @override
  _VoterPageState createState() =>
      _VoterPageState(itsc: itsc, eosAccountName: eosAccountName);
}

class _VoterPageState extends State<VoterPage> {
  final String itsc;
  final String eosAccountName;

  late Voter user;

  _VoterPageState({required this.itsc, required this.eosAccountName});

  bool _isLoad = false;
  Future<List<Campaign>> init(String voterName) async {
    user = Voter(voterName: eosAccountName);
    await user.init();
    List<Campaign> t = [];
    for (VotingRecord vr in user.getVotableCampaigns()) {
      Campaign c = new Campaign(
        campaignId: vr.campaignId,
        view: CampaignView.List,
        callback: _viewVotableCampaign,
        isVoted:
            vr.isVoted == true ? CampaignVoteStat.Yes : CampaignVoteStat.No,
      );
      await c.init();
      t.add(c);
    }
    print(user.getVotableCampaigns());
    _isLoad = true;
    // print(t.length);
    return Future<List<Campaign>>.value(t);
  }

  Future<void> _onRefresh() async {
    _isLoad = false;
    setState(() {});
    await Future.doWhile(() async {
      if (_isLoad == true) {
        return true;
      } else {
        return false;
      }
    });
    // return Future.delayed(Duration(seconds: 2));
  }

  void _viewVotableCampaign(Campaign c) {
    Navigator.pushNamed(context, 'v', arguments: c);
  }

  Widget _secondaryDetailText(Campaign c) {
    String text1 = "";
    String text2 = "";
    DateTime endTime = c.getEndTime();
    DateTime startTime = c.getStartTime();
    print(c.getCampaignStat());
    if (c.getCampaignStat() == CampaignStat.Ongoing) {
      text1 = "Ends On ";
      text2 = endTime.day.toString() +
          "-" +
          endTime.month.toString().padLeft(2, '0') +
          "-" +
          endTime.year.toString().padLeft(2, '0');
    } else if (c.getCampaignStat() == CampaignStat.Coming) {
      text1 = "Starts on ";
      text2 = startTime.day.toString() +
          "-" +
          startTime.month.toString().padLeft(2, '0') +
          "-" +
          startTime.year.toString().padLeft(2, '0');
    } else if (c.getCampaignStat() == CampaignStat.Ended) {
      text1 = "Ended On ";
      text2 = endTime.day.toString() +
          "-" +
          endTime.month.toString().padLeft(2, '0') +
          "-" +
          endTime.year.toString().padLeft(2, '0');
    }
    return Text(
      text1 + text2,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      softWrap: false,
      style: TextStyle(fontSize: 15.0, fontWeight: FontWeight.w500),
    );
  }

  Widget _createCampaignElement(Campaign c) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    var padding = MediaQuery.of(context).padding;
    double newHeight = height - padding.top - padding.bottom;

    Campaign currentCampaign = c;
    //int maxLimitForCampaignName = 18;
    String name = currentCampaign.getCampaignName();
    //name = "asdjanfjenfqenfiefneqigfqegiqebgeqbgqegbeqgqe";
    //name = "abcdeabcdeabcde";
    //name = "abc";
    //name = "abcdeabcdeabcde";

    // if (name.length >= maxLimitForCampaignName - 2) {
    //   name = name.substring(1, maxLimitForCampaignName - 2) + "..";
    //   name = name.padLeft(25);
    // } else {
    //   print("ELSE REACHED");
    //   String spaces = " " * (maxLimitForCampaignName - name.length);
    //   name.padLeft(20);

    //   name = name + spaces;
    // }

    //name = "abdahsofafineqoigfnewougwebgweu";
    //DateTime endTime = currentCampaign.getEndTime();
    return Container(
        width: double.infinity,
        height: 120,
        decoration: new BoxDecoration(
          color: Theme.of(context).colorScheme.background,
        ),
        alignment: Alignment.center,
        child:
            // width: width * 0.9,
            // height: 40,
            // decoration: new BoxDecoration(
            //     color:
            //         Theme.of(context).colorScheme.secondary,
            //     borderRadius: BorderRadius.circular(20)),
            ElevatedButton(
                onPressed: () {
                  print("BUTTON PRESSED"); //add routing function here
                  Navigator.pushNamed(context, 'm', arguments: currentCampaign);
                },
                style: ElevatedButton.styleFrom(
                    //primary: Colors.blue,
                    minimumSize: Size(width * 0.95, 100),
                    maximumSize: Size(width * 0.95, 100),
                    primary: Theme.of(context)
                        .colorScheme
                        .background, //Theme.of(context).colorScheme.secondary,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20.0),
                        side: BorderSide(
                          color: c.getCampaignStat() == CampaignStat.Ongoing
                              ? Theme.of(context).colorScheme.secondary
                              : Theme.of(context).colorScheme.primary,
                        ))),
                child:
                    Row(mainAxisAlignment: MainAxisAlignment.start, children: [
                  SizedBox(
                      width: width * 0.20,
                      height: width * 0.20,
                      child: Image.asset(
                        'assets/voting_icon.png',
                        height: 40,
                      )),
                  SizedBox(width: 35),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // SizedBox(
                      //   height: 30,
                      // ),
                      SizedBox(
                          width: width * 0.55,
                          child: Text(
                            "$name",
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            softWrap: false,
                            style: TextStyle(
                                fontSize: 20.0, fontWeight: FontWeight.bold),
                          )),
                      SizedBox(height: 10),
                      SizedBox(
                        width: width * 0.55,
                        child: _secondaryDetailText(currentCampaign),
                      ),
                    ],
                  )
                ])));
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _onRefresh,
      child: FutureBuilder(
        future: init(eosAccountName),
        builder: (context, snapshot) {
          List<Campaign> ongoing = [];
          List<Campaign> coming = [];
          List<Campaign> ended = [];

          if (snapshot.hasData) {
            List<Campaign> tempList = snapshot.data as List<Campaign>;
            for (Campaign c in tempList) {
              if (c.getCampaignStat() == CampaignStat.Coming) {
                coming.add(c);
              } else if (c.getCampaignStat() == CampaignStat.Ended) {
                ended.add(c);
              } else {
                ongoing.add(c);
              }
            }
          } else {
            Widget loading = SizedBox(
              width: 200,
              height: 200,
              child: CircularProgressIndicator(),
            );
            // ongoing = [loading];
            // ended = [loading];
            // coming = [loading];
          }
          double width = MediaQuery.of(context).size.width;
          double height = MediaQuery.of(context).size.height;
          var padding = MediaQuery.of(context).padding;
          double newHeight = height - padding.top - padding.bottom;
          if (ongoing.length == 0 && coming.length == 0 && ended.length == 0) {
            return Center(
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                  Image.asset(
                    'assets/app_logo_largest_without_bg.png',
                    height: newHeight * 0.2,
                  ),
                  SizedBox(height: 20),
                  RichText(
                    text: const TextSpan(
                      text: 'No Campaigns to Show',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 18.0,
                          fontWeight: FontWeight.normal),
                    ),
                  ),
                ]));
          } else {
            return Center(
                child: CustomScrollView(
              slivers: [
                SliverAppBar(
                  title: Text("Ongoing Campaign"),
                  pinned: true,
                ),
                ongoing.isEmpty
                    ? SliverToBoxAdapter(
                        child: SizedBox(
                            height: 50,
                            child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(
                                    "No Ongoing campaigns",
                                    style: TextStyle(
                                        fontSize: 15.0,
                                        fontWeight: FontWeight.bold),
                                  )
                                ])))
                    : SliverList(
                        delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          return _createCampaignElement(ongoing[index]);
                        },
                        childCount: ongoing.length,
                      )),
                SliverAppBar(
                  title: Text("Coming Campaign"),
                  pinned: true,
                ),
                coming.isEmpty
                    ? SliverToBoxAdapter(
                        child: SizedBox(
                            height: 50,
                            child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(
                                    "No Coming campaigns",
                                    style: TextStyle(
                                        fontSize: 15.0,
                                        fontWeight: FontWeight.bold),
                                  )
                                ])))
                    : SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            return _createCampaignElement(coming[index]);
                          },
                          childCount: coming.length,
                        ),
                      ),
                SliverAppBar(
                  title: Text("Ended Campaign"),
                  pinned: true,
                ),
                ended.isEmpty
                    ? SliverToBoxAdapter(
                        child: SizedBox(
                            height: 50,
                            child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(
                                    "No Ended campaigns",
                                    style: TextStyle(
                                        fontSize: 15.0,
                                        fontWeight: FontWeight.bold),
                                  )
                                ])))
                    : SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            return _createCampaignElement(ended[index]);
                          },
                          childCount: ended.length,
                        ),
                      )
              ],
            ));
          }
        },
      ),
    );
  }
}
