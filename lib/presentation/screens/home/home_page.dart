import 'package:bottom_nav_layout/bottom_nav_layout.dart';
import 'package:flutter/material.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:router/core/constants/style.dart';
import 'package:router/main.dart';
import 'package:router/presentation/screens/home/backup.dart';
import 'package:router/presentation/screens/users/users.dart';

class HomePage extends StatefulWidget {
  final int initialIndex;
 String ? url;
   HomePage({super.key, this.initialIndex = 2 , this.url});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {


  late int currentIndex;

  @override
  void initState() {
    super.initState();
    currentIndex = widget.initialIndex;
  }

  @override
  Widget build(BuildContext context) {


    return  BottomNavLayout(
      pages: [
            (_) =>  const Backup(),
            (_) =>  const  Users(),
            (_) =>   AutoRouterLogin(url: widget.url,),

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
          BottomNavigationBarItem( icon:  Icon(Bootstrap.server ,  size: 20), label: 'نسخ' , ),
          BottomNavigationBarItem( icon:  Icon(Bootstrap.person_add ,  size: 20), label: 'مستخدمين' , ),
          BottomNavigationBarItem( icon:  Icon(Bootstrap.hdd_network ,  size: 20), label: 'اتصال' , ),
        ],
      ),
      savePageState: false,
      lazyLoadPages: false,
      pageStack: ReorderToFrontPageStack(initialPage: widget.initialIndex),
      extendBody: false,
      resizeToAvoidBottomInset: false,

    );
  }}
