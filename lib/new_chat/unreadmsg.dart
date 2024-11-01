import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart' as MyDate;
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:flutter/material.dart';
import 'package:moi/new_chat/chat.dart';
import 'package:moi/const.dart';
import 'package:moi/new_chat/settings.dart';
import 'package:http/http.dart' as http;
import 'package:moi/models/theme_model.dart';

import 'package:moi/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UnreadMgs extends StatefulWidget {
  final String currentUserId;
  ThemeModel model;
  final BuildContext context;

  UnreadMgs(
      {Key? key,
      required this.currentUserId,
      required this.model,
      required this.context})
      : super(key: key);

  @override
  State createState() => UnreadMgsState(currentUserId: currentUserId);
}

class UnreadMgsState extends State<UnreadMgs> {
  UnreadMgsState({Key? key, required this.currentUserId});

  final String currentUserId;
  final String serverToken =
      'AAAAEoILIxw:APA91bEH3z_PoP20EdeDa-vBnxiwbzjQuBuNHe5upnN9jEcE1rw8bHOEFWTIjSsSD1mxhs2BCx7jPtscE8ZtRCr7V_iAiYbTnOE19CaFIk_va4rYxyj0JA9XkJFn6g0EoPBfk0RXWaHH';

  ///stop push notification
  // final FirebaseMessaging firebaseMessaging = FirebaseMessaging();
  // final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  //     FlutterLocalNotificationsPlugin();

  //final GoogleSignIn googleSignIn = GoogleSignIn();
  late ThemeModel mymodel;
  bool isLoading = false;
  List<Choice> choices = const <Choice>[
    const Choice(title: 'Profile', icon: Icons.settings),
    const Choice(title: 'Log out', icon: Icons.exit_to_app),
  ];
  late Stream unread;
  Future<Stream> getusers() async {
    return FirebaseFirestore.instance.collection('users').snapshots();
  }

  void init() async {
    mymodel = await Provider.of<ThemeModel>(context, listen: false);
    getusers().then((value) {
      setState(() {
        unread = value;
      });
    });
  }

  @override
  void didChangeDependencies() {
    //print('deps');
    init();
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
  }

  @override
  void initState() {
    init();
    super.initState();

    ///stop push notification
    // registerNotification();
    ////print('noti ${widget.model.notification}');
    configLocalNotification();

    //scheduleNotification();
    //sendAndRetrieveMessage();
  }

  ///stop push notification
  // Future<Map<String, dynamic>> sendAndRetrieveMessage() async {
  //   await firebaseMessaging.requestNotificationPermissions(
  //     const IosNotificationSettings(sound: true, badge: true, alert: true, provisional: false),
  //   );
  //
  //   /*await http.post(
  //     'https://fcm.googleapis.com/fcm/send',
  //     headers: <String, String>{
  //       'Content-Type': 'application/json',
  //       'Authorization': 'key=$serverToken',
  //     },
  //     body: jsonEncode(
  //       <String, dynamic>{
  //         'notification': <String, dynamic>{
  //           'body': 'that is a body',
  //           'title': 'that is a title'
  //         },
  //         'priority': 'high',
  //         'data': <String, dynamic>{
  //           'click_action': 'FLUTTER_NOTIFICATION_CLICK',
  //           'id': '1',
  //           'status': 'done'
  //         },
  //         'to': await firebaseMessaging.getToken(),
  //       },
  //     ),
  //   );*/
  //
  //   final Completer<Map<String, dynamic>> completer =
  //   Completer<Map<String, dynamic>>();
  //
  //   firebaseMessaging.configure(
  //     onMessage: (Map<String, dynamic> message) async {
  //       completer.complete(message);
  //     },
  //   );
  //
  //   return completer.future;
  // }

