import 'dart:io';

import 'package:flutter/material.dart';
import 'package:nfc_manager/nfc_manager.dart';
import './utils/renderTextFormField.dart';
import 'dart:convert' show utf8;

/// Global flag if NFC is avalible
bool isNfcAvalible = false;
var _textEditingController = TextEditingController();

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Required for the line below
  isNfcAvalible = await NfcManager.instance.isAvailable();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter NFC Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter NFC Demo'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;
  bool listenerRunning = false;
  bool writeCounterOnNextContact = false;

  String repeatCounts = '';
  String startingValue = '';
  String intervalCounts = '';
  String timeInterval = '';
  String firstRoundValue = '';
  String secondRoundValue = '';
  String thirdRoundValue = '';
  String fourthRoundValue = '';
  String durationTime = '';

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Container(
        width: 1000,
        height: 1000,
        child: GestureDetector(
            onTap: () => FocusScope.of(context).unfocus(),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                      padding: const EdgeInsets.fromLTRB(0, 30, 0, 40),
                      color: Colors.red,
                      child: Text(
                        _checkSupportNfc(), // nfc 사용 가능 판별
                      )),
                  Container(
                      padding: const EdgeInsets.fromLTRB(0, 0, 0, 40),
                      color: Colors.cyanAccent,
                      width: 600,
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Expanded(
                                child: renderTextFormField(
                                    keyboardType:
                                        const TextInputType.numberWithOptions(
                                            decimal: true),
                                    decoration: const InputDecoration(),
                                    label: '반복횟수',
                                    onSaved: (newValue) {},
                                    validator: (value) {})),
                            Expanded(
                                child: renderTextFormField(
                                    keyboardType:
                                        const TextInputType.numberWithOptions(
                                            decimal: true),
                                    decoration: const InputDecoration(),
                                    label: '시작값',
                                    onSaved: (newValue) {},
                                    validator: (value) {})),
                            Expanded(
                                child: renderTextFormField(
                                    keyboardType:
                                        const TextInputType.numberWithOptions(
                                            decimal: true),
                                    decoration: const InputDecoration(),
                                    label: 'interval',
                                    onSaved: (newValue) {},
                                    validator: (value) {})),
                            Expanded(
                                child: renderTextFormField(
                                    keyboardType:
                                        const TextInputType.numberWithOptions(
                                            decimal: true),
                                    decoration: const InputDecoration(),
                                    label: '시간간격',
                                    onSaved: (newValue) {},
                                    validator: (value) {}))
                          ])),
                  Container(
                      padding: const EdgeInsets.fromLTRB(0, 0, 0, 60),
                      width: 1000,
                      child: Row(
                        children: [
                          Expanded(
                              flex: 1,
                              child: TextField(
                                  controller: _textEditingController,
                                  keyboardType:
                                      const TextInputType.numberWithOptions(
                                          decimal: true),
                                  decoration: const InputDecoration(
                                      labelText: '1회',
                                      enabledBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                              width: 2,
                                              color: Colors.indigoAccent))),
                                  onChanged: (text) {
                                    setState(() {
                                      firstRoundValue = text;
                                    });
                                  })),
                          Expanded(
                              flex: 1,
                              child: TextField(
                                  controller: _textEditingController,
                                  keyboardType:
                                      const TextInputType.numberWithOptions(
                                          decimal: true),
                                  decoration: const InputDecoration(
                                      labelText: '2회',
                                      enabledBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                              width: 2,
                                              color: Colors.indigoAccent))),
                                  onChanged: (text) {
                                    setState(() {
                                      secondRoundValue = text;
                                    });
                                  })),
                          Expanded(
                              flex: 1,
                              child: TextField(
                                  controller: _textEditingController,
                                  keyboardType:
                                      const TextInputType.numberWithOptions(
                                          decimal: true),
                                  decoration: const InputDecoration(
                                      labelText: '3회',
                                      enabledBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                              width: 2,
                                              color: Colors.indigoAccent))),
                                  onChanged: (text) {
                                    setState(() {
                                      thirdRoundValue = text;
                                    });
                                  })),
                          Expanded(
                              flex: 1,
                              child: TextField(
                                  controller: _textEditingController,
                                  keyboardType:
                                      const TextInputType.numberWithOptions(
                                          decimal: true),
                                  decoration: const InputDecoration(
                                      labelText: '4회',
                                      enabledBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                              width: 2,
                                              color: Colors.indigoAccent))),
                                  onChanged: (text) {
                                    setState(() {
                                      fourthRoundValue = text;
                                    });
                                  }))
                        ],
                      )),
                  Row(children: [
                    ElevatedButton(
                      onPressed: () {},
                      child: const Text('START'),
                    ),
                    Expanded(
                      child: TextField(
                          keyboardType: const TextInputType.numberWithOptions(
                              decimal: true),
                          decoration: const InputDecoration(
                              labelText: '진행시간',
                              enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      width: 2, color: Colors.indigoAccent))),
                          onChanged: (text) {
                            setState(() {
                              durationTime = text;
                            });
                          }),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        _alert("message");
                        _resetAllValue();
                      },
                      child: const Text('RESET'),
                    )
                  ])
                ], // children
              ),
            )),
      ),
    );
  }

  String _checkSupportNfc() {
    if (isNfcAvalible) {
      return "You can use NFC! Have fun";
    } else {
      if (Platform.isIOS) {
        //Ios doesnt allow the user to turn of NFC at all,  if its not avalible it means its not build in
        return "Your device doesn't support NFC.\n Because IOS doesn't support it";
      } else {
        //Android phones can turn of NFC in the settings
        return "Your device doesn't support NFC or it's turned off in the system settings";
      }
    }
  }

  //Helper method to show a quick message
  void _alert(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
        ),
        duration: const Duration(
          seconds: 2,
        ),
      ),
    );
  }

  Future<void> _listenForNFCEvents() async {
    //Always run this for ios but only once for android
    if (Platform.isAndroid && listenerRunning == false || Platform.isIOS) {
      //Android supports reading nfc in the background, starting it one time is all we need
      if (Platform.isAndroid) {
        _alert(
          'NFC listener running in background now, approach tag(s)',
        );
        //Update button states
        setState(() {
          listenerRunning = true;
        });
      }

      NfcManager.instance.startSession(
        onDiscovered: (NfcTag tag) async {
          bool succses = false;
          //Try to convert the raw tag data to NDEF
          final ndefTag = Ndef.from(tag);
          //If the data could be converted we will get an object
          if (ndefTag != null) {
            // If we want to write the current counter vlaue we will replace the current content on the tag
            if (writeCounterOnNextContact) {
              //Ensure the write flag is off again
              setState(() {
                writeCounterOnNextContact = false;
              });
              //Create a 1Well known tag with en as language code and 0x02 encoding for UTF8
              final ndefRecord = NdefRecord.createText(_counter.toString());
              //Create a new ndef message with a single record
              final ndefMessage = NdefMessage([ndefRecord]);
              //Write it to the tag, tag must still be "connected" to the device
              try {
                //Any existing content will be overrwirten
                await ndefTag.write(ndefMessage);
                _alert('Counter written to tag');
                succses = true;
              } catch (e) {
                _alert("Writting failed, press 'Write to tag' again");
              }
            }
            //The NDEF Message was already parsed, if any
            else if (ndefTag.cachedMessage != null) {
              var ndefMessage = ndefTag.cachedMessage!;
              //Each NDEF message can have multiple records, we will use the first one in our example
              if (ndefMessage.records.isNotEmpty &&
                  ndefMessage.records.first.typeNameFormat ==
                      NdefTypeNameFormat.nfcWellknown) {
                //If the first record exists as 1:Well-Known we consider this tag as having a value for us
                final wellKnownRecord = ndefMessage.records.first;

                ///Payload for a 1:Well Known text has the following format:
                ///[Encoding flag 0x02 is UTF8][ISO language code like en][content]

                if (wellKnownRecord.payload.first == 0x02) {
                  //Now we know the encoding is UTF8 and we can skip the first byte
                  final languageCodeAndContentBytes =
                      wellKnownRecord.payload.skip(1).toList();
                  //Note that the language code can be encoded in ASCI, if you need it be carfully with the endoding
                  final languageCodeAndContentText =
                      utf8.decode(languageCodeAndContentBytes);
                  //Cutting of the language code
                  final payload = languageCodeAndContentText.substring(2);
                  //Parsing the content to int
                  final storedCounters = int.tryParse(payload);
                  if (storedCounters != null) {
                    succses = true;
                    _alert('Counter restored from tag');
                    setState(() {
                      _counter = storedCounters;
                    });
                  }
                }
              }
            }
          }
          //Due to the way ios handles nfc we need to stop after each tag
          if (Platform.isIOS) {
            NfcManager.instance.stopSession();
          }
          if (succses == false) {
            _alert(
              'Tag was not valid',
            );
          }
        },
        // Required for iOS to define what type of tags should be noticed
        pollingOptions: {
          NfcPollingOption.iso14443,
          NfcPollingOption.iso15693,
        },
      );
    }
  }

  @override
  void dispose() {
    try {
      NfcManager.instance.stopSession();
    } catch (_) {
      //We dont care
    }
    super.dispose();
  }

  void _writeNfcTag() {
    setState(() {
      writeCounterOnNextContact = true;
    });

    if (Platform.isAndroid) {
      _alert('Approach phone with tag');
    }
    //Writing a requires to read the tag first, on android this call might do nothing as the listner is already running
    _listenForNFCEvents();
  }

  void _resetAllValue() {
    _textEditingController.clear();
  }
}

//For ios always false, for android true if running
// final nfcRunning = Platform.isAndroid && listenerRunning;
// Row(
// mainAxisAlignment: MainAxisAlignment.center,
// children: [
// TextButton(
// onPressed: nfcRunning ? null : _listenForNFCEvents,
// child: Text(Platform.isAndroid
// ? listenerRunning
// ? 'NFC is running'
//     : 'Start NFC listener'
//     : 'Read from tag'),
// ),
// TextButton(
// onPressed: writeCounterOnNextContact ? null : _writeNfcTag,
// child: Text(writeCounterOnNextContact
// ? 'Waiting for tag to write'
//     : 'Write to tag'),
// )
// ],
// );
