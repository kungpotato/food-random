class Menu {
  final String category;
  final int timePerWeek;
  final String type;
  final List<SubMenu> sub;
  final List<String> dishes;
  final String? id;

  Menu(
      {required this.category,
      required this.timePerWeek,
      required this.type,
      required this.sub,
      required this.dishes,
      this.id});

  factory Menu.fromJson(Map<String, dynamic> json) {
    return Menu(
        category: json['category'],
        timePerWeek: json['timePerWeek'],
        type: json['type'],
        sub: (json['sub'] as List).map((e) => SubMenu.fromJson(e)).toList(),
        dishes: List<String>.from(json['dishes']),
        id: json['id']);
  }

  Map<String, dynamic> toMap() {
    return {
      'category': category,
      // 'timePerWeek': timePerWeek,
      'type': type,
      'sub': sub.map((e) => e.toMap()).toList(),
      'dishes': dishes,
    };
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

  Map<String, dynamic> toMap() {
    return {
      'category': category,
      'pick': pick,
      'dishes': dishes,
    };
  }
}
