import 'package:flutter/material.dart';
import 'global.dart' as global;
import 'app_config.dart';
import 'structure.dart';
import 'books_utility.dart';

class BrowseBooks extends StatefulWidget  {
  const BrowseBooks({super.key});

  @override
  State<BrowseBooks> createState() => _BrowseBooks();
}

class _BrowseBooks extends State<BrowseBooks> {

  String strDirName = '';
  AppConfig appConfig = AppConfig();

  @override
  void initState() {
    strDirName = global.globalAppConfig.getCurrentBookFolder();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    String receivedParameter = ModalRoute.of(context)!.settings.arguments as String;

    List<BookInfo> folders = <BookInfo>[];
    List<BookInfo> books = <BookInfo>[];

    BooksUtility bu = BooksUtility();

    List ans = bu.getBooksName(global.globalAppConfig.rootDir, strDirName);
    strDirName = ans[0];
    List booksName = ans[1];

    for(var i=0;i<booksName.length;i++){
      BookInfo value = booksName[i];
      if(value.isFile){
        books.add(value);
      }
      if(!value.isFile){
        folders.add(value);
      }
    }

    return Scaffold(
        appBar: AppBar(
          title: Text(global.globalAppConfig.convertToRelativePath(strDirName)),
        ),
        body: Row(children: [
          Expanded(
            child: Container(
              color: Theme.of(context).secondaryHeaderColor,
              child: ListView.builder(
                itemCount: folders.length,
                itemBuilder: (context, index) {
                  BookInfo folder = folders[index];
                  return ListTile(
                    minLeadingWidth: 24,
                    contentPadding: const EdgeInsets.only(left: 12, right: 2),
                    leading: folder.name == '..' ? const Icon(Icons.reply_outlined, color: Colors.blueAccent,) : const Icon(Icons.folder_open_outlined, color: Colors.blueGrey),
                    title: Text(folder.name),
                    onTap: (){
                      setState((){ strDirName = folder.path; });
                    },
                  );
                },
              ),
            ),
          ),
          Expanded(
              flex: 2,
              child: ListView.builder(
                itemCount: books.length,
                itemBuilder: (context, index) {
                  BookInfo book = books[index];
                  return ListTile(
                    leading: const Icon(Icons.menu_book_outlined, color: Colors.blueGrey,),
                    title: Text(book.name),
                    subtitle: Text(book.author),
                    onTap: (){
                      Navigator.of(context).pop(book);
                    }
                  );
                },
              ))
        ]));
  }
}

