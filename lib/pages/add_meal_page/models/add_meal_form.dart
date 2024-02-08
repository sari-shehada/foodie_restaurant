// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class AddMealForm {
  final int rating = 0;
  final String name;
  final int price;
  final String ingredients;
  final int category;

  AddMealForm({
    required this.name,
    required this.price,
    required this.ingredients,
    required this.category,
  });

  AddMealForm copyWith({
    int? rating,
    String? name,
    int? price,
    String? ingredients,
    int? category,
  }) {
    return AddMealForm(
      name: name ?? this.name,
      price: price ?? this.price,
      ingredients: ingredients ?? this.ingredients,
      category: category ?? this.category,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'rating': rating,
      'name': name,
      'price': price,
      'ingredients': ingredients,
      'category': category,
    };
  }

  factory AddMealForm.fromMap(Map<String, dynamic> map) {
    return AddMealForm(
      name: map['name'] as String,
      price: map['price'] as int,
      ingredients: map['ingredients'] as String,
      category: map['category'] as int,
    );
  }

  String toJson() => json.encode(toMap());

  factory AddMealForm.fromJson(String source) =>
      AddMealForm.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'AddMealForm(rating: $rating, name: $name, price: $price, ingredients: $ingredients, category: $category)';
  }

  @override
  bool operator ==(covariant AddMealForm other) {
    if (identical(this, other)) return true;

    return other.rating == rating &&
        other.name == name &&
        other.price == price &&
        other.ingredients == ingredients &&
        other.category == category;
  }

  @override
  int get hashCode {
    return rating.hashCode ^
        name.hashCode ^
        price.hashCode ^
        ingredients.hashCode ^
        category.hashCode;
  }
}
