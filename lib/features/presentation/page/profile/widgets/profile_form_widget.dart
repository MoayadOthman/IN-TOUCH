import 'package:flutter/material.dart';
import '../../../../../consts.dart';

class ProfileFormWidget extends StatelessWidget {
  final TextEditingController? controller;
  final String? title;
  const ProfileFormWidget({Key? key, this.title, this.controller}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          sizeVer(10),
          Container(
            decoration: BoxDecoration(
              color: primaryColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: TextFormField(
              maxLines: 5,
              controller: controller,
              style: TextStyle(color: primaryColor),
              decoration: InputDecoration(
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                border: InputBorder.none,
                hintText: "$title",
                labelStyle: TextStyle(color: Colors.white),
              ),
            ),
          ),
          Container(
            width: double.infinity,
            height: 1,
            color: secondaryColor,
          )
        ],
      ),
    );
  }
}
