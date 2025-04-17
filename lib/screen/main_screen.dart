import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:intl/intl.dart';
import 'package:savek/ad_mob_service.dart';
import 'package:savek/component/main_header.dart';
import 'package:savek/db/db_helper.dart';
import 'package:savek/model/memo.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {

  // google admob
  BannerAd? _bannerAd;

  // memo data
  DateTime _saveDateTime = DateTime.now();
  String _saveYM = '';
  List<Memo> _memoList = [];

  // summary
  int _sumAmount = 0;
  String _sumSentiment = 'sentiment_neutral';

  final Map<String, Widget> _sentimentIcon = {
    'sentiment_very_dissatisfied': Icon(Icons.sentiment_very_dissatisfied, size: 48, color: Colors.red),
    'sentiment_dissatisfied': Icon(Icons.sentiment_dissatisfied, size: 48, color: Colors.red),
    'sentiment_neutral': Icon(Icons.sentiment_neutral, size: 48, color: Colors.yellow),
    'sentiment_satisfied': Icon(Icons.sentiment_satisfied, size: 48, color: Colors.green),
    'sentiment_very_satisfied': Icon(Icons.sentiment_very_satisfied, size: 48, color: Colors.green),
  };  

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    // google admob init
    _createBannerAd();

    _init();
  }

  void _init() async {
    final saveYM = DateFormat('yyyy-MM').format(_saveDateTime);

    _loadMemo(saveYM);

    setState(() {
      _saveYM = saveYM;
    });
  }

  void _createBannerAd() {
    _bannerAd = BannerAd(
      size: AdSize.fullBanner,
      adUnitId: AdMobService.bannerAdUnitID!,
      listener: AdMobService.bannerAdListener,
      request: const AdRequest(),
    )
      ..load();
  }

	void _loadMemo([String searchYM = '']) async {
    if (searchYM == '') {
      final now = DateTime.now();
      searchYM = DateFormat('yyyy-MM').format(now);
    }

		final memoList = await DBHelper.loadMemo(searchYM);
    int sumAmount = 0;
    String sumSentiment = 'sentiment_very_dissatisfied';

    List.generate(
      memoList.length,
      (i) {
        sumAmount += memoList[i].amount;
      }
    );

    if (sumAmount >= 600000) {
      sumSentiment = 'sentiment_very_satisfied';
    } else if (sumAmount >= 400000) {
      sumSentiment = 'sentiment_satisfied';
    } else if (sumAmount >= 200000) {
      sumSentiment = 'sentiment_neutral';
    } else if (sumAmount > 0) {
      sumSentiment = 'sentiment_dissatisfied';
    } else {
      sumSentiment = 'sentiment_very_dissatisfied';
    }

		setState(() {
      _sumSentiment = sumSentiment;
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
  
  void _showDeleteConfirm(BuildContext context, VoidCallback onConfirm) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
				backgroundColor: Colors.white,
        title: Text('노트 삭제'),
        content: Text('티끌모아 태산이라니까요.. 😢'),
        actions: [
          ElevatedButton(
						style: ElevatedButton.styleFrom(
							backgroundColor: Colors.white,
							foregroundColor: Colors.black87,
							shape: RoundedRectangleBorder(
								borderRadius: BorderRadius.circular(30),
							),
							side: BorderSide(color: Colors.grey.shade300),
							elevation: 0,
						),
            child: Text('취소', style: TextStyle(color: Colors.black)),
            onPressed: () => Navigator.of(context).pop()
          ),
          ElevatedButton(
						style: ElevatedButton.styleFrom(
							backgroundColor: Colors.white,
							foregroundColor: Colors.black87,
							shape: RoundedRectangleBorder(
								borderRadius: BorderRadius.circular(30),
							),
							side: BorderSide(color: Colors.grey.shade300),
							elevation: 0,
						),
            child: Text('삭제'),
            onPressed: () {
              Navigator.of(context).pop();
              onConfirm();
            }
          )
        ],
      )
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
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
                decoration: BoxDecoration(
                  color: Colors.blueGrey[200],
                  borderRadius: BorderRadius.circular(8.0),
                ),
                alignment: Alignment.topRight,
                child: Row(
                  children: [
                    Column(
                      children: [
                        _sentimentIcon[_sumSentiment] ?? SizedBox(),
                      ],
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '${int.parse(_saveYM.substring(5, 7))}월에 이만큼 절약했어요',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18.0,
                              fontWeight: FontWeight.normal,
                            )
                          ),
                          SizedBox(height: 10.0),
                          Text(
                            '\u20A9 ${NumberFormat('#,###').format(_sumAmount)}',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 22.0,
                              fontWeight: FontWeight.w900,
                            )
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              alignment: Alignment.centerLeft,
              child: Row(
                children: [
                  Expanded(
                    child: Text('${_saveYM}', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.0, color: Colors.black)),
                  ),
                  Container(
                    width: 36.0,
                    height: 36.0,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.black.withAlpha(50),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back_ios_rounded, size: 15.0, color: Colors.white),
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
                    width: 36.0,
                    height: 36.0,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.black.withAlpha(50),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.arrow_forward_ios_rounded, size: 15.0, color: Colors.white),
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
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 5.0),
                    child: Container(
                      padding: const EdgeInsets.all(8.0),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      child: Row(
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${_memoList[i].content}',
                                style: TextStyle(
                                  color: Colors.black87,
                                  fontSize: 20.0,
                                )
                              ),
                              SizedBox(height: 5.0),
                              Text(
                                '${_memoList[i].date}',
                                style: TextStyle(
                                  color: Colors.black54
                                )
                              )
                            ],
                          ),
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.only(right: 10.0),
                              alignment: Alignment.centerRight,
                              child: Text(
                                '\u20A9 ${NumberFormat('#,###').format(_memoList[i].amount)}',
                                style: TextStyle(
                                  fontSize: 20.0,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black,
                                  letterSpacing: 0,
                                ),
                              ),
                            )
                          ),
													Container(
														alignment: Alignment.centerRight,
														child: IconButton(
															iconSize: 18.0,
															icon: Icon(Icons.delete),
															onPressed: () {
																_showDeleteConfirm(context, () async {
																	await DBHelper.deleteMemo(_memoList[i].id ?? -1);
																	_loadMemo();
																});
															}
														),
													)
                        ],
                      ),
                    ),
                  );
                }
              ),
            ),
						Container(
							height: 60.0,
							child: AdWidget(
                ad: _bannerAd!
              ),
						)
					],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showBottomSheet,
				// label: Text('메모 추가', style: TextStyle(color: Colors.white)),
				// icon: Icon(Icons.edit_note_rounded, color: Colors.white),
				backgroundColor: Colors.blue.shade800,
				shape: StadiumBorder(),
        child: Icon(Icons.edit_note_rounded, color: Colors.white, size: 32.0),
      ),
			floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}