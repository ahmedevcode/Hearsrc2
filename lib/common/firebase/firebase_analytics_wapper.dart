import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';

abstract class FirebaseAnalyticsAbs {
  /// Provide an empty implementation that can be overridden by subclasses.
  void init() {}

  List<NavigatorObserver> getMNavigatorObservers() {
    return const <NavigatorObserver>[];
  }
}

class FirebaseAnalyticsWrapper extends FirebaseAnalyticsAbs {
  late FirebaseAnalytics analytics;

  @override
  void init() {
    analytics = FirebaseAnalytics.instance;
    super.init(); // Calls the empty init method from the superclass.
  }

  @override
  List<NavigatorObserver> getMNavigatorObservers() {
    return [
      FirebaseAnalyticsObserver(analytics: analytics),
    ];
  }
}

class FirebaseAnalyticsWeb extends FirebaseAnalyticsAbs {
  @override
  void init() {
    // Web-specific initialization logic, if needed.
    super.init(); // Calls the empty init method from the superclass.
  }
}
