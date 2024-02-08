// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:flutter/foundation.dart';

import 'package:foodie_restaurant/pages/restaurant_meals_page/models/meal.dart';
import 'package:foodie_restaurant/pages/restaurant_meals_page/models/meal_category.dart';

class RestaurantCategoryMeals {
  MealCategory category;
  List<Meal> meals;
  RestaurantCategoryMeals({
    required this.category,
    required this.meals,
  });

  RestaurantCategoryMeals copyWith({
    MealCategory? category,
    List<Meal>? meals,
  }) {
    return RestaurantCategoryMeals(
      category: category ?? this.category,
      meals: meals ?? this.meals,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'category': category.toMap(),
      'meals': meals.map((x) => x.toMap()).toList(),
    };
  }

  factory RestaurantCategoryMeals.fromMap(Map<String, dynamic> map) {
    return RestaurantCategoryMeals(
      category: MealCategory.fromMap(map),
      meals: List<Meal>.from(
        (map['meals'] as List).map<Meal>(
          (x) => Meal.fromMap(x as Map<String, dynamic>),
        ),
      ),
    );
  }

  String toJson() => json.encode(toMap());

  factory RestaurantCategoryMeals.fromJson(String source) =>
      RestaurantCategoryMeals.fromMap(
          json.decode(source) as Map<String, dynamic>);

  @override
  String toString() => 'RestaurantMeals(category: $category, meals: $meals)';

  @override
  bool operator ==(covariant RestaurantCategoryMeals other) {
    if (identical(this, other)) return true;

    return other.category == category && listEquals(other.meals, meals);
  }

  @override
  int get hashCode => category.hashCode ^ meals.hashCode;
}
