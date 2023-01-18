import 'package:flutter/material.dart';
import 'extensions.dart';

import 'global.dart' as global;
import 'structure.dart';
import 'books_utility.dart';
import 'dialog.dart';

class PrintBook extends StatefulWidget {
  final Function() refreshAppBar;

  PrintBook({super.key, required this.refreshAppBar}) {
    // TODO: implement PrintBook
  }

  @override
  State<PrintBook> createState() => _PrintBook();
}

class _PrintBook extends State<PrintBook> {
  final _keyPrintBook = GlobalKey();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => {widget.refreshAppBar()});
  }

  void _onTap(TapDownDetails details) {
    //showMessage(context, 'ABC', 'Hello, Tony');

    Size? x = _keyPrintBook.currentContext!.size;
    String tapPosition = '';

    if (details.localPosition.dx > (x!.width / 2)) {
      tapPosition = 'Right';
      int prevPage =
          global.globalAppConfig.currentBook.currentChapterInfo.calculateCurrentPage(global.globalAppConfig.currentBook.currentPosInChapter) - 1;
      if (prevPage < 0) {
        // 已到達本章第一頁
        if ((global.globalAppConfig.currentBook.currentChapter - 1) < 0) {
          // 已到達第一章
          showMessage(context, global.globalAppConfig.currentBook.name, '已到達第一頁');
        } else {
          // 載入前一章
          global.globalAppConfig.currentBook.currentChapter = global.globalAppConfig.currentBook.currentChapter - 1;
          global.globalAppConfig.currentBook.currentChapterInfo.reset();
          global.globalAppConfig.currentBook.currentPosInChapter = -1;
        }
      } else {
        global.globalAppConfig.currentBook.currentPosInChapter = global.globalAppConfig.currentBook.currentChapterInfo.pageStartPos[prevPage];
      }

      global.globalAppConfig.saveCurrentBookInfo();
    } else {
      tapPosition = 'Left';
      int nextPage =
          global.globalAppConfig.currentBook.currentChapterInfo.calculateCurrentPage(global.globalAppConfig.currentBook.currentPosInChapter) + 1;
      if (nextPage >= global.globalAppConfig.currentBook.currentChapterInfo.totalPages) {
        // 已到達本章最後一頁
        if ((global.globalAppConfig.currentBook.currentChapter + 1) > global.globalAppConfig.currentBook.lastChapter) {
          // 已到達最後一章
          showMessage(context, global.globalAppConfig.currentBook.name, '已到達書本最後一頁');
        } else {
          // 載入下一章
          global.globalAppConfig.currentBook.currentChapter = global.globalAppConfig.currentBook.currentChapter + 1;
          global.globalAppConfig.currentBook.currentChapterInfo.reset();
          global.globalAppConfig.currentBook.currentPosInChapter = 0;
        }
      } else {
        global.globalAppConfig.currentBook.currentPosInChapter = global.globalAppConfig.currentBook.currentChapterInfo.pageStartPos[nextPage];
      }

      global.globalAppConfig.saveCurrentBookInfo();
    }
    setState(() => {});

    // tip : 等 widget 重新畫完後才呼叫 callback function "refreshAppBar"，這樣才會取得所有完成運算的值
    WidgetsBinding.instance.addPostFrameCallback((_) => {widget.refreshAppBar()});
  }

  @override
  Widget build(BuildContext context) {
    // 是否合法 ?
    if (global.globalAppConfig.currentBook.isValid) {
      // 載入目錄資訊
      if (!global.globalAppConfig.currentBook.alreadyLoadChapterList) {
        global.globalAppConfig.currentBook.loadBookChapterList();
      }
      // 載入本章內容
      if (!global.globalAppConfig.currentBook.hasChapterString) {
        global.globalAppConfig.currentBook.loadChapterString();
      }
    }

    if (global.globalAppConfig.currentBook.hasChapterString) {
      return GestureDetector(
          onTapDown: (details) => _onTap(details),
          child: Container(
            key: _keyPrintBook,
            color: global.globalAppConfig.canvasBackgroundColor,
            child: CustomPaint(size: Size.infinite, painter: MyPainter()),
          ));
    } else {
      return Container(
        color: global.globalAppConfig.canvasBackgroundColor,
      );
    }
  }
}

class MyPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    //print(size);

    // 計算章節屬性
    if (global.globalAppConfig.currentBook.currentChapterInfo.totalPages <= 0) {
      global.globalAppConfig.currentBook.currentChapterInfo.calculateChapterProperties(
          size,
          global.globalAppConfig.fontSize,
          global.globalAppConfig.canvasTopSpace,
          global.globalAppConfig.canvasBottomSpace,
          global.globalAppConfig.wordSpace,
          global.globalAppConfig.newlineSpace,
          global.globalAppConfig.paragraphSpace);
    }

    // 取得目前頁碼
    int currentPage =
      global.globalAppConfig.currentBook.currentChapterInfo.calculateCurrentPage(global.globalAppConfig.currentBook.currentPosInChapter);

    // debug
    int currentChapter = global.globalAppConfig.currentBook.currentChapter;
    print('currentChapter : $currentChapter');
    print('currentPage : $currentPage');

    TextStyle textStyle = TextStyle(
      // 因為預設 flutter 中文標點符號字形是對齊左下角，不是置中，因此另外下載 'Noto Sans Traditional Chinese' 字形，
      // 並在 pubspec.yaml 中定義只引用 NotoSansTC-Regular.otf 以節省空間
      // 下載地點 : https://fonts.google.com/
      fontFamily: 'NotoSansTC',
      color: global.globalAppConfig.canvasForegroundColor,
      fontSize: global.globalAppConfig.fontSize.toDouble(),
      height: global.globalAppConfig.wordSpace,
    );

    //
    int words = 0;
    int columns = 1;
    String columnString = '';
    bool drawColumn = false;
    int lastChracterPosition = global.globalAppConfig.currentBook.currentChapterInfo.chapterString.length -1;
    for (int i = global.globalAppConfig.currentBook.currentChapterInfo.pageStartPos[currentPage];
    i < global.globalAppConfig.currentBook.currentChapterInfo.chapterString.length;
    i++) {
      String ch = global.globalAppConfig.currentBook.currentChapterInfo.chapterString[i];

      // skip '\r'
      if (ch != '\r') {
        if (ch == '\n') {
          drawColumn = true;
          columns++;
          words = 0;
        } else {
          columnString += ch;
          words++;
        }

        if (words >= global.globalAppConfig.currentBook.currentChapterInfo.wordsPerLine) {
          drawColumn = true;
          columns++;
          words = 0;
        }

        if(i == lastChracterPosition) {
          drawColumn = true;
          columns++;
          words = 0;
        }
      }

      if(drawColumn){
        TextSpan textSpan = TextSpan(
          text: columnString,
          style: textStyle,
        );
        TextPainter textPainter = TextPainter(
          text: textSpan,
          textDirection: TextDirection.ltr,
          textAlign: TextAlign.center,
        );
        textPainter.layout(
          minWidth: 0,
          maxWidth: 4,
        );
        Offset offset = Offset(size.width - ((columns-1) * (global.globalAppConfig.fontSize + global.globalAppConfig.newlineSpace)), global.globalAppConfig.canvasTopSpace.toDouble());
        textPainter.paint(canvas, offset);

        drawColumn = false;
        columnString = '';
      }

      if (columns > global.globalAppConfig.currentBook.currentChapterInfo.columnsPerPage) break;
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