  ///stop push notification
  // void registerNotification() async{
  //   var check= await firebaseMessaging.requestNotificationPermissions();
  //   //print('check is: $check');
  //
  //   firebaseMessaging.configure(onMessage: (Map<String, dynamic> message) {
  //     //print('onMessage: $message');
  //     Platform.isAndroid
  //         ? showNotification(message['notification'])
  //         : showNotification(message['aps']['alert']);
  //     return;
  //   }, onResume: (Map<String, dynamic> message) {
  //     //print('onResume: $message');
  //     return;
  //   }, onLaunch: (Map<String, dynamic> message) {
  //     //print('onLaunch: $message');
  //     return;
  //   },);
  //
  //   firebaseMessaging.getToken().then((token) {
  //     //print('token: $token');
  //     FirebaseFirestore.instance
  //         .collection('users')
  //         .document(currentUserId)
  //         .updateData({'pushToken': token});
  //   }).catchError((err) {
  //     EdgeAlert.show(context,
  //         title: 'Uh oh!',
  //         description: err.message.toString(),
  //         gravity: EdgeAlert.BOTTOM,
  //         icon: Icons.error,
  //         backgroundColor: Colors.deepPurple[900]);
  //   });
  // }

  void configLocalNotification() {
    // var initializationSettingsAndroid =
    //     new AndroidInitializationSettings('launch_background');
    // // var initializationSettingsIOS = new IOSInitializationSettings();
    // var initializationSettings = new InitializationSettings(
    //   android: initializationSettingsAndroid,
    //   // iOS: initializationSettingsIOS
    // );
    //  flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  void onItemMenuPress(Choice choice) {
    if (choice.title == 'Log out') {
      handleSignOut();
    } else {
      if (widget.model != null && widget.context != null)
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => SettingsScreen(
                      model: widget.model,
                      context: widget.context,
                    )));
    }
  }

  Future<void> scheduleNotification() async {
    // var scheduledNotificationDateTime =
    //     DateTime.now().add(Duration(seconds: 5));
    // var androidPlatformChannelSpecifics = AndroidNotificationDetails(
    //   'channel id',
    //   'channel name',
    //   icon: 'launch_background',
    //   largeIcon: DrawableResourceAndroidBitmap('launch_background'),
    // );
    // //  var iOSPlatformChannelSpecifics = IOSNotificationDetails();
    // var platformChannelSpecifics = NotificationDetails();
    // await flutterLocalNotificationsPlugin.show(
    //   0,
    //   'scheduled title',
    //   'scheduled body',
    //   scheduledNotificationDateTime as NotificationDetails?,
    // );
  }

  void showNotification(message) async {
    // var androidPlatformChannelSpecifics = new AndroidNotificationDetails(
    //   Platform.isAndroid
    //       ? 'com.dfa.flutterchatdemo'
    //       : 'com.duytq.flutterchatdemo',
    //   'Flutter chat demo',
    //   playSound: true,
    //   enableVibration: true,
    //   // importance: Importance.max,
    //   // priority: Priority.high,
    //   // icon: 'launch_background',
    //   // largeIcon: DrawableResourceAndroidBitmap('launch_background'),
    // );
    //var iOSPlatformChannelSpecifics = new IOSNotificationDetails();
    // var platformChannelSpecifics = new NotificationDetails();

//    //print(message['body'].toString());
//    //print(json.encode(message));
    // if (widget.model.notification) {
    //   await flutterLocalNotificationsPlugin.show(0, message['title'].toString(),
    //    //   message['body'].toString(), platformChannelSpecifics,
    //       payload: json.encode(message));
    // } else {
    //   await flutterLocalNotificationsPlugin.cancelAll();
    // }

//    await flutterLocalNotificationsPlugin.show(
//        0, 'plain title', 'plain body', platformChannelSpecifics,
//        payload: 'item x');
  }

  Future<bool> onBackPress() {
    openDialog();
    return Future.value(false);
  }

  Future<Null> openDialog() async {
    switch (await showDialog(
        context: context,
        builder: (BuildContext context) {
          return SimpleDialog(
            contentPadding:
                EdgeInsets.only(left: 0.0, right: 0.0, top: 0.0, bottom: 0.0),
            children: <Widget>[
              Container(
                color: themeColor,
                margin: EdgeInsets.all(0.0),
                padding: EdgeInsets.only(bottom: 10.0, top: 10.0),
                height: 100.0,
                child: Column(
                  children: <Widget>[
                    Container(
                      child: Icon(
                        Icons.exit_to_app,
                        size: 30.0,
                        color: Colors.white,
                      ),
                      margin: EdgeInsets.only(bottom: 10.0),
                    ),
                    Text(
                      'Exit app',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'Are you sure to exit app?',
                      style: TextStyle(color: Colors.white70, fontSize: 14.0),
                    ),
                  ],
                ),
              ),
              SimpleDialogOption(
                onPressed: () {
                  Navigator.pop(context, 0);
                },
                child: Row(
                  children: <Widget>[
                    Container(
                      child: Icon(
                        Icons.cancel,
                        color: primaryColor,
                      ),
                      margin: EdgeInsets.only(right: 10.0),
                    ),
                    Text(
                      'CANCEL',
                      style: TextStyle(
                          color: primaryColor, fontWeight: FontWeight.bold),
                    )
                  ],
                ),
              ),
              SimpleDialogOption(
                onPressed: () {
                  Navigator.pop(context, 1);
                },
                child: Row(
                  children: <Widget>[
                    Container(
                      child: Icon(
                        Icons.check_circle,
                        color: primaryColor,
                      ),
                      margin: EdgeInsets.only(right: 10.0),
                    ),
                    Text(
                      'YES',
                      style: TextStyle(
                          color: primaryColor, fontWeight: FontWeight.bold),
                    )
                  ],
                ),
              ),
            ],
          );
        })) {
      case 0:
        break;
      case 1:
        Navigator.of(context).pushNamed('login');
        break;
    }
  }

  Future<Null> handleSignOut() async {
    Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => MyApp()),
        (Route<dynamic> route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      /* appBar: AppBar(
     backgroundColor: mymodel.primaryMainColor,
      title: Text(
        mymodel.appLocal.languageCode=='ar'?'جهات الاتصال':'Contacts',
        style: TextStyle(color: primaryColor,fontFamily: 'Cairo-Bold' ),
      ),
      centerTitle: true,
       actions: <Widget>[
         IconButton(
           icon: Icon(Icons.account_circle),
           onPressed: () => Navigator.push(
             context, MaterialPageRoute(builder: (context) => SettingsScreen(model: widget.model,context: widget.context,))),
         ),
         // PopupMenuButton<Choice>(
         //   onSelected: onItemMenuPress,
         //   itemBuilder: (BuildContext context) {
         //     return choices.map((Choice choice) {
         //       return PopupMenuItem<Choice>(
         //           value: choice,
         //           child: Row(
         //             children: <Widget>[
         //               Icon(
         //                 choice.icon,
         //                 color: primaryColor,
         //               ),
         //               Container(
         //                 width: 10.0,
         //               ),
         //               Text(
         //                 choice.title,
         //                 style: TextStyle(color: primaryColor),
         //               ),
         //             ],
         //           ));
         //     }).toList();
         //   },
         // ),
       ],
    ),*/
      body: mymodel != null
          ? WillPopScope(
              child: Stack(
                children: <Widget>[
                  // List
                  Container(
                    child: StreamBuilder(
                      stream: unread,
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return Center(
                              child: Column(
                            children: [
                              Icon(
                                Icons.filter_drama,
                                size: 50,
                                color: Colors.grey,
                              ),
                              Text(
                                mymodel.appLocal.languageCode == 'ar'
                                    ? 'جهات الاتصال فارغة'
                                    : 'Empty contacts',
                                style: TextStyle(
                                    fontStyle: FontStyle.italic,
                                    color: Colors.grey,
                                    fontSize: 18),
                              ),
                            ],
                          ));
                        } else {
                          return ListView.builder(
                            padding: EdgeInsets.all(10.0),
                            itemBuilder: (context, index) => buildItem(
                                context, snapshot.data.docs[index], mymodel),
                            itemCount: snapshot.data.docs.length,
                          );
                        }
                      },
                    ),
                  ),

                  // Loading
                  /*  Positioned(
            child: isLoading ? const Loading() : Container(),
          )*/
                ],
              ),
              onWillPop: onBackPress,
            )
          : Container(),
    );
  }

