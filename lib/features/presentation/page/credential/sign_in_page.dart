import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intouch/consts.dart';
import 'package:intouch/features/presentation/cubit/credentail/credential_cubit.dart';
import 'package:intouch/features/presentation/widgets/button_container_widget.dart';
import 'package:intouch/features/presentation/widgets/form_container_widget.dart';
import '../../cubit/auth/auth_cubit.dart';
import '../main_screen/main_screen.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({Key? key}) : super(key: key);

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();

  bool _isSigningIn = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backGroundColor,
      resizeToAvoidBottomInset: true,  // This makes sure the keyboard doesn't overlap content
      body: _bodyWidget(),
    );
  }

  _bodyWidget() {
    return SingleChildScrollView(  // Ensure the content is scrollable when keyboard is visible
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Removed Flexible to avoid unnecessary space constraints
            SizedBox(height: MediaQuery.of(context).size.height * 0.2),  // Use a specific height for spacing

            Center(
                child: Image.asset(
                  "assets/auth/logo.png",
                  color: primaryColor,
                  height: 250,
                )),
            sizeVer(30),
            FormContainerWidget(
              controller: _emailController,
              hintText: "Email",
            ),
            sizeVer(15),
            FormContainerWidget(
              controller: _passwordController,
              hintText: "Password",
              isPasswordField: true,
            ),
            sizeVer(15),
            ButtonContainerWidget(
              color: blueColor,
              text: "Sign In",
              onTapListener: () {
                _signInUser();
              },
            ),
            sizeVer(10),
            _isSigningIn == true
                ? Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Please wait",
                  style: TextStyle(
                      color: primaryColor,
                      fontSize: 16,
                      fontWeight: FontWeight.w400),
                ),
                sizeHor(10),
                CircularProgressIndicator()
              ],
            )
                : Container(
              width: 0,
              height: 0,
            ),

            // SizedBox to ensure proper spacing and avoid flex overflow
            SizedBox(height: MediaQuery.of(context).size.height * 0.19),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Don't have an account? ",
                  style: TextStyle(color: primaryColor),
                ),
                InkWell(
                  onTap: () {
                    Navigator.pushNamedAndRemoveUntil(
                        context, PageConst.signUpPage, (route) => false);
                  },
                  child: Text(
                    "Sign Up",
                    style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  // This function signs in the user and checks if the email is verified
  void _signInUser() async {
     final FirebaseAuth firebaseAuth;

    setState(() {
      _isSigningIn = true;
    });

    try {
      // Attempt to sign in the user
      await BlocProvider.of<CredentialCubit>(context).signInUser(
        email: _emailController.text,
        password: _passwordController.text,
      );
      // Check if the user's email is verified after sign-in
      if (FirebaseAuth.instance.currentUser != null && FirebaseAuth.instance.currentUser!.emailVerified) {
        // Email is verified, navigate to the MainScreen
        toast("Successfully signed in!");

        // Navigate to the MainScreen and remove all previous routes
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) => MainScreen(uid: FirebaseAuth.instance.currentUser!.uid),
          ),
              (route) => false, // Removes all previous routes
        );
      } else {
        // Email is not verified, notify the user
        toast("Please verify your email before logging in.");

        // Optionally send an email verification reminder
        await FirebaseAuth.instance.currentUser?.sendEmailVerification();
      }
    } catch (e) {
      toast("Error: $e");
    } finally {
      setState(() {
        _isSigningIn = false;
      });
    }
  }

  // Clear the form fields
  _clear() {
    setState(() {
      _emailController.clear();
      _passwordController.clear();
      _isSigningIn = false;
    });
  }
}
