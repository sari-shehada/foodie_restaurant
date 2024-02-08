import 'dart:io';

import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:foodie_restaurant/core/services/http_service.dart';
import 'package:foodie_restaurant/core/services/shared_prefs_service.dart';
import 'package:foodie_restaurant/core/services/snackbar_service.dart';
import 'package:foodie_restaurant/core/widgets/custom_future_builder.dart';
import 'package:foodie_restaurant/pages/add_meal_page/models/add_meal_form.dart';
import 'package:foodie_restaurant/pages/restaurant_meals_page/models/meal_category.dart';
import 'package:path/path.dart';

class AddMealPage extends StatefulWidget {
  const AddMealPage({super.key});

  @override
  State<AddMealPage> createState() => _AddMealPageState();
}

class _AddMealPageState extends State<AddMealPage> {
  final TextEditingController mealNameController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController mealIngredientsController =
      TextEditingController();
  MealCategory? category;
  File? image;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text(
          'Add Meal',
        ),
      ),
      body: ListView(
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
        children: [
          Container(
            margin: const EdgeInsets.only(bottom: 10.0),
            padding: const EdgeInsets.only(left: 20.0, right: 20.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(25.0),
            ),
            child: TextFormField(
              controller: mealNameController,
              decoration: const InputDecoration(
                hintText: "Name",
                border: InputBorder.none,
              ),
            ),
          ),
          Container(
            margin: const EdgeInsets.only(bottom: 10.0),
            padding: const EdgeInsets.only(left: 20.0, right: 20.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(25.0),
            ),
            child: TextFormField(
              keyboardType: TextInputType.number,
              controller: priceController,
              decoration: const InputDecoration(
                hintText: "Price",
                border: InputBorder.none,
              ),
            ),
          ),
          Container(
            margin: const EdgeInsets.only(bottom: 10.0),
            padding: const EdgeInsets.only(left: 20.0, right: 20.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(25.0),
            ),
            child: TextFormField(
              controller: mealIngredientsController,
              decoration: const InputDecoration(
                hintText: "Ingredients",
                border: InputBorder.none,
              ),
            ),
          ),
          category == null
              ? ElevatedButton(
                  onPressed: () => selectMealCategory(context),
                  child: const Text('Select Meal Category'),
                )
              : ListTile(
                  leading: Image.network(
                    category!.image,
                  ),
                  title: Text(category!.name),
                  trailing: ElevatedButton(
                    onPressed: () => selectMealCategory(context),
                    child: const Text(
                      'Re-Choose',
                    ),
                  ),
                ),
          SizedBox(
            height: 10.h,
          ),
          image == null
              ? ElevatedButton(
                  onPressed: () => selectMealImage(),
                  child: const Text('Select Meal Image'),
                )
              : Column(
                  children: [
                    Image.file(
                      image!,
                      height: 200.sp,
                      width: 200.sp,
                    ),
                    ElevatedButton(
                      onPressed: () => selectMealImage(),
                      child: const Text(
                        'Re-Choose',
                      ),
                    ),
                  ],
                ),
          ElevatedButton(
            onPressed: () => addMeal(context),
            child: const Text(
              'Add Meal',
            ),
          ),
        ],
      ),
    );
  }

  Future<void> selectMealCategory(BuildContext context) async {
    var result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const CategorySelectionPage(),
      ),
    );
    if (result is! MealCategory) return;
    category = result;
    setState(() {});
  }

  Future<void> selectMealImage() async {
    FilePickerResult? filePickerResult = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: false,
    );
    if (filePickerResult == null) {
      return;
    }
    if (filePickerResult.files.isNotEmpty) {
      image = File(filePickerResult.files.first.path!);
      setState(() {});
    }
  }

  String? validateFields() {
    if (mealNameController.text.isEmpty ||
        priceController.text.isEmpty ||
        mealIngredientsController.text.isEmpty) {
      return 'Please fill all fields to continue';
    }
    if (int.tryParse(priceController.text) == null) {
      return 'Please enter a valid price';
    }
    if (category == null) {
      return 'Please select a category for this meal';
    }
    if (image == null) {
      return 'Please select an image for this meal';
    }
    return null;
  }

  Future<void> addMeal(BuildContext context) async {
    String? validationMessage = validateFields();
    if (validationMessage != null) {
      SnackBarService.showErrorSnackbar(validationMessage);
      return;
    }
    try {
      int? restaurantId =
          SharedPreferencesService.instance.getInt('restaurantId');
      if (restaurantId == null) {
        throw Exception();
      }
      AddMealForm form = AddMealForm(
        name: mealNameController.text,
        price: int.parse(priceController.text),
        ingredients: mealIngredientsController.text,
        category: category!.id,
      );

      Response response = await HttpService.dioMultiPartPost(
        endPoint: 'restaurants/$restaurantId/addMeal/',
        formData: FormData.fromMap(
          {
            'image': await MultipartFile.fromFile(
              image!.path,
              filename: basename(image!.path),
            ),
          }..addAll(
              form.toMap(),
            ),
        ),
      );
      if (response.statusCode == 201) {
        SnackBarService.showSuccessSnackbar('Meal added!');
        // ignore: use_build_context_synchronously
        Navigator.pop(context);
      }
    } catch (e) {
      SnackBarService.showErrorSnackbar('Error Occurred');
    }
  }
}

class CategorySelectionPage extends StatefulWidget {
  const CategorySelectionPage({super.key});

  @override
  State<CategorySelectionPage> createState() => _CategorySelectionPageState();
}

class _CategorySelectionPageState extends State<CategorySelectionPage> {
  late Future<List<MealCategory>> categoriesFuture;

  @override
  void initState() {
    categoriesFuture = getCategories();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Select Meal Category',
        ),
      ),
      body: SizedBox.expand(
        child: CustomFutureBuilder(
          future: categoriesFuture,
          builder: (context, categories) {
            return GridView.builder(
              itemCount: categories.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
              ),
              itemBuilder: (context, index) {
                return InkWell(
                  onTap: () => Navigator.pop(
                    context,
                    categories[index],
                  ),
                  child: CategoryCardWidget(
                    category: categories[index],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  Future<List<MealCategory>> getCategories() async {
    return await HttpService.parsedMultiGet(
      endPoint: 'categories/',
      mapper: MealCategory.fromMap,
    );
  }
}

class CategoryCardWidget extends StatelessWidget {
  final MealCategory category;
  const CategoryCardWidget({super.key, required this.category});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Padding(
        padding: const EdgeInsets.all(5.0),
        child: Column(
          children: <Widget>[
            Container(
              height: 100.sp,
              width: 100.sp,
              clipBehavior: Clip.hardEdge,
              padding: const EdgeInsets.all(6.0),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.orange[100],
              ),
              child: CircleAvatar(
                foregroundImage: NetworkImage(
                  category.image,
                ),
              ),
            ),
            Text(
              category.name,
              style: const TextStyle(fontWeight: FontWeight.bold),
            )
          ],
        ),
      ),
    );
  }
}
