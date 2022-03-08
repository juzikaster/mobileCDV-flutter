import 'dart:io' show exit;

import 'package:flutter/material.dart';

import 'package:mobile_cdv/src/lib/localization/localization_manager.dart';

class LocaleDialog extends StatelessWidget {
  const LocaleDialog({Key? key}) : super(key: key);

  //TODO do design
  @override
  Widget build(BuildContext context){
    return AlertDialog(
      title: Text(
        getTextFromKey("Settings.AlertDialog")
      ),
      content: Text(
        getTextFromKey("Settings.AlertDialog.q")
      ),
      actions: [
        ElevatedButton(
          onPressed: () => exit(0),
          child: Text(
            getTextFromKey("Setting.AlertDialog.Restart")
          ),
        )
      ],
    );
  }
}

class Settings extends StatefulWidget {
  const Settings({Key? key}) : super(key: key);

  @override
  State<Settings> createState() => _SettingState();
}

class _SettingState extends State<Settings> {

  final String _currentLocale = getTextFromKey("Settings.locale");
  String dropdownValue = getTextFromKey("Settings.locale.choose");
  bool themeSwitch = false;

  void switchTheme(bool value){

  }

  void changeLocale(String loc){
    initLocalization(loc);
    showDialog(
        context: context,
        builder: (BuildContext dialogContext) {
          return const LocaleDialog();
        }
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                children: [
                  Text(
                    getTextFromKey("Settings.c.lang")
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 150),
                    child: DropdownButton<String>(
                      items: <String>[getTextFromKey("Settings.locale.choose"), "English", "Polski", "Русский", "Türkçe"].map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      value: dropdownValue,
                      onChanged: (String? newValue) {
                        dropdownValue = newValue!;
                        switch(newValue){
                          case "English":
                            changeLocale("en");
                            break;
                          case "Polski":
                            changeLocale("pl");
                            break;
                          case "Русский":
                            changeLocale("ru");
                            break;
                          case "Türkçe":
                            changeLocale("tr");
                            break;
                          default:
                            initLocalization("en");
                            break;
                        }
                      },
                    ),
                  )
                ],
              ),
              const Divider(
                thickness: 1.5,
              ),
              Row(
                children: [
                  Text(
                    getTextFromKey("Settings.theme")
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: 50),
                    child: Switch(
                      value: themeSwitch,
                      onChanged: (value){
                        print(themeSwitch);
                      },
                    ),
                  )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}