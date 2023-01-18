import 'package:flutter/material.dart';
import 'global.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

class BrowseChapters extends StatefulWidget {
  const BrowseChapters({super.key});

  @override
  State<BrowseChapters> createState() => _BrowseChapters();
}

class _BrowseChapters extends State<BrowseChapters> {
  final ItemScrollController itemScrollController = ItemScrollController();
  //final ItemPositionsListener itemPositionsListener = ItemPositionsListener.create();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(globalAppConfig.currentBook.name),
        ),
        body: Stack(children: [
          ScrollablePositionedList.builder(
            itemScrollController: itemScrollController,
            itemCount: globalAppConfig.currentBook.chapterCount,
            itemBuilder: (context, index) {
              return ListTile(
                  leading: const Icon(Icons.view_headline),
                  selected: (index == globalAppConfig.currentBook.currentChapter),
                  selectedColor: Colors.red,
                  selectedTileColor: Theme.of(context).secondaryHeaderColor,
                  title: Text(globalAppConfig.currentBook.getChapterName(index)),
                  onTap: () {
                    Navigator.of(context).pop(index);
                  });
            },
            initialScrollIndex:
                (globalAppConfig.currentBook.currentChapter - 3 > 0 ? globalAppConfig.currentBook.currentChapter - 3 : 0),
          ),
        Positioned(
          top: 0,
          right:0,
          child: FloatingActionButton.small(
            onPressed: () {
              itemScrollController.jumpTo(index: 0);
            },
            child: const Icon(Icons.vertical_align_top),
          ),
        ),
        Positioned(
            bottom: 0,
            right: 0,
            child: FloatingActionButton.small(
              onPressed: () {
                itemScrollController.jumpTo(index: globalAppConfig.currentBook.chapterCount-1);
                //itemScrollController.scrollTo(index: globalAppConfig.currentBook.chapterCount-1, duration: const Duration(seconds: 1));
              },
              child: const Icon(Icons.vertical_align_bottom),
            )
        ),
        ]));
  }
}
