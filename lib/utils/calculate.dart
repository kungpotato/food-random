import 'dart:math';

import 'package:foodrandom/models/menu_model.dart';

class MenuPlanner {
  MenuPlanner({required this.menus});

  final List<Menu> menus;

  final Random _random = Random();

  final Set<String> _pickedLunches = {};

  List<String> pickUniqueRandom(
      List<String> group, int count, Set<String> exclude) {
    final available = List<String>.from(group)
      ..removeWhere((item) => exclude.contains(item));
    if (available.length < count) {
      throw ArgumentError('Not enough unique items available.');
    }

    final picked = <String>[];
    while (picked.length < count) {
      final index = _random.nextInt(available.length);
      picked.add(available.removeAt(index));
    }
    _pickedLunches.addAll(picked);
    return picked;
  }

  void planMenus() {
    List<String> lunch = menus
        .where((e) => e.type == 'lunch')
        .map((e) => e.sub.isEmpty
            ? pickUniqueRandom(e.dishes, e.timePerWeek, _pickedLunches)
                .map((v) => '${e.category}=>$v')
            : pickUniqueRandom([
                ...e.dishes.map((v) => '${e.category}=>$v'),
                ...e.sub.asMap().entries.map((v) {
                  if (v.value.pick == 0) {
                    return '${e.category}=>${v.value.category}';
                  } else {
                    final ll = menus
                        .where((n) => n.timePerWeek == 3)
                        .map((j) => j.sub.map((p) {
                              return pickUniqueRandom(
                                  p.dishes, p.pick, _pickedLunches);
                            }).expand((i) => i))
                        .expand((i) => i)
                        .toList();
                    return '${e.category}=>${ll.join(',')}';
                  }
                })
              ], e.timePerWeek, _pickedLunches))
        .expand((i) => i)
        .toList()
      ..shuffle(_random);

    final dinner = menus
        .where((e) => e.type == 'dinner')
        .map((e) => pickUniqueRandom([
              ...e.dishes.map((v) => '${e.category}=>$v'),
              ...e.sub.map((v) => v.pick == 0
                  ? '${e.category}=>${v.category}'
                  : '${e.category}=>${v.category}:${pickUniqueRandom(v.dishes, v.pick, _pickedLunches).join(',')}')
            ], e.timePerWeek, _pickedLunches))
        .expand((i) => i)
        .toList()
      ..shuffle(_random);

    print('Lunch menus for the week:');
    lunch.forEach(print);

    print('\nDinner menus for the week:');
    dinner.forEach(print);
  }
}
