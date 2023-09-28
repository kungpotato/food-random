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

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: _columnCount,
          childAspectRatio: (1 / .5),
        ),
        itemCount: _rowCount * _columnCount,
        itemBuilder: (BuildContext context, int index) {
          if (index == 0) {
            return const SizedBox();
          }
          if (index == 1) {
            return _meal('อาหารกลางวัน', Colors.red);
          }
          if (index == 2) {
            return _meal('อาหารเย็น', Colors.black);
          }
          if (index == 3) {
            return _datItem('จันทร์', Colors.yellow);
          }
          if (index == 6) {
            return _datItem('อังคาร', Colors.pink);
          }
          if (index == 9) {
            return _datItem('พุธ', Colors.green);
          }
          if (index == 12) {
            return _datItem('พฤหัสบดี', Colors.orange);
          }
          if (index == 15) {
            return _datItem('ศุกร์', Colors.blue);
          }
          if (index == 18) {
            return _datItem('เสาร์', Colors.purple);
          }
          if (index == 21) {
            return _datItem('อาทิตย์', Colors.red);
          }
          if (index == 4 && lunch.isNotEmpty) {
            return Card(
              child: Center(
                child: Text(lunch[0]),
              ),
            );
          }
          if (index == 7 && lunch.isNotEmpty) {
            return Card(
              child: Center(
                child: Text(lunch[1]),
              ),
            );
          }
          if (index == 10 && lunch.isNotEmpty) {
            return Card(
              child: Center(
                child: Text(lunch[2]),
              ),
            );
          }
          if (index == 13 && lunch.isNotEmpty) {
            return Card(
              child: Center(
                child: Text(lunch[3]),
              ),
            );
          }
          if (index == 16 && lunch.isNotEmpty) {
            return Card(
              child: Center(
                child: Text(lunch[4]),
              ),
            );
          }
          if (index == 19 && lunch.isNotEmpty) {
            return Card(
              child: Center(
                child: Text(lunch[5]),
              ),
            );
          }
          if (index == 22 && lunch.isNotEmpty) {
            return Card(
              child: Center(
                child: Text(lunch[6]),
              ),
            );
          }
          if (index == 5 && dinner.isNotEmpty) {
            return Card(
              child: Center(
                child: Text(dinner[0]),
              ),
            );
          }
          if (index == 8 && dinner.isNotEmpty) {
            return Card(
              child: Center(
                child: Text(dinner[1]),
              ),
            );
          }
          if (index == 11 && dinner.isNotEmpty) {
            return Card(
              child: Center(
                child: Text(dinner[2]),
              ),
            );
          }
          if (index == 14 && dinner.isNotEmpty) {
            return Card(
              child: Center(
                child: Text(dinner[3]),
              ),
            );
          }
          if (index == 17 && dinner.isNotEmpty) {
            return Card(
              child: Center(
                child: Text(dinner[4]),
              ),
            );
          }
          if (index == 20 && dinner.isNotEmpty) {
            return Card(
              child: Center(
                child: Text(dinner[5]),
              ),
            );
          }
          if (index == 23 && dinner.isNotEmpty) {
            return Card(
              child: Center(
                child: Text(dinner[6]),
              ),
            );
          }
          return Card(
            child: Center(
              child: Text('Item $index'),
            ),
          );
        },
      ),
    );
  }

  Widget _meal(String text, Color color) {
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
                fontWeight: FontWeight.bold, color: Colors.white),
          ),
        ),
      ),
    );
  }

  Widget _datItem(String text, Color color) {
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
              )),
          // borderRadius: BorderRadius.circular(10.0),
        ),
        child: Center(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 20.0,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
