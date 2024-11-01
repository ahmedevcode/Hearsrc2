// import 'dart:async';
// import 'dart:convert';
// import 'dart:io';

// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
// import 'package:moi/new_chat/settings.dart';
// import 'package:provider/provider.dart';
// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:timeago/timeago.dart' as timeago;
// import 'package:flutter/material.dart';
// import 'package:moi/new_chat/chat.dart';
// import 'package:moi/const.dart';
// import 'package:moi/models/theme_model.dart';

// import 'package:moi/main.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// class ActiveUsers extends StatefulWidget {
//   final String currentUserId;
//   final ThemeModel model;
//   final BuildContext context;

//   ActiveUsers({
//     Key? key,
//     required this.currentUserId,
//     required this.model,
//     required this.context,
//   }) : super(key: key);

//   @override
//   State createState() => ActiveUsersState();
// }

// class ActiveUsersState extends State<ActiveUsers> {
//   late final String currentUserId;
//   late final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
//   late final ThemeModel mymodel;
//   bool isLoading = false;
//   late Stream<QuerySnapshot> unread;

//   @override
//   void initState() {
//     super.initState();
//     currentUserId = widget.currentUserId;
//     flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
//     configLocalNotification();
//     init();
//   }

//   void configLocalNotification() {
//     final initializationSettingsAndroid =
//         AndroidInitializationSettings('launch_background');
//     final initializationSettings = InitializationSettings(
//       android: initializationSettingsAndroid,
//     );
//     flutterLocalNotificationsPlugin.initialize(initializationSettings);
//   }

//   Future<void> init() async {
//     mymodel = await Provider.of<ThemeModel>(context, listen: false);
//     unread = FirebaseFirestore.instance.collection('users').snapshots();
//     setState(() {});
//   }

//   void onItemMenuPress(Choice choice) {
//     if (choice.title == 'Log out') {
//       handleSignOut();
//     } else if (widget.model != null && widget.context != null) {
//       Navigator.push(
//         context,
//         MaterialPageRoute(
//           builder: (context) => SettingsScreen(
//             model: widget.model,
//             context: widget.context,
//           ),
//         ),
//       );
//     }
//   }

//   Future<void> scheduleNotification() async {
//     final scheduledNotificationDateTime =
//         DateTime.now().add(Duration(seconds: 5));
//     final androidPlatformChannelSpecifics = AndroidNotificationDetails(
//       'channel id',
//       'channel name',
//       icon: 'launch_background',
//       largeIcon: DrawableResourceAndroidBitmap('launch_background'),
//     );
//     final platformChannelSpecifics =
//         NotificationDetails(android: androidPlatformChannelSpecifics);
//     await flutterLocalNotificationsPlugin.show(
//       0,
//       'scheduled title',
//       'scheduled body',
//       platformChannelSpecifics,
//       payload:
//           json.encode({'title': 'scheduled title', 'body': 'scheduled body'}),
//     );
//   }

//   void showNotification(Map<String, dynamic> message) async {
//     final androidPlatformChannelSpecifics = AndroidNotificationDetails(
//       Platform.isAndroid
//           ? 'com.dfa.flutterchatdemo'
//           : 'com.duytq.flutterchatdemo',
//       'Flutter chat demo',
//       playSound: true,
//       enableVibration: true,
//       importance: Importance.max,
//       priority: Priority.high,
//       icon: 'launch_background',
//       largeIcon: DrawableResourceAndroidBitmap('launch_background'),
//     );
//     final platformChannelSpecifics =
//         NotificationDetails(android: androidPlatformChannelSpecifics);
//     if (widget.model.notification) {
//       await flutterLocalNotificationsPlugin.show(
//         0,
//         message['title'] ?? 'No Title',
//         message['body'] ?? 'No Body',
//         platformChannelSpecifics,
//         payload: json.encode(message),
//       );
//     } else {
//       await flutterLocalNotificationsPlugin.cancelAll();
//     }
//   }

//   Future<bool> onBackPress() {
//     openDialog();
//     return Future.value(false);
//   }

