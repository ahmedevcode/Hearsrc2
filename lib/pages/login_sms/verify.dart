import 'dart:async';
import 'dart:convert';

//import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:moi/common/firebase_services.dart';
import 'package:moi/models/theme_model.dart';
//import 'package:moi/model/user_model.dart' as  UserModels;
import 'package:moi/new_chat/chathome.dart';
import 'package:moi/pages/login_sms/SplashCheckPage.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sms_autofill/sms_autofill.dart';

/*import '../../../common/constants.dart';
import '../../../common/firebase_services.dart';
import '../../../common/tools.dart';
import '../../../generated/l10n.dart';
import '../../../models/user_model.dart';*/
import 'login_animation.dart';
import 'widgets/pin_code_widget.dart';

class VerifyCode extends StatefulWidget {
  final String phoneNumber;
  final String verId;
  final Stream<PhoneAuthCredential> verifySuccessStream;

  VerifyCode(
      {required this.verId,
      required this.phoneNumber,
      required this.verifySuccessStream});

  @override
  _VerifyCodeState createState() => _VerifyCodeState();
}

class _VerifyCodeState extends State<VerifyCode>
    with TickerProviderStateMixin, CodeAutoFill {
  AnimationController? _loginButtonController;
  bool isLoading = false;
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  final TextEditingController _pinCodeController = TextEditingController();

  bool hasError = false;
  String currentText = '';
  var onTapRecognizer;

  @override
  void codeUpdated() {
    if (mounted && code != null && code!.isNotEmpty) {
      setState(() {
        _pinCodeController.clear();

        /// Support add code from RTL
        code!.characters.forEach((character) {
          _pinCodeController.text += character;
        });
      });
      FocusScope.of(context).requestFocus(FocusNode());
    }
  }

  Future<void> _verifySuccessStreamListener(
      PhoneAuthCredential credential) async {
    if (credential != null && mounted) {
      setState(() {
        _pinCodeController.text = credential.smsCode!;
      });
      FocusScope.of(context).requestFocus(FocusNode());
    }
  }

  @override
  void initState() {
    super.initState();

    widget.verifySuccessStream?.listen(_verifySuccessStreamListener);

    listenForCode();

    onTapRecognizer = TapGestureRecognizer()
      ..onTap = () {
        Navigator.pop(context);
      };

    _loginButtonController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    );
  }

  @override
  void dispose() {
    // widget.verifySuccessStream?.listen(null);
    _loginButtonController!.dispose();
    _pinCodeController.dispose();
    cancel();
    super.dispose();
  }

  Future<Null> _playAnimation() async {
    try {
      setState(() {
        isLoading = true;
      });
      await _loginButtonController!.forward();
    } on TickerCanceled {
      //print('[_playAnimation] error');
    }
  }

  Future<Null> _stopAnimation() async {
    try {
      await _loginButtonController!.reverse();
      setState(() {
        isLoading = false;
      });
    } on TickerCanceled {
      //print('[_stopAnimation] error');
    }
  }

  void _welcomeMessage(user, context) async {
    //showSnackBar(
    //    scaffoldKey.currentState, 'welcome  ${user.toString()}!');
    // //print('welcome  ${user.toString()}!');
    // final model=await Provider.of<ThemeModel>(context, listen: false);

    Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (context) => WelcomePageCheck(
            name: user.displayName ?? '',
            currentUserId: user.uid,
          ),
        ),
        (Route<dynamic> route) => false);
    /*  Navigator.of(context, rootNavigator: true).pushNamedAndRemoveUntil(
          'home', (Route<dynamic> route) => false);*/
  }

  static showSnackBar(ScaffoldState scaffoldState, message) {
    // ignore: deprecated_member_use
    //  scaffoldState.showSnackBar(SnackBar(content: Text(message)));
  }
  void _failMessage(message, context) {
    /// Showing Error messageSnackBarDemo
    /// Ability so close message
    final snackBar = SnackBar(
      content: Text(message),
      duration: const Duration(seconds: 30),
      action: SnackBarAction(
        label: 'close',
        onPressed: () {
          // Some code to undo the change.
        },
      ),
    );
    // ignore: deprecated_member_use
    // scaffoldKey.currentState.showSnackBar(snackBar);
  }

  void _loginSMS(smsCode, context) async {
    await _playAnimation();
    try {
      //print('a1 ${widget.verId}  $smsCode');
      if (widget.verId != null) {
        final AuthCredential credential = PhoneAuthProvider.credential(
          verificationId: widget.verId,
          smsCode: smsCode,
        );
        await _signInWithCredential(credential, context);
      } else {
        //print('a2 ${widget.verId}');
      }
    } catch (e) {
      await _stopAnimation();
      _failMessage(e.toString(), context);
      //print('a3 ${e.toString()}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            const SizedBox(height: 100),
            Column(
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Container(
                        height: 40.0, child: Image.asset('images/hearme.png')),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 50),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'Please enter verification code which we sent to you as SMS',
                softWrap: true,
                style: const TextStyle(
                  fontSize: 18,
                  color: Colors.black,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 30.0, vertical: 8),
              child: RichText(
                text: TextSpan(
                    text: '',
                    children: [
                      TextSpan(
                          text: widget.phoneNumber,
                          style: const TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 15)),
                    ],
                    style:
                        const TextStyle(color: Colors.black54, fontSize: 15)),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: PinCodeWidget(
                controller: _pinCodeController,
                length: 6,
                borderRadius: 2.0,
                onChanged: (value) {
                  _loginSMS(value, context);
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 50.0),
              child: Row(
                children: [
                  Text(
                    'If you agree with our  ',
                    softWrap: true,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.black54,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  Text(
                    'terms and policy press submit',
                    softWrap: true,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.black,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30.0),
              // error showing widget
              child: Text(
                hasError ? 'pleasefillUpAllCellsProperly' : '',
                style: TextStyle(color: Colors.red.shade300, fontSize: 15),
              ),
            ),
          ],
        ),
      ),
      bottomSheet: Container(
        margin: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 30),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                  text: 'didntReceiveCode',
                  style: const TextStyle(fontSize: 15),
                  children: [
                    TextSpan(
                        text: 'Resend Code',
                        recognizer: onTapRecognizer,
                        style: TextStyle(
                            color: Theme.of(context).primaryColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 16))
                  ]),
            ),
            const SizedBox(
              width: 10,
            ),
            // StaggerAnimation(
            //   titleButton: 'Submit',
            //   // buttonController: _loginButtonController.view,
            //   onTap: () {
            //     if (!isLoading) {
            //       // changeNotifier.add(Functions.submit);
            //     }
            //   },
            // ),
          ],
        ),
      ),
    );
  }

  Future<void> _signInWithCredential(AuthCredential credential, context) async {
    final User? user =
        (await FirebaseAuth.instance.signInWithCredential(credential)).user;
    //print('laa ${user.toString()}');
    if (user != null) {
      _stopAnimation();
      SharedPreferences pref = await SharedPreferences.getInstance();
      await pref.setString('id', user.uid);
      await pref.setString('phone', user.phoneNumber ?? '');
      await pref.setString('profile', user.toString());
      _welcomeMessage(user, context);
      /*   await Provider.of<UserModels.UserModel>(context, listen: false).loginFirebaseSMS(
        phoneNumber: user.phoneNumber.replaceAll('+', ''),
        success: (user) {
          _stopAnimation();
          _welcomeMessage(user, context);
        },
        fail: (message) {
          _stopAnimation();
          _failMessage(message, context);
        },
      );*/
    } else {
      await _stopAnimation();
      _failMessage('invalidSMSCode', context);
    }
  }
}

class PrimaryColorOverride extends StatelessWidget {
  const PrimaryColorOverride(
      {Key? key, required this.color, required this.child})
      : super(key: key);

  final Color color;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Theme(
      child: child,
      data: Theme.of(context).copyWith(primaryColor: color),
    );
  }
}
