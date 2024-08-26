import 'package:flutter/material.dart';
import 'package:securenote/models/noteModel.dart';
import 'package:securenote/services/database_helper.dart';

class ArchiveScreen extends StatefulWidget {
  @override
  _ArchiveScreenState createState() => _ArchiveScreenState();
}

class _ArchiveScreenState extends State<ArchiveScreen> {
  DatabaseHelper noteDatabase = DatabaseHelper.instance;
  List<NoteModel> archivedNotes = [];

  @override
  void initState() {
    super.initState();
    refreshArchivedNotes();
  }

  refreshArchivedNotes() {
    noteDatabase.getAll(archived: true).then((value) {
      setState(() {
        archivedNotes = value;
      });
    });
  }

  unarchiveNote({int? id}) async {
    NoteModel note = await noteDatabase.read(id!);
    note.isArchived = false;
    await noteDatabase.update(note);
    refreshArchivedNotes();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Archived Notes"),
      ),
      body: archivedNotes.isEmpty
          ? const Center(
        child: Text("No archived notes to display"),
      )
          : ListView.builder(
        itemCount: archivedNotes.length,
        itemBuilder: (context, index) {
          NoteModel note = archivedNotes[index];
          return ListTile(
            title: Text(note.title ?? ""),
            subtitle: Text(note.description ?? ""),
            trailing: IconButton(
              icon: const Icon(Icons.unarchive),
              onPressed: () => unarchiveNote(
                id: note.id,
              ),
            ),
            onTap: () => {},
          );
        },
      ),
    );
  }
}