//   Future<void> openDialog() async {
//     final result = await showDialog<int>(
//       context: context,
//       builder: (BuildContext context) {
//         return SimpleDialog(
//           contentPadding: EdgeInsets.zero,
//           children: <Widget>[
//             Container(
//               color: themeColor,
//               padding: EdgeInsets.only(bottom: 10.0, top: 10.0),
//               height: 100.0,
//               child: Column(
//                 children: <Widget>[
//                   Icon(
//                     Icons.exit_to_app,
//                     size: 30.0,
//                     color: Colors.white,
//                   ),
//                   Text(
//                     'Exit app',
//                     style: TextStyle(
//                       color: Colors.white,
//                       fontSize: 18.0,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                   Text(
//                     'Are you sure you want to exit the app?',
//                     style: TextStyle(
//                       color: Colors.white70,
//                       fontSize: 14.0,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             SimpleDialogOption(
//               onPressed: () => Navigator.pop(context, 0),
//               child: Row(
//                 children: <Widget>[
//                   Icon(Icons.cancel, color: primaryColor),
//                   SizedBox(width: 10.0),
//                   Text(
//                     'CANCEL',
//                     style: TextStyle(
//                         color: primaryColor, fontWeight: FontWeight.bold),
//                   ),
//                 ],
//               ),
//             ),
//             SimpleDialogOption(
//               onPressed: () => Navigator.pop(context, 1),
//               child: Row(
//                 children: <Widget>[
//                   Icon(Icons.check_circle, color: primaryColor),
//                   SizedBox(width: 10.0),
//                   Text(
//                     'YES',
//                     style: TextStyle(
//                         color: primaryColor, fontWeight: FontWeight.bold),
//                   ),
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
//     final groupChatId = currentUserId.hashCode <= peerid.hashCode
//         ? '$currentUserId-$peerid'
//         : '$peerid-$currentUserId';
//     final unreads = await FirebaseFirestore.instance
//         .collection('messages')
//         .doc(groupChatId)
//         .collection(groupChatId)
//         .where('seen', isEqualTo: false)
//         .limit(20)
//         .get();
//     final last =
//         unreads.docs.where((element) => element['idFrom'] != currentUserId);
//     final data = {
//       'unread': last.length,
//       'lastMSG': '',
//       'time': '',
//       'lastmsgseen': false
//     };
//     final lastone = await FirebaseFirestore.instance
//         .collection('messages')
//         .doc(groupChatId)
//         .collection(groupChatId)
//         .orderBy('timestamp', descending: true)
//         .limit(1)
//         .get();
//     if (lastone.docs.isNotEmpty) {
//       final lastMessage = lastone.docs[0];
//       data['lastmsgseen'] = lastMessage['seen'];
//       data['time'] = lastMessage['timestamp'];
//       data['lastMSG'] =
//           lastMessage['type'] == 0 ? lastMessage['content'] : 'Media msg';
//     }
//     return data;
//   }

//   Widget buildItem(
//       BuildContext context, DocumentSnapshot document, ThemeModel model) {
//     if (document.data() == currentUserId) {
//       return Container();
//     }
//     return FutureBuilder<Map<String, dynamic>>(
//       future: unReadMsg(document.id),
//       builder: (context, snapshot) {
//         if (!snapshot.hasData) {
//           return Container();
//         }
//         final data = snapshot.data!;

