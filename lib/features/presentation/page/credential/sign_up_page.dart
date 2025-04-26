import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intouch/consts.dart';
import 'package:intouch/features/domain/entities/user/user_entity.dart';
import 'package:intouch/features/presentation/cubit/credentail/credential_cubit.dart';
import 'package:intouch/features/presentation/widgets/button_container_widget.dart';
import 'package:intouch/features/presentation/widgets/form_container_widget.dart';
import 'package:intouch/profile_widget.dart';
import 'package:intouch/injection_container.dart' as di;

class SignUpPage extends StatefulWidget {
  const SignUpPage({Key? key}) : super(key: key);

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  TextEditingController _emailController = TextEditingController();
  TextEditingController _usernameController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  TextEditingController _bioController = TextEditingController();

  bool _isSigningUp = false;
  bool _isUploading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _bioController.dispose();
    _usernameController.dispose();
    super.dispose();
  }

  File? _image;

  Future selectImage() async {
    try {
      final pickedFile = await ImagePicker.platform.getImage(source: ImageSource.gallery);

      setState(() {
        if (pickedFile != null) {
          _image = File(pickedFile.path);
        } else {
          print("no image has been selected");
        }
      });
    } catch (e) {
      toast("some error occured $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: backGroundColor,
        body: BlocConsumer<CredentialCubit, CredentialState>(
          listener: (context, credentialState) {
            if (credentialState is CredentialSuccess) {
              // After successful sign up, navigate to login page
              toast("Account created successfully! Please check your email to verify your account.");
              Navigator.pushNamedAndRemoveUntil(
                context,
                PageConst.signInPage,
                    (route) => false,
              );
            }
            if (credentialState is CredentialFailure) {
              // Handle failure
              toast("Error: Unable to sign up. Please try again later.");
            }
          },
          builder: (context, credentialState) {
            if (credentialState is CredentialLoading) {
              return _bodyWidget();
            }
            return _bodyWidget();
          },
        ));
  }

  _bodyWidget() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Flexible(child: Container(), flex: 2),
            sizeVer(15),
            Center(
              child: Stack(
                children: [
                  Container(
                      width: 60,
                      height: 60,
                      child: ClipRRect(borderRadius: BorderRadius.circular(30), child: profileWidget(image: _image))),
                  Positioned(
                    right: -10,
                    bottom: -15,
                    child: IconButton(
                      onPressed: selectImage,
                      icon: Icon(Icons.add_a_photo, color: blueColor),
                    ),
                  ),
                ],
              ),
            ),
            sizeVer(30),
            FormContainerWidget(
              controller: _usernameController,
              hintText: "Username",
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return "Username is required";
                }
                return null;
              },
            ),
            sizeVer(15),
            FormContainerWidget(
              controller: _emailController,
              hintText: "Email",
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return "Email is required";
                }
                if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                  return "Please enter a valid email address";
                }
                return null;
              },
            ),
            sizeVer(15),
            FormContainerWidget(
              controller: _passwordController,
              hintText: "Password",
              isPasswordField: true,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return "Password is required";
                }
                if (value.length < 6) {
                  return "Password must be at least 6 characters long";
                }
                return null;
              },
            ),
            sizeVer(15),
            FormContainerWidget(
              controller: _bioController,
              hintText: "Bio",
            ),
            sizeVer(15),
            ButtonContainerWidget(
              color: blueColor,
              text: "Sign Up",
              onTapListener: () {
                if (_formKey.currentState!.validate()) {
                  _signUpUser();
                }
              },
            ),
            sizeVer(10),
            _isSigningUp == true || _isUploading == true
                ? Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Please wait",
                  style: TextStyle(color: primaryColor, fontSize: 16, fontWeight: FontWeight.w400),
                ),
                sizeHor(10),
                CircularProgressIndicator()
              ],
            )
                : Container(width: 0, height: 0),
            Flexible(child: Container(), flex: 2),
            Divider(
              color: secondaryColor,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Already have an account? ",
                  style: TextStyle(color: primaryColor),
                ),
                InkWell(
                  onTap: () {
                    Navigator.pushNamedAndRemoveUntil(context, PageConst.signInPage, (route) => false);
                  },
                  child: Text(
                    "Sign In",
                    style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _signUpUser() async {
    setState(() {
      _isSigningUp = true;
    });

    BlocProvider.of<CredentialCubit>(context).signUpUser(
      user: UserEntity(
        email: _emailController.text,
        password: _passwordController.text,
        bio: _bioController.text,
        username: _usernameController.text,
        totalPosts: 0,
        totalFollowing: 0,
        followers: [],
        totalFollowers: 0,
        website: "",
        following: [],
        name: "",
        imageFile: _image,
      ),
    ).then((value) {
      _clear();
      toast("Please check your email to verify your account.");
    }).catchError((e) {
      toast("Error: $e");
    });
  }

  _clear() {
    setState(() {
      _usernameController.clear();
      _bioController.clear();
      _emailController.clear();
      _passwordController.clear();
      _isSigningUp = false;
    });
  }
}
