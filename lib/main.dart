import 'package:flutter/material.dart';
import 'package:foodallergies_app/Screens/SearchPage.dart';
import 'Screens/MainPage.dart';
import 'Screens/ProfilePage.dart';
import 'Screens/FallergiesPage.dart';
import 'Screens/LoginPage.dart';
import 'Screens/RegisterPage.dart';
import 'Screens/Changepass.dart';

void main() {
  var login = Login();
  var regis = Register();
  var changepass = Changepass();
  var fallergies = Fallergies();
  var main = MainPage();
  var profile = Profile();
  var search = Search();

  runApp(MaterialApp(home: login));
}
