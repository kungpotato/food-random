import 'dart:math';

import 'package:foodrandom/models/menu_model.dart';

class MenuPlanner {
  MenuPlanner({required this.menus});

  final List<Menu> menus;

  final Random _random = Random();

  List<String> pickUniqueRandomItems(List<String> group, int count) {
    final picked = <String>[];
    final available = List<String>.from(group);
    while (picked.length < count) {
      final index = _random.nextInt(available.length);
      picked.add(available.removeAt(index));
    }
    return picked;
  }

  void planMenus() {
    final l1 = menus
        .where((e) => e.timePerWeek == 3)
        .map((e) => e.sub
            .map((v) => pickUniqueRandomItems(v.dishes, v.pick))
            .expand((i) => i))
        .expand((i) => i)
        .toList();
    final l2 = menus
        .where((e) => e.timePerWeek == 3)
        .map((e) => e.sub
            .map((v) => pickUniqueRandomItems(v.dishes, v.pick))
            .expand((i) => i))
        .expand((i) => i)
        .toList();
    final l3 = menus
        .where((e) => e.timePerWeek == 3)
        .map((e) => e.sub
            .map((v) => pickUniqueRandomItems(v.dishes, v.pick))
            .expand((i) => i))
        .expand((i) => i)
        .toList();
    final lunch = menus
        .where((e) => e.type == 'lunch')
        .map((e) => e.sub.isEmpty
            ? pickUniqueRandomItems(e.dishes, e.timePerWeek)
                .map((v) => '${e.category}=>$v')
            : pickUniqueRandomItems([
                ...e.dishes.map((v) => '${e.category}=>$v'),
                ...e.sub.asMap().entries.map((v) => v.value.pick == 0
                    ? '${e.category}=>${v.value.category}'
                    : '${e.category}=>@${v.key}')
              ], e.timePerWeek))
        .expand((i) => i)
        .map((e) => e.contains('@0') ? e.replaceAll('@0', l1.join(',')) : e)
        .map((e) => e.contains('@1') ? e.replaceAll('@1', l2.join(',')) : e)
        .map((e) => e.contains('@2') ? e.replaceAll('@2', l3.join(',')) : e)
        .toList()
      ..shuffle(_random);
    final dinner = menus
        .where((e) => e.type == 'dinner')
        .map((e) => pickUniqueRandomItems([
              ...e.dishes.map((v) => '${e.category}=>$v'),
              ...e.sub.map((v) => v.pick == 0
                  ? '${e.category}=>${v.category}'
                  : '${e.category}=>${v.category}:${pickUniqueRandomItems(v.dishes, v.pick).join(',')}')
            ], e.timePerWeek))
        .expand((i) => i)
        .toList()
      ..shuffle(_random);

    print('Lunch menus for the week:');
    lunch.forEach(print);

    print('\nDinner menus for the week:');
    dinner.forEach(print);
  }
}
