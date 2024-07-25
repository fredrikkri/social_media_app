import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:message_app/components/button.dart';
import 'package:message_app/components/text_field.dart';
import 'package:message_app/services/firestore_user.dart';

class RegisterPage extends StatefulWidget {
  final Function()? onTap;
  const RegisterPage({super.key, required this.onTap});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  // text editing controller
  final emailTextController = TextEditingController();
  final passwordTextController = TextEditingController();
  final confirmPasswordTextController = TextEditingController();

  // display a dialog message
  void displayMessage(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(message),
      ),
    );
  }

  // Sign user up method
  void signUp() async {
    // show loading circle
    showDialog(
      context: context,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    if (passwordTextController.text != confirmPasswordTextController.text) {
      // pop loading circle
      Navigator.pop(context);
      // show error to user
      displayMessage("Passwords don't match");
      return;
    }

    // try creating the user
    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailTextController.text,
        password: passwordTextController.text,
      );
      FirestoreUserService().addUser();
      // pop loading circle
      if (context.mounted) Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      Navigator.pop(context);
      //show error to user
      displayMessage(e.code);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                //Logo
                const Icon(
                  Icons.lock,
                  size: 100,
                ),

                const SizedBox(
                  height: 50,
                ),

                // Welcome back message
                Text(
                  "Lets create an account for you.",
                  style: TextStyle(color: Colors.grey[700]),
                ),

                const SizedBox(
                  height: 25,
                ),

                // email text field
                MyTextField(
                    controller: emailTextController,
                    hintText: "Email",
                    obscureText: false),

                const SizedBox(
                  height: 10,
                ),

                // password textfield
                MyTextField(
                    controller: passwordTextController,
                    hintText: "Password",
                    obscureText: true),

                const SizedBox(
                  height: 10,
                ),

                // confirm password textfield
                MyTextField(
                    controller: confirmPasswordTextController,
                    hintText: "Confirm Password",
                    obscureText: true),

                const SizedBox(
                  height: 25,
                ),

                // sign up button
                MyButton(
                  onTap: signUp,
                  text: "Sign Up",
                ),

                const SizedBox(
                  height: 25,
                ),

                // go to registrer page
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Already have an account?",
                      style: TextStyle(color: Colors.grey[700]),
                    ),
                    const SizedBox(width: 4),
                    GestureDetector(
                      onTap: widget.onTap,
                      child: const Text(
                        "Login now",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
