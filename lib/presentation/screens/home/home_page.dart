import 'package:bottom_nav_layout/bottom_nav_layout.dart';
import 'package:flutter/material.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:router/core/constants/style.dart';
import 'package:router/main.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {



  @override
  Widget build(BuildContext context) {

    return  BottomNavLayout(
      pages: [
            (_) =>  const AutoRouterLogin(),
            (_) =>  const AutoRouterLogin(),

      ],
      bottomNavigationBar: (currentIndex, onTap) => BottomNavigationBar(
        currentIndex: currentIndex,
        elevation: 0,
        selectedLabelStyle:  TextStyle(fontFamily: fontF),
        unselectedLabelStyle:  TextStyle(fontFamily: fontF) ,
        useLegacyColorScheme: false,
        selectedItemColor:  Colors.green  ,
        onTap: (index) {
          setState(() {
            currentIndex = index;
          });
          onTap(index);
        },
        items:  const [
          BottomNavigationBarItem( icon:  Icon(Bootstrap.controller ,  size: 20), label: 'اتصال' , ),
          BottomNavigationBarItem( icon:  Icon(Clarity.connect_line ,  size: 20), label: 'اتصال' , ),
        ],
      ),
      savePageState: true,
      lazyLoadPages: false,
      pageStack: ReorderToFrontPageStack(initialPage: 1),
      extendBody: false,
      resizeToAvoidBottomInset: false,


    );
  }}
