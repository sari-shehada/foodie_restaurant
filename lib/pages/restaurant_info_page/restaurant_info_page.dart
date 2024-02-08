import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:foodie_restaurant/core/services/http_service.dart';
import 'package:foodie_restaurant/core/services/shared_prefs_service.dart';
import 'package:foodie_restaurant/core/services/url_launcher_service.dart';
import 'package:foodie_restaurant/core/widgets/custom_future_builder.dart';
import 'package:foodie_restaurant/models/restaurant.dart';

class RestaurantInfoPage extends StatefulWidget {
  const RestaurantInfoPage({super.key});

  @override
  State<RestaurantInfoPage> createState() => _RestaurantInfoPageState();
}

class _RestaurantInfoPageState extends State<RestaurantInfoPage> {
  late Future<Restaurant> restaurantFuture;

  @override
  void initState() {
    restaurantFuture = getRestaurantInfo();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return CustomFutureBuilder(
      future: restaurantFuture,
      builder: (context, restaurant) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              flex: 40,
              child: Padding(
                padding: EdgeInsets.all(15.sp),
                child: Image.network(
                  restaurant.image,
                  fit: BoxFit.contain,
                ),
              ),
            ),
            Expanded(
              flex: 60,
              child: Column(
                children: [
                  SizedBox(
                    height: 10.h,
                  ),
                  Text(
                    restaurant.name,
                    style: TextStyle(
                      fontSize: 25.sp,
                      color: Colors.orange.shade700,
                    ),
                  ),
                  SizedBox(
                    height: 14.h,
                  ),
                  Icon(
                    Icons.location_pin,
                    size: 35.sp,
                  ),
                  SizedBox(
                    height: 10.h,
                  ),
                  Text(
                    restaurant.location,
                    style: TextStyle(
                      fontSize: 18.sp,
                    ),
                  ),
                  SizedBox(
                    height: 17.h,
                  ),
                  ListTile(
                    leading: const Icon(Icons.numbers),
                    title: const Text('Landline'),
                    subtitle: Text(
                      restaurant.landLine == null
                          ? 'Not Provided'
                          : restaurant.landLine!,
                    ),
                    trailing: restaurant.landLine == null
                        ? null
                        : IconButton(
                            style: ButtonStyle(
                              backgroundColor: MaterialStatePropertyAll(
                                Colors.orange.shade100,
                              ),
                              iconColor: MaterialStatePropertyAll(
                                Colors.orange.shade600,
                              ),
                              padding: MaterialStatePropertyAll(
                                EdgeInsets.all(8.sp),
                              ),
                            ),
                            onPressed: () => UrlLauncherService.openPhoneDialer(
                              phoneNumber: '011${restaurant.landLine ?? ''}',
                            ),
                            icon: const Icon(
                              Icons.phone,
                            ),
                          ),
                  ),
                  ListTile(
                    leading: const Icon(Icons.numbers),
                    title: const Text('Phone Number'),
                    subtitle: Text(
                      restaurant.phoneNumber == null
                          ? 'Not Provided'
                          : restaurant.phoneNumber!,
                    ),
                    trailing: restaurant.phoneNumber == null
                        ? null
                        : IconButton(
                            style: ButtonStyle(
                              backgroundColor: MaterialStatePropertyAll(
                                Colors.orange.shade100,
                              ),
                              iconColor: MaterialStatePropertyAll(
                                Colors.orange.shade600,
                              ),
                              padding: MaterialStatePropertyAll(
                                EdgeInsets.all(8.sp),
                              ),
                            ),
                            onPressed: () => UrlLauncherService.openPhoneDialer(
                              phoneNumber: restaurant.phoneNumber,
                            ),
                            icon: const Icon(
                              Icons.smartphone,
                            ),
                          ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Future<Restaurant> getRestaurantInfo() async {
    int? restaurantId =
        SharedPreferencesService.instance.getInt('restaurantId');
    if (restaurantId == null) {
      throw Exception();
    }
    return HttpService.parsedGet(
      endPoint: 'restaurants/$restaurantId/',
      mapper: Restaurant.fromJson,
    );
  }
}
