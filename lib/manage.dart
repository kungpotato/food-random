import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:foodrandom/menu_dialog.dart';
import 'package:foodrandom/models/menu_model.dart';

class Manage extends StatefulWidget {
  const Manage({super.key});

  @override
  State<Manage> createState() => _ManageState();
}

class _ManageState extends State<Manage> {
  StreamSubscription? disposeMenu;
  String groupName = '';
  String filterText = '';
  List<Menu> menuList = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      disposeMenu = getMenusFromDb().listen((data) {
        setState(() {
          if (groupName.isEmpty) {
            groupName = data.first.category;
            menuList = data;
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
            Row(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: DropdownButton<String>(
                      value: groupName,
                      isExpanded: true,
                      onChanged: (String? newValue) {
                        setState(() {
                          groupName = newValue!;
                          filterText = '';
                        });
                      },
                      items: menuList
                          .map((e) => e.category)
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
                ),
                PopupMenuButton<String>(
                  onSelected: (result) {
                    setState(() {
                      filterText = result;
                    });
                  },
                  itemBuilder: (context) =>
                      menuList
                          .firstWhereOrNull((e) => e.category == groupName)
                          ?.sub
                          .map((e) => e.category)
                          .map((e) => PopupMenuItem<String>(
                                value: e,
                                child: Text(e),
                              ))
                          .toList() ??
                      [],
                )
              ],
            ),
            ElevatedButton.icon(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return MenuDialog(
                          allMenu: menuList,
                          category: groupName,
                          type:
                              groupName.contains('เย็น') ? 'dinner' : 'lunch');
                    },
                  );
                },
                icon: const Icon(Icons.add),
                label: const Text('เพิ่มอาหาร')),
            if (filterText.isEmpty)
              ...menuList
                      .firstWhereOrNull((e) => e.category == groupName)
                      ?.dishes
                      .map((e) => ListTile(
                            title: Text(e),
                            trailing: IconButton(
                                icon: const Icon(Icons.delete),
                                onPressed: () async {
                                  Menu item = menuList.firstWhere(
                                      (e) => e.category == groupName);
                                  item.dishes.removeWhere((v) => e.contains(v));
                                  for (int i = 0; i < item.sub.length; i++) {
                                    item.sub[i].dishes
                                        .removeWhere((val) => e.contains(val));
                                  }
                                  final ref = FirebaseFirestore.instance
                                      .collection('menus')
                                      .doc(item.id);
                                  await ref.update(item.toMap());
                                  if (mounted) {
                                    ScaffoldMessenger.of(context)
                                        .showSnackBar(const SnackBar(
                                      content: Text('สำเร็จ'),
                                      backgroundColor: Colors.green,
                                      duration: Duration(seconds: 3),
                                    ));
                                  }
                                }),
                          ))
                      .toList() ??
                  [],
            ...menuList
                    .firstWhereOrNull((e) => e.category == groupName)
                    ?.sub
                    .where((v) => filterText.isNotEmpty
                        ? v.category.contains(filterText)
                        : true)
                    .map((e) => e.dishes)
                    .expand((i) => i)
                    .map((e) => ListTile(
                          title: Text(e),
                          trailing: IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () async {
                                Menu item = menuList
                                    .firstWhere((e) => e.category == groupName);
                                item.dishes.removeWhere((v) => e.contains(v));
                                for (int i = 0; i < item.sub.length; i++) {
                                  item.sub[i].dishes
                                      .removeWhere((val) => e.contains(val));
                                }
                                final ref = FirebaseFirestore.instance
                                    .collection('menus')
                                    .doc(item.id);
                                await ref.update(item.toMap());
                                if (mounted) {
                                  ScaffoldMessenger.of(context)
                                      .showSnackBar(const SnackBar(
                                    content: Text('สำเร็จ'),
                                    backgroundColor: Colors.green,
                                    duration: Duration(seconds: 3),
                                  ));
                                }
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
