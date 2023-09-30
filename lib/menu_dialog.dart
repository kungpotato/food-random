import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:foodrandom/models/menu_model.dart';

class MenuDialog extends StatefulWidget {
  const MenuDialog({super.key, required this.category, required this.type});

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
    return AlertDialog(
      title: Text(widget.category),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                decoration: const InputDecoration(labelText: 'Category'),
                onChanged: (value) {
                  //
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a category';
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
          child: const Text('Submit'),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Cancel'),
        ),
      ],
    );
  }
}
