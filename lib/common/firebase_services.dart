import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';

class FirebaseServices {
  static final FirebaseServices _instance = FirebaseServices._internal();

  factory FirebaseServices() => _instance;

  FirebaseServices._internal();

  bool _isAvailable = false;

  bool get isAvailable => _isAvailable;

  late FirebaseAuth _auth;
  late FirebaseFirestore _firestore;
  late FirebaseDynamicLinks _dynamicLinks;

  FirebaseAuth get auth => _auth;
  FirebaseFirestore get firestore => _firestore;
  FirebaseDynamicLinks get dynamicLinks => _dynamicLinks;

  Future<void> init() async {
    try {
      await Firebase.initializeApp();

      _auth = FirebaseAuth.instance;
      _firestore = FirebaseFirestore.instance;
      _dynamicLinks = FirebaseDynamicLinks.instance;

      _isAvailable = true;
    } catch (e) {
      _isAvailable = false;
      rethrow; // You can choose to handle this exception differently if needed
    }
  }

  /// Firebase Remote Config (You can add this when you implement Firebase Remote Config)
}
