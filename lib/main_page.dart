import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:package_info_plus/package_info_plus.dart';

import 'global.dart' as global;
import 'structure.dart';
import 'dialog.dart';
import 'print_book.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key, required this.title});

  final String title;

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  bool _hasStoragePermission = false;
  bool _readAppConfigComplete = false;

  bool _refreshAppBarAgain = false;

  PackageInfo _packageInfo = PackageInfo(
    appName: 'Unknown',
    packageName: 'Unknown',
    version: 'Unknown',
    buildNumber: 'Unknown',
    buildSignature: 'Unknown',
    installerStore: 'Unknown',
  );

  void _refreshAppBar() {
    setState(() => {});
  }

  Future<void> _checkStoragePermission() async {
    /*PermissionStatus resultM = await Permission.manageExternalStorage.request();
    PermissionStatus resultS = await Permission.storage.request();

    if (resultM.isGranted && resultS.isGranted) {
      setState(() => _hasStoragePermission = true);
    } else {
      setState(() => _hasStoragePermission = false);
    }*/
    PermissionStatus resultS = await Permission.storage.request();

    if (resultS.isGranted) {
      setState(() => _hasStoragePermission = true);
    } else {
      setState(() => _hasStoragePermission = false);
    }
  }

  Future<void> _readAppConfig() async {
    await global.globalAppConfig.loadAppConfig();
    setState(() => _readAppConfigComplete = true);
  }

  void _onTapDir(details) {
    _openBrowseChapters();
  }

  void _onTapBookName(details) {
    _openBrowseBookPage();
  }

  void _openBrowseBookPage() {
    Navigator.pushNamed(context, '/MainPage/BrowseBooks', arguments: '注意，這邊只能傳一個參數，如果想要傳多個參數，請自己寫個物件包起來').then((value) => {
          openBook(value as BookInfo).then((value) => {
                setState(() {
                  _refreshAppBarAgain = true;
                })
              }),
        });
  }

  void _openBrowseChapters() {
    Navigator.pushNamed(context, '/MainPage/BrowseChapters', arguments: '注意，這邊只能傳一個參數，如果想要傳多個參數，請自己寫個物件包起來').then((value) => {
          if (value != global.globalAppConfig.currentBook.currentChapter)
            {
              global.globalAppConfig.currentBook.currentChapter = value as int,
              global.globalAppConfig.currentBook.currentChapterInfo.reset(),
              global.globalAppConfig.currentBook.currentPosInChapter = 0,
              global.globalAppConfig.saveCurrentBookInfo(),
              setState(() {_refreshAppBarAgain = true;}),
            }
        });
  }

  void _openSettings() {
    Navigator.pushNamed(context, '/MainPage/Settings').then((value) => {
      if(value == true) {
        global.globalAppConfig.currentBook.currentChapterInfo.reset(),
        setState(() {_refreshAppBarAgain = true;}),
      }
    });
  }

  Future<void> _initPackageInfo() async {
    final info = await PackageInfo.fromPlatform();
    setState(() {
      _packageInfo = info;
    });
  }

  @override
  void initState() {
    super.initState();
    _initPackageInfo();
    _checkStoragePermission();
    _readAppConfig();
  }

  @override
  Widget build(BuildContext context) {
    Scaffold objScaffold;

    final ThemeData theme = Theme.of(context);
    final TextStyle textStyle = theme.textTheme.bodyMedium!;
    final List<Widget> aboutBoxChildren = <Widget>[
      const SizedBox(height: 24),
      RichText(
        text: TextSpan(
          children: <TextSpan>[
            TextSpan(
                style: textStyle,
                text: "Flutter is Google's UI toolkit for building beautiful, "
                    'natively compiled applications for mobile, web, and desktop '
                    'from a single codebase. Learn more about Flutter at '),
            TextSpan(
                style: textStyle.copyWith(color: theme.colorScheme.primary),
                text: 'https://flutter.dev'),
            TextSpan(style: textStyle, text: '.'),
          ],
        ),
      ),
    ];

    if (_hasStoragePermission && _readAppConfigComplete) {
      var height = AppBar().preferredSize.height;
      TextStyle primaryStyle = TextStyle(fontSize: height / 2.5, color: Colors.white);
      TextStyle secondaryStyle = TextStyle(fontSize: height / 4, color: Colors.white);

      String showBookName = widget.title;
      String showAuthor = _packageInfo.version;
      String showDirName = '';
      String showPageNumber = '';
      if (global.globalAppConfig.currentBook.isValid) {
        showBookName = global.globalAppConfig.currentBook.name;
        showAuthor = global.globalAppConfig.currentBook.author;
        if (global.globalAppConfig.currentBook.alreadyLoadChapterList) {
          showDirName = global.globalAppConfig.currentBook.getChapterName(global.globalAppConfig.currentBook.currentChapter);
        }
        if (global.globalAppConfig.currentBook.currentChapterInfo.totalPages > 0) {
          int currentPage =
              global.globalAppConfig.currentBook.currentChapterInfo.calculateCurrentPage(global.globalAppConfig.currentBook.currentPosInChapter) +
                  1;
          showPageNumber = '$currentPage/${global.globalAppConfig.currentBook.currentChapterInfo.totalPages}';
        }
      }

      objScaffold = Scaffold(
        resizeToAvoidBottomInset: false, // <== tip : 避免 keyboard 出現時佔去空間影響 container 的 size
        appBar: AppBar(
            title: Table(columnWidths: const {
          0: IntrinsicColumnWidth(),
          1: FlexColumnWidth(),
        }, children: [
          TableRow(children: [
            Column(
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                GestureDetector(
                  onTapDown: (details) => _onTapBookName(details),
                  child: RichText(
                    text: TextSpan(children: [
                      TextSpan(text: '$showBookName\n', style: primaryStyle),
                      TextSpan(text: showAuthor, style: secondaryStyle),
                    ]),
                  ),
                )
              ],
            ),
            Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
              GestureDetector(
                  onTapDown: (details) => _onTapDir(details),
                  child: RichText(
                    overflow: TextOverflow.fade,
                    textAlign: TextAlign.right,
                    maxLines: 2,
                    text: TextSpan(children: [
                      TextSpan(text: '$showDirName\n', style: secondaryStyle),
                    ]),
                  )),
              RichText(
                textAlign: TextAlign.right,
                text: TextSpan(children: [
                  TextSpan(text: showPageNumber, style: secondaryStyle),
                ]),
              ),
            ]),
          ])
        ])),
        drawer: Drawer(
            child: ListView(
          children: <Widget>[
            const DrawerHeader(
              decoration: BoxDecoration(),
                child: Text('HD Read Book', textAlign: TextAlign.center, style: TextStyle(fontSize: 26),)),
            ListTile(
                leading: const Icon(Icons.open_in_new_rounded, color: Colors.blueAccent,),
                title: const Text('開啟書本'),
                onTap: () {
                  Navigator.pop(context);
                  _openBrowseBookPage();
                }),
            ListTile(
                leading: const Icon(Icons.flip, color: Colors.deepPurple),
                title: const Text('選擇章節'),
                enabled: (global.globalAppConfig.currentBook.chapterCount > 0 ? true : false),
                onTap: () {
                  Navigator.pop(context);
                  _openBrowseChapters();
                }),
            const Divider(color: Colors.black54),
            ListTile(
                leading: const Icon(Icons.filter_vintage, color: Colors.black),
                title: const Text('設定'),
                onTap: () {
                  Navigator.pop(context);
                  _openSettings();
                }),
            const Divider(color: Colors.black54),
            /*ListTile(
                leading: const Icon(Icons.info_outline, color: Colors.blueGrey),
                title: const Text('關於'),
                onTap: () {
                  showMessage(context, '關於 HD Read Book', 'AAA');
                  Navigator.pop(context);
                }),*/
            AboutListTile(
                icon: const Icon(Icons.info_outline, color: Colors.blueGrey),
                applicationIcon: const FlutterLogo(),
                applicationName: 'HD Read Book',
                applicationVersion: _packageInfo.version,
                applicationLegalese: '\u{a9} Tony Huang',
                aboutBoxChildren: aboutBoxChildren,
                child: const Text('關於 HD Read Book')
            )
          ],
        )),
        body: PrintBook(refreshAppBar: () {
          _refreshAppBar();
        }),
      );
    } else {
      objScaffold = Scaffold(
          appBar: AppBar(
            title: Text(widget.title),
          ),
          body: const Center(
            child: Text('請離開 APP，重新開啟 APP 授予檔案存取權限', style: TextStyle(color: Colors.red, fontSize: 18)),
          ));
    }

    if (_refreshAppBarAgain) {
      _refreshAppBarAgain = false;
      WidgetsBinding.instance.addPostFrameCallback((_) => {_refreshAppBar()});
    }

    return objScaffold;
  }

  Future<bool> openBook(BookInfo bookInfo) async {
    BookInfo? existedBookInfo = await global.globalAppConfig.getBookInfoFromStorage(bookInfo.key);

    if (existedBookInfo != null) {
      global.globalAppConfig.currentBook = existedBookInfo;
    } else {
      global.globalAppConfig.currentBook = bookInfo;
    }
    global.globalAppConfig.currentBookKey = global.globalAppConfig.currentBook.key;
    global.globalAppConfig.saveCurrentBookInfo();
    global.globalAppConfig.saveCurrentBookKey();

    return true;
  }

}
