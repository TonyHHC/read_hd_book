import 'package:flutter/material.dart';
import 'dart:io';
import 'books_utility.dart';

////////////////////////////////////////////////////////////////////////////////////////////////////////////
class BookInfo {
  bool isFile = false; // true : book, false : folder
  String key = '';
  String name = ''; // book display name
  String path = ''; // book's full path
  String author = '';

  int currentChapter = 0;
  int currentPosInChapter = 0;

  List <String> chapterList = [];
  ChapterInfo currentChapterInfo = ChapterInfo();

  // Initial
  BookInfo(){
    reset();
  }

  // 這個 BookInfo 是有效還是無效的 ?
  bool get isValid {
    return File(path).existsSync();
  }

  // 取得書本章節數
  int get chapterCount {
    return chapterList.length;
  }

  // 最後一章 (0 based)
  int get lastChapter {
    return chapterList.length-1;
  }

  // 已經載入章節清單
  bool get alreadyLoadChapterList{
    return chapterList.isNotEmpty;
  }

  // 傳回章節名稱
  String getChapterName(int chapterNumber) {
    return(chapterList[chapterNumber]);
  }

  // 載入 章節清單
  void loadBookChapterList(){
    if(!isValid) return;

    BooksUtility bu = BooksUtility();
    Map bookSpec = bu.getBookSpec(path);
    chapterList = bookSpec['chapterList'];
  }

  void fromJson(Map<dynamic, dynamic> parsedJson) {
    key = parsedJson['key'] ?? "";
    name = parsedJson['name'] ?? "";
    path = parsedJson['path'] ?? "";
    author = parsedJson['author'] ?? "";
    currentChapter = parsedJson['currentChapter'] ?? 1;
    currentPosInChapter = parsedJson['currentPosInChapter'] ?? 0;
  }

  Map<String, dynamic> toJson() {
    return {
      "key": key,
      "name": name,
      "path": path,
      "author": author,
      "currentChapter": currentChapter,
      "currentPosInChapter": currentPosInChapter,
    };
  }

  void reset() {
    isFile = false; // true : book, false : folder
    key = '';
    name = ''; // book display name
    path = ''; // book's full path
    author = '';

    chapterList.clear();
    currentChapter = 0;
    currentPosInChapter = 0;
    currentChapterInfo.reset();
  }

  bool get hasChapterString{
    if(currentChapterInfo.chapterString == '') return false;
    return true;
  }

  void loadChapterString(){
    if(!isValid){
      reset();
      return;
    }

    BooksUtility bu = BooksUtility();
    currentChapterInfo.chapterString = bu.getChapterContents(path, currentChapter);
  }
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////
class ChapterInfo {
  String chapterString = '';

  int columnsPerPage = 0;
  int wordsPerLine = 0;

  List<int> pageStartPos = [];

  ChapterInfo() {
    reset();
  }

  void reset(){
    chapterString = '';
    columnsPerPage = wordsPerLine = 0;
    pageStartPos.clear();
  }

  void calculateChapterProperties(
      Size canvasSize, int fontSize, int canvasTopSpace, int canvasBottomSpace, double wordSpace, int newlineSpace, int sectionSpace) {
    columnsPerPage = canvasSize.width ~/ (fontSize + newlineSpace);
    wordsPerLine = (canvasSize.height - canvasTopSpace - canvasBottomSpace) ~/ (fontSize * wordSpace);

    pageStartPos.clear();

    int words = 0;
    int columns = 1;
    for (int i = 0; i < chapterString.length; i++) {
      if (columns == 1 && words == 0) {
        pageStartPos.add(i);
      }

      String ch = '';
      while(i < chapterString.length){
        ch = chapterString[i];
        if(ch != '\r') break;
        i++;
      }

      if (ch != '\r') {
        if (ch == '\n') {
          columns++;
          words = 0;
        } else {
          words++;
        }

        if (words >= wordsPerLine) {
          columns++;
          words = 0;
        }
        if (columns > columnsPerPage) {
          columns = 1;
          words = 0;
        }
      }
    }
  }

  int get totalPages{
    return pageStartPos.length;
  }

  int calculateCurrentPage(int currentWordPos){
    if (currentWordPos < 0) return pageStartPos.length-1;

    for(int i=pageStartPos.length-1 ; i>=0 ; i--){
      if(currentWordPos >= pageStartPos[i]) return i;
    }

    return -1;
  }



}
