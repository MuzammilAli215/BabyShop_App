
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_eproject/Controllers/auth_controller.dart';

import 'splash_screen.dart';



class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    AuthController authController= AuthController();
    return Scaffold(
      appBar: AppBar(
        title: Text("Home Screen"),
        centerTitle: true,
        actions: [
          IconButton(onPressed: ()async{
            String result =await authController.logoutUser();
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(result)));
            Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context){
              return SplashScreen();
            }), ((route) => false));
          }, icon: Icon(Icons.logout))
        ],
      ),
      body: const Center(
        child: Text(
          "Welcome to Baby Shop",
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
