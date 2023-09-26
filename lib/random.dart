import 'package:flutter/material.dart';

class RandomFood extends StatefulWidget {
  const RandomFood({super.key});

  @override
  State<RandomFood> createState() => _RandomFoodState();
}

class _RandomFoodState extends State<RandomFood> {
  static const int _rowCount = 8;
  static const int _columnCount = 3;

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
            return _meal('อาหารกลางวัน', Colors.greenAccent);
          }
          if (index == 2) {
            return _meal('อาหารเย็น', Colors.blueAccent);
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
            style: const TextStyle(fontWeight: FontWeight.bold),
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
