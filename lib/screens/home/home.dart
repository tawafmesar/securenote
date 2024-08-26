
import 'package:flutter/material.dart';
import 'package:securenote/screens/shared/topContainer.dart';
import 'package:securenote/models/noteModel.dart';
import 'package:securenote/screens/views/note_view.dart';
import 'package:securenote/services/database_helper.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

import '../archive/archive.dart';

class Home extends StatefulWidget {
  final String title;

  const Home({Key? key, required this.title}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  DatabaseHelper noteDatabase = DatabaseHelper.instance;
  List<NoteModel> notes = [];

  TextEditingController searchController = TextEditingController();
  bool isSearchTextNotEmpty = false;
  List<NoteModel> filteredNotes = [];

  @override
  void initState() {
    refreshNotes();
    search();
    super.initState();
  }

  @override
  dispose() {
    noteDatabase.close();
    super.dispose();
  }

  search() {
    searchController.addListener(() {
      setState(() {
        isSearchTextNotEmpty = searchController.text.isNotEmpty;
        if (isSearchTextNotEmpty) {
          filteredNotes = notes.where((note) {
            return note.title!.toLowerCase().contains(searchController.text.toLowerCase()) ||
                note.description!.toLowerCase().contains(searchController.text.toLowerCase());
          }).toList();
        } else {
          filteredNotes.clear();
        }
      });
    });
  }

  refreshNotes() {
    noteDatabase.getAll().then((value) {
      setState(() {
        notes = value;
      });
    });
  }

  goToNoteDetailsView({int? id}) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => NoteView(noteId: id)),
    );
    refreshNotes();
  }

  deleteNote({
    int? id
  }) async {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Row(children: const [
              Icon(
                Icons.delete_forever,
                color: Color.fromARGB(255, 255, 81, 0),
              ),
              Text('Delete permanently!')
            ]),
            content: SingleChildScrollView(
              child: ListBody(
                children: [
                  const Text('Are you sure, you want to delete this note?'),
                ],
              ),
            ),
            actions: [
              ElevatedButton(
                style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(Colors.red)
                ),
                onPressed: () async {
                  await noteDatabase.delete(id!);
                  Navigator.pop(context);
                  setState(() {});
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text("Note successfully deleted."),
                    backgroundColor: Color.fromARGB(255, 235, 108, 108),
                  ));
                  refreshNotes();
                },
                child: const Text('Yes'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('No'),
              ),
            ],
          );
        }
    );
  }

  goToArchiveScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ArchiveScreen()),
    );
  }

  archiveNote({int? id}) async {
    NoteModel note = await noteDatabase.read(id!);
    note.isArchived = true;
    await noteDatabase.update(note);
    refreshNotes();
  }

  pinUnpinNote({
    int? id
  }) async {
    NoteModel note = await noteDatabase.read(id!);
    note.isPinned = !note.isPinned;
    await noteDatabase.update(note);
    refreshNotes();
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: const Color.fromRGBO(247, 250, 252, 1.0),
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.archive),
            onPressed: goToArchiveScreen,
          ),
        ],
      ),
      body: Column(
        children: < Widget > [
          TopContainer(
            height: 160,
            width: width,
            child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: < Widget > [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 0, vertical: 0.0
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: < Widget > [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: < Widget > [
                            Container(
                              child: const Text(
                                'Secure Note',
                                textAlign: TextAlign.start,
                                style: TextStyle(
                                  fontSize: 22.0,
                                  color: Color.fromRGBO(247, 250, 252, 1.0),
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                            const Text(
                              'Manage and archive Your Notes',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 14.0,
                                color: Colors.white70,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                  )
                ]
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: searchController,
                    decoration: const InputDecoration(
                      hintText: 'Search Notes...',
                      prefixIcon: Icon(Icons.search),
                    ),
                  ),
                ),
                if (isSearchTextNotEmpty)
                  IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      searchController.clear();
                      filteredNotes.clear();
                      refreshNotes();
                    },
                  ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Container(
                    child: notes.isEmpty ?
                    const Padding(
                      padding: EdgeInsets.only(top: 50.0),
                      child: Text(
                        "No notes to display",
                        style: TextStyle(
                          fontWeight: FontWeight.normal,
                          fontSize: 14,
                        ),
                      ),
                    ): Column(
                      children: [
                        if (isSearchTextNotEmpty)
                          ...filteredNotes.map((note) {
                            return buildNoteCard(note);
                          }).toList()
                        else
                          ...notes.map((note) {
                            return buildNoteCard(note);
                          }).toList(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: goToNoteDetailsView,
        tooltip: 'Create Note',
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget buildNoteCard(NoteModel note) {
    return Card(
      child: GestureDetector(
        onTap: () => {},
        child: ListTile(
          leading: const Icon(
            Icons.note,
            color: Color.fromARGB(255, 253, 237, 89),
          ),
          title: Text(note.title ?? ""),
          subtitle: Text(note.description ?? ""),
          trailing: Wrap(
            children: [
              IconButton(
                onPressed: () => goToNoteDetailsView(id: note.id),
                icon: const Icon(Icons.arrow_forward_ios),
              ),
              IconButton(
                onPressed: () => deleteNote(id: note.id),
                icon: const Icon(
                  Icons.delete,
                  color: Color.fromARGB(255, 255, 81, 0),
                ),
              ),
              IconButton(
                onPressed: () => archiveNote(
                  id: note.id,
                ),
                icon: const Icon(Icons.archive),
              ),
              IconButton(
                onPressed: () => pinUnpinNote(
                  id: note.id,
                ),
                icon: Icon(
                  note.isPinned ? Icons.push_pin : Icons.push_pin_outlined,
                  color: note.isPinned ? Colors.blue : Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Text subheading(String title) {
    return Text(
      title,
      style: const TextStyle(
          color: Color.fromRGBO(94, 114, 228, 1.0),
          fontSize: 20.0,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.2),
    );
  }
}