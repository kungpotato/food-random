import 'package:flutter/material.dart';

class Manage extends StatefulWidget {
  const Manage({super.key});

  @override
  State<Manage> createState() => _ManageState();
}

class _ManageState extends State<Manage> {
  static final List<String> _listViewData = List<String>.generate(
    20,
    (index) => 'List item $index',
  );

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: ListView.builder(
        itemCount: _listViewData.length,
        itemBuilder: (BuildContext context, int index) {
          return ListTile(
            title: Text(_listViewData[index]),
          );
        },
      ),
    );
  }
}
