import 'dart:math';
import 'package:flutter/material.dart';

class MainHeader extends StatelessWidget {
  const MainHeader({super.key});

  @override
  Widget build(BuildContext context) {
    List<String> _sentence = [
      '절약은 나를 위한 선물이에요. 😀',
      '돈을 아끼는 습관이 나를 부자로 만든다. 🤓',
      '하루 천 원의 기적, 시작해볼까요? 😎',
      '티끌모아 태산이다 😊',
    ];

    final randomIndex = Random().nextInt(_sentence.length);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      alignment: Alignment.bottomCenter,
      decoration: BoxDecoration(color: Colors.blue.shade800),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(_sentence[randomIndex], style: TextStyle(fontSize: 14.0, fontWeight: FontWeight.bold, color: Colors.white)),
              Text('절약노트', style: TextStyle(fontSize: 26.0, fontWeight: FontWeight.bold, color: Colors.white)),
            ],
          ),
          // Row(
          //   children: [
          //     Container(
          //       decoration: BoxDecoration(
          //         borderRadius: BorderRadius.circular(15),
          //         color: Colors.black.withAlpha(50),
          //       ),
          //       child: IconButton(
          //         icon: const Icon(Icons.search, size: 28.0, color: Colors.white),
          //         onPressed: () {},
          //       ),
          //     ),
          //     SizedBox(width: 10.0),
          //     Container(
          //       decoration: BoxDecoration(
          //         borderRadius: BorderRadius.circular(15),
          //         color: Colors.black.withAlpha(50),
          //       ),
          //       child: IconButton(
          //         icon: const Icon(Icons.search, size: 28.0, color: Colors.white),
          //         onPressed: () {},
          //       ),
          //     ),
          //   ],
          // )
        ],
      ),
    );
  }
}