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
    final _inputController = TextEditingController();
    DateTime? _selectedDate;
    String? _selectedDateText;

    showModalBottomSheet(
      backgroundColor: Colors.white,
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20))
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) => Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom + 20.0,
              left: 20.0,
              right: 20.0,
              top: 20.0,
            ),
            child: Wrap(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Center(
                      child: Container(
                        width: 40.0,
                        height: 4.0,
                        margin: EdgeInsets.only(bottom: 20.0),
                        decoration: BoxDecoration(
                          color: Colors.grey[400],
                          borderRadius: BorderRadius.circular(2),
                        )
                      ),
                    ),
                    Text('new memo', style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold)),
                    SizedBox(height: 10.0),
                    TextField(
                      controller: _inputController,
                      minLines: 2,
                      maxLines: 3,
                      decoration: InputDecoration(
                        hintText: '....',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        contentPadding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                      )
                    ),
                    SizedBox(height: 10.0),
                    TextButton.icon(
                      style: TextButton.styleFrom(
                        backgroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.0),
                          side: BorderSide(color: Colors.grey)
                        ),
                      ),
                      icon: Icon(Icons.calendar_today, color: Colors.blueAccent),
                      label: Text(
                        (_selectedDate == null) ? '날짜를 선택하세요.' : _selectedDateText.toString(),
                        style: TextStyle(color: Colors.blueAccent),
                      ),
                      onPressed: () async {
                        final now = DateTime.now();
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: now,
                          firstDate: DateTime(now.year, now.month - 1),
                          lastDate: DateTime(now.year, now.month, now.day),
                        );

                        if (picked != null) {
                          setState(() {
                            _selectedDate = picked;
                            _selectedDateText = _selectedDate.toString().substring(0, 10);
                          });
                        }
                      },
                    ),
                    SizedBox(height: 20.0),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent,
                        padding: EdgeInsets.symmetric(vertical: 14.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.0)
                        ),
                      ),
                      onPressed: () async {
                        if (_inputController.text.trim().isEmpty) return;

                        final newNote = Note(content: _inputController.text.trim());
                        await DBHelper.insertNote(newNote);
                        _controller.clear();
                        Navigator.pop(context);
                        _loadNotes();
                      },
                      child: Text('SAVE', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 18.0)),
                    ),
                    SizedBox(height: 10.0),
                  ],
                )
              ],
            ),
          ),
        );
      }
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('test note')),
      body: SafeArea(
        child: Column(
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
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showBottomSheet,
        child: Icon(Icons.add),
      )
    );
  }
}