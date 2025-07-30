import 'package:flutter/material.dart';

Widget addTaskButton() {
  return Builder(
    builder: (context) {
      return FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) => Dialog(
              child: Padding(padding: EdgeInsets.all(20), child: Text('text')),
            ),
          );
        },
        child: Icon(Icons.add),
      );
    },
  );
}
