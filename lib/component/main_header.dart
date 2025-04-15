import 'package:flutter/material.dart';

class MainHeader extends StatelessWidget {
  const MainHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 100.0,
      padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
      alignment: Alignment.bottomCenter,
      decoration: BoxDecoration(color: Colors.blue.shade800),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('lorem ipsum', style: TextStyle(fontSize: 26.0, fontWeight: FontWeight.bold, color: Colors.white)),
              Text('dolor sit amet', style: TextStyle(fontSize: 14.0, fontWeight: FontWeight.bold, color: Colors.white)),
            ],
          ),
          Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  color: Colors.black.withAlpha(50),
                ),
                child: IconButton(
                  icon: const Icon(Icons.search, size: 28.0, color: Colors.white),
                  onPressed: () {},
                ),
              ),
              SizedBox(width: 10.0),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  color: Colors.black.withAlpha(50),
                ),
                child: IconButton(
                  icon: const Icon(Icons.search, size: 28.0, color: Colors.white),
                  onPressed: () {},
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}