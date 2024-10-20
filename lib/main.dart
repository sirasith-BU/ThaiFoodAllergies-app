import 'package:flutter/material.dart';
import 'package:foodallergies_app/Screens/SearchPage.dart';
import 'Screens/MainPage.dart';
import 'Screens/ProfilePage.dart';
import 'Screens/FallergiesPage.dart';
import 'Screens/LoginPage.dart';
import 'Screens/RegisterPage.dart';
import 'Screens/Changepass.dart';

void main() {
  var login = const Login();
  var regis = const Register();
  var changepass = const Changepass();
  var fallergies = const Fallergies();
  var main = const MainPage();
  var profile = const Profile();
  var search = const Search();

  runApp(MaterialApp(home: login));
}
