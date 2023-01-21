import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:material_color_generator/material_color_generator.dart';
import 'package:flutter/services.dart';

import 'app_config.dart';
import 'global.dart' as global;
import 'main_page.dart';
import 'browse_books.dart';
import 'browse_chapters.dart';
import 'settings.dart';

void setNavigationBarColor() {
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(systemNavigationBarColor: Colors.black));
}

Future<void> main() async {
  /*
  // force App on portrait mode
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations(
    [
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ],
  ).then((val) {
    runApp(const App());
  });*/

  runApp(const App());
}

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _App();
}

class _App extends State<App> {

  bool _initialComplete = false;

  Future<void> _readAppConfig() async {
    await global.globalAppConfig.loadAppConfig();
    setState(() => _initialComplete = true);
  }

  @override
  void initState() {
    super.initState();
    _readAppConfig();
  }

  @override
  Widget build(BuildContext context) {
    global.globalAppConfig.loadAppConfig().then((value) => {});

    if(!_initialComplete) {
      return initialApp();
    } else {
      return materialApp();
    }
  }

  Widget initialApp() {
    return Container(
      color: Colors.blueGrey,
      child: Center(
        child: Image.asset(
          'assets/read_hd_book.png',
          //height: 1024,
          //width: 1024,
        ),
      )
    );
  }

  Widget materialApp() {
    return ChangeNotifierProvider(
      create: (_) => AppConfigChangeNotifier(),
      child: Consumer<AppConfigChangeNotifier>(builder: (context, AppConfigChangeNotifier appConfigNotifier, child) {
        return MaterialApp(
          title: '好好讀書',
          theme: ThemeData(
            primarySwatch: generateMaterialColor(color:global.globalAppConfig.themeDataPrimarySwatch),
          ),
          home: MainPage(title: '好好讀書'),
          routes: <String, WidgetBuilder>{
            '/MainPage': (BuildContext context) => MainPage(title: '好好讀書'),
            '/MainPage/BrowseBooks': (BuildContext context) => const BrowseBooks(),
            '/MainPage/BrowseChapters': (BuildContext context) => const BrowseChapters(),
            '/MainPage/Settings': (BuildContext context) => const Settings(),
          },
        );
      }),
    );
  }


}

