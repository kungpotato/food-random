import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:foodrandom/models/menu_model.dart';
import 'package:foodrandom/utils/calculate.dart';

class RandomFood extends StatefulWidget {
  const RandomFood({super.key});

  @override
  State<RandomFood> createState() => _RandomFoodState();
}

class _RandomFoodState extends State<RandomFood> {
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

  List<String> lunch = [];
  List<String> dinner = [];

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
        lunch = plan.planLunchMenus();
        dinner = plan.planDinnerMenus();
      });
    });
  }

  Widget _buildMealCard(String meal) {
    final item = meal.split('=>');
    final data = item[1].split(',');
    return InkWell(
      onTap: () {
        if (data.length > 1) {
          _showTextDialog(data, item[0]);
        } else {
          _showTextDialog([item[1]], item[0]);
        }
      },
      child: Card(
          child:
              Padding(padding: const EdgeInsets.all(4), child: Text(item[1]))),
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

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: _columnCount,
          childAspectRatio: (1 / .6),
        ),
        itemCount: _rowCount * _columnCount,
        itemBuilder: (BuildContext context, int index) {
          if (index == 0) {
            return const SizedBox(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '25-1',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'ตุลาคม 2523',
                    style: TextStyle(fontStyle: FontStyle.italic),
                  ),
                ],
              ),
            );
          }
          if (index == 1) return _buildLabel('อาหารกลางวัน', Colors.orange);
          if (index == 2) return _buildLabel('อาหารเย็น', Colors.black);
          if (_dayNames.containsKey(index)) {
            return _buildDayItem(_dayNames[index]!, _dayColors[index]!);
          }
          if (index >= 4 && index <= 22 && index % 3 == 1 && lunch.isNotEmpty) {
            return _buildMealCard(lunch[(index - 4) ~/ 3]);
          }
          if (index >= 5 &&
              index <= 23 &&
              index % 3 == 2 &&
              dinner.isNotEmpty) {
            return _buildMealCard(dinner[(index - 5) ~/ 3]);
          }
          return Card(child: Center(child: Text('Item $index')));
        },
      ),
    );
  }

  void _showTextDialog(List<String> list, String title) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: list
                .map((e) => ListTile(
                      title: Text(
                        e,
                        style: const TextStyle(fontSize: 18),
                      ),
                    ))
                .toList(),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }
}
