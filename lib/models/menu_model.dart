class Menu {
  final String category;
  final int timePerWeek;
  final String type;
  final List<SubMenu> sub;
  final List<String> dishes;

  Menu({
    required this.category,
    required this.timePerWeek,
    required this.type,
    required this.sub,
    required this.dishes,
  });

  factory Menu.fromJson(Map<String, dynamic> json) {
    return Menu(
      category: json['category'],
      timePerWeek: json['timePerWeek'],
      type: json['type'],
      sub: (json['sub'] as List).map((e) => SubMenu.fromJson(e)).toList(),
      dishes: List<String>.from(json['dishes']),
    );
  }
}

class SubMenu {
  final String category;
  final int pick;
  final List<String> dishes;

  SubMenu({
    required this.category,
    required this.pick,
    required this.dishes,
  });

  factory SubMenu.fromJson(Map<String, dynamic> json) {
    return SubMenu(
      category: json['category'],
      pick: json['pick'],
      dishes: List<String>.from(json['dishes']),
    );
  }
}
