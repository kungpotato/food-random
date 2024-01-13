import 'dart:async';
import 'dart:convert';
import 'dart:math';

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
  StreamSubscription? disposeDate;
  StreamSubscription? disposeMeal;
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
  List<Menu> menuList = [];

  Future<List<Menu>> loadMenu() async {
    String jsonString = await rootBundle.loadString('assets/mocks/menu.json');
    final list = jsonDecode(jsonString) as List;
    return list.map((e) => Menu.fromJson(e)).toList();
  }

  DateTime _findMonday(DateTime dateTime) {
    int daysUntilMonday = dateTime.weekday - DateTime.monday;
    return dateTime.subtract(Duration(days: daysUntilMonday));
  }

  Future<void> saveDate(DateTime date) async {
    try {
      final datesCollection =
          FirebaseFirestore.instance.collection('date').doc('start_date');
      await datesCollection.set({'date': Timestamp.fromDate(date)});
      print("Dates saved successfully");
    } catch (error) {
      print("Failed to save dates: $error");
      throw error;
    }
  }

  Stream<DateTime?> dateStream() {
    final datesCollection =
        FirebaseFirestore.instance.collection('date').doc('start_date');

    return datesCollection.snapshots().map((snapshot) {
      if (snapshot.exists) {
        Map<String, dynamic>? data = snapshot.data();
        if (data != null && data.containsKey('date')) {
          Timestamp? timestamp = data['date'] as Timestamp?;
          if (timestamp != null) {
            return timestamp.toDate();
          }
        }
      }
      print("No date found in the document");
      return null;
    }).handleError((error) {
      print("Failed to fetch date: $error");
      throw error;
    });
  }

  @override
  void initState() {
    super.initState();
    // saveMenusToDb();
    setState(() {
      selectedDate = _findMonday(DateTime.now());
    });
    disposeDate = dateStream().listen((timestamp) {
      if (timestamp != null) {
        setState(() {
          selectedDate = timestamp;
        });
      } else {
        saveDate(_findMonday(DateTime.now()));
      }
    });
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      disposeMeal = getMealFromDb().listen((data) {
        setState(() {
          lunch = data.first['lunch'] ?? [];
          dinner = data.first['dinner'] ?? [];
        });
      }, onError: (err, st) {
        print(err);
        print(st);
      });
      disposeMenu = getMenusFromDb().listen((data) {
        setState(() {
          menuList = data;
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
    disposeMeal?.cancel();
    disposeDate?.cancel();
  }

  Widget _buildMealCard(String meal, DateTime date, [bool lunch = true]) {
    final data = meal.split(',');
    return InkWell(
      onTap: () {
        if (data.isNotEmpty) {
          _showTextDialog(data, date, lunch);
        } else {
          _showTextDialog([meal], date, lunch);
        }
      },
      child: Card(
          child: Center(
              child: Padding(
                  padding: const EdgeInsets.all(4),
                  child: Text(data.length > 1 ? 'กับข้าวพี่เล็ก' : meal)))),
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
    DateTime initialMonday = selectedDate;
    while (initialMonday.weekday != DateTime.monday) {
      initialMonday = initialMonday.add(const Duration(days: 1));
    }

    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: initialMonday,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
      selectableDayPredicate: (date) {
        return date.weekday == DateTime.monday;
      },
    );
    if (pickedDate != null && pickedDate != selectedDate) {
      saveDate(pickedDate);
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
                          mainAxisAlignment: MainAxisAlignment.center,
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
                  return _buildMealCard(dinner[(index - 5) ~/ 3], date, false);
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

  Future<void> _showEditDialog(String title, bool isLunch) async {
    final formKey = GlobalKey<FormState>();
    final controller = TextEditingController(text: title);

    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(builder: (context, setState) {
          return WillPopScope(
            onWillPop: () async => false,
            child: AlertDialog(
              title: const Text('แก้ไขเมนู'),
              content: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            decoration:
                                const InputDecoration(labelText: 'อาหาร'),
                            controller: controller,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'ใส่ชื่ออาหาร';
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () async {
                    final menusCollection = FirebaseFirestore.instance
                        .collection('meal')
                        .doc('1234');
                    if (isLunch) {
                      List<String> temp = lunch;
                      final index = temp.indexWhere((e) => e.contains(title));
                      temp[index] = controller.value.text;
                      await menusCollection
                          .set({'lunch': temp, 'dinner': dinner});
                    } else {
                      List<String> temp = dinner;
                      final index = temp.indexWhere((e) => e.contains(title));
                      temp[index] = controller.value.text;
                      await menusCollection
                          .set({'dinner': temp, 'lunch': lunch});
                    }
                    if (mounted) {
                      controller.clear();
                      Navigator.pop(context);
                      Navigator.pop(context);
                    }
                  },
                  child: const Text('ตกลง'),
                ),
                TextButton(
                  onPressed: () {
                    controller.clear();
                    Navigator.of(context).pop();
                  },
                  child: const Text('ปิด'),
                ),
              ],
            ),
          );
        });
      },
    );
  }

  void _showTextDialog(List<String> list, DateTime date, bool isLunch) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(DateFormat('EEEE, d MMMM y', 'th').format(date)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
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
                          trailing: IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () async {
                                await _showEditDialog(e.value, isLunch);
                              }),
                        ))
                    .toList()
              ],
            ),
          ),
          actions: <Widget>[
            if (list.length > 1)
              ElevatedButton(
                  onPressed: () {
                    getMenusFromDb(false).listen((data) {
                      final newList = [
                        ...data
                            .where((e) => e.id == '100' || e.id == '101')
                            .map((e) => e.dishes),
                        ...data
                            .where((e) => e.id == '100' || e.id == '101')
                            .map((e) => e.sub.map((v) => v.dishes))
                            .expand((i) => i)
                      ].expand((i) => i).toList()
                        ..shuffle(
                            Random(DateTime.now().microsecondsSinceEpoch));
                      final val = newList.take(list.length);
                      final menusCollection = FirebaseFirestore.instance
                          .collection('meal')
                          .doc('1234');
                      List<String> temp = lunch;
                      final index =
                          temp.indexWhere((e) => e.contains(list.first));
                      temp[index] = val.join(',');
                      menusCollection.set({'lunch': temp, 'dinner': dinner});
                      Navigator.of(context).pop();
                      showSuccessSnackBar();
                    }, onError: (err, st) {
                      print(err);
                      print(st);
                    });
                  },
                  child: const Text('สุ่มอาหารพี่เล็ก')),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                showSuccessSnackBar();
              },
              child: const Text('ปิด'),
            ),
          ],
        );
      },
    );
  }

  void showSuccessSnackBar() {
    const snackBar = SnackBar(
      content: Text('สำเร็จ'),
      backgroundColor: Colors.green,
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}
