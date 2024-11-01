import 'package:flutter/material.dart';
import 'package:moi/new_chat/groupPage.dart';
import 'package:moi/new_chat/chathome.dart';
import 'package:moi/new_chat/favoriteUser.dart';
import 'package:moi/new_chat/unreadmsg.dart';
import 'package:moi/pages/My%20home/Drawer1.dart';
import 'package:moi/pages/My%20home/bottom_navigaton_bar_active_item.dart';
import 'package:moi/pages/My%20home/chatsNavigationBar.dart';
//import 'package:moi/pages/home/tabsPages/Groups.dart';
//import 'file:///D:/graduation%20project/New%20folder/Hearsrc/lib/pages/home/tabsPages/all_page.dart';
//import 'file:///D:/graduation%20project/New%20folder/Hearsrc/lib/pages/home/tabsPages/favorite.dart';
//import 'file:///D:/graduation%20project/New%20folder/Hearsrc/lib/pages/home/tabsPages/unread_page.dart';

//import 'Drawer.dart';
import 'floating_action_button_page.dart';

class HomeScreen extends StatefulWidget {
  final model;
  final String currentUserId;
  //final context;
  const HomeScreen({Key? key, this.model, required this.currentUserId})
      : super(key: key);
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Widget> BottomNaigationar = [];
  int SelectedItem = 0;
//  void navigationBar(index) {
//    BottomNaigationar[SelectedItem];
//    SelectedItem=index;
//    if(widget.model!=null)
//    setState(() {
//      Navigator.push(
//        context,
//        MaterialPageRoute(builder: (context) => BottomNaigationar[SelectedItem]),
//      );
//    });
//  }
  @override
  void initState() {
    BottomNaigationar = [
      // ChatContacts(currentUserId: widget.currentUserId,model: widget.model,context: context),
      ChatItem(model: widget.model, currentUserId: widget.currentUserId),
      ActiveItem(
        model: widget.model,
        currentUsrid: widget.currentUserId,
        key: null,
      ),
    ];
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(right: 15, bottom: 30),
        child: FloatingActionButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => FloatingActionPage(
                        currentUserId: '',
                        context: null,
                        model: null,
                      )),
            );
          },
          backgroundColor: Colors.blue,
          child: Image.asset(
            'assets/SMS.png',
            width: 30,
            height: 30,
          ),
        ),
      ),
      appBar: AppBar(
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.black),
        backgroundColor: Colors.white,
        title: Padding(
          padding: const EdgeInsets.only(left: 70),
          child: Image.asset(
            'assets/hearme.png',
            width: 130,
            height: 130,
          ),
        ),
      ),
      drawer: Drawer(
        child: DrawerContent(),
      ),
      body: BottomNaigationar[SelectedItem],
      bottomNavigationBar: ClipRRect(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30.0),
          topRight: Radius.circular(30.0),
        ),
        child: BottomNavigationBar(
          backgroundColor: Colors.black.withBlue(50),
          selectedItemColor: Colors.blue,
          unselectedItemColor: Colors.white,
          currentIndex: SelectedItem,
          onTap: (index) {
            SelectedItem = index;
          }, //
          // this will be set when a new tab is tapped
          items: [
            BottomNavigationBarItem(
                icon: Image.asset(
                  'assets/SMS.png',
                  color: SelectedItem == 0 ? Colors.blue : Colors.white,
                ),
                label: 'chats'),
            BottomNavigationBarItem(
                icon: Image.asset(
                  'assets/group.png',
                  color: SelectedItem == 1 ? Colors.blue : Colors.white,
                ),
                label: 'Active'
                // icon: new Text('Active',style: TextStyle(fontSize: 16),),
                ),
          ],
        ),
      ),
    );
  }
}
