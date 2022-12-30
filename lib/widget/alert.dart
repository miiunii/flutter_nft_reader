//Helper method to show a quick message
import 'package:flutter/material.dart';
import 'package:quickalert/quickalert.dart';

class Alert {

    void confirmAlert(BuildContext context, String message) {
        QuickAlert.show(
            context: context, type: QuickAlertType.confirm, text: message);
      }
}
// class ConfirmAlert extends StatelessWidget {
//
//   const ConfirmAlert({Key? key}) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//
//     void confirmAlert(String message) {
//       QuickAlert.show(
//           context: context, type: QuickAlertType.confirm, text: 'confirm');
//     }
//
//     return const Scaffold();
//   }
// }
//   @override
//   Widget build(BuildContext context) {
//
//     void confirmAlert(String message) {
//       QuickAlert.show(
//           context: context, type: QuickAlertType.confirm, text: 'confirm');
//     }
//
//     void errorAlert(String message) {
//       QuickAlert.show(
//           context: context, type: QuickAlertType.error, text: 'error');
//     }
//
//     void warningAlert(String message) {
//       QuickAlert.show(
//           context: context, type: QuickAlertType.warning, text: 'warning');
//     }
//
//     void infoAlert(String message) {
//       QuickAlert.show(context: context, type: QuickAlertType.info, text: 'info');
//     }
//
//     void loadingAlert(String message) {
//       QuickAlert.show(
//           context: context, type: QuickAlertType.loading, text: 'loading');
//     }
//
//     return const Scaffold();
//   }
//
//
