// import 'dart:async';
// import 'dart:convert';
// import 'dart:io';
// import 'package:flutter/cupertino.dart';
// import 'package:font_awesome_flutter/font_awesome_flutter.dart';
// import 'package:intl/intl.dart' as MyDate;
// import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
// import 'package:moi/common/firebase_services.dart';
// import 'package:provider/provider.dart';
// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:timeago/timeago.dart' as timeago;
// import 'package:flutter/material.dart';
// import 'package:moi/new_chat/chat.dart';
// import 'package:moi/const.dart';
// import 'package:moi/new_chat/settings.dart';
// import 'package:http/http.dart' as http;
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:moi/models/theme_model.dart';

// import 'package:moi/main.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// class ChatContacts extends StatefulWidget {
//   final String currentUserId;
//   final ThemeModel? model;
//   final BuildContext context;

//   ChatContacts({
//     Key? key,
//     required this.currentUserId,
//     this.model,
//     required this.context,
//   }) : super(key: key);

//   @override
//   State<ChatContacts> createState() => ChatContactsState();
// }

// class ChatContactsState extends State<ChatContacts> {
//   late final String currentUserId;
//   late final ThemeModel mymodel;
//   late final BuildContext context;

//   bool isLoading = false;
//   final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
//       FlutterLocalNotificationsPlugin();

//   final String serverToken =
//       'AAAAEoILIxw:APA91bEH3z_PoP20EdeDa-vBnxiwbzjQuBuNHe5upnN9jEcE1rw8bHOEFWTIjSsSD1mxhs2BCx7jPtscE8ZtRCr7V_iAiYbTnOE19CaFIk_va4rYxyj0JA9XkJFn6g0EoPBfk0RXWaHH';

//   @override
//   void initState() {
//     super.initState();
//     currentUserId = widget.currentUserId;
//     context = widget.context;
//     mymodel = widget.model!;

//     configLocalNotification();
//     createUser();
//   }

//   void configLocalNotification() {
//     var initializationSettingsAndroid =
//         AndroidInitializationSettings('launch_background');
//     var initializationSettings =
//         InitializationSettings(android: initializationSettingsAndroid);
//     flutterLocalNotificationsPlugin.initialize(initializationSettings);
//   }

//   Future<void> createUser() async {
//     setState(() {
//       isLoading = true;
//     });

//     final SharedPreferences prefs = await SharedPreferences.getInstance();
//     final QuerySnapshot result = await FirebaseFirestore.instance
//         .collection('users')
//         .where('id', isEqualTo: currentUserId)
//         .get();
//     final List<DocumentSnapshot> documents = result.docs;

//     if (documents.isEmpty) {
//       // Update data to server if new user
//       await FirebaseFirestore.instance
//           .collection('users')
//           .doc(currentUserId)
//           .set({
//         'nickname': prefs.getString('username') ??
//             FirebaseServices().auth.currentUser!.phoneNumber,
//         'photoUrl': '',
//         'status': 'Hi I am using Hearme',
//         'groups': [],
//         'id': currentUserId,
//         'active': true,
//         'createdAt': DateTime.now().millisecondsSinceEpoch.toString(),
//         'chattingWith': null,
//       });

//       // Write data to local
//       await prefs.setString('id', currentUserId);
//       await prefs.setString('photoUrl', '');
//     } else {
//       // Write data to local
//       await prefs.setString('id', documents[0].id);
//     }

//     setState(() {
//       isLoading = false;
//     });
//   }

//   Future<void> showNotification(Map<String, dynamic> message) async {
//     // var androidPlatformChannelSpecifics = AndroidNotificationDetails(
//     //   'com.example.yourapp', // Use your app's package name
//     //   'Your App Name',
//     //   importance: Importance.max,
//     //   priority: Priority.high,
//     //   icon: 'launch_background',
//     //   largeIcon: DrawableResourceAndroidBitmap('launch_background'),
//     // );

//     // var platformChannelSpecifics =
//     //     NotificationDetails(android: androidPlatformChannelSpecifics);
//     // if (widget.model!.notification) {
//     //   await flutterLocalNotificationsPlugin.show(
//     //     0,
//     //     message['title'].toString(),
//     //     message['body'].toString(),
//     //     platformChannelSpecifics,
//     //     payload: json.encode(message),
//     //   );
//     // } else {
//     //   await flutterLocalNotificationsPlugin.cancelAll();
//     }
//   }

//   Future<bool> onBackPress() async {
//     openDialog();
//     return Future.value(false);
//   }

//   Future<void> openDialog() async {
//     final result = await showDialog<int>(
//       context: context,
//       builder: (BuildContext context) {
//         return SimpleDialog(
//           contentPadding: EdgeInsets.all(0.0),
//           children: <Widget>[
//             Container(
//               color: themeColor,
//               padding: EdgeInsets.symmetric(vertical: 10.0),
//               height: 100.0,
//               child: Column(
//                 children: <Widget>[
//                   Icon(Icons.exit_to_app, size: 30.0, color: Colors.white),
//                   Text('Exit app',
//                       style: TextStyle(
//                           color: Colors.white,
//                           fontSize: 18.0,
//                           fontWeight: FontWeight.bold)),
//                   Text('Are you sure to exit app?',
//                       style: TextStyle(color: Colors.white70, fontSize: 14.0)),
//                 ],
//               ),
//             ),
//             SimpleDialogOption(
//               onPressed: () => Navigator.pop(context, 0),
//               child: Row(
//                 children: <Widget>[
//                   Icon(Icons.cancel, color: primaryColor),
//                   SizedBox(width: 10.0),
//                   Text('CANCEL',
//                       style: TextStyle(
//                           color: primaryColor, fontWeight: FontWeight.bold)),
//                 ],
//               ),
//             ),
//             SimpleDialogOption(
//               onPressed: () => Navigator.pop(context, 1),
//               child: Row(
//                 children: <Widget>[
//                   Icon(Icons.check_circle, color: primaryColor),
//                   SizedBox(width: 10.0),
//                   Text('YES',
//                       style: TextStyle(
//                           color: primaryColor, fontWeight: FontWeight.bold)),
//                 ],
//               ),
//             ),
//           ],
//         );
//       },
//     );

