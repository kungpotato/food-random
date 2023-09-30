import 'dart:async';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:foodrandom/models/menu_model.dart';
import 'package:foodrandom/utils/calculate.dart';
import 'package:intl/intl.dart';

class RandomFood extends StatefulWidget {
  const RandomFood({super.key});

  @override
  State<RandomFood> createState() => _RandomFoodState();
}

class _RandomFoodState extends State<RandomFood> {
  StreamSubscription? disposeMenu;
  static const int _rowCount = 8;
  static const int _columnCount = 3;
  static const Map<int, String> _dayNames = {
    3: 'จันทร์',
    6: 'อังคาร',
    9: 'พุธ',
    12: 'พฤหัสบดี',
    15: 'ศุกร์',
    18: 'เสาร์',
    21: 'อาทิตย์',
  };
  static const Map<int, Color> _dayColors = {
    3: Colors.yellow,
    6: Colors.pink,
    9: Colors.green,
    12: Colors.orange,
    15: Colors.blue,
    18: Colors.purple,
    21: Colors.red,
  };
  late DateTime selectedDate;

  List<String> lunch = [];
  List<String> dinner = [];

  Future<List<Menu>> loadMenu() async {
    String jsonString = await rootBundle.loadString('assets/mocks/menu.json');
    final list = jsonDecode(jsonString) as List;
    return list.map((e) => Menu.fromJson(e)).toList();
  }

  DateTime _findMonday(DateTime dateTime) {
    int daysUntilMonday = dateTime.weekday - DateTime.monday;
    return dateTime.subtract(Duration(days: daysUntilMonday));
  }

