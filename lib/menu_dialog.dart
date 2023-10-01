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
  String supCategory = '';
  List<String> options = [];
  List<SubMenu> sub = [];
  List<String> dishes = [];
  bool noGroup = false;
  final controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    setState(() {
      options = widget.allMenu
          .where((e) => e.category == widget.category)
          .map((e) => e.sub)
          .expand((i) => i)
          .map((e) => e.category)
          .toList();
      if (options.isNotEmpty) {
        supCategory = options.first;
      } else {
        noGroup = true;
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.category),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              if (options.isNotEmpty && !noGroup)
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: DropdownButton<String>(
                    value: supCategory,
                    isExpanded: true,
                    onChanged: (v) {
                      if (v != null) {
                        setState(() {
                          supCategory = v;
                        });
                      }
                    },
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
              if (options.isNotEmpty)
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    const Text('ไม่มีกลุ่ม'),
                    Checkbox(
                        value: noGroup,
                        onChanged: (v) {
                          if (v != null) {
                            setState(() {
                              noGroup = v;
                            });
                          }
                        }),
                  ],
                ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'อาหาร'),
                controller: controller,
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
          onPressed: () async {
            if (_formKey.currentState!.validate()) {
              Menu item = widget.allMenu
                  .firstWhere((e) => e.category == widget.category);
              final ref =
                  FirebaseFirestore.instance.collection('menus').doc(item.id);
              if (supCategory.isNotEmpty && !noGroup) {
                SubMenu sup =
                    item.sub.firstWhere((e) => e.category == supCategory);
                sup.dishes.add(controller.value.text);
                final index =
                    item.sub.indexWhere((e) => e.category == sup.category);
                item.sub[index] = sup;
                final map = {
                  'sub': item.sub.map((e) => e.toMap()),
                  ...item.toMap()
                };
                await ref.update(map);
              } else {
                item.dishes.add(controller.value.text);
                final map = {'dishes': item.dishes, ...item.toMap()};
                await ref.update(map);
              }
              if (mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text('สำเร็จ'),
                  backgroundColor: Colors.green,
                  duration: Duration(seconds: 3),
                ));
              }
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
