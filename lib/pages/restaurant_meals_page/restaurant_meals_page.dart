import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:foodie_restaurant/core/services/http_service.dart';
import 'package:foodie_restaurant/core/services/navigation_service.dart';
import 'package:foodie_restaurant/core/services/shared_prefs_service.dart';
import 'package:foodie_restaurant/core/widgets/custom_future_builder.dart';
import 'package:foodie_restaurant/pages/meal_page/meal_page.dart';
import 'package:foodie_restaurant/pages/restaurant_meals_page/models/meal.dart';
import 'package:foodie_restaurant/pages/restaurant_meals_page/models/restaurant_category_meals.dart';

class RestaurantMealsPage extends StatefulWidget {
  const RestaurantMealsPage({super.key});

  @override
  State<RestaurantMealsPage> createState() => _RestaurantMealsPageState();
}

class _RestaurantMealsPageState extends State<RestaurantMealsPage> {
  late Future<List<RestaurantCategoryMeals>> futureCategoryMeals;

  @override
  void initState() {
    futureCategoryMeals = getMeals();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return CustomFutureBuilder(
      future: futureCategoryMeals,
      builder: (context, categoriesMeals) {
        return RefreshIndicator(
          onRefresh: () async {
            futureCategoryMeals = getMeals();
            setState(() {});
          },
          child: ListView.builder(
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            itemCount: categoriesMeals.length,
            itemBuilder: (context, index) {
              RestaurantCategoryMeals categoryMeals = categoriesMeals[index];
              return Column(
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10.w),
                    child: Row(
                      children: [
                        Text(
                          '- ${categoryMeals.category.name}',
                          style: TextStyle(
                            fontSize: 19.sp,
                            color: Colors.orange,
                          ),
                        ),
                        SizedBox(
                          width: 15.w,
                        ),
                        Expanded(
                          child: Container(
                            height: 1.5.h,
                            width: double.maxFinite,
                            color: Colors.orange.withOpacity(0.5),
                          ),
                        )
                      ],
                    ),
                  ),
                  SizedBox(height: 10.h),
                  ...List.generate(
                    categoryMeals.meals.length,
                    (index1) {
                      Meal meal = categoryMeals.meals[index1];
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 3),
                        child: MealCardWidget(meal: meal),
                      );
                    },
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }

  Future<List<RestaurantCategoryMeals>> getMeals() async {
    int? restaurantId =
        SharedPreferencesService.instance.getInt('restaurantId');
    if (restaurantId == null) {
      throw Exception();
    }
    return HttpService.parsedMultiGet(
      endPoint: 'restaurants/$restaurantId/meals/',
      mapper: RestaurantCategoryMeals.fromMap,
    );
  }
}

class MealCardWidget extends StatelessWidget {
  const MealCardWidget({
    super.key,
    required this.meal,
  });

  final Meal meal;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () => NavigationService.push(
        context,
        MealPage(
          mealId: meal.id,
        ),
      ),
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(5.r),
        child: SizedBox.square(
          dimension: 53.sp,
          child: Image.network(
            meal.image,
            fit: BoxFit.fill,
          ),
        ),
      ),
      title: Text(meal.name),
      trailing: meal.discountedPrice != null
          ? Container(
              padding: EdgeInsets.symmetric(
                vertical: 5.h,
                horizontal: 10.w,
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(6.r),
                color: Colors.orange.withOpacity(0.15),
              ),
              child: Text(
                'In Promotion',
                style: TextStyle(
                  color: Colors.orange.shade600,
                ),
              ),
            )
          : null,
    );
  }
}
