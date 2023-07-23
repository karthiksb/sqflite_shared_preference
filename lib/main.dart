import 'package:flutter/material.dart';
import 'package:storage_flutter/Models/Note.dart';
import 'package:storage_flutter/utils/database_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main()  async{
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter storage'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
 Color appbarColor = Colors.amber;

  final dbHelper = DatabaseHelper();
  TextEditingController titleController = TextEditingController();
  TextEditingController contentController = TextEditingController();
  List<Note> notes = [];

  @override
  void initState() {
    print("start");
    // TODO: implement initState
    super.initState();
    refreshNotes();
    _loadSelectedColor();
    print("end");

  }

  void refreshNotes() async {
    List<Note> retrievedNotes = await dbHelper.getNotes();
    setState(() {
      notes = retrievedNotes;
    });
  }

  void _saveNote() async {
    String title = titleController.text.trim();
    String content = contentController.text.trim();

    if (title.isNotEmpty && content.isNotEmpty) {
      Note note = Note(
        title: title,
        content: content,
      );
      await dbHelper.insert(note);
      titleController.clear();
      contentController.clear();
      refreshNotes();
    }
  }

  void _deleteNote(int id) async {
    await dbHelper.delete(id);
    refreshNotes();
  }

 void _loadSelectedColor() async {
   SharedPreferences prefs = await SharedPreferences.getInstance();
   int? colorValue = prefs.getInt('appbarColor');
   if (colorValue != null) {
     setState(() {
       appbarColor = Color(colorValue);
     });
   }
 }

 _saveSelectedColor(Color selectedColor) async{
   SharedPreferences prefs = await SharedPreferences.getInstance();
   await prefs.setInt('appbarColor', selectedColor.value);
 }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor:  appbarColor,
        title: Text(widget.title),
        actions: <Widget>[
          PopupMenuButton<Color>(
            onSelected: (Color selectedColor) {
              setState(() {
                appbarColor = selectedColor;
              });
              _saveSelectedColor(selectedColor);
            },
            itemBuilder: (BuildContext context) {
              return <PopupMenuEntry<Color>>[
                const PopupMenuItem(
                  value: Colors.blue,
                  child: Text('Blue'),
                ),
                const PopupMenuItem(
                  value: Colors.red,
                  child: Text('Red'),
                ),
                const PopupMenuItem(
                  value: Colors.green,
                  child: Text('Green'),
                ),
              ];
            },
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: notes.length,
        itemBuilder: (context, index) {
          Note note = notes[index];
          return Column(
            children: [
              ListTile(
                title: Text(note.title),
                subtitle: Text(note.content),
                trailing: IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () {
                    _deleteNote(note.id!);
                  },
                ),
              ),
              const Divider(
                thickness: 1,
                color: Colors.black,
              )
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: const Text('Add Note'),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: titleController,
                      decoration: const InputDecoration(
                        labelText: 'Title',
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: contentController,
                      decoration: const InputDecoration(
                        labelText: 'Content',
                      ),
                    ),
                  ],
                ),
                actions: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text('Cancel'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      _saveNote();
                      Navigator.of(context).pop();
                    },
                    child: const Text('Save'),
                  ),
                ],
              );
            },
          );
        },
        tooltip: 'Add note',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
