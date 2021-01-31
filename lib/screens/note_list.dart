import 'package:flutter/material.dart';
import 'dart:async';
import '../database_helper.dart';
import '../Note.dart';
import 'note_details.dart';
import 'package:sqflite/sqflite.dart';

class NoteList extends StatefulWidget {
  @override
  _NoteListState createState() => _NoteListState();
}

class _NoteListState extends State<NoteList> {
  DatabaseHelper databaseHelper = DatabaseHelper();
  List<Note> noteList;
  int count = 0;

  Future<List<Note>> getNoteList() async {
    List<Note> noteList = await databaseHelper.getNoteList();
    return noteList;
  }

  @override
  Widget build(BuildContext context) {
    if (noteList != null) {
      noteList = List<Note>();
      updateListview();
    }
    return Scaffold(
      appBar: AppBar(
        title: Text('MyToDo App'),
        backgroundColor: Colors.blue,
      ),
      body: FutureBuilder<List<Note>>(
          future: getNoteList(), //Get the list of notes
          builder: (BuildContext context, AsyncSnapshot<List<Note>> snapshot) {
            if (snapshot.hasData) {
              List<Note> noteList = snapshot.data;

              //No notes yet
              if (noteList.isEmpty) {
                return Center(
                  child: Text('Add notes by tapping on the + button'),
                );
              }
              return ListView.builder(
                itemCount: noteList.length,
                itemBuilder: (BuildContext context, int index) {
                  Note note = noteList.elementAt(index);
                  String noteTitle = note.title;
                  String noteDescription = note.description;
                  String noteDate = note.date;
                  int notePriorityAsInt = note.priority;
                  String notePriorityAsString =
                      Util.getPrioritiyAsString(notePriorityAsInt);

                  return Card(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0)),
                    color: Colors.blue,
                    elevation: 4.0,
                    child: Column(
                      children: [
                        (ListTile(
                          leading: CircleAvatar(
                            backgroundImage: NetworkImage(
                                'https://learncodeonline.in/mascot.png'),
                          ),
                          title: Text(
                            noteTitle,
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 25.0,
                            ),
                          ),
                          subtitle: Text(
                            noteDate,
                            style: TextStyle(color: Colors.white),
                          ),
                          trailing: GestureDetector(
                              child: Icon(
                                Icons.open_in_new,
                                color: Colors.white,
                              ),
                              onTap: () {
                                navigateToDetail(note, ' Edit ToDo ');
                              }),
                        )),
                      ],
                    ),
                  );
                  // return ListTile(
                  // title: Text(noteTitle),
                  // subtitle: Column(
                  //   crossAxisAlignment: CrossAxisAlignment.start,
                  //   children: <Widget>[
                  //     noteDescription != null
                  //         ? Text(noteDescription)
                  //         : SizedBox
                  //             .shrink(), //Display nothing if descripion is null
                  //     Text(
                  //       noteDate,
                  //       style: TextStyle(
                  //         fontStyle: FontStyle.italic,
                  //       ),
                  //     ),
                  //   ],
                  // ),
                  // trailing: Text(notePriorityAsString),
                },
              );
            } else {
              //snapshot has no data which means it is still loading
              //so show a loader
              return Center(
                child: CircularProgressIndicator(),
              );
            }
          }),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blue,
        child: Icon(Icons.add),
        onPressed: () {
          navigateToDetail(Note('', '', 2), 'Add Note');
        },
      ),
    );
  }

  void navigateToDetail(Note note, String title) async {
    bool result =
        await Navigator.push(context, MaterialPageRoute(builder: (context) {
      return Note_details(note, title);
    }));

    if (result == true) {
      updateListview();
    }
  }

  void updateListview() {
    final Future<Database> dbFuture = databaseHelper.initalizeDatabase();
    dbFuture.then((database) {
      Future<List<Note>> noteListFuture = databaseHelper.getNoteList();
      noteListFuture.then((noteList) {
        setState(() {
          this.noteList = noteList;
          this.count = noteList.length;
        });
      });
    });
  }
}

class Util {
  static const priorities = ['High', 'Low'];

  static String getPrioritiyAsString(int value) {
    String priority;
    switch (value) {
      case 1:
        priority = priorities[0];
        break;
      case 2:
        priority = priorities[1];
        break;
    }
    return priority;
  }
}
