import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:foodrandom/models/menu_model.dart';

class MenuDialog extends StatefulWidget {
  const MenuDialog(
      {super.key,
      required this.category,
      required this.type,
      required this.allMenu});

  final List<Menu> allMenu;
  final String category;
  final String type;

  @override
  MenuDialogState createState() => MenuDialogState();
}

class MenuDialogState extends State<MenuDialog> {
  final _formKey = GlobalKey<FormState>();

  List<SubMenu> sub = [];
  List<String> dishes = [];

  @override
  Widget build(BuildContext context) {
    final options = widget.allMenu
        .where((e) => e.category == widget.category)
        .map((e) => e.sub)
        .expand((i) => i)
        .map((e) => e.category);
    return AlertDialog(
      title: Text(widget.category),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              if (options.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: DropdownButton<String>(
                    value: options.first,
                    isExpanded: true,
                    onChanged: (String? newValue) {},
                    items: options.map<DropdownMenuItem<String>>((value) {
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
              TextFormField(
                decoration: const InputDecoration(labelText: 'อาหาร'),
                onChanged: (value) {
                  //
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'ใส่ชื่ออาหาร';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              CollectionReference menus =
                  FirebaseFirestore.instance.collection('menus');
              menus
                  .add(Menu(
                category: '',
                timePerWeek: 0,
                type: '',
                sub: sub,
                dishes: dishes,
              ).toMap())
                  .then((value) {
                print("Menu Added");
              }).catchError((error) {
                print("Failed to add menu: $error");
              });
            }
          },
          child: const Text('บันทึก'),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('ยกเลิก'),
        ),
      ],
    );
  }
}
