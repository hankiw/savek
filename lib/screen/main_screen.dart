import 'package:flutter/material.dart';
import 'package:savek/db/db_helper.dart';
import 'package:savek/model/note.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final _controller = TextEditingController();
  List<Note> _notes = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    
    _loadNotes();
  }

  void _loadNotes() async {
    final notes = await DBHelper.fetchNotes();
    setState(() {
      _notes = notes;
    });
  }

  void _addNote() async {
    if (_controller.text.trim().isEmpty) return;

    final newNote = Note(content: _controller.text.trim());
    await DBHelper.insertNote(newNote);
    _controller.clear();
    _loadNotes();
  }

  void _deleteNote(int id) async {
    await DBHelper.deleteNote(id);
    _loadNotes();
  }

  void _showBottomSheet() {
    final _controller = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20))
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 20.0,
          right: 20.0,
          top: 20.0,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('add memo', style: TextStyle(fontSize: 10.0, fontWeight: FontWeight.bold)),
            TextField(
              controller: _controller,
              autofocus: true,
              maxLines: null,
            ),
            SizedBox(height: 10.0),
            ElevatedButton(
              onPressed: () async {
                final content = _controller.text.trim();
                if (content.isNotEmpty) {
                  await DBHelper.insertNote(Note(content: content));
                  Navigator.of(context).pop();
                  _loadNotes();
                }
              },
              child: Text('save'),
            ),
            SizedBox(height: 10.0),
          ]
        ),
      )
    );
  }

  // 미사용 (input dialog 띄우기)
  void _showAddNoteDialog() {
    final _dialogController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('add memo'),
        content: TextField(
          controller: _dialogController,
          autofocus: true,
          decoration: InputDecoration(hintText: 'memo'),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text('cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final content = _dialogController.text.trim();
              if (content.isNotEmpty) {
                await DBHelper.insertNote(Note(content: content));
                Navigator.of(context).pop();
                _loadNotes();
              }
            },
            child: Text('save'),
          )
        ]
      )
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('test note')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(hintText: 'input memo')
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.add),
                  onPressed: () {
                    debugPrint('check1');
                    _addNote();
                  }
                )
              ],
            )
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _notes.length,
              itemBuilder: (context, i) {
                return ListTile(
                  title: Text(_notes[i].content),
                  trailing: IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () {
                      debugPrint('check222');
                      _deleteNote(_notes[i].id!);
                    }
                  ),
                );
              }
            ),
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showBottomSheet,
        child: Icon(Icons.add),
      )
    );
  }
}