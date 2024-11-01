import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:moi/common/firebase_services.dart';

import 'package:moi/pages/login_sms/index.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../const.dart';
import 'floating_action_button_page.dart';

class DrawerContent extends StatefulWidget {
  @override
  _DrawerContentState createState() => _DrawerContentState();
}

class _DrawerContentState extends State<DrawerContent> {
  SharedPreferences? pref;
  String currentuid = '';
  var profiledata;
  String? name, photot, status;
  init() async {
    pref = await SharedPreferences.getInstance();
    currentuid = FirebaseServices().auth.currentUser!.uid; //.get();
//print('hi ${profiledata}');
  }

  @override
  void initState() {
    init();
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: <Widget>[
          Container(
            color: Colors.white,
            child: StreamBuilder(
                stream: FirebaseServices()
                    .firestore
                    .collection('users')
                    .where('id', isEqualTo: currentuid)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasData)
                    return snapshot.data!.docs.length > 0
                        ? Center(
                            child: Column(
                              children: <Widget>[
                                Padding(
                                  padding: const EdgeInsets.only(left: 250),
                                  child: IconButton(
                                      icon:
                                          Image.asset('assets/changeInfo.png'),
                                      onPressed: () {}),
                                ),
                                SizedBox(
                                  height: 6,
                                ),
                                Material(
                                  child: snapshot.data?.docs[0]
                                              ?.data()['photoUrl'] !=
                                          null
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
                                          imageUrl: snapshot.data!.docs[0]
                                              .data()['photoUrl'],
                                          errorWidget: (context, url, error) =>
                                              Material(
                                            child: Icon(
                                              Icons.account_circle_outlined,
                                              size: 50,
                                              color: Colors.blue.shade400,
                                            ),
//                                Image.asset(
//                                  'assets/hossam.jpg',
//                                  width: 50.0,
//                                  height: 50.0,
//                                  fit: BoxFit.cover,
//                                ),
                                            borderRadius: BorderRadius.all(
                                              Radius.circular(25.0),
                                            ),
                                            clipBehavior: Clip.hardEdge,
                                          ),
                                          width: 50.0,
                                          height: 50.0,
                                          fit: BoxFit.cover,
                                        )
                                      : Icon(
                                          Icons.account_circle,
                                          size: 50.0,
                                          color: greyColor,
                                        ),
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(25.0)),
                                  clipBehavior: Clip.hardEdge,
                                ),
                                SizedBox(
                                  height: 6,
                                ),
                                Text(
                                  snapshot.data!.docs[0].data()['nickname'] ??
                                      '',
                                  style: TextStyle(
                                      color: Colors.black, fontSize: 14),
                                ),
                                SizedBox(
                                  height: 6,
                                ),
                                Text(
                                  snapshot.data!.docs[0].data()['aboutMe'] ??
                                      '',
                                  style: TextStyle(
                                      color: Colors.grey.shade600,
                                      fontSize: 14),
                                ),
                                SizedBox(
                                  height: 30,
                                ),
                              ],
                            ),
                          )
                        : Center(
                            child: Column(
                              children: <Widget>[
                                Padding(
                                  padding: const EdgeInsets.only(left: 250),
                                  child: IconButton(
                                      icon:
                                          Image.asset('assets/changeInfo.png'),
                                      onPressed: () {}),
                                ),
                                SizedBox(
                                  height: 6,
                                ),
                                Material(
                                  child: Image.asset(
                                    'assets/hossam.jpg',
                                    width: 50.0,
                                    height: 50.0,
                                    fit: BoxFit.cover,
                                  ),
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(25.0),
                                  ),
                                  clipBehavior: Clip.hardEdge,
                                ),
                                SizedBox(
                                  height: 54,
                                ),
                              ],
                            ),
                          );
                  else
                    return Center(
                      child: Column(
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.only(left: 250),
                            child: IconButton(
                                icon: Image.asset('assets/changeInfo.png'),
                                onPressed: () {}),
                          ),
                          SizedBox(
                            height: 6,
                          ),
                          Material(
                            child: Image.asset(
                              'assets/hossam.jpg',
                              width: 50.0,
                              height: 50.0,
                              fit: BoxFit.cover,
                            ),
                            borderRadius: BorderRadius.all(
                              Radius.circular(25.0),
                            ),
                            clipBehavior: Clip.hardEdge,
                          ),
                          SizedBox(
                            height: 54,
                          ),
                        ],
                      ),
                    );
                }),
          ),
          Expanded(
            child: Container(
              color: Colors.black.withBlue(50),
              child: Padding(
                padding: const EdgeInsets.only(top: 60),
                child: Column(
                  children: <Widget>[
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors
                            .transparent, // Set background color to transparent
                        shadowColor: Colors.transparent, // Remove shadow
                        padding:
                            EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                      ),
                      onPressed: () {},
                      child: Row(
                        children: <Widget>[
                          Image.asset(
                            'assets/group_add.png',
                            height: 29,
                            width: 29,
                          ),
                          SizedBox(width: 30),
                          Text(
                            'New Group',
                            style: TextStyle(color: Colors.white, fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        padding:
                            EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => FloatingActionPage(
                                    model: null,
                                    context: null,
                                  )),
                        );
                      },
                      child: Row(
                        children: <Widget>[
                          Image.asset(
                            'assets/contacts.png',
                            height: 29,
                            width: 29,
                          ),
                          SizedBox(width: 30),
                          Text(
                            'Contact',
                            style: TextStyle(color: Colors.white, fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        padding:
                            EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                      ),
                      onPressed: () {
                        Navigator.pushNamed(context, 'profilesetting');
                      },
                      child: Row(
                        children: <Widget>[
                          Image.asset(
                            'assets/settings.png',
                            height: 29,
                            width: 29,
                          ),
                          SizedBox(width: 30),
                          Text(
                            'Settings',
                            style: TextStyle(color: Colors.white, fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        padding:
                            EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                      ),
                      onPressed: () {},
                      child: Row(
                        children: <Widget>[
                          Image.asset(
                            'assets/help.png',
                            height: 29,
                            width: 29,
                          ),
                          SizedBox(width: 30),
                          Text(
                            'Help',
                            style: TextStyle(color: Colors.white, fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        padding:
                            EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                      ),
                      onPressed: () {},
                      child: Row(
                        children: <Widget>[
                          Image.asset(
                            'assets/aboutUs.png',
                            height: 29,
                            width: 29,
                          ),
                          SizedBox(width: 30),
                          Text(
                            'About Us',
                            style: TextStyle(color: Colors.white, fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        padding:
                            EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                      ),
                      onPressed: () async {
                        await pref?.clear();
                        FirebaseServices().auth.signOut();
                        Navigator.of(context, rootNavigator: true)
                            .pushAndRemoveUntil(
                          MaterialPageRoute(builder: (context) => LoginSMS()),
                          (Route<dynamic> route) => false,
                        );
                      },
                      child: Row(
                        children: <Widget>[
                          Icon(
                            Icons.logout,
                            size: 30,
                            color: Colors.white,
                          ),
                          SizedBox(width: 30),
                          Text(
                            'Log Out',
                            style: TextStyle(color: Colors.white, fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
