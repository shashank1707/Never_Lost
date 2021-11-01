// import 'package:flutter/material.dart';
// import 'package:never_lost/constants.dart';
// import 'package:never_lost/firebase/auth.dart';

// class CustomAppbar extends StatefulWidget {
  
//   final Map user;

//   const CustomAppbar({required this.user, Key? key}) : super(key: key);

//   @override
//   _CustomAppbarState createState() => _CustomAppbarState();
// }

// class _CustomAppbarState extends State<CustomAppbar> {
//   @override
//   Widget build(BuildContext context) {
//     return AppBar(
//       shadowColor: Colors.transparent,
//       backgroundColor: Colors.transparent,
//       title: Container(
//         decoration: BoxDecoration(
//           color: themeColor3.withOpacity(0.03),
//         ),
//         child: TextField(),
//       ),
//       actions: [
//         // if(widget.photoURL != '') CircleAvatar(backgroundImage: NetworkImage(widget.photoURL),)
//         Container(
//           decoration: BoxDecoration(
//             border: Border.all(width: 2, color: themeColor1),
//             borderRadius: BorderRadius.circular(500)
//           ),
//           child: CircleAvatar(
//             backgroundImage: NetworkImage(widget.user['photoURL'], scale: 0.25),
//           ),
//         )
//       ],
//     );
//   }
// }
