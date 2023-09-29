import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:foodrandom/manage.dart';
import 'package:foodrandom/random.dart';

import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blueGrey,
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
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool isLoad = true;
  int _selectedIndex = 0;

  List<Widget> _pages() => [
        isLoad
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : const RandomFood(),
        isLoad
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : const Manage(),
      ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      _auth.authStateChanges().listen((user) async {
        if (user == null) {
          _auth.signInWithEmailAndPassword(
              email: 'admin@mail.com', password: '12345678');
        } else {
          setState(() {
            isLoad = false;
          });
        }
      }, onError: (err, st) {
        print(err);
        print(st);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
            _selectedIndex == 0 ? 'เมนูประจำอาทิตย์' : 'จัดการรายการอาหาร'),
        elevation: 0,
        actions: [
          if (_selectedIndex == 1)
            IconButton(
                onPressed: () {
                  //
                },
                icon: const Icon(Icons.add_circle))
        ],
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