  @override
  void initState() {
    super.initState();
    setState(() {
      selectedDate = _findMonday(DateTime.now());
    });
    // saveMenusToDb();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      disposeMenu = getMealFromDb().listen((data) {
        setState(() {
          lunch = data.first['lunch'] ?? [];
          dinner = data.first['dinner'] ?? [];
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

  Widget _buildMealCard(String meal, DateTime date) {
    final item = meal.split('=>');
    final data = item[1].split(',');
    return InkWell(
      onTap: () {
        if (data.length > 1) {
          _showTextDialog(data, item[0], date);
        } else {
          _showTextDialog([item[1]], item[0], date);
        }
      },
      child: Card(
          child: Center(
              child: Padding(
                  padding: const EdgeInsets.all(4),
                  child: Text(data.length > 1 ? 'กับข้าวพี่เล็ก' : item[1])))),
    );
  }

  Widget _buildLabel(String text, Color color) {
    return Padding(
      padding: const EdgeInsets.all(4),
      child: Container(
        decoration: BoxDecoration(
          color: color,
          borderRadius: const BorderRadius.all(Radius.circular(10.0)),
        ),
        child: Center(
          child: Text(
            text,
            style: const TextStyle(
                fontWeight: FontWeight.bold, color: Colors.white, fontSize: 16),
          ),
        ),
      ),
    );
  }

  Widget _buildDayItem(String text, Color color) {
    return Padding(
      padding: const EdgeInsets.all(4),
      child: Container(
        decoration: BoxDecoration(
          border: Border(
            left: BorderSide(
              color: color,
              width: 10.0,
            ),
            bottom: const BorderSide(
              color: Colors.grey,
            ),
          ),
        ),
        child: Center(
          child: Text(
            text,
            style: const TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }

  Future<void> _selectDate() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
      selectableDayPredicate: (DateTime date) {
        return date.weekday == DateTime.monday;
      },
    );
    if (pickedDate != null && pickedDate != selectedDate) {
      setState(() {
        selectedDate = pickedDate;
      });
    }
  }

  Future<void> saveMenusToDb() async {
    final menus = await loadMenu();
    int count = 100;
    for (Menu menu in menus) {
      final menusCollection =
          FirebaseFirestore.instance.collection('menus').doc(count.toString());
      await menusCollection.set(menu.toMap());
      count++;
    }
  }

  Future<void> saveLunchDinnerToDb(
      List<String> lunchData, List<String> dinnerData) async {
    final menusCollection =
        FirebaseFirestore.instance.collection('meal').doc('1234');
    await menusCollection.set({'lunch': lunchData, 'dinner': dinnerData});
  }

  Stream<List<Map<String, List<String>>>> getMealFromDb() {
    final CollectionReference menusCollection =
        FirebaseFirestore.instance.collection('meal');
    return menusCollection.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final map = doc.data() as Map<String, dynamic>;
        return {
          'lunch': (map['lunch'] as List).map((e) => e.toString()).toList(),
          'dinner': (map['dinner'] as List).map((e) => e.toString()).toList()
        };
      }).toList();
    });
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

  _random() async {
    getMenusFromDb(false).listen((data) {
      final plan = MenuPlanner(menus: data);
      final lunchData = plan.planLunchMenus();
      final dinnerData = plan.planDinnerMenus();
      saveLunchDinnerToDb(lunchData, dinnerData);
    }, onError: (err, st) {
      print(err);
      print(st);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          ElevatedButton(
              onPressed: () {
                _random();
              },
              child: const Text('สุ่มอาหาร')),
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: _columnCount,
                childAspectRatio: (1 / .6),
              ),
              itemCount: _rowCount * _columnCount,
              itemBuilder: (BuildContext context, int index) {
                if (index == 0) {
                  return SizedBox(
                    child: GestureDetector(
                      onTap: () {
                        _selectDate();
                      },
                      child: Card(
                        color: Colors.blueGrey.shade100,
                        child: Column(
                          children: [
                            Text(
                              DateFormat('dd-MMM-yyyy', 'th')
                                  .format(selectedDate),
                              style: const TextStyle(fontSize: 14),
                            ),
                            const Text('ถึง'),
                            Text(
                              DateFormat('dd-MMM-yyyy', 'th').format(
                                  selectedDate.add(const Duration(days: 6))),
                              style: const TextStyle(fontSize: 14),
                            )
                          ],
                        ),
                      ),
                    ),
                  );
                }
                if (index == 1) {
                  return _buildLabel('อาหารกลางวัน', Colors.orange);
                }
                if (index == 2) return _buildLabel('อาหารเย็น', Colors.black87);
                if (_dayNames.containsKey(index)) {
                  return _buildDayItem(_dayNames[index]!, _dayColors[index]!);
                }
                if (index >= 4 &&
                    index <= 22 &&
                    index % 3 == 1 &&
                    lunch.isNotEmpty) {
                  final date = _indexLunchToDay(index);
                  return _buildMealCard(lunch[(index - 4) ~/ 3], date);
                }
                if (index >= 5 &&
                    index <= 23 &&
                    index % 3 == 2 &&
                    dinner.isNotEmpty) {
                  final date = _indexDinnerToDay(index);
                  return _buildMealCard(dinner[(index - 5) ~/ 3], date);
                }
                return Card(child: Center(child: Text('Item $index')));
              },
            ),
          )
        ],
      ),
    );
  }

  DateTime _indexLunchToDay(int index) {
    switch (index) {
      case 4:
        return selectedDate;
      case 7:
        return selectedDate.add(const Duration(days: 1));
      case 10:
        return selectedDate.add(const Duration(days: 2));
      case 13:
        return selectedDate.add(const Duration(days: 3));
      case 16:
        return selectedDate.add(const Duration(days: 4));
      case 19:
        return selectedDate.add(const Duration(days: 5));
      case 22:
        return selectedDate.add(const Duration(days: 6));
      default:
        return selectedDate;
    }
  }

  DateTime _indexDinnerToDay(int index) {
    switch (index) {
      case 5:
        return selectedDate;
      case 8:
        return selectedDate.add(const Duration(days: 1));
      case 11:
        return selectedDate.add(const Duration(days: 2));
      case 14:
        return selectedDate.add(const Duration(days: 3));
      case 17:
        return selectedDate.add(const Duration(days: 4));
      case 20:
        return selectedDate.add(const Duration(days: 5));
      case 23:
        return selectedDate.add(const Duration(days: 6));
      default:
        return selectedDate;
    }
  }

  void _showTextDialog(List<String> list, String title, DateTime date) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(DateFormat('EEEE, d MMMM y', 'th').format(date)),
              const Divider(thickness: 2),
              const SizedBox(height: 8),
              ...list
                  .asMap()
                  .entries
                  .map((e) => ListTile(
                        leading: list.length > 1
                            ? Text((e.key + 1).toString())
                            : null,
                        title: Text(
                          e.value,
                          style: const TextStyle(fontSize: 18),
                        ),
                      ))
                  .toList()
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text('แก้ไข'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text('ปิด'),
            ),
          ],
        );
      },
    );
  }
}
