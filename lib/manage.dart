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
                Tab(text: 'Tab 1'),
                Tab(text: 'Tab 2'),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              children: [
                // Tab 1 Content
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
                // Tab 2 Content
                const Center(
                  child: Text('Content for Tab 2'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
