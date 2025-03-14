import 'package:flutter/material.dart';

class SearchWidget extends StatefulWidget {
  const SearchWidget({super.key});

  @override
  State<SearchWidget> createState() => _SearchWidgetState();
}

class _SearchWidgetState extends State<SearchWidget> {
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: TextField(
        autocorrect: true,
        decoration: InputDecoration(fillColor: Colors.grey,filled: true,counterText: "Enter",enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.red)),
        hintText: "Search",
        prefixIcon: Icon(Icons.search,size: 21,),

        ),
        
        
        cursorColor: Colors.green,
        
        
      ),
    );
  }
}