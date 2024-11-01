import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:moi/new_chat/settings.dart';
import 'package:moi/pages/My%20home/home_screen.dart';
import 'package:moi/pages/login_sms/index.dart';
import 'package:moi/pages/tutorial/tut.dart';
import 'package:moi/utils/internet_connectivity.dart';
import 'package:moi/utils/notification.dart';

import 'package:provider/provider.dart';
import 'package:moi/models/theme_model.dart';
import 'package:moi/settings/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'common/firebase/firebase_cloud_messaging_wapper.dart';
import 'common/firebase_services.dart';
import 'models/app_model.dart';
import 'new_chat/chathome.dart';

void main() async {
  //GoogleMap.init('AIzaSyDvaS7W8iRIZTGJ6v5yePMWF4B2sCEVWqg');
  WidgetsFlutterBinding.ensureInitialized();
  Provider.debugCheckInvalidValueType = null;
  await Firebase.initializeApp();
  //await GmsTools().checkGmsAvailability();
  await FirebaseServices().init();

  if (FirebaseServices().isAvailable) {
    // await Configurations().loadRemoteConfig();
    //print('[main] Initialize Firebase successfully');
  }

  // await FirebaseApp.configure(name: "moi-flutter", options: null);
  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider<ThemeModel>(
        create: (_) => ThemeModel(),
      ),
    ],
    child: MyApp(),
  ));
}

/*loadJson() async {
  String data = await rootBundle.loadString('assets/geo.json');
  // String jsonResult = await json.decode(data);
  geoLocations = geoLocationsFromJson(data);
}*/

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp>
    implements FirebaseCloudMessagingDelegate {
  final _app = AppModel();
  late String userId;
  bool isFirstSeen = false;
  bool isLoggedIn = false;
  void appInitialModules() {
    Future.delayed(
      const Duration(seconds: 1),
      () {
        //print('[AppState] init mobile modules ..');
        checkInternetConnection();

        FirebaseCloudMessagagingWapper()
          ..init()
          ..delegate = this;

        //print('[AppState] register modules .. DONE');
      },
    );
  }
//  ThemeData getTheme(context) {
//    //print('[AppState] build Theme');
//
//    var appModel = Provider.of<AppModel>(context);
//    var isDarkTheme = appModel.darkTheme ?? false;
//
//    if (appModel.appConfig == null) {
//      /// This case is loaded first time without config file
//      return buildLightTheme(appModel.langCode);
//    }
//
//    if (isDarkTheme) {
//      return buildDarkTheme(appModel.langCode);
//    }
//    return buildLightTheme(appModel.langCode);
//  }

  void checkInternetConnection() {
    MyConnectivity.instance.initialise();
    MyConnectivity.instance.myStream.listen((onData) {
      //print('[App] internet issue change: $onData');
    });
  }

  void saveMessage(Map<String, dynamic> message) {
    if (message.containsKey('data')) {
      // _app.deeplink = message['data'];
    }

    var a = FStoreNotification.fromJsonFirebase(message);
    final id = message['notification'] != null
        ? message['notification']['tag']
        : message['data']['google.message_id'];

    a.saveToLocal(id);
  }

  @override
  void initState() {
    appInitialModules();

    super.initState();
  }

  @override
  Future<void> onLaunch(Map<String, dynamic> message) async {
    //print('[app.dart] onLaunch Pushnotification: $message');
    saveMessage(message);
  }

  @override
  Future<void> onMessage(Map<String, dynamic> message) async {
    //print('[app.dart] onMessage Pushnotification: $message');
    saveMessage(message);
  }

  @override
  Future<void> onResume(Map<String, dynamic> message) async {
    //print('[app.dart] onResume Pushnotification: $message');
    saveMessage(message);
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<ThemeModel>(
        create: (BuildContext context) => ThemeModel(),
        child: Consumer<ThemeModel>(builder: (context, model, __) {
          model.checkLogin();
          //print('ggg ${model.userId}');
          // //print('login ${model.login}');
          return Directionality(
            textDirection: model.appLocal == Locale('ar')
                ? TextDirection.rtl
                : TextDirection.ltr,
            child: MaterialApp(
              locale: model.appLocal,
              localizationsDelegates: [
                AppLocalizations.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
              ],
              supportedLocales: [
                const Locale('en', 'US'),
                const Locale('ar', ''),
              ],

              title: 'News Aggregator',
              debugShowCheckedModeBanner: false,
              darkTheme: ThemeData.dark(),
              theme: ThemeData(
                  dividerColor: model.dividerColor,
                  textTheme: Theme.of(context).textTheme.apply(
                      bodyColor: model.textColor,
                      displayColor: model.textColor),
                  appBarTheme: AppBarTheme(color: model.appbarcolor),
                  primaryColor: model.primaryMainColor,
                  hintColor: model.accentColor,
                  brightness: Brightness.light),
              // home: Home(),
              //home: RegisrtationScreen(),
              initialRoute: model!.login ? 'home' : 'tut',
              //initialRoute:'home',
              routes: {
                // 'contacts': (context) => ChatContacts(
                //       model: model,
                //       context: context,
                //       currentUserId: model.userId ?? '',
                //     ),

                'home': (context) =>
                    HomeScreen(model: model, currentUserId: model.userId ?? ''),

                'login': (context) => LoginSMS(),
                'tut': (context) => Introduction(),

                'profilesetting': (context) => model != null
                    ? SettingsScreen(
                        model: model,
                        context: context,
                      )
                    : Container(),

                //  'chatcontact': (context) => ChatContacts(currentUserId: currentUserId),
              },
            ),
          );
        }));
  }
}
