import 'package:flutter/material.dart';
import 'package:neterite/common/widgets/neterite_bottom_navigator.dart';
import 'package:neterite/features/Lobby/widgets/neterite_card_note.dart';
import 'package:neterite/features/Lobby/widgets/neterite_schedule_tile.dart';
import 'package:neterite/features/Lobby/widgets/neterite_todo_tile.dart';

class LobbyScreen extends StatelessWidget {
  const LobbyScreen({super.key});

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
              
              // Últimas Notas Section
              const Padding(
                padding: EdgeInsets.only(left: 10),
                child: Text(
                  "ULTIMAS NOTAS",
                  style: TextStyle(
                    fontSize: 35,
                    fontWeight: FontWeight.w500,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
              const SizedBox(height: 15),
              const SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    SizedBox(width: 10),
                    NeteriteCardNote(noteTitle: "This is a note"),
                    NeteriteCardNote(noteTitle: "Another note"),
                    NeteriteCardNote(noteTitle: "More note"),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              
              // Horario Section
              const Padding(
                padding: EdgeInsets.only(left: 10),
                child: Text(
                  "HORARIO",
                  style: TextStyle(
                    fontSize: 35,
                    fontWeight: FontWeight.w500,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
              const Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(width: 10),
                  RotatedBox(
                    quarterTurns: 9, // Rotate "HOY" vertically
                    child: Text(
                      "HOY",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w300,
                        letterSpacing: 5,
                      ),
                    ),
                  ),
                  SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        NeteriteScheduleTile(title: "Hey there", subtitle: "No"),
                        NeteriteScheduleTile(title: "New tile", subtitle: "Hey there"),
                        NeteriteScheduleTile(title: "New tile", subtitle: "tile"),
                        NeteriteScheduleTile(title: "New tile", subtitle: "tile"),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const Padding(
                padding: EdgeInsets.only(left: 10),
                child: Text(
                  "TO DO",
                  style: TextStyle(
                    fontSize: 35,
                    fontWeight: FontWeight.w500,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
              const Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(width: 10),
                  RotatedBox(
                    quarterTurns: 9, // Rotate "HOY" vertically
                    child: Text(
                      "ESTA SEMANA",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w300,
                        letterSpacing: 3,
                      ),
                    ),
                  ),
                  SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        NeteriteTodoTile(title: "Hi", subtitle: "Hello"),
                        NeteriteTodoTile(title: "Hi", subtitle: "Hello")
                      ],
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
      bottomNavigationBar: const NeteriteBottomNavigator(currentIndex: 2),
    );
  }
}
