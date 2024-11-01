import 'dart:async';

import 'package:country_code_picker/country_code_picker.dart';
import 'package:date_format/date_format.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:moi/common/firebase_services.dart';
import 'package:moi/new_chat/chathome.dart';
import 'login_animation.dart';
import 'verify.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;

class LoginSMS extends StatefulWidget {
  @override
  _LoginSMSState createState() => _LoginSMSState();
}

class _LoginSMSState extends State<LoginSMS> with TickerProviderStateMixin {
  late AnimationController _loginButtonController;
  final TextEditingController _controller = TextEditingController(text: '');

  late CountryCode countryCode;
  late String phoneNumber;
  late String _phone;
  bool isLoading = false;

  final StreamController<PhoneAuthCredential> _verifySuccessStream =
      StreamController<PhoneAuthCredential>.broadcast();
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _loginButtonController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    );

    _phone = '';
    countryCode = CountryCode(
      code: 'EG',
      dialCode: '+20',
      name: 'Egypt',
    );
    _controller.addListener(() {
      if (_controller.text != _phone && _controller.text != '') {
        _phone = _controller.text;
        onPhoneNumberChange(
          _phone,
          '${countryCode.dialCode}$_phone',
          countryCode.code ?? '',
        );
      }
    });
  }

  @override
  void dispose() {
    _loginButtonController.dispose();
    super.dispose();
  }

  Future<Null> _playAnimation() async {
    try {
      setState(() {
        isLoading = true;
      });
      await _loginButtonController.forward();
    } on TickerCanceled {
      //print('[_playAnimation] error');
    }
  }

  Future<Null> _stopAnimation() async {
    try {
      await _loginButtonController.reverse();
      setState(() {
        isLoading = false;
      });
    } on TickerCanceled {
      //print('[_stopAnimation] error');
    }
  }

  void _failMessage(message, context) {
    /// Showing Error messageSnackBarDemo
    /// Ability so close message
    final snackBar = SnackBar(
      content: Text('⚠️: $message'),
      duration: const Duration(seconds: 30),
      action: SnackBarAction(
        label: 'close',
        onPressed: () {
          // Some code to undo the change.
        },
      ),
    );

    Scaffold.of(context);
    // ignore: deprecated_member_use
    //  ..removeCurrentSnackBar()
    // ignore: deprecated_member_use
    // ..showSnackBar(snackBar);
  }

  void onPhoneNumberChange(
    String number,
    String internationalizedPhoneNumber,
    String isoCode,
  ) {
    if (internationalizedPhoneNumber.isNotEmpty) {
      phoneNumber = internationalizedPhoneNumber;
    } else {
      phoneNumber = null ?? '';
    }
  }

  // static showSnackBar(ScaffoldState scaffoldState, message) {
  //   // ignore: deprecated_member_use
  //   scaffoldState.showSnackBar(SnackBar(content: Text(message)));
  // }

  Future<void> _loginSMS(context) async {
    if (phoneNumber == null) {
      // showSnackBar(Scaffold.of(context), 'pleaseInput');
    } else {
      await _playAnimation();
      final PhoneCodeAutoRetrievalTimeout autoRetrieve = (String verId) {
        _stopAnimation();
      };
      PhoneVerificationCompleted verificationCompleted =
          (PhoneAuthCredential phoneAuthCredential) async {
        await FirebaseServices().auth.signInWithCredential(phoneAuthCredential);
        if (FirebaseServices().auth.currentUser != null) {
          /*//print(
                  "ada Phone number automatically verified and user signed in: ${FirebaseServices()
                      .au0th.currentUser.uid}");*/

//              final model = await Provider.of<ThemeModel>(
//                  context, listen: false);

          // Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
          //     // MaterialPageRoute(
          //     //   // builder: (context) => ChatContacts(
          //     //   //   currentUserId: FirebaseServices().auth.currentUser!.uid,
          //     //   //   context: context,
          //     //   // ),
          //     // ),
          //     // (Route<dynamic> route) => false);
        }
      };
      final PhoneCodeSent smsCodeSent = (String verId, [int? forceCodeResend]) {
        _stopAnimation();

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => VerifyCode(
              verId: verId,
              phoneNumber: phoneNumber,
              verifySuccessStream: _verifySuccessStream.stream,
            ),
          ),
        );
      } as PhoneCodeSent;

      final verifiedSuccess = _verifySuccessStream.add;

      final PhoneVerificationFailed veriFailed =
          (FirebaseAuthException exception) {
        _stopAnimation();
        _failMessage(exception.message, context);
        //print('alla ${exception.message}');
      };

      await _auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        codeAutoRetrievalTimeout: autoRetrieve,
        codeSent: smsCodeSent,
        timeout: const Duration(seconds: 120),
        verificationCompleted: verificationCompleted, //verifiedSuccess,
        verificationFailed: veriFailed,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Builder(
          builder: (context) => Stack(
            children: [
              SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 30.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      const SizedBox(height: 80.0),
                      Column(
                        children: <Widget>[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Container(
                                height: 40.0,
                                child: Image.asset('images/hearme.png'),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 80.0),
                      Text(
                        'We will send you a message for verify your number',
                        style: TextStyle(fontSize: 18, color: Colors.black),
                        textAlign: TextAlign.left,
                      ),
                      const SizedBox(height: 40.0),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          CountryCodePicker(
                            onChanged: (country) {
                              setState(() {
                                countryCode = country;
                              });
                            },
                            // Initial selection and favorite can be one of code ('IT') OR dial_code('+39')
                            initialSelection: countryCode.code,

                            //Get the country information relevant to the initial selection
                            onInit: (code) {
                              countryCode = code!;
                            },
                          ),
                          const SizedBox(width: 8.0),
                          Expanded(
                            child: TextField(
                              decoration: InputDecoration(
                                  labelText: 'Enter your phone number'),
                              keyboardType: TextInputType.phone,
                              controller: _controller,
                              style: TextStyle(color: Colors.black),
                            ),
                          )
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 25.0, top: 15),
                        child: Text(
                          'Please verify your country code and Phone number',
                          style: TextStyle(fontSize: 12, color: Colors.black),
                        ),
                      ),
                      const SizedBox(
                        height: 60.0,
                      ),
                    ],
                  ))
            ],
          ),
        ),
      ),
      bottomSheet: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            // StaggerAnimation(
            //   titleButton: 'Next ',

            //   onTap: () async {
            //     //final model=await Provider.of<ThemeModel>(context, listen: false);
            //     // if( model!=null)
            //     // Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context)=>
            //     //  ChatContacts(currentUserId: "7gkY4L4WlvcCVl2wkKN2m2K7b4x2",context: context,model: model,)),);
            //     if (!isLoading) {
            //       _loginSMS(context);
            //     }
            //   },
            // ),
          ],
        ),
      ),
    );
  }
}
