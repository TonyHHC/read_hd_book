import 'package:flutter/material.dart';

import 'main_page.dart';
import 'browse_books.dart';
import 'browse_chapters.dart';
import 'settings.dart';

Future <void> main() async {
  runApp(const App());
}

class App extends StatelessWidget {

  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '好好讀書',
      theme: ThemeData(
        primarySwatch: Colors.blueGrey,
      ),
      home: const MainPage(title: '好好讀書'),
      routes: <String, WidgetBuilder> {
        '/MainPage': (BuildContext context) => const MainPage(title: '好好讀書'),
        '/MainPage/BrowseBooks' : (BuildContext context) => const BrowseBooks(),
        '/MainPage/BrowseChapters' : (BuildContext context) => const BrowseChapters(),
        '/MainPage/Settings' : (BuildContext context) => const Settings(),
      },
    );
  }
}



