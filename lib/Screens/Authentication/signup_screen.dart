
import 'package:flutter/material.dart';
import 'package:flutter_eproject/Controllers/auth_controller.dart';
import 'package:provider/provider.dart';
import 'package:flutter_eproject/Controllers/password_controller.dart';

class SignupScreen extends StatelessWidget {
  SignupScreen({super.key});

  final TextEditingController usernameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue.shade50,

        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.white,
                Color(0xff64B5F6),
              ],
            ),
          ),



      child: Padding(
        padding: const EdgeInsets.all(20),
     child:  Column(
        children: [
          Image.asset(
            'assets/logos/Imagelogo.png',
            width: 150,
            height: 150,
            fit: BoxFit.contain,
          ),
          Text(
            "Create Account",
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.blue,
            ),
          ),
          TextField(
            controller: usernameController,
            decoration: InputDecoration(
              labelText: "Full Name",
              prefixIcon: Icon(Icons.person, color: Colors.blue),
              border: OutlineInputBorder(),
            ),
          ),
          SizedBox(height: 20,),
          TextField(
            controller: emailController,
            decoration: InputDecoration(
              labelText: "Email",
              prefixIcon: Icon(Icons.email, color: Colors.blue),
              border: OutlineInputBorder(),
            ),
          ),
          SizedBox(height: 20,),
          Consumer<PasswordController>(
            builder: (context, controller, child) {
              return TextFormField(
                controller: passwordController,
                obscureText: controller.isVisible,
                decoration: InputDecoration(
                  labelText: "Password",
                  prefixIcon: const Icon(
                    Icons.lock,
                    color: Colors.blue,
                  ),
                  suffixIcon: IconButton(
                    onPressed: () {
                      controller.ChangeVisiblility();
                    },
                    icon: Icon(
                      controller.isVisible
                          ? Icons.visibility_off
                          : Icons.visibility,
                      color: Colors.blue,
                    ),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(
                      color: Colors.blue,
                      width: 2,
                    ),
                  ),
                ),
              );
            },
          ),

          SizedBox(height: 20,),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              final authController = context.read<AuthController>();
              final success = await authController.register(
                usernameController.text,
                emailController.text,
                passwordController.text,
              );

              if (!context.mounted) return;
              if (success) {
                Navigator.pushReplacementNamed(context, '/user-home');
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(authController.error ?? 'Registration failed'),
                  ),
                );
              }
            }, child: const Text("Sign Up"),
          ),
        ],
      ),
      ),
        ),
    );
  }
}
