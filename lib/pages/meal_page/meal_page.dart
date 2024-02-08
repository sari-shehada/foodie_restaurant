import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:foodie_restaurant/core/services/http_service.dart';
import 'package:foodie_restaurant/core/services/snackbar_service.dart';
import 'package:foodie_restaurant/core/widgets/custom_future_builder.dart';
import 'package:foodie_restaurant/pages/restaurant_meals_page/models/meal.dart';

class MealPage extends StatefulWidget {
  const MealPage({
    super.key,
    required this.mealId,
  });
  final int mealId;
  @override
  State<MealPage> createState() => _MealPageState();
}

class _MealPageState extends State<MealPage> {
  late Future<Meal> futureMeal;
  @override
  void initState() {
    futureMeal = getMealDetails();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Meal Details'),
      ),
      body: CustomFutureBuilder(
        future: futureMeal,
        builder: (context, meal) {
          return MealPageBody(
            meal: meal,
            updatePromotionCallback: () => rateMeal(meal),
          );
        },
      ),
    );
  }

  Future<void> rateMeal(Meal meal) async {
    (bool, int?)? result = await showDialog(
      context: context,
      builder: (context) => MealPromotionUpdateDialog(
        oldPrice: meal.discountedPrice?.toInt(),
      ),
    );
    if (result == null) {
      return;
    }
    if (result.$1 == true) {
      try {
        if (result.$2 == null && meal.discountedPrice != null) {
          var response = await HttpService.rawFullResponsePost(
            endPoint: 'meals/${meal.id}/removePromotion/',
          );
          if (response.statusCode == 200) {
            SnackBarService.showSuccessSnackbar('Promotion Removed');
            futureMeal = getMealDetails();
            setState(() {});
          }
        }
        if (result.$2 != null) {
          if (result.$2! >= meal.price) {
            SnackBarService.showNeutralSnackbar(
              'Promotion price cannot exceed or equal original meal price',
            );
            return;
          }
          var response = await HttpService.rawFullResponsePost(
            endPoint: 'meals/${meal.id}/addPromotion/',
            body: {
              'promotionPrice': result.$2,
            },
          );
          if (response.statusCode == 200) {
            SnackBarService.showSuccessSnackbar(
              'Promotion ${meal.discountedPrice == null ? 'Added' : 'Updated'}',
            );
            futureMeal = getMealDetails();
            setState(() {});
          }
        }
      } catch (e) {
        SnackBarService.showErrorSnackbar('Error Occurred');
      }
    }
  }

  Future<Meal> getMealDetails() async {
    return HttpService.parsedGet(
      endPoint: 'meals/${widget.mealId}/',
      mapper: Meal.fromJson,
    );
  }
}

class MealPromotionUpdateDialog extends StatefulWidget {
  const MealPromotionUpdateDialog({
    super.key,
    this.oldPrice,
  });

  final int? oldPrice;
  @override
  State<MealPromotionUpdateDialog> createState() =>
      _MealPromotionUpdateDialogState();
}

class _MealPromotionUpdateDialogState extends State<MealPromotionUpdateDialog> {
  TextEditingController promotionController = TextEditingController();

  @override
  void initState() {
    promotionController.text = widget.oldPrice?.toString() ?? '';
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        '${widget.oldPrice == null ? 'Add' : 'Update'} or remove promotion',
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            margin: const EdgeInsets.only(bottom: 10.0),
            padding: const EdgeInsets.only(left: 20.0, right: 20.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(25.0),
            ),
            child: TextFormField(
              keyboardType: TextInputType.number,
              controller: promotionController,
              decoration: const InputDecoration(
                hintText: "New Promotion Price",
                border: InputBorder.none,
              ),
            ),
          ),
          SizedBox(
            height: 10.h,
          ),
          Row(
            children: [
              if (widget.oldPrice != null)
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(
                        context,
                        (true, null),
                      );
                    },
                    child: const Text(
                      'Stop Promo',
                    ),
                  ),
                ),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    int? price = int.tryParse(promotionController.text);
                    if (price == null) {
                      SnackBarService.showErrorSnackbar(
                        'Please enter a valid price or tap the remove promotion button',
                      );
                      return;
                    }
                    Navigator.pop(
                      context,
                      (true, price),
                    );
                  },
                  child: Text(
                    '${widget.oldPrice == null ? 'Add' : 'Update'} Promo',
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class MealPageBody extends StatefulWidget {
  const MealPageBody({
    super.key,
    required this.meal,
    required this.updatePromotionCallback,
  });

  final Meal meal;
  final VoidCallback updatePromotionCallback;

  @override
  State<MealPageBody> createState() => _MealPageBodyState();
}

class _MealPageBodyState extends State<MealPageBody> {
  late bool isAddedToCart;
  late int currentItemQty;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: Column(
        children: [
          SizedBox(
            height: MediaQuery.of(context).padding.top,
          ),
          Expanded(
            flex: 45,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: SizedBox.square(
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                        clipBehavior: Clip.hardEdge,
                        child: Image.network(
                          widget.meal.image,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 20.h,
                  ),
                  Text(
                    widget.meal.name,
                    style: TextStyle(
                      fontSize: 19.sp,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  SizedBox(
                    height: 5.h,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.star,
                        color: Colors.orange,
                        size: 27.sp,
                      ),
                      SizedBox(
                        width: 6.w,
                      ),
                      Text(
                        widget.meal.rating.toString(),
                        style: TextStyle(fontSize: 16.sp),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
          Expanded(
            flex: 55,
            child: Column(
              children: [
                Text(widget.meal.ingredients),
                SizedBox(
                  height: 20.h,
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 35.w),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Text(
                            'Price for this meal:',
                            style: TextStyle(fontSize: 16.sp),
                          ),
                          const Spacer(),
                          Text(
                            '${widget.meal.price} SYP',
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.orange,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 5.h,
                      ),
                      Row(
                        children: [
                          Text(
                            'Promotion Price:',
                            style: TextStyle(fontSize: 16.sp),
                          ),
                          const Spacer(),
                          Text(
                            widget.meal.discountedPrice == null
                                ? 'Not on promotion'
                                : '${widget.meal.discountedPrice} SYP',
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.orange,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 5.h,
                      ),
                      ElevatedButton(
                        onPressed: widget.updatePromotionCallback,
                        child: const Text(
                          'Update meal promotion',
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
