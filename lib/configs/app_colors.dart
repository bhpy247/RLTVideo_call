import 'package:flutter/material.dart';


class Styles{

  static final Styles _instance = Styles.newInstance();
  Styles.newInstance();
  factory Styles() => _instance;

  //region ShimmerColors
  static Color shimmerHighlightColor = const Color(0xfff2f2f2);
  static Color shimmerBaseColor = const Color(0xffb6b6b6);
  static Color shimmerContainerColor = const Color(0xffc2c2c2);

  //endregion

  //region Custom Colors
  static Color tealPrimaryColor = const Color(0xff80D4C8);
  static Color violetPrimaryColor = const Color(0xff7f6ffb);
  static Color backgroundGreyColor = const Color(0xffE9E9EE);
  static Color termsTextColor = const Color(0xff585858);
  static Color goldColor = const Color(0xffEBB430);
  static Color settingsButtonGreyColor = const Color(0xffEFEEFC);
  static Color whiteColor = const Color(0xffffffff);
  static Color whiteSecondColor = const Color(0xfffafbfd);



  //endregion

  Color lightPrimaryColor = const Color(0xff7f6ffb);
  Color darkPrimaryColor = const Color(0xff7f6ffb);

  Color lightPrimaryVariant = const Color(0xff7f6ffb).withOpacity(0.6);
  Color darkPrimaryVariant = const Color(0xff7f6ffb).withOpacity(0.6);

  Color lightSecondaryColor = Colors.blueAccent;
  Color darkSecondaryColor = Colors.blueAccent;

  Color lightSecondaryVariant = Colors.blueAccent.shade400;
  Color darkSecondaryVariant = Colors.blueAccent.shade400;

  Color lightAppBarTextColor = const Color(0xffffffff);
  Color darkAppBarTextColor = const Color(0xffffffff);

  Color lightTextColor = const Color(0xff495057);
  Color darkTextColor = const Color(0xffffffff);

  Color lightBackgroundColor = const Color(0xffFFF1F1);
  Color darkBackgroundColor = const Color(0xffffffff);

  Color lightAppBarColor = const Color(0xff2680C5);
  Color darkAppBarColor = const Color(0xff2e343b);

  Color lightTextFiledFillColor = Colors.white;
  Color darkTextFiledFillColor = Colors.black;

  Color lightHoverColor = Colors.grey.withOpacity(0.05);
  Color darkHoverColor = Colors.grey.withOpacity(0.5);

  Color lightFocusedTextFormFieldColor = const Color(0xff3F9CCF).withOpacity(0.05);
  Color darkFocusedTextFormFieldColor = const Color(0xff3F9CCF).withOpacity(0.5);

  double buttonBorderRadius = 5;


}