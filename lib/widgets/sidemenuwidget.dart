

import 'package:dashboard_desk/data/side_menu_data.dart';
import 'package:flutter/material.dart';

class Sidemenuwidget extends StatefulWidget {
  final Function(int) onItemSelected;
  final int selectedIndex;
  final VoidCallback onBurgerIconPressed;
  final bool isMenuExpanded;

  const Sidemenuwidget({
    super.key,
    required this.onItemSelected,
    required this.selectedIndex,
    required this.onBurgerIconPressed,
    required this.isMenuExpanded,
  });

  @override
  State<Sidemenuwidget> createState() => _SidemenuwidgetState();
}

class _SidemenuwidgetState extends State<Sidemenuwidget> {
  @override
  Widget build(BuildContext context) {
    final data = SideMenuData();

    return Container(
      color: Colors.blueGrey,
      padding: EdgeInsets.all(30),
      child: Column(
        children: [
          InkWell(
            onTap: widget.onBurgerIconPressed,
            child: Icon(
              widget.isMenuExpanded ? Icons.menu_open : Icons.menu,
              color: Colors.white,
              size: 30,
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: data.menu.length,
              itemBuilder: (context, index) => buildMenuItem(data, index),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildMenuItem(SideMenuData data, int index) {
    final isSelected = widget.selectedIndex == index;

    return Container(
      decoration: BoxDecoration(
        color: isSelected ? Colors.orange : Colors.cyanAccent,
        borderRadius: BorderRadius.circular(20),
      ),
      margin: EdgeInsets.only(left: 2, right: 12, top: 12),
      child: InkWell(
        onTap: () {
          widget.onItemSelected(index);
        },
        child: Row(
          children: [
            Padding(
              padding: const EdgeInsets.only(right: 2, top: 5, bottom: 5, left: 8),
              child: Icon(
                data.menu[index].icon,
                color: isSelected ? const Color.fromARGB(255, 13, 16, 13) : Colors.limeAccent,
              ),
            ),
            if (widget.isMenuExpanded) ...[
              SizedBox(width: 12),
              Text(
                data.menu[index].title,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
