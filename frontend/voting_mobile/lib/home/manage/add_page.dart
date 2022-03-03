import 'dart:io';

import 'package:eosdart/eosdart.dart' as eos;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:permission_handler/permission_handler.dart';
import 'package:file_picker/file_picker.dart';
import 'package:csv/csv.dart';
import 'package:dio/dio.dart';

import '../../global_variable.dart';
import '../../success_page.dart';
import 'edit_page.dart';

class AddPage extends StatefulWidget {
  final EditType editType;
  final int campaignId;
  const AddPage({required this.campaignId, required this.editType});

  @override
  _AddPageState createState() =>
      _AddPageState(editType: editType, campaignId: campaignId);
}

class _AddPageState extends State<AddPage> {
  final EditType editType;
  final int campaignId;

  List<String> _addList = [];
  List<bool> _isChecked = [];
  int _checkedCount = 0;

  TextEditingController _addListController = TextEditingController();
  TextEditingController _pkController = TextEditingController();

  _AddPageState({required this.campaignId, required this.editType});

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
                    showLoaderDialog(context, "Adding");

                    _addChoice(context, _pkController.text);
                  },
                  child: Text("Submit"),
                )
              ],
            ));
  }

  void _addChoice(BuildContext context, String pk) async {
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
          'new_choice': ""
        };

        try {
          print(_addList.length);
          for (int i = 0; i < _addList.length; ++i) {
            print(_addList[i]);
            data["new_choice"] = _addList[i];
            List<eos.Action> actions = [
              eos.Action()
                ..account = contractAccount
                ..name = 'addchoice'
                ..authorization = auth
                ..data = data
            ];
            eos.Transaction transaction = eos.Transaction()..actions = actions;
            var response =
                await voteClient.pushTransaction(transaction, broadcast: true);
            print(response);
            if (!response.containsKey('transaction_id')) {
              _errDialog("Unknown Error");
              break;
            }
          }
          SuccessPageArg arg = new SuccessPageArg(
              message: 'All Selected has been added successfully!',
              returnPage: 'h');
          Navigator.pop(context);
          Navigator.pushNamed(context, 's', arguments: arg);
        } catch (e) {
          Navigator.pop(context);
          Map error = json.decode(e as String);
          print(error);

          _errDialog(error["error"]["details"][0]["message"]);
        }
      } catch (e) {
        print(e);
        Navigator.pop(context);
        _errDialog("Invalid Private Key format");
      }
    } else {
      Navigator.pop(context);
      _errDialog("Haven't login");
    }
  }

  void _addVoter(BuildContext context) async {
    // List<String> failed_item = [];
    BaseOptions opt = BaseOptions(baseUrl: backendServerUrl);
    var dio = Dio(opt);
    for (int i = _addList.length - 1; i >= 0; --i) {
      try {
        Response response = await dio.post("/contract/addvoter",
            data: {'itsc': _addList[i], 'campaignId': campaignId});
        print(response.data);
        if (response.statusCode != 200) {
          print("fail");
          // failed_item.add(_addList[i]);
          _errDialog("Fail to add " +
              _addList[i] +
              ", Reason: " +
              response.data["message"]);
          return;
        } else {
          _addList.removeAt(i);
        }
      } catch (e) {
        DioError err = e as DioError;

        Map<String, dynamic> response = (err.response?.data);

        _errDialog(
            "Fail to add " + _addList[i] + ", Reason: " + response["message"]!);

        return;
      }
    }
    SuccessPageArg arg = new SuccessPageArg(
        message: 'All Selected has been added successfully!', returnPage: 'h');
    Navigator.pop(context);
    Navigator.pushNamed(context, 's', arguments: arg);
  }

  void _csvLoader() async {
    var status = await Permission.storage.status;
    print(status);
    if (status.isPermanentlyDenied) {
      openAppSettings();
    } else if (status.isGranted ||
        await Permission.contacts.request().isGranted) {
      // print("hi");
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowMultiple: false,
        allowedExtensions: ["csv"],
      );
      if (result != null) {
        File csv = File(result.paths[0] as String);

        final input = csv.openRead();
        final fields = await input
            .transform(utf8.decoder)
            .transform(new CsvToListConverter())
            .toList();
        for (String s in fields[0]) {
          _addList.add(s);
          _isChecked.add(false);
        }
        setState(() {});
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Add " + editType.toString().substring(9)),
          actions: [
            Padding(
              padding: EdgeInsets.only(right: 10),
              child: GestureDetector(
                onTap: () {
                  _csvLoader();
                },
                child: Text("Import from csv"),
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
                child: Row(
                  children: [
                    Expanded(
                      child: Card(
                        child: ListTile(
                          title: TextField(
                            controller: _addListController,
                            decoration: InputDecoration(
                                hintText:
                                    'New ' + editType.toString().substring(9),
                                border: InputBorder.none),
                            onChanged: (String s) {},
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.cancel),
                            onPressed: () {
                              _addListController.clear();
                            },
                          ),
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        _addList.add(_addListController.text);
                        _isChecked.add(false);
                        _addListController.clear();
                        setState(() {});
                      },
                      icon: const Icon(
                        Icons.add,
                        color: Colors.white,
                      ),
                    )
                  ],
                ),
              ),
            ),
            Expanded(
                child: ListView.builder(
              shrinkWrap: true,
              itemCount: _addList.length,
              itemBuilder: (_, index) => Container(
                  child: CheckboxListTile(
                controlAffinity: ListTileControlAffinity.leading,
                title: Text(_addList[index]),
                value: _isChecked[index],
                onChanged: (value) {
                  _isChecked[index] = value as bool;
                  if (value as bool == true) {
                    ++_checkedCount;
                  } else {
                    --_checkedCount;
                  }
                  setState(() {});
                },
              )),
            ))
          ],
        ),
        floatingActionButton: _addList.isNotEmpty
            ? _checkedCount > 0
                ? FloatingActionButton(
                    onPressed: () {
                      setState(() {
                        for (int i = _addList.length - 1; i >= 0; --i) {
                          if (_isChecked[i]) {
                            _addList.removeAt(i);
                            _isChecked.removeAt(i);
                            --_checkedCount;
                          }
                        }
                      });
                    },
                    child: Icon(IconData(0xf695, fontFamily: 'MaterialIcons')),
                  )
                : FloatingActionButton(
                    onPressed: () {
                      if (editType == EditType.Choice) {
                        _requestKey();
                      } else {
                        _addVoter(context);
                      }
                    },
                    child: Icon(IconData(0xe047, fontFamily: 'MaterialIcons')),
                  )
            : null);
  }
}
