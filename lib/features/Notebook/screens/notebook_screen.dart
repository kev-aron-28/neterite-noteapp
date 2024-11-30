import 'package:flutter/material.dart';
import 'package:neterite/common/widgets/neterite_bottom_navigator.dart';
import 'package:neterite/features/Lobby/widgets/neterite_card_note.dart';
import 'package:neterite/features/Lobby/widgets/neterite_schedule_tile.dart';
import 'package:neterite/features/Lobby/widgets/neterite_todo_tile.dart';

class NotebookScreen extends StatelessWidget {
  const NotebookScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20), // Adjust as needed
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Search Bar
              Center(
                child: Padding(
                padding: const EdgeInsets.only(top: 30),
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.95,
                  child: const SearchBar(
                    leading: Icon(Icons.search),
                    hintText: "Buscar nota",
                  ),
                ),
              ),
              ),
              const SizedBox(height: 25),
              ListView(
                padding: const EdgeInsets.all(8),
                children: [
                   Container()
                ],
              )
            ],
          ),
        ),
      ),
      bottomNavigationBar: const NeteriteBottomNavigator(currentIndex: 0),
    );
  }
}
