import 'dart:io';

import 'package:eosdart/eosdart.dart' as eos;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:permission_handler/permission_handler.dart';
import 'package:file_picker/file_picker.dart';
import 'package:csv/csv.dart';
import 'package:dio/dio.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

import '../../global_variable.dart';
import '../../success_page.dart';
import 'edit_page.dart';
import '../../shared_dialog.dart';
import '../navigation_bar_view.dart';

class AddPage extends StatefulWidget {
  final EditType editType;
  final int campaignId;
  const AddPage({required this.campaignId, required this.editType});

  @override
  _AddPageState createState() =>
      _AddPageState(editType: editType, campaignId: campaignId);
}

class _AddPageState extends State<AddPage> with SharedDialog {
  final EditType editType;
  final int campaignId;

  List<String> _addList = [];
  List<bool> _isChecked = [];
  int _checkedCount = 0;

  TextEditingController _addListController = TextEditingController();
  TextEditingController _pkController = TextEditingController();

  _AddPageState({required this.campaignId, required this.editType});

  void _addChoice(BuildContext context, String pk) async {
    eos.EOSClient voteClient = client;
    final prefs = await SharedPreferences.getInstance();

    final String eosName = prefs.getString('eosName') ?? "";
    final String itsc = prefs.getString('itsc') ?? "";
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
              errDialog(context, "Unknown Error");
              break;
            }
          }
          HomeArg homeArg = HomeArg(itsc, eosName);
          SuccessPageArg arg = SuccessPageArg(
              message: 'All Selected has been added successfully!',
              returnPage: 'h',
              arg: homeArg);
          Navigator.pop(context);
          Navigator.pushNamed(context, 's', arguments: arg);
        } catch (e) {
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

  void _addVoter(BuildContext context) async {
    // List<String> failed_item = [];
    final prefs = await SharedPreferences.getInstance();

    final String eosName = prefs.getString('eosName') ?? "";
    final String itsc = prefs.getString('itsc') ?? "";

    BaseOptions opt = BaseOptions(baseUrl: backendServerUrl);
    var dio = Dio(opt);
    try {
      Response response = await dio.post("/contract/addvoter",
          data: {'itsc': _addList, 'campaignId': campaignId});
      print(response.data);
      if (response.statusCode != 200) {
        print("fail");
        // failed_item.add(_addList[i]);
        errDialog(context, "Fail to add, Reason: " + response.data["message"]);
        return;
      }
    } catch (e) {
      DioError err = e as DioError;

      Map<String, dynamic> response = (err.response?.data);

      errDialog(context, "Fail to add, Reason: " + response["message"]!);

      return;
    }
    HomeArg homeArg = HomeArg(itsc, eosName);
    SuccessPageArg arg = new SuccessPageArg(
        message: 'All Selected has been added successfully!',
        returnPage: 'h',
        arg: homeArg);
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

  void _deleteElement(int index) {
    if (_isChecked[index] == true) {
      --_checkedCount;
    }
    _addList.removeAt(index);
    _isChecked.removeAt(index);
    setState(() {});
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
              itemBuilder: (_, index) => Slidable(
                key: Key(_addList[index]),
                endActionPane: ActionPane(
                  dismissible: DismissiblePane(onDismissed: () {
                    _deleteElement(index);
                  }),
                  motion: ScrollMotion(),
                  children: [
                    SlidableAction(
                      onPressed: (context) {
                        _deleteElement(index);
                      },
                      backgroundColor: Color(0xFFFE4A49),
                      foregroundColor: Colors.white,
                      icon: Icons.delete,
                      label: 'Delete',
                    ),
                  ],
                ),
                child: Container(
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
              ),
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
                    child: Icon(Icons.delete_forever_rounded),
                  )
                : FloatingActionButton(
                    onPressed: () {
                      if (editType == EditType.Choice) {
                        requestKey(context, _addChoice, "Adding");
                      } else {
                        _addVoter(context);
                      }
                    },
                    child: Icon(IconData(0xe047, fontFamily: 'MaterialIcons')),
                  )
            : null);
  }
}
