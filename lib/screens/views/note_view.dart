import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:securenote/models/noteModel.dart';
import 'package:securenote/services/database_helper.dart';

class NoteView extends StatefulWidget {
  const NoteView({Key? key, this.noteId}) : super(key: key);
  final int? noteId;

  @override
  State<NoteView> createState() => _NoteViewState();
}

class _NoteViewState extends State<NoteView> {
  final formKey = GlobalKey<FormState>();

  DatabaseHelper noteDatabase = DatabaseHelper.instance;
  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();

  late NoteModel note;
  bool isLoading = false;
  bool isNewNote = false;

  @override
  void initState() {
    refreshNotes();
    super.initState();
  }

  refreshNotes() {
    if (widget.noteId == null) {
      setState(() {
        isNewNote = true;
      });
      return;
    }
    noteDatabase.read(widget.noteId!).then((value) {
      setState(() {
        note = value;
        titleController.text = note.title ?? '';
        descriptionController.text = note.description ?? '';
      });
    });
  }

  insert(NoteModel model) {
    noteDatabase.insert(model).then((respond) async {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Note successfully added."),
        backgroundColor: Color.fromARGB(255, 4, 160, 74),
      ));
      Navigator.pop(context, {'reload': true});
    }).catchError((error) {
      if (kDebugMode) {
        print(error);
      }
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Note failed to save."),
        backgroundColor: Color.fromARGB(255, 235, 108, 108),
      ));
    });
  }

  update(NoteModel model) {
    noteDatabase.update(model).then((respond) async {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Note successfully updated."),
        backgroundColor: Color.fromARGB(255, 4, 160, 74),
      ));
      Navigator.pop(context, {'reload': true});
    }).catchError((error) {
      if (kDebugMode) {
        print(error);
      }
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Note failed to update."),
        backgroundColor: Color.fromARGB(255, 235, 108, 108),
      ));
    });
  }

  createNote() async {
    setState(() {
      isLoading = true;
    });

    if (formKey.currentState != null && formKey.currentState!.validate()) {
      formKey.currentState?.save();

      NoteModel model = NoteModel(titleController.text, descriptionController.text);

      if (isNewNote) {
        insert(model);
      } else {
        model.id = note.id;
        update(model);
      }
    }
    setState(() {
      isLoading = false;
    });
  }

  deleteNote() {
    noteDatabase.delete(note.id!);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text("Note successfully deleted."),
      backgroundColor: Color.fromARGB(255, 235, 108, 108),
    ));
    Navigator.pop(context);
  }

  togglePin() async {
    note.isPinned = !note.isPinned;
    await noteDatabase.update(note);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(note.isPinned ? "Note pinned" : "Note unpinned"),
      backgroundColor: note.isPinned ? Colors.blue : Colors.grey,
    ));
    refreshNotes();
  }

  String? validateTitle(String? value) {
    if (value == null || value.isEmpty) {
      return 'Enter a title.';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(247, 250, 252, 1.0),
      appBar: AppBar(
        backgroundColor: const Color.fromRGBO(94, 114, 228, 1.0),
        elevation: 0.0,
        title: Text(
          isNewNote ? 'Add a note' : 'Edit note',
        ),
        actions: [
          if (!isNewNote)
            IconButton(
              icon: Icon(
                note.isPinned ? Icons.push_pin : Icons.push_pin_outlined,
              ),
              onPressed: togglePin,
            ),
        ],
      ),
      body: Form(
        key: formKey,
        child: Container(
          padding: const EdgeInsets.all(30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextFormField(
                    controller: titleController,
                    decoration: const InputDecoration(
                      hintText: "Enter the title",
                      labelText: 'Title',
                      border: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors.white,
                          width: 0.75,
                        ),
                        borderRadius: BorderRadius.all(
                          Radius.circular(10.0),
                        ),
                      ),
                    ),
                    validator: validateTitle,
                  ),
                ],
              ),
              const SizedBox(
                height: 20,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextFormField(
                    controller: descriptionController,
                    decoration: const InputDecoration(
                      hintText: "Enter the description",
                      labelText: 'Description',
                      border: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors.white,
                          width: 0.75,
                        ),
                        borderRadius: BorderRadius.all(
                          Radius.circular(10.0),
                        ),
                      ),
                    ),
                    keyboardType: TextInputType.multiline,
                    maxLines: 2,
                  ),
                ],
              ),
              const SizedBox(
                height: 20,
              ),
              Container(
                width: double.infinity,
                margin: const EdgeInsets.all(10.0),
                child: ElevatedButton(
                  onPressed: createNote,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromRGBO(94, 114, 228, 1.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    padding: const EdgeInsets.all(20),
                  ),
                  child: const Text(
                    "Save",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
              ),
              Container(
                width: double.infinity,
                margin: const EdgeInsets.all(10.0),
                child: Visibility(
                  visible: !isNewNote, // Set this to determine if the button should be visible
                  child: ElevatedButton(
                    onPressed: deleteNote,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 235, 108, 108),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      padding: const EdgeInsets.all(20),
                    ),
                    child: const Text(
                      "Delete",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}