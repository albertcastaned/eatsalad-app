import 'dart:async';

import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:progress_dialog/progress_dialog.dart';

import '../constants.dart';

Flushbar flushBar;
const flushbarDuration = Duration(seconds: 3);
const successDuration = Duration(seconds: 2);
void buildError(BuildContext context, String message,
    [String actionText, Function action]) {
  flushBar = Flushbar(
    messageText: Text(
      message,
      textAlign: TextAlign.center,
      style: TextStyle(color: Colors.white),
    ),
    duration: flushbarDuration,
    backgroundColor: Theme.of(context).errorColor,
    flushbarPosition: FlushbarPosition.TOP,
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

Future<void> showSuccesfulDialog(String message, BuildContext context) {
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

Future<void> showDescriptionDialog(BuildContext context, String description,
    [String title = "Descripcion"]) async {
  return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: Text(
            title,
            textAlign: TextAlign.center,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(
                borderRadius,
              ),
            ),
          ),
          content: SingleChildScrollView(
            child: Text(description),
          ),
          actions: <Widget>[
            FlatButton(
              child: Text('Ok'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            )
          ],
        );
      });
}
