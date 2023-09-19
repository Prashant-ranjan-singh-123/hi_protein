import 'package:flutter/material.dart';

class AlertDialogExample extends StatefulWidget {
  const AlertDialogExample({Key? key}) : super(key: key);

  @override
  _AlertDialogState createState() => _AlertDialogState();
}

class _AlertDialogState extends State<AlertDialogExample> {
  

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Alert Dialog'),
      content: Text('This is an example alert.'),
      actions: <Widget>[
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text('OK'),
        ),
      ],
    );
  }
}
