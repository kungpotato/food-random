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
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
            ),
            child: const TabBar(
              tabs: [
                Tab(text: 'กลุ่ม'),
                Tab(text: 'อาหาร'),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              children: [
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: ListView.builder(
                    itemCount: _listViewData.length,
                    itemBuilder: (BuildContext context, int index) {
                      return ListTile(
                        title: Text(_listViewData[index]),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: ListView.builder(
                    itemCount: _listViewData.length,
                    itemBuilder: (BuildContext context, int index) {
                      return ListTile(
                        title: Text(_listViewData[index]),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
