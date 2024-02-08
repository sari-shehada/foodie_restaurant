// ignore_for_file: use_build_context_synchronously

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:foodie_restaurant/core/services/http_service.dart';
import 'package:foodie_restaurant/core/services/navigation_service.dart';
import 'package:foodie_restaurant/core/services/shared_prefs_service.dart';
import 'package:foodie_restaurant/core/services/snackbar_service.dart';
import 'package:foodie_restaurant/models/restaurant.dart';
import 'package:foodie_restaurant/pages/loader_page/loader_page.dart';
import 'package:foodie_restaurant/pages/login_page/models/login_form_data.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController userNameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0.0,
      ),
      body: Container(
        margin: const EdgeInsets.all(10.0),
        child: Column(
          children: <Widget>[
            Expanded(
              child: Form(
                child: ListView(
                  children: <Widget>[
                    Container(
                      margin: const EdgeInsets.only(bottom: 35.0),
                      child: const Text(
                        "Log in to your account",
                        style: TextStyle(
                            fontSize: 25.0,
                            color: Colors.orange,
                            fontWeight: FontWeight.bold),
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
                        controller: userNameController,
                        decoration: const InputDecoration(
                          hintText: "Username",
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.only(bottom: 10.0),
                      padding: const EdgeInsets.only(left: 20.0, right: 20.0),
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(25.0)),
                      child: TextFormField(
                        obscureText: true,
                        controller: passwordController,
                        decoration: const InputDecoration(
                          hintText: "Password",
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                    MaterialButton(
                      onPressed: login,
                      child: Container(
                        alignment: Alignment.center,
                        width: MediaQuery.of(context).size.width,
                        margin: const EdgeInsets.only(bottom: 10.0, top: 10.0),
                        padding: EdgeInsets.all(8.sp),
                        decoration: BoxDecoration(
                            color: Colors.orange,
                            borderRadius: BorderRadius.circular(25.0)),
                        child: Text(
                          "log in",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18.0.sp,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String? validateFields() {
    if (userNameController.text.isEmpty || passwordController.text.isEmpty) {
      return 'Please fill all fields to continue';
    }
    return null;
  }

  Future<void> login() async {
    String? validationMessage = validateFields();
    if (validationMessage != null) {
      SnackBarService.showErrorSnackbar(validationMessage);
      return;
    }
    LoginFormData formData = LoginFormData(
      username: userNameController.text,
      password: passwordController.text,
    );
    try {
      String result = await HttpService.rawPost(
        endPoint: 'restaurants/login/',
        body: formData.toMap(),
      );
      var decodedResult = jsonDecode(result);

      if (decodedResult == false) {
        throw Exception();
      }
      Restaurant info = Restaurant.fromMap(decodedResult);
      await SharedPreferencesService.instance.setInt(
        key: 'restaurantId',
        value: info.id,
      );
      NavigationService.pushAndPopAll(
        context,
        const HomePage(),
      );
    } catch (e) {
      SnackBarService.showErrorSnackbar('Invalid Login Credentials!');
    }
  }
}