//         return ElevatedButton(
//           child: Row(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             textDirection: mymodel.appLocal == Locale('ar')
//                 ? TextDirection.rtl
//                 : TextDirection.ltr,
//             children: <Widget>[
//               Stack(
//                 children: [
//                   Positioned(
//                     bottom: 2,
//                     right: 5,
//                     child: Container(
//                       width: 11,
//                       height: 11,
//                       decoration: BoxDecoration(
//                         shape: BoxShape.circle,
//                         color: Colors.green,
//                       ),
//                     ),
//                   ),
//                   Padding(
//                     padding: const EdgeInsets.symmetric(vertical: 8.0),
//                     child: Material(
//                       borderRadius: BorderRadius.circular(25.0),
//                       clipBehavior: Clip.hardEdge,
//                       child: document.data() != null
//                           ? CachedNetworkImage(
//                               placeholder: (context, url) => Container(
//                                 child: CircularProgressIndicator(
//                                   strokeWidth: 1.0,
//                                   valueColor:
//                                       AlwaysStoppedAnimation<Color>(themeColor),
//                                 ),
//                                 width: 50.0,
//                                 height: 50.0,
//                                 padding: EdgeInsets.all(15.0),
//                               ),
//                               imageUrl: '',
//                               errorWidget: (context, url, error) => Material(
//                                 child: Image.asset(
//                                   'assets/profile.png',
//                                   width: 40.0,
//                                   height: 40.0,
//                                   fit: BoxFit.cover,
//                                 ),
//                                 borderRadius: BorderRadius.circular(20.0),
//                                 clipBehavior: Clip.hardEdge,
//                               ),
//                               width: 50.0,
//                               height: 50.0,
//                               fit: BoxFit.cover,
//                             )
//                           : Material(
//                               child: Image.asset(
//                                 'assets/profile.png',
//                                 width: 50.0,
//                                 height: 50.0,
//                                 fit: BoxFit.cover,
//                               ),
//                               borderRadius: BorderRadius.circular(20.0),
//                               clipBehavior: Clip.hardEdge,
//                             ),
//                     ),
//                   ),
//                 ],
//               ),
//               Expanded(
//                 child: Padding(
//                   padding: const EdgeInsets.symmetric(vertical: 10.0),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: <Widget>[
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         children: <Widget>[
//                           Text(
//                             document.id ?? 'Unknown',
//                             style: TextStyle(
//                               color: Colors.black,
//                               fontWeight: FontWeight.bold,
//                               fontSize: 15.0,
//                             ),
//                           ),
//                           if (data['unread'] > 0)
//                             Container(
//                               padding: EdgeInsets.all(5.0),
//                               decoration: BoxDecoration(
//                                 color: Colors.red,
//                                 borderRadius: BorderRadius.circular(10.0),
//                               ),
//                               child: Text(
//                                 '${data['unread']}',
//                                 style: TextStyle(
//                                     color: Colors.white,
//                                     fontWeight: FontWeight.bold),
//                               ),
//                             ),
//                         ],
//                       ),
//                       SizedBox(height: 5.0),
//                       Text(
//                         data['lastMSG'],
//                         overflow: TextOverflow.ellipsis,
//                         style: TextStyle(
//                           color: Colors.black54,
//                           fontSize: 14.0,
//                         ),
//                       ),
//                       SizedBox(height: 5.0),
//                       Text(
//                         timeago.format(DateTime.parse(data['time'])),
//                         style: TextStyle(
//                           color: Colors.black38,
//                           fontSize: 12.0,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ],
//           ),
//           onPressed: () {
//             // Navigator.push(
//             //   context,
//             //   MaterialPageRoute(
//             //     builder: (context) => ChatScreen(
//             //       peerId: document.id,
//             //       peerName: document.id,
//             //       peerAvatar: document.id,
//             //     ),
//             //   ),
//             // );
//           },
//         );
//       },
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return WillPopScope(
//       onWillPop: onBackPress,
//       child: Scaffold(
//         appBar: AppBar(
//           leading: IconButton(
//             icon: Icon(Icons.menu),
//             onPressed: () {
//               Navigator.push(
//                 context,
//                 MaterialPageRoute(
//                   builder: (context) => SettingsScreen(
//                     model: widget.model,
//                     context: widget.context,
//                   ),
//                 ),
//               );
//             },
//           ),
//           title: Text('Active Users'),
//           actions: <Widget>[
//             IconButton(
//               icon: Icon(Icons.notifications),
//               onPressed: scheduleNotification,
//             ),
//             PopupMenuButton<Choice>(
//               onSelected: onItemMenuPress,
//               itemBuilder: (BuildContext context) {
//                 return Choices.choices.map((Choice choice) {
//                   return PopupMenuItem<Choice>(
//                     value: choice,
//                     child: Row(
//                       children: <Widget>[
//                         Icon(choice.icon),
//                         SizedBox(width: 10.0),
//                         Text(choice.title),
//                       ],
//                     ),
//                   );
//                 }).toList();
//               },
//             ),
//           ],
//         ),
//         body: StreamBuilder<QuerySnapshot>(
//           stream: unread,
//           builder: (context, snapshot) {
//             if (!snapshot.hasData) {
//               return Center(child: CircularProgressIndicator());
//             }
//             final docs = snapshot.data!.docs;
//             return ListView(
//               children: docs
//                   .map((doc) => buildItem(context, doc, widget.model))
//                   .toList(),
//             );
//           },
//         ),
//       ),
//     );
//   }
// }

// class Choice {
//   const Choice({required this.title, required this.icon});
//   final String title;
//   final IconData icon;
// }

// class Choices {
//   static const List<Choice> choices = <Choice>[
//     Choice(title: 'Log out', icon: Icons.exit_to_app),
//     Choice(title: 'Settings', icon: Icons.settings),
//   ];
// }
