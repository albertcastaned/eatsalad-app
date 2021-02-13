import 'dart:async';

import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:progress_dialog/progress_dialog.dart';

import '../constants.dart';

Flushbar flushBar;
const flushbarDuration = Duration(seconds: 3);
const successDuration = Duration(seconds: 2);
void buildFlashBar(BuildContext context, String message,
    {String actionText, Function action, bool isError = true}) {
  flushBar = Flushbar(
    messageText: Text(
      message,
      textAlign: TextAlign.center,
      style: TextStyle(color: Colors.white),
    ),
    duration: flushbarDuration,
    backgroundColor:
        isError ? Theme.of(context).errorColor : Theme.of(context).primaryColor,
    flushbarPosition: isError ? FlushbarPosition.TOP : FlushbarPosition.BOTTOM,
    mainButton: action != null
        ? FlatButton(
            onPressed: () {
              flushBar.dismiss(true);
              action();
            },
            child: Text(
              actionText,
              style: TextStyle(color: Colors.white),
            ),
          )
        : null,
  )..show(context);
}

Future<void> showSuccesfulDialog(BuildContext context, String message) {
  final deviceSize = MediaQuery.of(context).size;
  final textScaleFactor = deviceSize.height / 800;
  return showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (context) {
      Future.delayed(successDuration, () {
        Navigator.of(context).pop(true);
      });
      return AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(borderRadius),
          ),
        ),
        content: SingleChildScrollView(
          child: ListBody(
            children: <Widget>[
              Icon(
                Icons.check_circle,
                size: deviceSize.height / 8,
                color: Theme.of(context).primaryColor,
              ),
              SizedBox(
                height: 20,
              ),
              Text(
                message,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: textScaleFactor * 16),
              ),
            ],
          ),
        ),
      );
    },
  );
}

ProgressDialog buildLoadingDialog(BuildContext context, [String message]) {
  if (message == null) message = 'Cargando...';
  var dialog = ProgressDialog(
    context,
    isDismissible: false,
  );

  dialog.style(
    message: message,
    borderRadius: borderRadius,
    progressWidget: CircularProgressIndicator(),
    progressTextStyle: TextStyle(
      color: Colors.black,
      fontSize: 9.0,
    ),
    messageTextStyle: TextStyle(
      color: Colors.black,
      fontSize: 13.0,
    ),
  );

  return dialog;
}

ProgressDialog showLoadingDialog({
  @required BuildContext context,
  ProgressDialogType dialogType = ProgressDialogType.Normal,
  String message = "Cargando...",
}) {
  final progressDialog = ProgressDialog(
    context,
    isDismissible: false,
    type: dialogType,
  );
  progressDialog.style(
    padding: const EdgeInsets.symmetric(vertical: 25, horizontal: 20),
    message: message,
    borderRadius: 10.0,
    backgroundColor: Colors.white,
    elevation: 10.0,
    insetAnimCurve: Curves.easeInOut,
    progressTextStyle: TextStyle(
        color: Colors.black, fontSize: 13.0, fontWeight: FontWeight.w400),
    messageTextStyle: TextStyle(
      color: Colors.black,
      fontSize: 16.0,
    ),
  );
  return progressDialog;
}

Future<void> showAlertDialog(
    {@required BuildContext context,
    @required String title,
    @required String content,
    List<Widget> actions}) {
  final alert = AlertDialog(
    title: Text(title),
    content: Text(content),
    actions: actions,
    shape: RoundedRectangleBorder(),
  );
  return showDialog<void>(
    context: context,
    builder: (context) => alert,
  );
}
