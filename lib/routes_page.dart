import 'package:flutter/material.dart';
import 'globals.dart' as globals;

class RoutesPage extends StatefulWidget {
  final List<List<String>> routes;
  final List<String> dayLookup = <String>[
    'Δευτέρα',
    'Τρίτη',
    'Τετάρτη',
    'Πέμπτη',
    'Παρασκευή',
    'Σάββατο',
    'Κυριακή'
  ];

  RoutesPage(this.routes, {super.key});

  @override
  State<RoutesPage> createState() => _RoutesPageState();
}

class _RoutesPageState extends State<RoutesPage> {
  @override
  void initState() {
    super.initState();

    // Sort the result based on the waiting time (widget.routes[4])
    widget.routes.sort((a, b) {
      int durationA = int.parse(a[4].replaceAll(RegExp(r'[^0-9]'), ''));
      int durationB = int.parse(b[4].replaceAll(RegExp(r'[^0-9]'), ''));
      return durationA.compareTo(durationB); // Ascending order
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          dismissDirection: DismissDirection.down,
          content: Text(
              "Τα δρομολόγια πρέπει να επιβεβαιώνονται απο το ΚΤΕΛ ΜΑΚΕΔΟΝΙΑ ή/και τα τοπικά πρακτορία."),
          duration: Duration(seconds: 5),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: widget.routes.isEmpty
          ? ErrorWidget(widget: widget)
          : MainRoutesWidget(widget: widget),
    );
  }
}

class ErrorWidget extends StatelessWidget {
  const ErrorWidget({
    super.key,
    required this.widget,
  });
  final RoutesPage widget;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            // Error message
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.all(Radius.circular(10)),
              color: Theme.of(context).colorScheme.tertiary,
            ),
            padding: const EdgeInsets.all(15),
            child: Text(
                "Δεν βρέθηκαν δρομολόγια για τις επιλογές: \nΑφαιτερία: ${globals.departureCity}\nΠροορισμός: ${globals.destinationCity}\nΗμέρα: ${widget.dayLookup[int.parse(globals.day) - 1]}\nΕλάχιστος χρόνος αναμονής: ${globals.minDelayTime.inMinutes} λεπτά\nΜέγιστος χρόνος αναμονής: ${globals.maxDelayTime.inMinutes} λεπτά",
                style: const TextStyle(fontSize: 18)),
          ), // error Message
          FilledButton(
            style: ButtonStyle(
              padding: MaterialStateProperty.all(
                  const EdgeInsets.fromLTRB(50, 2, 50, 2)),
            ),
            onPressed: () => Navigator.pop(context),
            child: const Text("Πίσω"),
          ), // Back button
        ],
      ),
    );
  }
}

class MainRoutesWidget extends StatelessWidget {
  const MainRoutesWidget({
    super.key,
    required this.widget,
  });

  final RoutesPage widget;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          // Text Area Above the List
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              "Δρομολόγια για:\n${globals.departureCity}➜${globals.destinationCity}\nΗμέρα: ${widget.dayLookup[int.parse(globals.day) - 1]}",
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 18),
            ),
          ),

          // List of Routes
          Expanded(
            child: ListView.builder(
              itemCount: widget.routes.length,
              itemBuilder: (context, index) {
                final route = widget.routes[index];
                return Card(
                  margin: const EdgeInsets.all(8),
                  child: ListTile(
                    title: Text(
                        "Αναχώρηση: ${route[0]} ➜ Άφιξη: ${route[3]} \nΧρόνος αναμονής: ${convertMinutesToHHMM(route[4])}"),
                    subtitle:
                        Text("Περίοδος αναμονής: ${route[1]} - ${route[2]}"),
                    leading: const Icon(Icons.directions_bus),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

String convertMinutesToHHMM(String minutesDiff) {
  // Convers the "diff" minutes value to houres and minutes

  int minutes = int.parse(minutesDiff);
  if (minutes < 59) {
    return "${minutes.toString()}min";
  }

  int hours = minutes ~/ 60; // Get the number of hours
  int remainingMinutes = minutes % 60; // Get the remaining minutes
  // output format:  x ώρες κ' x λετπά
  return "${hours.toString()}h ${remainingMinutes.toString()}min";
}
