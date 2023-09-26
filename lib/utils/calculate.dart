import 'dart:math';

class MenuSelector {
  final List<String> group1 = [
    'Menu 1A',
    'Menu 1B',
    'Menu 1C',
    'Menu 1D',
    'Menu 1E',
    'Menu 1F',
    'Menu 1G',
    'Menu 1H',
    'Menu 1I',
    'Menu 1J',
  ];

  final List<String> group2 = [
    'Menu 2A',
    'Menu 2B',
    'Menu 2C',
    'Menu 2D',
    'Menu 2E',
    'Menu 2F',
    'Menu 2G',
    'Menu 2H',
    'Menu 2I',
    'Menu 2J',
  ];

  final List<String> group3 = [
    'Menu 3A',
    'Menu 3B',
    'Menu 3C',
    'Menu 3D',
    'Menu 3E',
    'Menu 3F',
    'Menu 3G',
    'Menu 3H',
    'Menu 3I',
    'Menu 3J',
  ];

  final _random = Random();

  String selectRandomItem(List<String> group) {
    final index = _random.nextInt(group.length);
    return group[index];
  }

  void generateWeeklyMenu() {
    final selectedMenus = <String>[];

    for (int i = 0; i < 5; i++) {
      selectedMenus.add(selectRandomItem(group1));
    }
    for (int i = 0; i < 6; i++) {
      selectedMenus.add(selectRandomItem(group2));
    }
    for (int i = 0; i < 3; i++) {
      selectedMenus.add(selectRandomItem(group3));
    }

    selectedMenus.shuffle();

    print('Weekly Menu for Lunch and Dinner:');
    for (int i = 0; i < 7; i++) {
      final lunch = selectedMenus.removeLast();
      final dinner = selectedMenus.removeLast();
      print('Day ${i + 1}: Lunch - $lunch, Dinner - $dinner');
    }
  }
}
