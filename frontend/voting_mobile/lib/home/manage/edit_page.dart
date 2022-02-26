import 'package:eosdart/eosdart.dart' as eos;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import '../../global_variable.dart';
import '../../success_page.dart';

enum EditType { Choice, Voter }

class EditPage extends StatefulWidget {
  final EditType editType;
  final int campaignId;
  List<String> editingList;
  EditPage(
      {required this.campaignId,
      required this.editType,
      required this.editingList});

  @override
  _EditPageState createState() => _EditPageState(
      campaignId: campaignId, editType: editType, editingList: editingList);
}

class _EditPageState extends State<EditPage> {
  final EditType editType;
  final int campaignId;
  List<String> editingList;
  List<bool> _isChecked = [];
  int _checkedCount = 0;
  TextEditingController _searchController = new TextEditingController();
  TextEditingController _pkController = new TextEditingController();

  _EditPageState(
      {required this.campaignId,
      required this.editType,
      required this.editingList}) {
    _isChecked = List<bool>.filled(editingList.length, false);
  }

  List<int> _searchResult = [];

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

  void _searchHandler(String keyword) {
    _searchResult.clear();
    if (keyword.length <= 0) {
      setState(() {});
      return;
    }
    for (int i = 0; i < editingList.length; ++i) {
      if (editingList[i].contains(keyword)) {
        _searchResult.add(i);
      }
    }
    setState(() {});
  }

  List<Widget> _getAllSelected() {
    List<Widget> temp = [];
    for (int i = 0; i < _isChecked.length; ++i) {
      if (_isChecked[i]) {
        temp.add(Text(editingList[i]));
      }
    }
    return temp;
  }

  void _comfirmDelete() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("The following will be deleted from campaign"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: _getAllSelected(),
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
            child: Text("Delete"),
          )
        ],
      ),
    );
  }

  void _requestKey() {
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

                    if (editType == EditType.Choice) {
                      _delChoice(context, _pkController.text);
                    } else {
                      _delVoter(context);
                    }
                  },
                  child: Text("Submit"),
                )
              ],
            ));
  }

  void _delChoice(BuildContext context, String pk) async {
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
          'owner': eosName,
          'campaign_id': campaignId.toString(),
          'choice_idx': ""
        };

        List<eos.Action> actions = [
          eos.Action()
            ..account = contractAccount
            ..name = 'delchoice'
            ..authorization = auth
            ..data = data
        ];
        eos.Transaction transaction = eos.Transaction()..actions = actions;

        try {
          for (int i = 0; i < _isChecked.length; ++i) {
            if (_isChecked[i]) {
              data["choice_idx"] = i.toString();
              var response = await voteClient.pushTransaction(transaction,
                  broadcast: true);
              if (!response.containsKey('transaction_id')) {
                print(response);
                _errDialog("Unknown Error");
                break;
              }
            }
          }
          SuccessPageArg arg = new SuccessPageArg(
              message: 'All Selected has been deleted successfully!',
              returnPage: 'h');
          Navigator.pushNamed(context, 's', arguments: arg);
        } catch (e) {
          Navigator.pop(context);
          Map error = json.decode(e as String);
          print(error);
          // print(error["error"]["details"][0]["message"]);
          // print(e.runtimeType);
          _errDialog(error["error"]["details"][0]["message"]);
        }
      } catch (e) {
        // print(e);
        Navigator.pop(context);
        _errDialog("Invalid Private Key format");
      }
    } else {
      Navigator.pop(context);
      _errDialog("Haven't login");
    }
  }

  void _delVoter(BuildContext context) async {}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Edit " + editType.toString()),
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 10),
            child: GestureDetector(
              onTap: () {
                if (_checkedCount > 0) _comfirmDelete();
              },
              child: Icon(
                IconData(0xf695, fontFamily: 'MaterialIcons'),
                color: _checkedCount > 0
                    ? Colors.white
                    : Colors.white.withOpacity(0.3),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(right: 10),
            child: GestureDetector(
              onTap: () {},
              child: Icon(IconData(0xe047, fontFamily: 'MaterialIcons')),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            color: Theme.of(context).primaryColor,
            child: new Padding(
              padding: const EdgeInsets.all(8.0),
              child: new Card(
                child: new ListTile(
                  leading: new Icon(Icons.search),
                  title: new TextField(
                    controller: _searchController,
                    decoration: new InputDecoration(
                        hintText: 'Search', border: InputBorder.none),
                    onChanged: _searchHandler,
                  ),
                  trailing: new IconButton(
                    icon: new Icon(Icons.cancel),
                    onPressed: () {
                      _searchController.clear();
                      _searchHandler('');
                    },
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: _searchController.text.isNotEmpty
                ? ListView.builder(
                    shrinkWrap: true,
                    itemCount: _searchResult.length,
                    itemBuilder: (_, index) => Container(
                        child: CheckboxListTile(
                      title: Text(editingList[_searchResult[index]]),
                      value: _isChecked[_searchResult[index]],
                      onChanged: (value) {
                        setState(() {
                          _isChecked[_searchResult[index]] = value as bool;
                          if (value as bool == true) {
                            ++_checkedCount;
                          } else {
                            --_checkedCount;
                          }
                          print(_checkedCount);
                        });
                      },
                    )),
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    itemCount: editingList.length,
                    itemBuilder: (_, index) => Container(
                        child: CheckboxListTile(
                      title: Text(editingList[index]),
                      value: _isChecked[index],
                      onChanged: (value) {
                        setState(() {
                          _isChecked[index] = value as bool;
                          if (value as bool == true) {
                            ++_checkedCount;
                          } else {
                            --_checkedCount;
                          }
                          print(_checkedCount);
                        });
                      },
                    )),
                  ),
          ),
        ],
      ),
    );
  }
}
