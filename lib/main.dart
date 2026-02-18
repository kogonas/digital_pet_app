import 'dart:async';
import 'package:flutter/material.dart';

void main() {
  runApp(MaterialApp(
    home: DigitalPetApp(),
  ));
}

class DigitalPetApp extends StatefulWidget {
  @override
  _DigitalPetAppState createState() => _DigitalPetAppState();
}

class _DigitalPetAppState extends State<DigitalPetApp> {
  String petName = "Your Pet";
  int happinessLevel = 50;
  int hungerLevel = 50;

  // Part 2 additions
  int energyLevel = 80;
  String selectedActivity = "Run";

  // Timer for auto-hunger
  Timer? hungerTimer;

  // Timer for win condition
  Timer? winTimer;
  int winCounter = 0;

  TextEditingController nameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    startHungerTimer();
    startWinTimer();
  }

  @override
  void dispose() {
    hungerTimer?.cancel();
    winTimer?.cancel();
    super.dispose();
  }

  // Auto-increasing hunger every 30 seconds
  void startHungerTimer() {
    hungerTimer = Timer.periodic(Duration(seconds: 30), (timer) {
      setState(() {
        hungerLevel += 5;
        if (hungerLevel > 100) hungerLevel = 100;
      });
      checkLossCondition();
    });
  }

  // Win condition: happiness > 80 for 3 minutes
  void startWinTimer() {
    winTimer = Timer.periodic(Duration(seconds: 10), (timer) {
      if (happinessLevel > 80) {
        winCounter++;
        if (winCounter >= 18) {
          showWinDialog();
        }
      } else {
        winCounter = 0;
      }
    });
  }

  void _playWithPet() {
    setState(() {
      happinessLevel += 10;
      if (happinessLevel > 100) happinessLevel = 100;

      hungerLevel += 5;
      if (hungerLevel > 100) hungerLevel = 100;

      energyLevel -= 10;
      if (energyLevel < 0) energyLevel = 0;
    });

    checkLossCondition();
  }

  void _feedPet() {
    setState(() {
      hungerLevel -= 15;
      if (hungerLevel < 0) hungerLevel = 0;

      happinessLevel += 5;
      if (happinessLevel > 100) happinessLevel = 100;

      energyLevel += 5;
      if (energyLevel > 100) energyLevel = 100;
    });

    checkLossCondition();
  }

  // Activity logic (Part 2)
  void _performActivity() {
    setState(() {
      if (selectedActivity == "Run") {
        happinessLevel += 5;
        energyLevel -= 20;
        hungerLevel += 10;
      } else if (selectedActivity == "Sleep") {
        energyLevel += 20;
        hungerLevel += 5;
      }

      if (happinessLevel > 100) happinessLevel = 100;
      if (energyLevel > 100) energyLevel = 100;
      if (hungerLevel > 100) hungerLevel = 100;
    });

    checkLossCondition();
  }

  // Mood text + emoji
  String getMood() {
    if (happinessLevel > 70) return "Happy 😄";
    if (happinessLevel >= 30) return "Neutral 🙂";
    return "Unhappy 😢";
  }

  // ColorFiltered mood color
  Color _moodColor(int happiness) {
    if (happiness > 70) return Colors.green;
    if (happiness >= 30) return Colors.yellow;
    return Colors.red;
  }

  // Loss condition
  void checkLossCondition() {
    if (hungerLevel == 100 && happinessLevel <= 10) {
      showLossDialog();
    }
  }

  void showLossDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("Game Over"),
        content: Text("Your pet became too hungry and sad."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("OK"),
          )
        ],
      ),
    );
  }

  void showWinDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("You Win!"),
        content: Text("You kept your pet happy for 3 minutes!"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Yay!"),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Digital Pet'),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: [
              SizedBox(height: 20),

              // Name input
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: nameController,
                        decoration: InputDecoration(
                          labelText: "Enter pet name",
                        ),
                      ),
                    ),
                    SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          petName = nameController.text;
                        });
                      },
                      child: Text("Set Name"),
                    )
                  ],
                ),
              ),

              SizedBox(height: 20),

              Text("Name: $petName", style: TextStyle(fontSize: 22)),
              Text("Mood: ${getMood()}", style: TextStyle(fontSize: 20)),

              SizedBox(height: 20),

              // Pet image with color filter
              ColorFiltered(
                colorFilter: ColorFilter.mode(
                  _moodColor(happinessLevel),
                  BlendMode.modulate,
                ),
                child: Image.asset(
                  'assets/pet_image.png',
                  height: 200,
                ),
              ),

              SizedBox(height: 20),

              Text("Happiness: $happinessLevel"),
              Text("Hunger: $hungerLevel"),
              Text("Energy: $energyLevel"),

              SizedBox(height: 20),

              // Energy bar (Part 2)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: LinearProgressIndicator(
                  value: energyLevel / 100,
                  minHeight: 12,
                  backgroundColor: Colors.grey[300],
                  color: Colors.blue,
                ),
              ),

              SizedBox(height: 20),

              ElevatedButton(
                onPressed: _playWithPet,
                child: Text("Play with Pet"),
              ),
              ElevatedButton(
                onPressed: _feedPet,
                child: Text("Feed Pet"),
              ),

              SizedBox(height: 20),

              // Activity dropdown (Part 2)
              DropdownButton<String>(
                value: selectedActivity,
                items: ["Run", "Sleep"]
                    .map((e) => DropdownMenuItem(
                          value: e,
                          child: Text(e),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    selectedActivity = value!;
                  });
                },
              ),

              ElevatedButton(
                onPressed: _performActivity,
                child: Text("Do Activity"),
              ),

              SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}


