import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:nfc_test_app/widget/alert.dart';
import 'package:provider/provider.dart';
import 'dart:io' show Platform;
import './utils/renderTextFormField.dart';
import './utils/checking.dart';
import './utils/customTimer.dart';
import './utils/readNfc.dart';

var _textEditingController = TextEditingController();

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Required for the line below
  runApp(MultiProvider(providers: [
    ChangeNotifierProvider(create: (_) => CustomTimer()),
    ChangeNotifierProvider(create: (_) => NfcEvents())
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
  final nfcRunning = Platform.isAndroid && NfcEvents().listenerRunning;

  String repeatCounts = '';
  String startingValue = '';
  String intervalCounts = '';
  String timeInterval = '';
  List<String> roundValue = ['0', '0', '0', '0'];
  String durationTime = '';

  final formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Alert alert = Alert();

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
                                TextSpan(
                                    text:
                                        context.watch<NfcEvents>().getValue(0))
                              ]),
                            )),
                            const SizedBox(width: 30),
                            Expanded(
                                child: Text.rich(
                              TextSpan(text: '2회 : ', children: <TextSpan>[
                                TextSpan(
                                    text:
                                        context.watch<NfcEvents>().getValue(1))
                              ]),
                            )),
                            const SizedBox(width: 30),
                            Expanded(
                                child: Text.rich(
                              TextSpan(text: '3회 : ', children: <TextSpan>[
                                TextSpan(
                                    text:
                                        context.watch<NfcEvents>().getValue(2))
                              ]),
                            )),
                            const SizedBox(width: 30),
                            Expanded(
                                child: Text.rich(
                              TextSpan(text: '4회 : ', children: <TextSpan>[
                                TextSpan(
                                    text:
                                        context.watch<NfcEvents>().getValue(3))
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
                                runNfcDemo(
                                    repeatCounts,
                                    startingValue,
                                    intervalCounts
                                );
                              }
                            },
                            child: const Text('START'),
                          ),
                          const SizedBox(width: 30),
                          Expanded(
                              child: Center(
                                  child: Text(context.watch<NfcEvents>().result.value))),
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

  void _resetAllValue() {
    _textEditingController.clear();
  }

  void runNfcDemo(String repeatCount, String initialValue, String intervalValue ) async {
    int initialRepeatCount = 0;
    int toIntRepeatCount = int.parse(repeatCount);
    int toIntInitialValue = int.parse(initialValue);
    double toDoubleIntervalValue = double.parse(intervalValue);

    context.read<NfcEvents>().writeAndReadNfc(initialValue, 0);

  }

}
