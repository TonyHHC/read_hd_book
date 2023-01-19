import 'package:flutter/material.dart';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import 'structure.dart';

class AppConfigChangeNotifier extends ChangeNotifier  {

  AppConfigChangeNotifier() {
    //
  }

  // settings change
  void settingsChange() {
    notifyListeners();
  }
}

class AppConfig {
  String rootDir = '/storage/emulated/0';

  // BookInfo
  BookInfo currentBook = BookInfo();
  String currentBookKey = '';

  // ThemeData primarySwatch default value
  final Color _defaultThemeDataPrimarySwatch = Colors.blueGrey;

  // Print Book default values
  final Color _defaultCanvasBackgroundColor = Colors.black;
  final Color _defaultCanvasForegroundColor = Colors.white;

  final int _defaultFontSize = 24;
  final int _defaultCanvasTopSpace = 5;
  final int _defaultCanvasBottomSpace = 5;
  final double _defaultWordSpace = 1.2;
  final int _defaultNewlineSpace = 2;
  final int _defaultParagraphSpace = 0;

  // ThemeData primarySwatch
  late Color themeDataPrimarySwatch;

  // Print Book properties
  late Color canvasBackgroundColor;
  late Color canvasForegroundColor;

  late int fontSize;
  late int canvasTopSpace;
  late int canvasBottomSpace;
  late double wordSpace; // 因為是直書，所以對應的是 TextStyle 的 height，不是 letterSpacing
  late int newlineSpace;
  late int paragraphSpace;

  // constructor
  AppConfig() {
    resetPrintBookProperties();
  }

  // reset print book properties
  void resetPrintBookProperties() {
    themeDataPrimarySwatch = _defaultThemeDataPrimarySwatch;

    canvasBackgroundColor = _defaultCanvasBackgroundColor;
    canvasForegroundColor = _defaultCanvasForegroundColor;

    fontSize = _defaultFontSize;
    canvasTopSpace = _defaultCanvasTopSpace;
    canvasBottomSpace = _defaultCanvasBottomSpace;
    wordSpace = _defaultWordSpace;
    newlineSpace = _defaultNewlineSpace;
    paragraphSpace = _defaultParagraphSpace;
  }

  // currentBookPath
  Future<void> loadCurrentBookKey() async {
    final prefs = await SharedPreferences.getInstance();
    currentBookKey = (prefs.getString('currentBookKey') ?? '');
  }

  Future<void> saveCurrentBookKey() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('currentBookKey', currentBookKey);
  }

  // App Print Book 一般設定
  Future<void> loadPrintBookProperties() async {
    final prefs = await SharedPreferences.getInstance();

    themeDataPrimarySwatch = Color(prefs.getInt('themeDataPrimarySwatch') ?? _defaultThemeDataPrimarySwatch.value);

    canvasBackgroundColor = Color(prefs.getInt('canvasBackgroundColor') ?? _defaultCanvasBackgroundColor.value);
    canvasForegroundColor = Color(prefs.getInt('canvasForegroundColor') ?? _defaultCanvasForegroundColor.value);

    fontSize = (prefs.getInt('fontSize') ?? _defaultFontSize);
    canvasTopSpace = (prefs.getInt('canvasTopSpace') ?? _defaultCanvasTopSpace);
    canvasBottomSpace = (prefs.getInt('canvasBottomSpace') ?? _defaultCanvasBottomSpace);
    wordSpace = (prefs.getDouble('wordSpace') ?? _defaultWordSpace);
    newlineSpace = (prefs.getInt('newlineSpace') ?? _defaultNewlineSpace);
    paragraphSpace = (prefs.getInt('paragraphSpace') ?? _defaultParagraphSpace);
  }

  Future<void> savePrintBookProperties() async {
    final prefs = await SharedPreferences.getInstance();

    prefs.setInt('themeDataPrimarySwatch', themeDataPrimarySwatch.value);

    prefs.setInt('canvasBackgroundColor', canvasBackgroundColor.value);
    prefs.setInt('canvasForegroundColor', canvasForegroundColor.value);

    prefs.setInt('fontSize', fontSize);
    prefs.setInt('canvasTopSpace', canvasTopSpace);
    prefs.setInt('canvasBottomSpace', canvasBottomSpace);
    prefs.setDouble('wordSpace', wordSpace);
    prefs.setInt('newlineSpace', newlineSpace);
    prefs.setInt('paragraphSpace', paragraphSpace);
  }

  // 載入 AppConfig
  Future<void> loadAppConfig() async {
    final prefs = await SharedPreferences.getInstance();

    await loadCurrentBookKey();
    await loadPrintBookProperties();

    if(currentBookKey != ''){
      String jsonCurrentBook = (prefs.getString(currentBookKey) ?? '');
      if(jsonCurrentBook != '') {
        Map decodeCurrentBook = jsonDecode(jsonCurrentBook);
        currentBook.fromJson(decodeCurrentBook);
      }
      else {
        currentBookKey = '';
      }
    }
  }

  // 儲存目前的 book 狀態
  Future<void> saveCurrentBookInfo() async{
    // default save path is "/data/data/YOUR_PACKAGE_NAME/shared_prefs/YOUR_PREFS_NAME.xml"
    final prefs = await SharedPreferences.getInstance();
    String jsonCurrentBook = jsonEncode(currentBook.toJson());
    prefs.setString(currentBook.key, jsonCurrentBook);
  }

  // get BookInfo from Storage
  Future<BookInfo?> getBookInfoFromStorage (String bookKey) async{
    BookInfo bookInfo = BookInfo();

    final prefs = await SharedPreferences.getInstance();
    String  jsonBookInfo= (prefs.getString(bookKey) ?? '');

    if(jsonBookInfo == '' ){
      return null;
    } else{
      Map decodeCurrentBook = jsonDecode(jsonBookInfo);
      bookInfo.fromJson(decodeCurrentBook);
      return bookInfo;
    }

  }

  // 取得目前書本所在目錄
  String getCurrentBookFolder(){
    var f = File(currentBook.path);
    if(f.existsSync()){
      return f.parent.path;
    }
    
    return rootDir;
  }

  // 將 path 轉為相對路徑
  String convertToRelativePath(String path){
    if( path == rootDir) {
      return path.replaceFirst(rootDir, '/');
    }
    return path.replaceFirst(rootDir, '');
  }

}