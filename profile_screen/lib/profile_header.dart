import 'package:flutter/material.dart';

class ProfileHeader extends StatelessWidget {
  final String name;
  final String university;

  const ProfileHeader({
    super.key,
    required this.name,
    required this.university,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Image.asset(
          'assets/images/profile.jpg',
          width: 150,
          height: 150,
        ),
        Text(
          name,
          style: const TextStyle(
            fontFamily: 'MyFont',
            fontSize: 24,
          ),
        ),
        Text(
          university,
          style: const TextStyle(
            fontFamily: 'MyFont',
            fontSize: 16,
          ),
        ),
      ],
    );
  }
}