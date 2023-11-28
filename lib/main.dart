import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:nfc_manager/nfc_manager.dart';
import 'package:provider/provider.dart';
import 'dart:io' show Platform, sleep;
import './utils/renderTextFormField.dart';
import './utils/checking.dart';
import './utils/customTimer.dart';
import './utils/readNfc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Required for the line below
  runApp(MultiProvider(providers: [
    ChangeNotifierProvider(create: (_) => CustomTimer()),
    // ChangeNotifierProvider(create: (_) => NfcEvents())
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
      home:
          const MyHomePage(result: 'ready to start', title: 'Flutter NFC Demo'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  final String title;
  final String result;

  const MyHomePage({super.key, required this.result, required this.title});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final nfcRunning = Platform.isAndroid && NfcEvents().listenerRunning;

  String repeatCounts = '';
  String startingValue = '';
  String intervalCounts = '';
  List<String> roundValue = ['0', '0', '0', '0'];
  late String result;
  int initialRepeatCount = 0;
  bool isFinished = false;

  final formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    result = widget.result;
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
                                return const Text('에러화면');
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
                                TextSpan(text: roundValue[0])
                              ]),
                            )),
                            const SizedBox(width: 30),
                            Expanded(
                                child: Text.rich(
                              TextSpan(text: '2회 : ', children: <TextSpan>[
                                TextSpan(text: roundValue[1])
                              ]),
                            )),
                            const SizedBox(width: 30),
                            Expanded(
                                child: Text.rich(
                              TextSpan(text: '3회 : ', children: <TextSpan>[
                                TextSpan(text: roundValue[2])
                              ]),
                            )),
                            const SizedBox(width: 30),
                            Expanded(
                                child: Text.rich(
                              TextSpan(text: '4회 : ', children: <TextSpan>[
                                TextSpan(text: roundValue[3])
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
                                formKey.currentState!.save();
                                loopNfcDemo();
                              }
                            },
                            child: const Text('START'),
                          ),
                          const SizedBox(width: 30),
                          Expanded(child: Center(child: Text(result))),
                          const SizedBox(width: 30),
                          ElevatedButton(
                            onPressed: () {
                              setState((){
                                roundValue = ['0', '0', '0', '0'];
                                result = 'ready to start';
                                initialRepeatCount = 0;
                              });
                              formKey.currentState!.reset();
                              NfcManager.instance.stopSession();
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

  Future<void> setResultState(String value) async{
    setState(() => result = value);
  }

  Future<void> setRoundValueState(int location, String value) async{
    setState(() => roundValue[location] = value);
  }

  Future<void> writeNfcTag(int nfcValue, String intervalValue, NfcTag tag) async {
    try {
      Ndef? ndef = Ndef.from(tag);

      // write
      setResultState('write $nfcValue');

      if (!ndef!.isWritable) {
        setState(() => result = 'Tag is not ndef writable');
      }

      NdefMessage message =
      NdefMessage([NdefRecord.createText(nfcValue.toString())]);

      await ndef.write(message);

      sleep(Duration(seconds: int.parse(intervalValue)));

    } catch (e) {
      setState(() => result = 'write failed : $e');
    }
  }

  Future<void> readNfcTag(int repeatCount, int nfcValue, String intervalValue, NfcTag tag) async {
    try {
      Ndef? ndef = Ndef.from(tag);

      setResultState('read $nfcValue');
      NdefMessage readValue = await ndef!.read();
      NdefRecord record = readValue.records.first;

      if (record.typeNameFormat == NdefTypeNameFormat.nfcWellknown &&
          record.type.length == 1 &&
          record.type.first == 0x54) {
        var languageCodeLength = record.payload.first;
        var languageCode =
        ascii.decode(record.payload.sublist(1, 1 + languageCodeLength));
        String text =
        utf8.decode(record.payload.sublist(1 + languageCodeLength));

        await setRoundValueState(repeatCount, text);

        setState(() {
          initialRepeatCount += 1;
          startingValue = (nfcValue + 1).toString();
        });
      }
    } catch (e) {
      setState(() => result = 'read failed : $e');
    }
  }

  Future<void> loopNfcDemo() async {
    NfcManager.instance.startSession(onDiscovered: (NfcTag tag) async {
      for (int i=0; i < int.parse(repeatCounts); i++) {
        await writeNfcTag(int.parse(startingValue), intervalCounts, tag);
        await readNfcTag(initialRepeatCount, int.parse(startingValue), intervalCounts, tag);
      }
    });

  }
}
