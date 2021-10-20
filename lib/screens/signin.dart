import 'package:flutter/material.dart';
import 'package:never_lost/firebase/auth.dart';

class Signin extends StatefulWidget {
  const Signin({Key? key}) : super(key: key);

  @override
  _SigninState createState() => _SigninState();
}

class _SigninState extends State<Signin> {
  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    return Scaffold(
        body: Column(
          // mainAxisAlignment: MainAxisAlignment.center,
          // crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(height: 64,),
        const Text('NeverLost',
            style: TextStyle(
                fontSize: 40,
                color: Color(0xff22577A),
                fontWeight: FontWeight.bold)),
        Image.asset(
          'assets/images/background1.png',
          width: width,
        ),
        const Padding(
          padding: EdgeInsets.all(16.0),
          child: Text('Share live location with your friends', style: TextStyle(color: Color(0xff22577A), fontSize: 20, fontWeight: FontWeight.w400), textAlign: TextAlign.center,),
        ),
        TextButton(onPressed: (){
          AuthMethods().signInWithGoogle();
        }, child: const Text('Sign in with Google', style: TextStyle(color: Color(0xff57CC99), fontSize: 24, fontWeight: FontWeight.bold),))
      ],
    ));
  }
}
