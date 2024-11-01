import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:moi/models/theme_model.dart';
import 'package:moi/new_chat/activeusers.dart';
//import 'package:moi/pages/home/home/Drawer.dart';
import 'package:moi/new_chat/groupPage.dart';
import 'package:moi/new_chat/chathome.dart';
import 'package:moi/new_chat/favoriteUser.dart';
import 'package:moi/new_chat/unreadmsg.dart';

class ChatItem extends StatefulWidget {
  final String currentUserId;
  final ThemeModel model;

  const ChatItem({Key? key, required this.currentUserId, required this.model})
      : super(key: key);
  @override
  _ChatItemState createState() => _ChatItemState();
}

class _ChatItemState extends State<ChatItem> {
  List<Color> colorList = [
    Colors.blue,
    Colors.black.withBlue(50),
    Colors.black.withBlue(50),
    Colors.black.withBlue(50),
  ];
  List<Widget> Tabs = [];
  @override
  void initState() {
    Tabs = [
      // ChatContacts(
      //     currentUserId: widget.currentUserId,
      //     model: widget.model,
      //     context: context),
      FavoriteUsers(
          currentUserId: widget.currentUserId,
          model: widget.model,
          context: context),
      UnreadMgs(
          currentUserId: widget.currentUserId,
          model: widget.model,
          context: context),
      GroupsPage()
    ];
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return new DefaultTabController(
      length: Tabs.length,
      child: new Scaffold(
        backgroundColor: Colors.white,
        appBar: new AppBar(
          backgroundColor: Colors.white,
          flexibleSpace: new Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              new TabBar(
                  onTap: (index) {
                    setState(() {
                      colorList[index] = Colors.blue;
                      for (int i = 0; i < 4; i++) {
                        if (i != index) {
                          colorList[i] = Colors.black.withBlue(50);
                        }
                      }
                    });
                  },
                  tabs: <Widget>[
                    Tab(
                      child: Container(
                        child: Center(
                            child: Text('All',
                                style: TextStyle(
                                    fontSize: 16, color: Colors.white))),
                        width: 150,
                        height: 30,
                        decoration: BoxDecoration(
                          color: colorList[0],
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                    ),
                    Tab(
                      child: Container(
                        child: Center(
                            child: Text('Favorite',
                                style: TextStyle(
                                    fontSize: 16, color: Colors.white))),
                        width: 150,
                        height: 30,
                        decoration: BoxDecoration(
                          color: colorList[1],
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                    ),
                    Tab(
                      child: Container(
                        child: Center(
                            child: Text('Unread',
                                style: TextStyle(
                                    fontSize: 16, color: Colors.white))),
                        width: 150,
                        height: 30,
                        decoration: BoxDecoration(
                          color: colorList[2],
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                    ),
                    Tab(
                      child: Container(
                        child: Center(
                            child: Text('Groups',
                                style: TextStyle(
                                    fontSize: 16, color: Colors.white))),
                        width: 150,
                        height: 30,
                        decoration: BoxDecoration(
                          color: colorList[3],
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                    ),
                  ]),
            ],
          ),
        ),
        body: TabBarView(children: Tabs),
      ),
    );
  }
}
