import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:foodie_restaurant/core/services/navigation_service.dart';
import 'package:foodie_restaurant/core/services/shared_prefs_service.dart';
import 'package:foodie_restaurant/pages/add_meal_page/add_meal_page.dart';
import 'package:foodie_restaurant/pages/login_page/login_page.dart';
import 'package:foodie_restaurant/pages/restaurant_info_page/restaurant_info_page.dart';
import 'package:foodie_restaurant/pages/restaurant_meals_page/restaurant_meals_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int index = 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'Foodie Restaurant',
        ),
        actions: [
          IconButton(
            onPressed: () {
              SharedPreferencesService.instance.removeKey(key: 'restaurantId');
              NavigationService.pushAndPopAll(
                context,
                const LoginPage(),
              );
            },
            icon: const Icon(
              Icons.logout,
            ),
          ),
        ],
      ),
      body: SizedBox.expand(
        child: IndexedStack(
          index: index,
          children: const [
            RestaurantInfoPage(),
            RestaurantMealsPage(),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => NavigationService.push(
          context,
          const AddMealPage(),
        ),
        label: Row(
          children: [
            const Text(
              'Add new meal',
            ),
            SizedBox(
              width: 4.w,
            ),
            const Icon(Icons.add),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        onTap: (value) => setState(() {
          index = value;
        }),
        currentIndex: index,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: 'Meals',
          ),
        ],
      ),
    );
  }
}
