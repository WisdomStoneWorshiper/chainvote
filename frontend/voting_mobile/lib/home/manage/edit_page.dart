import 'package:eosdart/eosdart.dart' as eos;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:dio/dio.dart';

import '../../global_variable.dart';
import '../../success_page.dart';
import 'add_page.dart';
import '../../shared_dialog.dart';

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

class _EditPageState extends State<EditPage> with SharedDialog {
  final EditType editType;
  final int campaignId;
  List<String> editingList = [];
  List<bool> _isChecked = [];
  int _checkedCount = 0;
  TextEditingController _searchController = new TextEditingController();
  TextEditingController _pkController = new TextEditingController();

  _EditPageState(
      {required this.campaignId,
      required this.editType,
      required editingList}) {
    _isChecked = List<bool>.filled(editingList.length, false);
    this.editingList = editingList.toList();
  }

  List<int> _searchResult = [];

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
              if (editType == EditType.Choice) {
                requestKey(context, _delChoice, "Deleting");
              } else {
                _delVoter(context);
              }
            },
            child: Text("Delete"),
          )
        ],
      ),
    );
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

        try {
          for (int i = _isChecked.length - 1; i > 0; --i) {
            if (_isChecked[i]) {
              print(i);
              data["choice_idx"] = i.toString();
              List<eos.Action> actions = [
                eos.Action()
                  ..account = contractAccount
                  ..name = 'delchoice'
                  ..authorization = auth
                  ..data = data
              ];
              eos.Transaction transaction = eos.Transaction()
                ..actions = actions;
              var response = await voteClient.pushTransaction(transaction,
                  broadcast: true);
              if (!response.containsKey('transaction_id')) {
                print(response);
                errDialog(context, "Unknown Error");
                break;
              }
            }
          }
          SuccessPageArg arg = new SuccessPageArg(
              message: 'All Selected has been deleted successfully!',
              returnPage: 'h');
          Navigator.pop(context);
          Navigator.pushNamed(context, 's', arguments: arg);
        } catch (e) {
          Navigator.pop(context);
          Map error = json.decode(e as String);
          print(error);
          // print(error["error"]["details"][0]["message"]);
          // print(e.runtimeType);
          errDialog(context, error["error"]["details"][0]["message"]);
        }
      } catch (e) {
        // print(e);
        Navigator.pop(context);
        errDialog(context, "Invalid Private Key format");
      }
    } else {
      Navigator.pop(context);
      errDialog(context, "Haven't login");
    }
  }

  void _delVoter(BuildContext context) async {
    // List<String> failed_item = [];
    BaseOptions opt = BaseOptions(baseUrl: backendServerUrl);
    var dio = Dio(opt);
    for (int i = _isChecked.length - 1; i > 0; --i) {
      if (_isChecked[i]) {
        try {
          Response response = await dio.post("/contract/delvoter",
              data: {'itsc': editingList[i], 'campaignId': campaignId});
          print(response.data);
          if (response.statusCode != 200) {
            print("fail");
            // failed_item.add(editingList[i]);
            errDialog(
                context,
                "Cannot delete " +
                    editingList[i] +
                    ", Reason: " +
                    response.data["message"]);
            return;
          } else {
            editingList.removeAt(i);
            _isChecked.removeAt(i);
          }
        } catch (e) {
          DioError err = e as DioError;

          Map<String, dynamic> response = (err.response?.data);

          errDialog(
              context,
              "Cannot delete " +
                  editingList[i] +
                  ", Reason: " +
                  response["message"]!);

          return;
        }
      }
    }
    SuccessPageArg arg = new SuccessPageArg(
        message: 'All Selected has been deleted successfully!',
        returnPage: 'h');
    Navigator.pop(context);
    Navigator.pushNamed(context, 's', arguments: arg);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Edit " + editType.toString().substring(9)),
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
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => AddPage(
                            editType: editType,
                            campaignId: campaignId,
                          )),
                );
              },
              child: Icon(IconData(0xe047, fontFamily: 'MaterialIcons')),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            color: Theme.of(context).primaryColor,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Card(
                child: ListTile(
                  leading: Icon(Icons.search),
                  title: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                        hintText: 'Search', border: InputBorder.none),
                    onChanged: _searchHandler,
                  ),
                  trailing: IconButton(
                    icon: Icon(Icons.cancel),
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
                      controlAffinity: ListTileControlAffinity.leading,
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
