import 'dart:io';
import 'package:flutter/material.dart';
import 'package:nfc_manager/nfc_manager.dart';
import 'package:provider/provider.dart';
import './utils/renderTextFormField.dart';
import './utils/checking.dart';
import './utils/customTimer.dart';
import 'dart:convert' show utf8;

var _textEditingController = TextEditingController();

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Required for the line below
  runApp(MultiProvider(providers: [
    ChangeNotifierProvider(create: (_) => CustomTimer()),
  ], child: const MyApp()));
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

  final formKey = GlobalKey<FormState>();

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
      body: ChangeNotifierProvider(
        create: (BuildContext context) => CustomTimer(),
        child: SizedBox(
          width: MediaQuery.of(context).size.width,
          height: 1000,
          child: GestureDetector(
              onTap: () => FocusScope.of(context).unfocus(),
              child: SingleChildScrollView(
                  child: Form(
                key: formKey,
                child: Column(
                  children: [
                    Container(
                        padding: const EdgeInsets.fromLTRB(0, 30, 0, 40),
                        child: FutureBuilder<String>(
                            future: Checking.checkSupportNfc(),
                            builder: (context, snapshot) {
                              if (snapshot.hasData) {
                                String? status = snapshot.data;
                                return Text(status!);
                              } else if (snapshot.hasError) {
                                return const Text("에러 일때 화면");
                              } else {
                                return const Text("로딩 화면");
                              }
                            })),
                    Container(
                        padding: const EdgeInsets.fromLTRB(0, 0, 0, 40),
                        width: 600,
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: <Widget>[
                              const SizedBox(width: 30),
                              Expanded(
                                  child: renderTextFormField(
                                      decoration: const InputDecoration(),
                                      label: '반복횟수',
                                      onSaved: (newValue) {
                                        setState(() {
                                          repeatCounts = newValue!;
                                        });
                                      },
                                      validator: (value) {
                                        if (value.isEmpty) {
                                          return '값을 입력해주세요';
                                        }

                                        int valueAsInt = int.parse(value);
                                        if (valueAsInt < 1 || valueAsInt > 4) {
                                          return '1~4 값을 입력';
                                        }

                                        return null;
                                      })),
                              const SizedBox(width: 30),
                              Expanded(
                                  child: renderTextFormField(
                                      decoration: const InputDecoration(),
                                      label: '시작값',
                                      onSaved: (newValue) {
                                        setState(() {
                                          startingValue = newValue;
                                        });
                                      },
                                      validator: (value) {
                                        if (value.isEmpty) {
                                          return '값을 입력해주세요';
                                        }

                                        int valueAsInt = int.parse(value);
                                        if (valueAsInt < 1 || valueAsInt > 20) {
                                          return '1~20 값을 입력';
                                        }

                                        return null;
                                      })),
                              const SizedBox(width: 30),
                              Expanded(
                                  child: renderTextFormField(
                                      decoration: const InputDecoration(),
                                      label: 'interval',
                                      onSaved: (newValue) {
                                        setState(() {
                                          intervalCounts = newValue;
                                        });
                                      },
                                      validator: (value) {
                                        if (value.isEmpty) {
                                          return '값을 입력해주세요';
                                        }

                                        double valueAsDouble =
                                            double.parse(value);
                                        if (valueAsDouble < 1.0 ||
                                            valueAsDouble > 9.9) {
                                          return '1.0~9.9 값을 입력';
                                        }

                                        return null;
                                      })),
                              const SizedBox(width: 30),
                              Expanded(
                                  child: renderTextFormField(
                                      decoration: const InputDecoration(),
                                      label: '시간간격',
                                      onSaved: (newValue) {
                                        setState(() {
                                          timeInterval = newValue;
                                        });
                                      },
                                      validator: (value) {
                                        if (value.isEmpty) {
                                          return '값을 입력해주세요';
                                        }

                                        double valueAsDouble =
                                            double.parse(value);
                                        if (valueAsDouble < 0.1 ||
                                            valueAsDouble > 30.0) {
                                          return '1.0~9.9 값을 입력';
                                        }

                                        return null;
                                      })),
                              const SizedBox(width: 30),
                            ])),
                    Container(
                        padding: const EdgeInsets.fromLTRB(0, 0, 0, 60),
                        width: 1000,
                        child: Row(
                          children: [
                            const SizedBox(width: 30),
                            Expanded(
                                child: Text.rich(
                              TextSpan(text: '1회 : ', children: <TextSpan>[
                                TextSpan(
                                    text: context
                                        .watch<CustomTimer>()
                                        .currentTime
                                        .toStringAsFixed(1))
                              ]),
                            )),
                            const SizedBox(width: 30),
                            Expanded(
                                child: Text.rich(
                              TextSpan(text: '2회 : ', children: <TextSpan>[
                                TextSpan(
                                    text: context
                                        .watch<CustomTimer>()
                                        .currentTime
                                        .toStringAsFixed(1))
                              ]),
                            )),
                            const SizedBox(width: 30),
                            Expanded(
                                child: Text.rich(
                              TextSpan(text: '3회 : ', children: <TextSpan>[
                                TextSpan(
                                    text: context
                                        .watch<CustomTimer>()
                                        .currentTime
                                        .toStringAsFixed(1))
                              ]),
                            )),
                            const SizedBox(width: 30),
                            Expanded(
                                child: Text.rich(
                              TextSpan(text: '4회 : ', children: <TextSpan>[
                                TextSpan(
                                    text: context
                                        .watch<CustomTimer>()
                                        .currentTime
                                        .toStringAsFixed(1))
                              ]),
                            )),
                            const SizedBox(width: 30),
                          ],
                        )),
                    Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          const SizedBox(width: 30),
                          ElevatedButton(
                            onPressed: () async {
                              if (formKey.currentState!.validate()) {
                                formKey.currentState?.save();
                                context.read<CustomTimer>().start();
                              }
                            },
                            child: const Text('START'),
                          ),
                          const SizedBox(width: 30),
                          Expanded(
                              child: Center(
                                  child: Text(context
                                      .watch<CustomTimer>()
                                      .currentTime
                                      .toStringAsFixed(1)))),
                          const SizedBox(width: 30),
                          ElevatedButton(
                            onPressed: () {
                              _resetAllValue();
                              formKey.currentState?.save();
                              context.read<CustomTimer>().reset();
                            },
                            child: const Text('RESET'),
                          ),
                          const SizedBox(width: 30)
                        ])
                  ], // children
                ),
              ))),
        ),
      ),
    );
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
