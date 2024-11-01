import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';


abstract class FirebaseCloudMessagagingAbs {
  void init();
  late FirebaseCloudMessagingDelegate delegate;
}

abstract class FirebaseCloudMessagingDelegate {
  Future<void> onMessage(Map<String, dynamic> message);
  Future<void> onResume(Map<String, dynamic> message);
  Future<void> onLaunch(Map<String, dynamic> message);
}

class FirebaseCloudMessagagingWapper extends FirebaseCloudMessagagingAbs {
  static const String topicAllDevices = 'fluxstore_channel';
  late FirebaseMessaging _firebaseMessaging;

  @override
  void init() {
    _firebaseMessaging = FirebaseMessaging.instance;
    _firebaseMessaging.getToken().then((token) async {
      //print('[FirebaseCloudMessagaging]--> FCM token: [ $token ]');
    });
    firebaseCloudMessagingListeners();
  }

  void firebaseCloudMessagingListeners() {

    _firebaseMessaging.subscribeToTopic(topicAllDevices);
   /* _firebaseMessaging.configure(
      onMessage: (Map<String, dynamic> message) => delegate?.onMessage(message),
      onResume: (Map<String, dynamic> message) => delegate?.onResume(message),
      onLaunch: (Map<String, dynamic> message) => delegate?.onLaunch(message),
    );*/
  }


}