//     if (result == 1) {
//       Navigator.of(context).pushNamed('login');
//     }
//   }

//   Future<void> handleSignOut() async {
//     Navigator.of(context).pushAndRemoveUntil(
//       MaterialPageRoute(builder: (context) => MyApp()),
//       (Route<dynamic> route) => false,
//     );
//   }

//   Future<Map<String, dynamic>> unReadMsg(String peerid) async {
//     String groupChatId = currentUserId.hashCode <= peerid.hashCode
//         ? '$currentUserId-$peerid'
//         : '$peerid-$currentUserId';

//     var data = {
//       'unread': 0,
//       'lastMSG': 'Hi, I am using Hearme',
//       'time': '',
//       'lastmsgseen': false
//     };

//     QuerySnapshot unreads = await FirebaseFirestore.instance
//         .collection('messages')
//         .doc(groupChatId)
//         .collection(groupChatId)
//         .where('seen', isEqualTo: false)
//         .limit(20)
//         .get();
//     if (unreads.docs.isNotEmpty) {
//       var last =
//           unreads.docs.where((element) => element['idFrom'] != currentUserId);
//       if (last.isNotEmpty) {
//         data['unread'] = last.length;
//       }
//     }

//     QuerySnapshot lastone = await FirebaseFirestore.instance
//         .collection('messages')
//         .doc(groupChatId)
//         .collection(groupChatId)
//         .orderBy('timestamp', descending: true)
//         .limit(1)
//         .get();
//     if (lastone.docs.isNotEmpty) {
//       data['lastmsgseen'] = lastone.docs[0]['seen'];
//       data['time'] = lastone.docs[0]['timestamp'];
//       if (lastone.docs[0]['type'] == 'image') {
//         data['lastMSG'] = 'Image';
//       } else {
//         data['lastMSG'] = lastone.docs[0]['content'];
//       }
//     }

//     return data;
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: WillPopScope(
//         onWillPop: onBackPress,
//         child: Stack(
//           children: <Widget>[
//             StreamBuilder<QuerySnapshot>(
//               stream:
//                   FirebaseFirestore.instance.collection('users').snapshots(),
//               builder: (context, snapshot) {
//                 if (!snapshot.hasData) {
//                   return Center(
//                     child: Column(
//                       mainAxisSize: MainAxisSize.min,
//                       children: [
//                         Icon(Icons.filter_drama, size: 50, color: Colors.grey),
//                         SizedBox(height: 20),
//                         Text('Loading...',
//                             style: TextStyle(color: Colors.grey, fontSize: 16)),
//                       ],
//                     ),
//                   );
//                 }
//                 if (snapshot.hasError) {
//                   return Center(child: Text('Error: ${snapshot.error}'));
//                 }

//                 return ListView.builder(
//                   itemCount: snapshot.data!.docs.length,
//                   itemBuilder: (context, index) {
//                     final user = snapshot.data!.docs[index];
//                     if (user['id'] == currentUserId) return SizedBox.shrink();

//                     return FutureBuilder<Map<String, dynamic>>(
//                       future: unReadMsg(user['id']),
//                       builder: (context, futureSnapshot) {
//                         if (!futureSnapshot.hasData) {
//                           return ListTile(
//                             title: Text(user['nickname']),
//                             subtitle: Text('Loading...'),
//                           );
//                         }

//                         final unreadData = futureSnapshot.data!;
//                         return ListTile(
//                           leading: CircleAvatar(
//                             backgroundImage: user['photoUrl'] == ''
//                                 ? AssetImage('assets/images/avatar_default.png')
//                                 : CachedNetworkImageProvider(user['photoUrl'])
//                                     as ImageProvider,
//                           ),
//                           title: Text(user['nickname']),
//                           subtitle: Text(unreadData['lastMSG']),
//                           trailing: unreadData['unread'] > 0
//                               ? CircleAvatar(
//                                   backgroundColor: Colors.red,
//                                   radius: 10,
//                                   child: Text(
//                                     unreadData['unread'].toString(),
//                                     style: TextStyle(
//                                         color: Colors.white, fontSize: 12),
//                                   ),
//                                 )
//                               : null,
//                           onTap: () {
//                             // Navigator.push(
//                             //  // context,
//                             //   // MaterialPageRoute(
//                             //   //   builder: (context) => Chat(
//                             //   //     peerId: user['id'],
//                             //   //     peerName: user['nickname'],
//                             //   //     peerAvatar: user['photoUrl'],
//                             //   //   ),
//                             //   // ),
//                             // );
//                           },
//                         );
//                       },
//                     );
//                   },
//                 );
//               },
//             ),
//             if (isLoading)
//               Center(
//                 child: CircularProgressIndicator(),
//               ),
//           ],
//         ),
//       ),
//     );
//   }
// }
