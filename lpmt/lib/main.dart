import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(SanctionApp());
}

class SanctionApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Outil de Modération',
      theme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.red,
        scaffoldBackgroundColor: Color(0xFF1E1E1E),
      ),
      home: SanctionHomePage(),
    );
  }
}

class SanctionHomePage extends StatefulWidget {
  @override
  _SanctionHomePageState createState() => _SanctionHomePageState();
}

class _SanctionHomePageState extends State<SanctionHomePage> {
  final Map<String, List<String>> sanctions = {
    "Spam": ["Bot (Wick)", "Bot (Wick)", "Bot (Wick)", "Ban"],
    "Diffamation": ["Avertissement", "Ban", "Ban", "Ban"],
    "Insulte": ["Mute(24h)", "Ban", "Ban", "Ban"],
    "Envoi d'image inappropriée": ["Rappel à l'ordre en MP", "Ban", "Ban", "Ban"],
    "Message privé sans autorisation": ["Avertissement", "Mute(24h)", "Ban", "Ban"],
    "Abus du système de tickets": ["Avertissement", "Mute(24h)", "Ban", "Ban"],
    "Non-respect du thème": ["Avertissement", "Avertissement", "Mute(24h)", "Ban"],
    "Publicité non autorisée": ["Mute(24h)", "Ban", "Ban", "Ban"],
    "Discussion NSFW": ["Avertissement", "Mute(24h)", "Ban", "Ban"],
    "Troll": ["Ban", "Ban", "Ban", "Ban"],
    "Harcèlement": ["Ban", "Ban", "Ban", "Ban"],
    "Non-respect des thèmes de canal": ["Avertissement", "Avertissement", "Mute(24h)", "Ban"],
  };

  String selectedOffense = "Spam";
  String selectedRecurrence = "Première";
  String username = "";
  String actionResult = "";

  final List<String> recurrenceOptions = ["Première", "Récidive 1x", "Récidive 2x", "Récidive 3x"];

  void _showSanction() {
    final int recurrenceIndex = recurrenceOptions.indexOf(selectedRecurrence);
    final List<String>? actions = sanctions[selectedOffense];
    String action = "Action non définie";

    if (actions != null && recurrenceIndex < actions.length) {
      action = actions[recurrenceIndex];
    }

    String command;
    if (action == "Mute(24h)") {
      command = "/timeout add user:$username duration:24h reason:$selectedOffense";
    } else if (action == "Avertissement") {
      command = "/warn utilisateur:$username raison:$selectedOffense";
    } else if (action == "Ban") {
      command = "/ban utilisateur:$username raison:$selectedOffense";
    } else {
      command = "/$action utilisateur:$username raison:$selectedOffense";
    }

    setState(() {
      actionResult = "Action: $action\nRésumé: $command";
    });

    Clipboard.setData(ClipboardData(text: command));

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Commande copiée dans le presse-papiers")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Outil de Modération"),
        centerTitle: true,
        backgroundColor: Colors.orangeAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Offense Dropdown
            Text("Choisissez une infraction:", style: TextStyle(fontSize: 18, color: Colors.grey[400])),
            SizedBox(height: 8),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Color(0xFF333333),
                borderRadius: BorderRadius.circular(8),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: selectedOffense,
                  dropdownColor: Color(0xFF333333),
                  iconEnabledColor: Colors.orangeAccent,
                  onChanged: (String? newValue) {
                    setState(() {
                      selectedOffense = newValue!;
                    });
                  },
                  items: sanctions.keys.map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value, style: TextStyle(color: Colors.white)),
                    );
                  }).toList(),
                ),
              ),
            ),
            SizedBox(height: 16),

            // Username Input
            Text("Entrez le pseudo de l'utilisateur:", style: TextStyle(fontSize: 18, color: Colors.grey[400])),
            SizedBox(height: 8),
            TextField(
              onChanged: (text) {
                setState(() {
                  username = text;
                });
              },
              decoration: InputDecoration(
                hintText: "Pseudo de l'utilisateur",
                filled: true,
                fillColor: Color(0xFF333333),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
                prefixIcon: Icon(Icons.person, color: Colors.orangeAccent),
              ),
              style: TextStyle(color: Colors.white),
            ),
            SizedBox(height: 16),

            // Recurrence Dropdown
            Text("Niveau de récidive:", style: TextStyle(fontSize: 18, color: Colors.grey[400])),
            SizedBox(height: 8),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Color(0xFF333333),
                borderRadius: BorderRadius.circular(8),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: selectedRecurrence,
                  dropdownColor: Color(0xFF333333),
                  iconEnabledColor: Colors.orangeAccent,
                  onChanged: (String? newValue) {
                    setState(() {
                      selectedRecurrence = newValue!;
                    });
                  },
                  items: recurrenceOptions.map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value, style: TextStyle(color: Colors.white)),
                    );
                  }).toList(),
                ),
              ),
            ),
            SizedBox(height: 16),

            // Action Button
            Center(
              child: ElevatedButton(
                onPressed: _showSanction,
                child: Text("Afficher la sanction"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orangeAccent,
                  foregroundColor: Colors.black, // Texte en noir pour meilleure lisibilité
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  textStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
            SizedBox(height: 24),

            // Displaying the Action Result
            if (actionResult.isNotEmpty)
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Color(0xFF444444),
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 6,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Text(
                  actionResult,
                  style: TextStyle(fontSize: 16, color: Colors.orangeAccent),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
