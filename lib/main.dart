import 'package:flutter/material.dart';
import 'package:foodrandom/manage.dart';
import 'package:foodrandom/random.dart';
import 'package:foodrandom/utils/calculate.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.green,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  MyHomePageState createState() => MyHomePageState();
}

class MyHomePageState extends State<MyHomePage> {
  int _selectedIndex = 0;

  List<Widget> _pages() => [
        const RandomFood(),
        const Manage(),
      ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  void initState() {
    super.initState();
    final menuSelector = MenuSelector();
    menuSelector.generateWeeklyMenu();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            Text(_selectedIndex == 0 ? 'รายการอาหารสุ่ม' : 'จัดการรายการอาหาร'),
        elevation: 0,
      ),
      body: _pages().elementAt(_selectedIndex),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.menu_book),
            label: 'สุ่ม',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'จัดการ',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}
