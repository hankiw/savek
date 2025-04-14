class Memo {
  // CREATE TABLE memo (id INTEGER PRIMARY KEY AUTOINCREMENT, date TEXT, amount INTEGER, content TEXT)

  final int? id;
  final String date;
  final int amount;
  final String content;

  // contructor
  Memo({
    this.id,
    required this.date,
    required this.amount,
    required this.content,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date,
      'amount': amount,
      'content': content,
    };
  }

  factory Memo.fromMap(Map<String, dynamic> map) {
    return Memo(id: map['id'], date: map['date'], amount: map['amount'], content: map['content']);
  }
}