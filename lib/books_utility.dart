import 'dart:io';
import 'extensions.dart';
import 'package:path/path.dart';
import 'dart:convert' show utf8;
import 'dart:typed_data';
import 'structure.dart';
import 'big5.dart';

class BooksUtility {
  static const List<String> acceptFileExtensions = <String>['.updb', '.pdb'];
  static const Map chineseNumber = {'一': 1, '二': 2, '三': 3, '四': 4, '五': 5, '六': 6, '七': 7, '八': 8, '九': 9};

  String externalStoragePath = '';

  // Get books name in a directory
  List getBooksName(String rootDir, String strDirName) {
    List answer = [];
    List mapBooks = [];

    var dir = Directory(strDirName);

    if (strDirName != rootDir && strDirName != '') {
      BookInfo objBookInfo = BookInfo();
      objBookInfo.isFile = false;
      objBookInfo.path = dir.parent.path;
      objBookInfo.key = objBookInfo.name = '..';
      mapBooks.add(objBookInfo);
    }

    try {
      List<FileSystemEntity> allFiles = dir.listSync(recursive: false, followLinks: false);

      for (FileSystemEntity element in allFiles) {
        if ((element is Directory) || (element is File && acceptFileExtensions.contains(extension(element.path)))) {
          BookInfo objBookInfo = BookInfo();
          objBookInfo.isFile = (element is File) ? true : false;
          objBookInfo.key = basename(element.path);
          objBookInfo.path = element.path;
          objBookInfo.name = basenameWithoutExtension(element.path);

          String keyName = objBookInfo.name;
          String lastWord = keyName.substring(keyName.length - 1);
          if (chineseNumber.keys.contains(lastWord)) {
            objBookInfo.key = keyName.substring(0, keyName.length - 1) + chineseNumber[lastWord].toString();
          }

          if (element is File) {
            Map bookSpec = getBookSpec(element.path);
            objBookInfo.key = bookSpec['fileType'] + bookSpec['author'] + objBookInfo.key;
            objBookInfo.name = bookSpec['bookName'];
            objBookInfo.author = bookSpec['author'];
          }

          mapBooks.add(objBookInfo);
        }
      }
      // sort by key
      mapBooks.sort((a, b) => a.key.compareTo(b.key));
    } catch (e) {
      var des = e.toString();
    }

    answer.add(strDirName);
    answer.add(mapBooks);

    return answer;
  }

  // Get book specification
  Map getBookSpec(String fileName) {
    Map bookSpec = {};

    String fileExtension = extension(fileName).toUpperCase();
    if (fileExtension == '.UPDB') {
      bookSpec = getUPDBFileSpec(fileName);
    }
    if (fileExtension == '.PDB') {
      bookSpec = getPDBFileSpec(fileName);
    }

    return bookSpec;
  }

  // Get uPDB file specification
  Map getUPDBFileSpec(String fileName) {
    Map bookSpec = {};

    File file = File(fileName);
    RandomAccessFile raf = file.openSync(mode: FileMode.read);

    Uint8List bytes;

    raf.setPositionSync(0);
    bytes = raf.readSync(35);
    int nullStartPos = findSubListInList(bytes, [0]);
    String author = String.fromCharCodes(bytes.sublist(0,nullStartPos).buffer.asUint16List());
    bookSpec['author'] = author.trim();

    raf.setPositionSync(64);
    bytes = raf.readSync(4);
    String fileType = utf8.decode(bytes);
    bookSpec['fileType'] = fileType;

    raf.setPositionSync(76);
    bytes = raf.readSync(2);
    int recordCount = ByteData.view(bytes.buffer).getUint16(0);
    bookSpec['recordCount'] = recordCount;

    List<int> recordStartPos = [];
    for (int i = 0; i < recordCount; i++) {
      raf.setPositionSync(78 + (8 * i));
      bytes = raf.readSync(4);
      recordStartPos.add(ByteData.view(bytes.buffer).getUint32(0));
    }
    bookSpec['recordStartPos'] = recordStartPos;

    // 1'st record
    raf.setPositionSync(recordStartPos[0]);
    bytes = raf.readSync(recordStartPos[1] - recordStartPos[0]);
    var tmp = Uint8List.fromList(bytes + Uint8List.fromList([13, 0, 10, 0]));

    int escStartPos = findSubListInList(tmp, [27, 0, 27, 0, 27, 0]);
    String bookName = String.fromCharCodes(tmp.sublist(8, escStartPos).buffer.asUint16List());
    bookSpec['bookName'] = bookName;

    int currentIndex = escStartPos + 6;

    escStartPos = findSubListInList(tmp, [27, 0], currentIndex);
    int chapterCount = int.parse(String.fromCharCodes(tmp.sublist(currentIndex, escStartPos)));
    bookSpec['chapterCount'] = chapterCount;

    currentIndex = escStartPos + 2;
    List<String> chapterList = [];
    int chapterEnd = 0;
    while ((chapterEnd = findSubListInList(tmp.sublist(currentIndex, tmp.length), [13, 0, 10, 0])) != -1) {
      chapterList.add(String.fromCharCodes(tmp.sublist(currentIndex, currentIndex + chapterEnd).buffer.asUint16List()));
      currentIndex += (chapterEnd + 4);
    }
    bookSpec['chapterList'] = chapterList;

    raf.closeSync();

    return bookSpec;
  }

