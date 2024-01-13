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

  List<String> planLunchMenus() {
    final lunch = menus
        .where((e) => e.type == 'lunch')
        .map((e) {
          final List<String> list = [
            ...e.dishes,
            ...e.sub.map((v) => v.pick == 0
                ? v.category
                : pickUniqueRandom(v.dishes, v.pick, _pickedLunches).join(','))
          ];
          final val = pickUniqueRandom(list, e.timePerWeek, {});
          return val;
        })
        .expand((i) => i)
        .toList()
      ..shuffle(_random);

    return lunch;
  }

  List<String> planDinnerMenus() {
    final dinner = menus
        .where((e) => e.type == 'dinner')
        .map((e) {
          final List<String> list = e.sub
              .map((v) => pickUniqueRandom(v.dishes, v.pick, _pickedLunches))
              .expand((i) => i)
              .toList();
          return pickUniqueRandom(list, e.timePerWeek, {});
        })
        .expand((i) => i)
        .toList()
      ..shuffle(_random);
    return dinner;
  }

  Map<String, List<String>> get allMenu {
    Map<String, List<String>> map = {};
    for (var e in menus) {
      map[e.category] = e.dishes;
      for (var v in e.sub) {
        map[e.category]!.addAll(v.dishes.map((k) => '${v.category}:$k'));
      }
    }
    return map;
  }
}
