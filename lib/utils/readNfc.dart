import 'dart:async';
import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:nfc_manager/nfc_manager.dart';

class NfcEvents extends ChangeNotifier {
  bool listenerRunning = false;
  bool writeCounterOnNextContact = false;
  ValueNotifier<dynamic> result = ValueNotifier('ready to start');
  List<String> resultValue = ['', '', '', ''];

  getValue(int index) => resultValue[index];

  setValue(int index, String value) => resultValue[index] = value;

  Future<void> writeAndReadNfc(String starting, int writingPoint) async {
    result.value = 'please bring your phone to tag';

    NfcManager.instance.startSession(onDiscovered: (NfcTag tag) async {
    result.value = tag.data;
      //   Ndef? ndef = Ndef.from(tag);
    //   var ndefMessage = ndef!.cachedMessage;
    //   final record = ndefMessage!.records[0];
    //
    //   // write NFC
    //   if (!ndef.isWritable) {
    //     result.value = 'Tag is not ndef writable';
    //     NfcManager.instance.stopSession(errorMessage: result.value);
    //     return;
    //   }
    //
    //   NdefMessage message = NdefMessage([NdefRecord.createText(starting)]);
    //
    //   try {
    //     await ndef.write(message);
    //     result.value = 'write success';
    //
    //     // read NFC
    //     if (record.typeNameFormat == NdefTypeNameFormat.nfcWellknown &&
    //         record.type.length == 1 &&
    //         record.type.first == 0x54 && result.value == 'write success') {
    //       result.value = 'read start';
    //
    //       // record type: NFC WellKnown Text
    //       final languageCodeLength = record.payload.first;
    //       final languageCode =
    //           ascii.decode(record.payload.sublist(1, 1 + languageCodeLength));
    //       final text =
    //           utf8.decode(record.payload.sublist(1 + languageCodeLength));
    //
    //       resultValue[writingPoint] = text;
    //       result.value = 'read success';
    //       notifyListeners();
    //       NfcManager.instance.stopSession();
    //     }
    //
    //     return;
    //   } catch (e) {
    //     NfcManager.instance.stopSession(errorMessage: result.value.toString());
    //     result.value = 'write fail...';
    //     return;
    //   }
    });
  }

  Future<void> readTag(int writingPoint) async {
    result.value = 'read start';

    NfcManager.instance.startSession(onDiscovered: (NfcTag tag) async {
      var ndef = Ndef.from(tag);
      var ndefMessage = ndef!.cachedMessage;
      final record = ndefMessage!.records[1];

      if (record.typeNameFormat == NdefTypeNameFormat.nfcWellknown &&
          record.type.length == 1 &&
          record.type.first == 0x54) {
        // record type: NFC Wellknown Text
        final languageCodeLength = record.payload.first;
        final languageCode =
            ascii.decode(record.payload.sublist(1, 1 + languageCodeLength));
        final text =
            utf8.decode(record.payload.sublist(1 + languageCodeLength));
        resultValue[writingPoint] = text;
        result.value = 'read success';
        notifyListeners();
        NfcManager.instance.stopSession();
      }
    });
  }

  Future<void> writeNdef(String starting) async {
    result.value = 'write start';

    NfcManager.instance.startSession(onDiscovered: (NfcTag tag) async {
      Ndef? ndef = Ndef.from(tag);

      if (ndef == null || !ndef.isWritable) {
        result.value = 'Tag is not ndef writable';
        NfcManager.instance.stopSession(errorMessage: result.value);
        return;
      }

      NdefMessage message = NdefMessage([NdefRecord.createText(starting)]);

      try {
        await ndef.write(message);
        // NfcManager.instance.stopSession();
        result.value = 'write success';
        return;
      } catch (e) {
        NfcManager.instance.stopSession(errorMessage: result.value.toString());
        result.value = 'write fail...';
        return;
      }
    });
  }

  void writeLockNdef() {
    NfcManager.instance.startSession(onDiscovered: (NfcTag tag) async {
      var ndef = Ndef.from(tag);
      if (ndef == null) {
        result.value = 'Tag is not ndef';
        NfcManager.instance.stopSession(errorMessage: result.value.toString());
        return;
      }

      try {
        await ndef.writeLock();
        result.value = 'Success to "Ndef Write Lock"';
        NfcManager.instance.stopSession();
      } catch (e) {
        result.value = e;
        NfcManager.instance.stopSession(errorMessage: result.value.toString());
        return;
      }
    });
  }
}
