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
      color: Colors.blueGrey, // Sidebar background color
      padding: const EdgeInsets.all(30),
      child: Column(
        children: [
          // Menu/Burger Icon
          InkWell(
            onTap: widget.onBurgerIconPressed,
            child: Icon(
              widget.isMenuExpanded ? Icons.menu_open : Icons.menu,
              color: Colors.white,
              size: 30,
            ),
          ),
          const SizedBox(height: 20), // Spacing below the menu icon

          // Menu Items List
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
        color: isSelected ? Colors.white : Colors.black, // Selected: White, Not selected: Cyan
        borderRadius: BorderRadius.circular(20), // Rounded corners for menu items
      ),
      margin: const EdgeInsets.only(left: 2, right: 12, top: 12), // Spacing for menu items
      child: InkWell(
        onTap: () {
          widget.onItemSelected(index); // Trigger item selection
        },
        child: Row(
          children: [
            Padding(
              padding: const EdgeInsets.only( top: 8, bottom: 8, left: 19),
              
              child: Icon(
                data.menu[index].icon,
                color: isSelected ? Colors.black : Colors.white, // Selected: Black icon
                size: 24,
              ),
            ),
            if (widget.isMenuExpanded) ...[
              const SizedBox(width: 12),
              Text(
                data.menu[index].title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: isSelected ? Colors.black : Colors.white, // Selected: Black text
                  fontSize: 16,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
