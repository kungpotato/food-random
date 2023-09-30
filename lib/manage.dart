import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:foodrandom/menu_dialog.dart';
import 'package:foodrandom/models/menu_model.dart';
import 'package:foodrandom/utils/calculate.dart';

class Manage extends StatefulWidget {
  const Manage({super.key});

  @override
  State<Manage> createState() => _ManageState();
}

class _ManageState extends State<Manage> {
  StreamSubscription? disposeMenu;
  Map<String, List<String>> menus = {};
  String groupName = '';
  List<Menu> allMenu = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      disposeMenu = getMenusFromDb().listen((data) {
        setState(() {
          allMenu = data;
        });
        final plan = MenuPlanner(menus: data);
        setState(() {
          menus = plan.allMenu;
          if (groupName.isEmpty) {
            groupName = menus.entries.first.key;
          }
        });
      }, onError: (err, st) {
        print(err);
        print(st);
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
    disposeMenu?.cancel();
  }

  Stream<List<Menu>> getMenusFromDb([bool isSnap = true]) {
    final CollectionReference menusCollection =
    FirebaseFirestore.instance.collection('menus');
    if (isSnap) {
      return menusCollection.snapshots().map((snapshot) {
        return snapshot.docs.map((doc) {
          return Menu.fromJson(
              {'id': doc.id, ...doc.data() as Map<String, dynamic>});
        }).toList();
      });
    } else {
      return menusCollection.get().asStream().map((snapshot) {
        return snapshot.docs.map((doc) {
          return Menu.fromJson(
              {'id': doc.id, ...doc.data() as Map<String, dynamic>});
        }).toList();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          children: [
            ElevatedButton.icon(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return MenuDialog(
                          allMenu: allMenu,
                          category: groupName,
                          type:
                          groupName.contains('เย็น') ? 'dinner' : 'lunch');
                    },
                  );
                },
                icon: const Icon(Icons.add),
                label: const Text('เพิ่มอาหาร')),
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
                ?.map((e) =>
                ListTile(
                  title: Text(
                      e
                          .split(':')
                          .length > 1 ? e.split(':')[1] : e),
                  subtitle: Text(
                      e
                          .split(':')
                          .length > 1 ? e.split(':')[0] : ''),
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
