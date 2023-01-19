import 'package:flutter/material.dart';
import 'package:card_settings/card_settings.dart';

import 'global.dart' as global;

class Settings extends StatefulWidget {
  const Settings({super.key});

  @override
  State<Settings> createState() => _Settings();
}

class _Settings extends State<Settings> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return (Scaffold(
        appBar: AppBar(
          title: const Text('設定'),
        ),
        body: Column(mainAxisSize: MainAxisSize.max, children: [
          Expanded(
            child: ListView(
              children: [
                Form(
                    key: _formKey,
                    child: CardSettings.sectioned(children: <CardSettingsSection>[
                      CardSettingsSection(
                          header: CardSettingsHeader(
                            label: '顏色',
                          ),
                          children: <CardSettingsWidget>[
                            CardSettingsColorPicker(
                              label: 'AppBar 色彩',
                              pickerType: CardSettingsColorPickerType.block,
                              initialValue: global.globalAppConfig.themeDataPrimarySwatch,
                              onSaved: (value) {
                                global.globalAppConfig.themeDataPrimarySwatch = value!;
                              },
                            ),
                            CardSettingsColorPicker(
                              label: '文字色彩',
                              pickerType: CardSettingsColorPickerType.material,
                              initialValue: global.globalAppConfig.canvasForegroundColor,
                              onSaved: (value) {
                                global.globalAppConfig.canvasForegroundColor = value!;
                              },
                            ),
                            CardSettingsColorPicker(
                              label: '背景色彩',
                              pickerType: CardSettingsColorPickerType.material,
                              initialValue: global.globalAppConfig.canvasBackgroundColor,
                              onSaved: (value) {
                                global.globalAppConfig.canvasBackgroundColor = value!;
                              },
                            )
                          ]),
                      CardSettingsSection(
                          header: CardSettingsHeader(
                            label: '字體',
                          ),
                          children: <CardSettingsWidget>[
                            CardSettingsNumberPicker(
                              label: '單字大小',
                              min: 16,
                              max: 48,
                              stepInterval: 2,
                              initialValue: global.globalAppConfig.fontSize,
                              onSaved: (value) {
                                global.globalAppConfig.fontSize = value!;
                              },
                            ),
                          ]),
                      CardSettingsSection(
                          header: CardSettingsHeader(
                            label: '間隔',
                          ),
                          children: <CardSettingsWidget>[
                            CardSettingsInt(
                              label: '頂部空間',
                              initialValue: global.globalAppConfig.canvasTopSpace,
                              maxLength: 2,
                              unitLabel: 'px',
                              keyboardType: TextInputType.number,
                              onSaved: (value) {
                                global.globalAppConfig.canvasTopSpace = value!;
                              },
                            ),
                            CardSettingsInt(
                              label: '底部空間',
                              initialValue: global.globalAppConfig.canvasBottomSpace,
                              maxLength: 2,
                              unitLabel: 'px',
                              keyboardType: TextInputType.number,
                              onSaved: (value) {
                                global.globalAppConfig.canvasBottomSpace = value!;
                              },
                            ),
                            CardSettingsSlider(
                              label: '字距',
                              min: 1.0,
                              max: 2.0,
                              divisions: 10,
                              initialValue: global.globalAppConfig.wordSpace,
                              onSaved: (value) {
                                global.globalAppConfig.wordSpace = value!;
                              },
                            ),
                            CardSettingsInt(
                              label: '行距',
                              initialValue: global.globalAppConfig.newlineSpace,
                              maxLength: 2,
                              unitLabel: 'px',
                              keyboardType: TextInputType.number,
                              onSaved: (value) {
                                global.globalAppConfig.newlineSpace = value!;
                              },
                            ),
                          ]),
                    ]))
              ],
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(textStyle: const TextStyle(fontSize: 20)),
                onPressed: () {
                  Navigator.of(context).pop(false);
                },
                child: const Text('取消'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(textStyle: const TextStyle(fontSize: 20)),
                onPressed: () {
                  _formKey.currentState?.save();
                  global.globalAppConfig.savePrintBookProperties();
                  Navigator.of(context).pop(true);
                },
                child: const Text('確定'),
              ),
            ],
          )
        ])));
  }
}
