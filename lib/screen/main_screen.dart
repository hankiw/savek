import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:savek/component/main_header.dart';
import 'package:savek/db/db_helper.dart';
import 'package:savek/model/memo.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {

  // memo data
  DateTime _saveDateTime = DateTime.now();
  String _saveYM = '';
  List<Memo> _memoList = [];

  // summary
  int _sumAmount = 0;
  

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    _init();
  }

  void _init() async {
    final saveYM = DateFormat('yyyy-MM').format(_saveDateTime);

    _loadMemo(saveYM);

    setState(() {
      _saveYM = saveYM;
    });
  }

	void _loadMemo([String searchYM = '']) async {
    if (searchYM == '') {
      final now = DateTime.now();
      searchYM = DateFormat('yyyy-MM').format(now);
    }

		final memoList = await DBHelper.loadMemo(searchYM);
    int sumAmount = 0;

    List.generate(
      memoList.length,
      (i) {
        sumAmount += memoList[i].amount;
      }
    );

		setState(() {
      _sumAmount = sumAmount;
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
                        _loadMemo();
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
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: Column(
          children: [
            MainHeader(),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
              alignment: Alignment.topRight,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('lorem ipsum dolor sit amet'),
                  SizedBox(height: 10.0),
                  Text('\u20A9 ${NumberFormat('#,###').format(_sumAmount)}'),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              alignment: Alignment.centerLeft,
              child: Row(
                children: [
                  Expanded(
                    child: Text('${_saveYM} lorem ipsum', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.0, color: Colors.black)),
                  ),
                  Container(
                    height: 40.0,
                    width: 40.0,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.black.withAlpha(50),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back, size: 15.0, color: Colors.white),
                      onPressed: () async {
                        final targetDateTime = DateTime(_saveDateTime.year, (_saveDateTime.month - 1), _saveDateTime.day);
                        final saveYM = DateFormat('yyyy-MM').format(targetDateTime);
                        _loadMemo(saveYM);
                        setState(() {
                          _saveDateTime = targetDateTime;
                          _saveYM = saveYM;
                        });
                      },
                    ),
                  ),
                  SizedBox(width: 10.0),
                  Container(
                    height: 40.0,
                    width: 40.0,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.black.withAlpha(50),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.arrow_forward, size: 15.0, color: Colors.white),
                      onPressed: () async {
                        final targetDateTime = DateTime(_saveDateTime.year, (_saveDateTime.month + 1), _saveDateTime.day);
                        final saveYM = DateFormat('yyyy-MM').format(targetDateTime);
                        _loadMemo(saveYM);
                        setState(() {
                          _saveDateTime = targetDateTime;
                          _saveYM = saveYM;
                        });
                      },
                    ),
                  )
                ],
              ),
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