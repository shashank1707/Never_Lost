
import 'package:flutter/material.dart';
import 'package:never_lost/constants.dart';

class Loading extends StatelessWidget {
  const Loading({ Key? key }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: backgroundColor2,
      body: Center(child: CircularProgressIndicator(color: backgroundColor1,)),
    );
  }
}