import 'package:flutter/material.dart';
import 'package:meme_app/screen/meme_home_page.dart';

void main(){
    runApp(MemeApp());
}

class MemeApp extends StatelessWidget {
  const MemeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
            primaryColor: Colors.lightBlue,
            visualDensity: VisualDensity.adaptivePlatformDensity
        ),
        home:  const MemeHomePage(),
    );
  }
}