  // Get PDB file specification
  Map getPDBFileSpec(String fileName) {
    Map bookSpec = {};

    File file = File(fileName);
    RandomAccessFile raf = file.openSync(mode: FileMode.read);

    Uint8List bytes;

    raf.setPositionSync(0);
    bytes = raf.readSync(35);
    String author = Big5.decode(bytes);
    bookSpec['author'] = '';

    raf.setPositionSync(64);
    bytes = raf.readSync(4);
    String fileType = utf8.decode(bytes);
    bookSpec['fileType'] = fileType;

    raf.setPositionSync(76);
    bytes = raf.readSync(2);
    int recordCount = ByteData.view(bytes.buffer).getUint16(0);
    bookSpec['recordCount'] = recordCount;

    List<int> recordStartPos = [];
    for (int i = 0; i < recordCount; i++) {
      raf.setPositionSync(78 + (8 * i));
      bytes = raf.readSync(4);
      recordStartPos.add(ByteData.view(bytes.buffer).getUint32(0));
    }
    bookSpec['recordStartPos'] = recordStartPos;

    // 1'st record
    raf.setPositionSync(recordStartPos[0]);
    bytes = raf.readSync(recordStartPos[1] - recordStartPos[0]);
    var tmp = Uint8List.fromList(bytes + Uint8List.fromList([27]));

    int escStartPos = findSubListInList(tmp, [27, 27, 27]);
    String bookName = Big5.decode(tmp.sublist(8, escStartPos));
    bookSpec['bookName'] = bookName;

    int currentIndex = escStartPos + 3;

    escStartPos = findSubListInList(tmp, [27], currentIndex);
    int chapterCount = int.parse(String.fromCharCodes(tmp.sublist(currentIndex, escStartPos)));
    bookSpec['chapterCount'] = chapterCount;

    currentIndex = escStartPos + 1;
    List<String> chapterList = [];
    int chapterEnd = 0;
    while ((chapterEnd = findSubListInList(tmp.sublist(currentIndex, tmp.length), [27])) != -1) {
      chapterList.add(Big5.decode(tmp.sublist(currentIndex, currentIndex + chapterEnd)));
      currentIndex += (chapterEnd + 1);
    }
    bookSpec['chapterList'] = chapterList;

    raf.closeSync();

    return bookSpec;
  }

  // Get chapter contents (chapterNumber = 1,2,3, ...)
  String getChapterContents(String fileName, int chapterNumber) {
    String chapterString = '';

    String fileExtension = extension(fileName).toUpperCase();

    if (fileExtension == '.UPDB') {
      chapterString = getUPDBChapterContents(fileName, chapterNumber);
    }

    if (fileExtension == '.PDB') {
      chapterString = getPDBChapterContents(fileName, chapterNumber);
    }

    return chapterString;
  }

  // Get uPDB chapter (chapterNumber = 1,2,3, ...)
  String getUPDBChapterContents(String fileName, int chapterNumber) {
    String chapterString = '';
    Map bookSpec = getUPDBFileSpec(fileName);

    chapterNumber++;

    if (chapterNumber >= 1 && chapterNumber <= (bookSpec['recordCount'] - 2)) {
      List<int> recordStartPos = bookSpec['recordStartPos'];
      File file = File(fileName);
      RandomAccessFile raf = file.openSync(mode: FileMode.read);
      raf.setPositionSync(recordStartPos[chapterNumber]);
      var bytes = raf.readSync(recordStartPos[chapterNumber + 1] - recordStartPos[chapterNumber]);
      chapterString = String.fromCharCodes(bytes.buffer.asUint16List());
      raf.close();
    }

    return chapterString.toFullWidth();
  }

  // Get uPDB chapter (chapterNumber = 1,2,3, ...)
  String getPDBChapterContents(String fileName, int chapterNumber) {
    String chapterString = '';
    Map bookSpec = getPDBFileSpec(fileName);

    chapterNumber++;

    if (chapterNumber >= 1 && chapterNumber <= (bookSpec['recordCount'] - 2)) {
      List<int> recordStartPos = bookSpec['recordStartPos'];
      File file = File(fileName);
      RandomAccessFile raf = file.openSync(mode: FileMode.read);
      raf.setPositionSync(recordStartPos[chapterNumber]);
      var bytes = raf.readSync(recordStartPos[chapterNumber + 1] - recordStartPos[chapterNumber]);
      chapterString = Big5.decode(bytes);
      raf.close();
    }

    return chapterString.toFullWidth();
  }

  // isListEqual
  bool isListEqual(var list1, var list2) {
    if (list1.length != list2.length) {
      return false;
    }

    for (int i = 0; i < list1.length; i++) {
      if (list1[i] != list2[i]) {
        return false;
      }
    }

    return true;
  }

  // findSubListInList
  int findSubListInList(var listSource, var listFind, [int startPos = 0]) {
    int listFindLength = listFind.length;

    for (int i = startPos; i <= listSource.length - listFindLength; i++) {
      if (isListEqual(listSource.sublist(i, i + listFindLength), listFind)) {
        return i;
      }
    }

    return -1;
  }
}
