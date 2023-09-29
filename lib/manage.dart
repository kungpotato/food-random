import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:foodrandom/models/menu_model.dart';
import 'package:foodrandom/utils/calculate.dart';

class Manage extends StatefulWidget {
  const Manage({super.key});

  @override
  State<Manage> createState() => _ManageState();
}

class _ManageState extends State<Manage> {
  Map<String, List<String>> menus = {};
  String groupName = '';

  Future<List<Menu>> loadMenu() async {
    String jsonString = await rootBundle.loadString('assets/mocks/menu.json');
    final list = jsonDecode(jsonString) as List;
    return list.map((e) => Menu.fromJson(e)).toList();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final data = await loadMenu();
      final plan = MenuPlanner(menus: data);
      setState(() {
        menus = plan.allMenu;
        groupName = menus.entries.first.key;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: DropdownButton<String>(
                value: groupName,
                isExpanded: true,
                onChanged: (String? newValue) {
                  setState(() {
                    groupName = newValue!;
                  });
                },
                items: menus.entries
                    .map((e) => e.key)
                    .map<DropdownMenuItem<String>>((value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Text(value),
                    ),
                  );
                }).toList(),
              ),
            ),
            ...menus[groupName]
                    ?.map((e) => ListTile(
                          title: Text(
                              e.split(':').length > 1 ? e.split(':')[1] : e),
                          subtitle: Text(
                              e.split(':').length > 1 ? e.split(':')[0] : ''),
                          trailing: IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () {
                                //
                              }),
                        ))
                    .toList() ??
                []
          ],
        ),
      ),
    );
  }
}
