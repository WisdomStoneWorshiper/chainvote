import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:intl/intl.dart';
import 'package:eosdart/eosdart.dart' as eos;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import '../../global_variable.dart';
import '../../success_page.dart';

class CreatePage extends StatelessWidget {
  final String _dateFormat = 'yyyy-MM-dd kk:mm';
  final String _createDateFormat = 'yyyy-MM-ddTkk:mm:00.000';
  final form = GlobalKey<FormState>();
  final TextEditingController _campaignNameController =
      new TextEditingController();
  final TextEditingController _starttimeController =
      new TextEditingController();
  final TextEditingController _endtimeController = new TextEditingController();
  final TextEditingController _pkController = TextEditingController();
  DateTime _starttime = DateTime.now();
  DateTime _endtime = DateTime.now().add(Duration(hours: 1));

  CreatePage({Key? key}) : super(key: key);

  void _errDialog(BuildContext context, String message) {
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

  void _requestKey(BuildContext context) {
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
                    showLoaderDialog(context, "Creating");

                    _createCampaign(context, _pkController.text);
                  },
                  child: Text("Submit"),
                )
              ],
            ));
  }

  void _createCampaign(BuildContext context, String pk) async {
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
          'campaign_name': _campaignNameController.text,
          'start_time_string':
              DateFormat(_createDateFormat).format(_starttime.toUtc()),
          'end_time_string':
              DateFormat(_createDateFormat).format(_endtime.toUtc()),
        };

        List<eos.Action> actions = [
          eos.Action()
            ..account = contractAccount
            ..name = 'createcamp'
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
            _errDialog(context, "Unknown Error");
          } else {
            String transHex = response["transaction_id"];
            SuccessPageArg arg = new SuccessPageArg(
                message:
                    'Campaign has been created successfully!\n Transaction hash: $transHex',
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

          _errDialog(context, error["error"]["details"][0]["message"]);
        }
      } catch (e) {
        print(e);
        Navigator.pop(context);
        _errDialog(context, "Invalid Private Key format");
      }
    } else {
      Navigator.pop(context);
      _errDialog(context, "Haven't login");
    }
  }

  bool _dataChecker(BuildContext context) {
    if (_campaignNameController.text.isEmpty) {
      _errDialog(context, "Campaign name cannot be empty.");
      return false;
    } else if (_starttime.isBefore(DateTime.now())) {
      _errDialog(context, "Start time cannot earlier than current time");
      return false;
    } else if (_endtime.isBefore(_starttime)) {
      _errDialog(context, "ENd time cannot earlier than start time");
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    _starttimeController.text = DateFormat(_dateFormat).format(_starttime);
    _endtimeController.text = DateFormat(_dateFormat).format(_endtime);

    return Scaffold(
      appBar: AppBar(
        title: Text("Create new campaign"),
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(16),
            child: Material(
              elevation: 1,
              clipBehavior: Clip.antiAlias,
              borderRadius: BorderRadius.circular(8),
              child: Form(
                key: form,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    AppBar(
                      automaticallyImplyLeading: false,
                      elevation: 0,
                      title: Text('Campaign Details'),
                      centerTitle: true,
                      actions: <Widget>[
                        IconButton(
                          icon: Icon(Icons.delete),
                          onPressed: () {
                            _campaignNameController.text = "";
                            _starttime = DateTime.now();
                            _endtime = DateTime.now().add(Duration(hours: 1));
                            _starttimeController.text =
                                DateFormat(_dateFormat).format(_starttime);
                            _endtimeController.text =
                                DateFormat(_dateFormat).format(_endtime);
                          },
                        )
                      ],
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: 16, right: 16, top: 16),
                      child: TextFormField(
                        controller: _campaignNameController,
                        decoration: InputDecoration(
                          labelText: 'Campaign Name',
                          hintText: 'Enter Campaign Name',
                          icon: Icon(Icons.view_headline),
                          isDense: true,
                        ),
                        validator: (String? value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter Campaign Name';
                          }
                          return null;
                        },
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: 16, right: 16, bottom: 24),
                      child: TextFormField(
                        controller: _starttimeController,
                        decoration: InputDecoration(
                          labelText: 'Start time',
                          icon: Icon(Icons.timer_outlined),
                        ),
                        onTap: () {
                          DatePicker.showDateTimePicker(
                            context,
                            showTitleActions: true,
                            minTime: DateTime.now(),
                            currentTime: _starttime,
                            onConfirm: (date) {
                              _starttime = date;
                              _starttimeController.text =
                                  DateFormat(_dateFormat).format(_starttime);
                            },
                          );
                        },
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: 16, right: 16, bottom: 24),
                      child: TextFormField(
                        controller: _endtimeController,
                        decoration: InputDecoration(
                          labelText: 'End time',
                          icon: Icon(Icons.timer_off_outlined),
                        ),
                        onTap: () {
                          DatePicker.showDateTimePicker(
                            context,
                            showTitleActions: true,
                            minTime: DateTime.now(),
                            currentTime: _endtime,
                            onConfirm: (date) {
                              _endtime = date;

                              _endtimeController.text =
                                  DateFormat(_dateFormat).format(_endtime);
                            },
                          );
                        },
                      ),
                    ),
                    ElevatedButton(
                        onPressed: () {
                          if (_dataChecker(context)) {
                            _requestKey(context);
                          }
                        },
                        child: Text("Create")),
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