/*Future<String> getLastMSG (String peerid)async{
  if (currentUserId.hashCode <= peerid.hashCode) {
    groupChatId = '$currentUserId-$peerid';
  } else {
    groupChatId = '$peerid-$currentUserId';
  }
  DocumentSnapshot userDocSnapshot= await FirebaseFirestore.instance
      .collection('messages').doc(groupChatId)
      .get();
  List<dynamic> users=userDocSnapshot.get('users');
  if(users.contains(peerid))
  return userDocSnapshot.get('lastMessage')['content'];
  else return '';
}*/
  Future<dynamic> unReadMsg(String peerid) async {
    String groupChatId = '';
    var data = {'unread': 0, 'lastMSG': '', 'time': '', 'lastmsgseen': false};
    if (currentUserId.hashCode <= peerid.hashCode) {
      groupChatId = '$currentUserId-$peerid';
    } else {
      groupChatId = '$peerid-$currentUserId';
    }
    //.where('idFrom',isNotEqualTo: currentUserId)
    QuerySnapshot unreads = await FirebaseFirestore.instance
        .collection('messages')
        .doc(groupChatId)
        .collection(groupChatId)
        .where('seen', isEqualTo: false)
        .limit(20)
        .get();
    var last =
        unreads.docs.where((element) => element['idFrom'] != currentUserId);
    //print('unread msgs ${ last.length}');
    if (last.length > 0) {
      data['unread'] = last.length;
    }
    QuerySnapshot lastone = await FirebaseFirestore.instance
        .collection('messages')
        .doc(groupChatId)
        .collection(groupChatId)
        .orderBy('timestamp', descending: true)
        .limit(1)
        .get();
    //print('last msg ${ lastone.docs[0]['content']}');
    if (lastone?.docs[0]['content'] != null ?? false) {
      data['lastmsgseen'] = lastone.docs[0]['seen'];
      data['time'] = lastone.docs[0]['timestamp'];
      if (lastone.docs[0]['type'] == 0)
        data['lastMSG'] = lastone.docs[0]['content'];
      else
        data['lastMSG'] = 'Media msg';
    }

    return data;
  }

  Widget buildItem(
      BuildContext context, DocumentSnapshot document, ThemeModel model) {
    String lastmsg;
    if (document.id == currentUserId) {
      return Container();
    } else {
      //unReadMsg(document.data()['id']);

      return FutureBuilder(
          future: unReadMsg(document.id),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              //print('Unread ${snapshot?.data['unread']}');
              if (snapshot?.data['unread'] > 0 ?? false)
                return Container(
                  child: ElevatedButton(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      textDirection: mymodel.appLocal == Locale('ar')
                          ? TextDirection.rtl
                          : TextDirection.ltr,
                      children: <Widget>[
                        Stack(
                          children: [
                            Positioned(
                                bottom: 2,
                                right: 5,
                                child: Container(
                                  width: 11,
                                  height: 11,
                                  decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.green),
                                )),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 4.0),
                              child: Material(
                                child: (document.id.isNotEmpty)
                                    ? CachedNetworkImage(
                                        placeholder: (context, url) =>
                                            Container(
                                          child: CircularProgressIndicator(
                                            strokeWidth: 1.0,
                                            valueColor:
                                                AlwaysStoppedAnimation<Color>(
                                                    themeColor),
                                          ),
                                          width: 50.0,
                                          height: 50.0,
                                          padding: EdgeInsets.all(15.0),
                                        ),
                                        imageUrl: document.id,
                                        errorWidget: (context, url, error) =>
                                            Material(
                                          child: Image.asset(
                                            'assets/profile.png',
                                            width: 40.0,
                                            height: 40.0,
                                            fit: BoxFit.cover,
                                          ),
                                          borderRadius: BorderRadius.all(
                                            Radius.circular(20.0),
                                          ),
                                          clipBehavior: Clip.hardEdge,
                                        ),
                                        width: 50.0,
                                        height: 50.0,
                                        fit: BoxFit.cover,
                                      )
                                    : Icon(
                                        Icons.account_circle,
                                        size: 55.0,
                                        color: greyColor,
                                      ),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(25.0)),
                                clipBehavior: Clip.hardEdge,
                              ),
                            ),
                          ],
                        ),
                        Flexible(
                          child: Container(
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Container(
                                          child: Text(
                                            ' ${document}',
                                            style: TextStyle(
                                                color: primaryColor,
                                                fontSize: 16),
                                          ),
                                          alignment: Alignment.centerLeft,
                                          margin: EdgeInsets.fromLTRB(
                                              10.0, 0.0, 0.0, 5.0),
                                        ),
                                        Row(
                                          children: [
                                            Icon(MdiIcons.checkAll,
                                                size: 20,
                                                color: snapshot
                                                        ?.data['lastmsgseen']
                                                    ? Colors.green
                                                    : Colors.grey),
                                            Container(
                                              // margin:EdgeInsets.only(top: 5),
                                              child: Text(
                                                snapshot?.data['lastMSG'] ?? '',
                                                style: TextStyle(
                                                    color: Colors.black54),
                                              ),

                                              alignment: Alignment.centerLeft,
                                              margin: EdgeInsets.fromLTRB(
                                                  10.0, 0.0, 0.0, 0.0),
                                            ),
                                          ],
                                        ),
                                        /*Container(
                                    child: Text(
                                      document.data()['active']?'online':'offline',
                                      style: TextStyle(color: primaryColor),
                                    ),
                                    alignment: Alignment.centerLeft,
                                    margin: EdgeInsets.fromLTRB(10.0, 0.0, 0.0, 0.0),
                                  ),*/
                                      ],
                                    ),
                                    Column(
                                      children: [
                                        snapshot?.data['time'] != ''
                                            ? Text(
                                                timeago.format(
                                                    DateTime
                                                        .fromMillisecondsSinceEpoch(
                                                            int.parse(
                                                                snapshot?.data[
                                                                    'time'])),
                                                    locale: 'en_short'),
                                                style: TextStyle(
                                                    color: greyColor,
                                                    fontSize: 14.0,
                                                    fontStyle:
                                                        FontStyle.italic),
                                              )
                                            : Container(),
                                        snapshot?.data['unread'] > 0
                                            ? Container(
                                                margin: EdgeInsets.symmetric(
                                                    vertical: 4),
                                                width: 25,
                                                height: 25,
                                                decoration: BoxDecoration(
                                                    shape: BoxShape.circle,
                                                    color: Colors.blue),
                                                child: Center(
                                                  child: Text(
                                                    '${snapshot?.data['unread']}' ??
                                                        '',
                                                    style: TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 14.0,
                                                        fontStyle:
                                                            FontStyle.italic),
                                                  ),
                                                ),
                                              )
                                            : Container(),
                                      ],
                                    ),
                                  ],
                                ),
                                Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 10),
                                  child: Divider(
                                    thickness: 1.50,
                                  ),
                                )
                              ],
                            ),
                            margin: EdgeInsets.only(left: 20.0),
                          ),
                        ),
                      ],
                    ),
                    onPressed: () {
                      clearNotify();
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => Chat(
                                    peerId: document.id,
                                    // peerAvatar: document.data['photoUrl'],
                                    peerAvatar: document.id,
                                    nickName: document.id,
                                    active: document.exists,
                                    model: model,
                                  )));
                    },
                    // color: greyColor2,
                    // padding: EdgeInsets.fromLTRB(25.0, 10.0, 25.0, 10.0),
                    // shape:
                    // RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
                  ),
                  margin: EdgeInsets.only(bottom: 10.0, left: 5.0, right: 5.0),
                );
              else
                return Container();
            } else
              return Container();
          });
    }
  }

  void clearNotify() async {
    // await flutterLocalNotificationsPlugin.cancelAll();
  }
}

class Choice {
  const Choice({required this.title, required this.icon});

  final String title;
  final IconData icon;
}
