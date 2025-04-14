import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:savek/db/db_helper.dart';
import 'package:savek/model/memo.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final _controller = TextEditingController();
  List<Memo> _memoList = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

		_loadMemo();
  }

	void _loadMemo() async {
		final memoList = await DBHelper.loadMemo();
		setState(() {
			_memoList = memoList;
		});
	}

  void _showBottomSheet() {
    final _amount = TextEditingController();
		final _content = TextEditingController();
    String _selectedDate = '';

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
                        (_selectedDate == '') ? '날짜를 선택하세요.' : _selectedDate,
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
                            _selectedDate = picked.toString().substring(0, 10);
														debugPrint(_selectedDate);
                          });
                        }
                      },
                    ),
										SizedBox(height: 10.0),
										TextField(
											controller: _amount,
											keyboardType: TextInputType.number,
											decoration: InputDecoration(
                        hintText: '금액',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        contentPadding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                      )
										),
										SizedBox(height: 10.0),
                    TextField(
                      controller: _content,
                      minLines: 2,
                      maxLines: 3,
                      decoration: InputDecoration(
                        hintText: '내용을 입력하세요.',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        contentPadding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                      )
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
                        if (_selectedDate != '' && _amount.text.isNotEmpty && _content.text.isNotEmpty) {
													await DBHelper.insertMemo(Memo(date: _selectedDate, amount: int.parse(_amount.text), content: _content.text));
												}
												Navigator.pop(context);
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
                    }
                  )
                ],
              )
            ),
            Expanded(
              child: ListView.builder(
                itemCount: _memoList.length,
                itemBuilder: (context, i) {
                  return ListTile(
                    title: Text('\u20A9 ${NumberFormat('#,###').format(_memoList[i].amount)} , ${_memoList[i].content}'),
										subtitle: Text(_memoList[i].date),
                    trailing: IconButton(
                      icon: Icon(Icons.delete),
                      onPressed: () {
                        debugPrint('check222');
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