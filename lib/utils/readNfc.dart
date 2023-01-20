import 'dart:async';
import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:nfc_manager/nfc_manager.dart';
import 'package:flutter_nfc_kit/flutter_nfc_kit.dart';
import 'package:ndef/ndef.dart' as ndef;


class NfcEvents extends ChangeNotifier {
  bool listenerRunning = false;
  bool writeCounterOnNextContact = false;
  bool readingFinished = false;
  bool writingFinished = false;

  ValueNotifier<dynamic> result = ValueNotifier('ready to start');
  ValueNotifier<dynamic> resultValue = ValueNotifier(['', '', '', '']);

  getValue(int index) => resultValue.value[index];

  setValue(int index, String value) => resultValue.value[index] = value;

  Future<bool> writeAndReadNfc(int starting, int writingPoint,
      BuildContext context) async {
    result.value = 'please bring your phone to tag';

    while (writingPoint < 3) {
      await writeNdef(starting);

      await readTag(writingPoint);

      writingPoint += 1;
      starting += 1;
    }

    if (writingFinished && readingFinished) {
      return Future<bool>.value(true);
    }

    return Future<bool>.value(false);

    NfcManager.instance.startSession(onDiscovered: (NfcTag tag) async {
      try {
        result.value = 'current writingPoint : $writingPoint';

        Ndef? ndef = Ndef.from(tag);

        if (ndef != null) {
          if (!ndef.isWritable) {
            result.value = 'Tag is not ndef writable';
            NfcManager.instance.stopSession(errorMessage: result.value);
            return;
          }

          // write NFC
          NdefMessage message =
              NdefMessage([NdefRecord.createText(starting.toString())]);

          await ndef.write(message);
          await Future.delayed(const Duration(seconds: 5));

          result.value = 'write success $writingPoint';
          await Future.delayed(const Duration(seconds: 5));

          // read NFC
          var ndefMessage = ndef.cachedMessage;
          var record = ndefMessage!.records.last;

          if (record.typeNameFormat == NdefTypeNameFormat.nfcWellknown &&
              record.type.length == 1 &&
              record.type.first == 0x54) {

            result.value = 'read start $writingPoint';
            await Future.delayed(const Duration(seconds: 5));

            // record type: NFC WellKnown Text
            var languageCodeLength = record.payload.first;
            var languageCode =
                ascii.decode(record.payload.sublist(1, 1 + languageCodeLength));
            var text =
                utf8.decode(record.payload.sublist(1 + languageCodeLength));

            resultValue.value[writingPoint] = text;
            result.value = 'read success $writingPoint';

            notifyListeners();
            await Future.delayed(const Duration(seconds: 5));
            NfcManager.instance.stopSession();
            return;
          } else {
            result.value = 'write fail $writingPoint';
            NfcManager.instance
                .stopSession(errorMessage: result.value);
            return;
          }
        }
        result.value = 'There is no NDEF tag';
        NfcManager.instance
            .stopSession(errorMessage: result.value);
      } catch (e) {
        result.value = 'unknown error : $e';
        NfcManager.instance.stopSession(errorMessage: result.value);
        return;
      }
    });
  }

  Future<void> readTag(int writingPoint) async {
    readingFinished = false;
    result.value = 'read start $writingPoint';

    NfcManager.instance.startSession(onDiscovered: (NfcTag tag) async {
      var ndef = Ndef.from(tag);
      var ndefMessage = ndef!.cachedMessage;
      var record = ndefMessage!.records.first;

      try {
        if (record.typeNameFormat == NdefTypeNameFormat.nfcWellknown &&
            record.type.length == 1 &&
            record.type.first == 0x54) {
          // record type: NFC Wellknown Text
          var languageCodeLength = record.payload.first;
          var languageCode =
          ascii.decode(record.payload.sublist(1, 1 + languageCodeLength));
          String text =
          utf8.decode(record.payload.sublist(1 + languageCodeLength));

          result.value = 'read success : $writingPoint';

          await setValue(writingPoint, text);
          await Future.delayed(const Duration(seconds: 5));
          readingFinished = true;
          notifyListeners();
          // NfcManager.instance.stopSession(alertMessage: "finished!");
        }
      } catch (e) {
        result.value = 'read fail : $e';
        NfcManager.instance.stopSession(errorMessage: "finished!");
        return;
      }
    });

    // return Future<bool>.value(isReadingOver);
  }

  Future<void> writeNdef(int starting) async {
    result.value = 'write start $starting';
    writingFinished = false;

    NfcManager.instance.startSession(onDiscovered: (NfcTag tag) async {
      Ndef? ndef = Ndef.from(tag);

      if (ndef == null || !ndef.isWritable) {
        result.value = 'Tag is not ndef writable';
        NfcManager.instance.stopSession(errorMessage: result.value);
        return;
      }

      NdefMessage message = NdefMessage(
          [NdefRecord.createText(starting.toString())]);

      try {
        await ndef.write(message);

        result.value = 'write success $starting';

        writingFinished = true;
        await Future.delayed(const Duration(seconds: 5));
      } catch (e) {
        result.value = 'write fail : $e';
        NfcManager.instance.stopSession(errorMessage: result.value);
        return;
      }
    });
  }
}