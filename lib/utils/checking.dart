import 'package:nfc_manager/nfc_manager.dart';
import 'dart:io' show Platform;

late var isNfcAvailable;

class Checking{

  static Future<String> checkSupportNfc()  async {
    isNfcAvailable = await NfcManager.instance.isAvailable();

    if (isNfcAvailable) {
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
}
