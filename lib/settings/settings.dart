// import 'package:flutter/material.dart';
// //import 'app_localizations.dart';
// import 'package:moi/models/theme_model.dart';
// import 'package:provider/provider.dart';
//
// import 'app_localizations.dart';
//
// class Setting extends StatefulWidget {
//   ThemeModel model;
//   BuildContext context;
//   Setting(this.model, this.context);
//   @override
//   _SettingState createState() => _SettingState();
// }
//
// class _SettingState extends State<Setting> {
//   String picker = 'accent';
//   double _value = 10;
//   bool notify = false;
//   List<bool> isSelected = [true, false];
//   @override
//   void initState() {
//     super.initState();
//     isSelected[0] =
//         AppLocalizations.of(widget.context).locale.languageCode == 'ar'
//             ? false
//             : true;
//     isSelected[1] =
//         AppLocalizations.of(widget.context).locale.languageCode == 'ar'
//             ? true
//             : false;
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return ChangeNotifierProvider.value(
//         value: widget.model,
//         child: Consumer<ThemeModel>(
//           builder: (_, model, __) => Scaffold(
//             backgroundColor: Colors.white,
//             appBar: new AppBar(
//               backgroundColor: model.primaryMainColor,
//               leading: GestureDetector(
//                 onTap: () {
//                   //dNavigator.of(context).pop();
//                 },
//                 child: Container(),
//               ),
//               title: new Text(
//                 AppLocalizations.of(widget.context).translate('settings') ??
//                     'Setting',
//                 style: TextStyle(fontFamily: 'Cairo-Regular'),
//               ),
//               centerTitle: true,
//               bottomOpacity: 1,
//             ),
//             body: Column(children: <Widget>[
//               SizedBox(height: 10.0),
//               Padding(
//                 padding: const EdgeInsets.all(15),
//                 child: Column(
//                   children: <Widget>[
//                     SizedBox(
//                       height: 20,
//                     ),
//                     Column(
//                       children: <Widget>[
//                         Center(
//                           child: Text(
//                             AppLocalizations.of(widget.context)
//                                 .translate('csetting'),
//                             style: TextStyle(
//                                 fontSize: 20,
//                                 fontWeight: FontWeight.bold,
//                                 fontFamily: 'Cairo-Regular'),
//                           ),
//                         ),
//                         SizedBox(
//                           height: 40,
//                         ),
//                         Row(
//                           mainAxisAlignment: MainAxisAlignment.spaceAround,
//                           textDirection: model.appLocal == Locale('ar')
//                               ? TextDirection.rtl
//                               : TextDirection.ltr,
//                           children: [
//                             Container(),
//                             Text(
//                               AppLocalizations.of(widget.context)
//                                   .translate('sample'),
//                               style: TextStyle(fontSize: _value),
//                             ),
//                           ],
//                         ),
//                         Row(
//                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                           textDirection: model.appLocal == Locale('ar')
//                               ? TextDirection.rtl
//                               : TextDirection.ltr,
//                           children: [
//                             Row(
//                               children: <Widget>[
//                                 customText(AppLocalizations.of(widget.context)
//                                     .translate('text')),
//                               ],
//                             ),
//                             SliderTheme(
//                               data: SliderTheme.of(context).copyWith(
//                                 activeTrackColor: model.primaryMainColor,
//                                 inactiveTrackColor: Colors.grey[100],
//                                 trackShape: RectangularSliderTrackShape(),
//                                 trackHeight: 4.0,
//                                 thumbColor: model.primaryMainColor,
//                                 thumbShape: RoundSliderThumbShape(
//                                     enabledThumbRadius: 12.0),
//                                 overlayColor:
//                                     model.primaryMainColor.withAlpha(32),
//                                 overlayShape: RoundSliderOverlayShape(
//                                     overlayRadius: 28.0),
//                               ),
//                               child: Directionality(
//                                 textDirection: model.appLocal == Locale('ar')
//                                     ? TextDirection.rtl
//                                     : TextDirection.ltr,
//                                 child: Slider(
//                                   min: 10,
//                                   max: 50,
//                                   divisions: 50,
//                                   value: model.article_size,
//                                   onChanged: (value) {
//                                     setState(() {
//                                       _value = value;
//                                       model.changeArticle(value);
//                                       //print(_value);
//                                     });
//                                   },
//                                 ),
//                               ),
//                             ),
//                           ],
//                         ),
//                         Row(
//                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                           textDirection: model.appLocal.languageCode == 'en'
//                               ? TextDirection.ltr
//                               : TextDirection.rtl,
//                           children: [
//                             customText(AppLocalizations.of(widget.context)
//                                 .translate('theme')),
//                             Row(
//                               textDirection: model.appLocal == Locale('ar')
//                                   ? TextDirection.rtl
//                                   : TextDirection.ltr,
//                               children: <Widget>[
//                                 ClipRRect(
//                                   borderRadius: BorderRadius.circular(5),
//                                   child: InkWell(
//                                     onTap: () {
//                                       _showToast(context);
//                                       model.setPrimaryMainColor(
//                                           Color(0xffb68a35));
//                                       model.setAppbarShadeColor(
//                                           Color(0xffb68a35));
//                                       model.setTempPrimaryMainColor(Color(0xffb68a35));
//                                     },
//                                     child: Container(
//                                         height: 30,
//                                         width: 30,
//                                         color: Color(0xffb68a35)
//                                         /*color: Colors.orange,*/
// //                                    decoration: BoxDecoration(
// //                                        shape: BoxShape.circle,
// //                                        color: Color(0xffA600B1)
// //                                    ),
//                                         ),
//                                   ),
//                                 ),
//                                 SizedBox(
//                                   width: 20,
//                                 ),
//                                 InkWell(
//                                     onTap: () {
//                                       _showToast(context);
//                                       model.setPrimaryMainColor(
//                                           Color(0xff5789b3));
//                                       model.setAppbarShadeColor(
//                                           Color(0xff5789b3));
//                                       model.setTempPrimaryMainColor(Color(0xff5789b3));
//
//                                     },
//                                     child: ClipRRect(
//                                       borderRadius: BorderRadius.circular(5),
//                                       child: Container(
//                                           height: 30,
//                                           width: 30,
//                                           color: Color(0xff5789b3)
//                                           /*color: Colors.orange,*/
// //                                    decoration: BoxDecoration(
// //                                        shape: BoxShape.circle,
// //                                        color: Color(0xffA600B1)
// //                                    ),
//                                           ),
//                                     )),
//                                 SizedBox(
//                                   width: 20,
//                                 ),
//                                 InkWell(
//                                     onTap: () {
//                                       _showToast(context);
//                                       model.setPrimaryMainColor(
//                                           Color(0xffcc8c7f));
//                                       model.setAppbarShadeColor(
//                                           Color(0xffcc8c7f));
//                                       model.setTempPrimaryMainColor(Color(0xffcc8c7f));
//                                     },
//                                     child: ClipRRect(
//                                       borderRadius: BorderRadius.circular(5),
//                                       child: Container(
//                                           height: 30,
//                                           width: 30,
//                                           color: Color(0xffcc8c7f)
//                                           /*color: Colors.orange,*/
// //                                    decoration: BoxDecoration(
// //                                        shape: BoxShape.circle,
// //                                        color: Color(0xffA600B1)
// //                                    ),
//                                           ),
//                                     )),
//                                 SizedBox(
//                                   width: 20,
//                                 ),
//                                 InkWell(
//                                     onTap: () {
//                                       _showToast(context);
//                                       model.setPrimaryMainColor(Colors.green);
//                                       model.setAppbarShadeColor(Colors.green);
//
//
//                                       //print('hdhd');
//                                     },
//                                     child: ClipRRect(
//                                       borderRadius: BorderRadius.circular(5),
//                                       child: Container(
//                                           height: 30,
//                                           width: 30,
//                                           color: Colors.green
//                                           /*color: Colors.orange,*/
// //                                    decoration: BoxDecoration(
// //                                        shape: BoxShape.circle,
// //                                        color: Color(0xffA600B1)
// //                                    ),
//                                           ),
//                                     )),
//                               ],
//                             ),
//                           ],
//                         ),
//                         SizedBox(
//                           height: 10,
//                         ),
//                         Row(
//                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                           textDirection: model.appLocal == Locale('ar')
//                               ? TextDirection.rtl
//                               : TextDirection.ltr,
//                           children: <Widget>[
//                             customText(AppLocalizations.of(widget.context)
//                                 .translate('black')),
//                             Switch(
//                               activeColor: Colors.black,
//                               value: model.primaryMainColor.value==Colors.black.value?true:false,
//                               onChanged: (value) {
//                                 setState(() {
//                                   if(value){
//                                     _showToast(context);
//                                     model.setPrimaryMainColor(Colors.black);
//                                     model.setAppbarShadeColor(Colors.black);
//                                   }else{
//                                     model.setPrimaryMainColor(model.tempPrimaryMainColor);
//                                     model.setAppbarShadeColor(model.tempPrimaryMainColor);
//
//                                   }
//                                 });
//                               },
//                             )
//                           ],
//                         ),
//                         SizedBox(
//                           height: 10,
//                         ),
//                         Row(
//                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                           textDirection: model.appLocal == Locale('ar')
//                               ? TextDirection.rtl
//                               : TextDirection.ltr,
//                           children: <Widget>[
//                             customText(AppLocalizations.of(widget.context)
//                                 .translate('notification')),
//                             Switch(
//                               activeColor: model.primaryMainColor,
//                               value: model.notification,
//                               onChanged: (value) {
//                                 setState(() {
//                                   notify = value;
//                                   model.changeNotify(value);
//                                 });
//                               },
//                             )
//                           ],
//                         ),
//                         Row(
//                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                           textDirection: model.appLocal == Locale('ar')
//                               ? TextDirection.rtl
//                               : TextDirection.ltr,
//                           children: <Widget>[
//                             customText(AppLocalizations.of(widget.context)
//                                 .translate('language')),
//                             ToggleButtons(
//                               isSelected: isSelected,
//                               children: [
//                                 Text(
//                                   'EN',
//                                   style: TextStyle(
//                                       fontSize: 14,
//                                       fontWeight: FontWeight.bold,
//                                       fontFamily: 'Cairo-Regular'),
//                                 ),
//                                 Text(
//                                   'عربي',
//                                   style: TextStyle(
//                                       fontSize: 14,
//                                       fontWeight: FontWeight.bold,
//                                       fontFamily: 'Cairo-Regular'),
//                                 ),
//                               ],
//                               onPressed: (int index) {
//                                 if (index == 0) {
//                                   model.changeLanguage(Locale('en'));
//                                   setState(() {
//                                     isSelected[0] = true;
//                                     isSelected[1] = false;
//                                   });
//                                 } else {
//                                   model.changeLanguage(Locale('ar'));
//                                   setState(() {
//                                     isSelected[0] = false;
//                                     isSelected[1] = true;
//                                   });
//                                 }
//                               },
//                               selectedColor: model.primaryMainColor,
//                             )
//                           ],
//                         ),
//
//                       ],
//                     )
//                   ],
//                 ),
//               ),
//             ]),
//           ),
//         ));
//   }
//
//   Widget customText(String text) {
//     return Text(
//       text,
//       style: TextStyle(fontFamily: 'Cairo-SemiBold'),
//     );
//   }
//
//   void _showToast(BuildContext context) {
//     final scaffold = Scaffold.of(context);
//     scaffold.showSnackBar(
//       SnackBar(
//         content: const Text('Theme Colour Applied'),
//         action: SnackBarAction(
//             label: 'Close', onPressed: scaffold.hideCurrentSnackBar),
//       ),
//     );
//   }
// }
