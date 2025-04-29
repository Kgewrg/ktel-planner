// ignore_for_file: prefer_const_constructors

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:main_v2/themes_global.dart';
import 'package:main_v2/routes_page.dart';
import "globals.dart" as globals;
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' show parse;
import 'package:flutter/services.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/cupertino.dart';

void main() {
  // Defining default parameters
  globals.day = "1"; // Monday

  runApp(const RootWidget());
}

ThemeData activeTheme = darkTheme;

class RootWidget extends StatelessWidget {
  const RootWidget({super.key});

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    return MaterialApp(
      title: "KTEL Planner",
      theme: activeTheme,
      home: SafeArea(
          child: Scaffold(
        body: MainAppBody(),
      )),
    );
  }
}

class MainAppBody extends StatelessWidget {
  const MainAppBody({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(0),
      child: Column(
        children: <Widget>[
          Expanded(
              flex: 3,
              child: Row(children: const <Widget>[
                Expanded(child: CitiesList(cityDef: "depart")),
                VerticalDivider(width: 2, thickness: 1),
                Expanded(child: CitiesList(cityDef: "destin"))
              ])),
          Container(
            color: activeTheme.colorScheme.background,
            child: const Divider(height: 6, color: Colors.black, thickness: 2),
          ),
          Container(
            color: activeTheme.colorScheme.background,
            child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [Text("Ημέρα: "), DayDropdown()]),
          ),
          Container(
            color: activeTheme.colorScheme.background,
            child: DelayTimes(),
          ),
          Container(
            color: activeTheme.colorScheme.background,
            child: const Padding(
                padding: EdgeInsets.only(right: 2.5, bottom: 3),
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [SearchRouteButton()])),
          ),
        ],
      ),
    );
  }
}

class DelayTimes extends StatefulWidget {
  const DelayTimes({
    super.key,
  });

  @override
  State<DelayTimes> createState() => _DelayTimesState();
}

class _DelayTimesState extends State<DelayTimes> {
// Εδώ καλό θα ήταν να βάλεις textformfield
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(3, 1, 3, 1),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Column(
            children: [
              Text("Ελάχ. χρόνος αναμονής"),
              ElevatedButton(
                onPressed: () {
                  _showTimePicker(
                    context,
                    globals.minDelayTime,
                    (newDuration) =>
                        setState(() => globals.minDelayTime = newDuration),
                  );
                },
                child: Text("${globals.minDelayTime.inMinutes} Λεπτά"),
              ),
            ],
          ),
          const VerticalDivider(),
          Column(
            children: [
              Text("Μεγ. χρόνος αναμονής"),
              ElevatedButton(
                onPressed: () {
                  _showTimePicker(
                      context,
                      globals.maxDelayTime,
                      (newDuration) =>
                          setState(() => globals.maxDelayTime = newDuration));
                },
                child: Text("${globals.maxDelayTime.inMinutes} Λεπτά"),
              ),
            ],
          )
        ],
      ),
    );
  }

  // Εμφανίζει το timepicker και επίσης στην κλήση της ενημερώνει τις global
  // μεταβλητές με το valueChanged
  void _showTimePicker(
    BuildContext context,
    Duration initialDuration,
    ValueChanged<Duration> onTimeChanged,
  ) {
    showCupertinoModalPopup(
        context: context,
        builder: (BuildContext context) {
          return Container(
            height: 200,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.background,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: Text("OK")),
                    )
                  ],
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(1, 1, 1, 40),
                    child: CupertinoTimerPicker(
                        initialTimerDuration: initialDuration,
                        mode: CupertinoTimerPickerMode.hm,
                        onTimerDurationChanged: onTimeChanged),
                  ),
                ),
              ],
            ),
          );
        });
  }
}

class DayDropdown extends StatefulWidget {
  const DayDropdown({super.key});

  @override
  State<DayDropdown> createState() => _DayDropdownState();
}

class _DayDropdownState extends State<DayDropdown> {
  static List<String> dayList = <String>[
    'Δευτέρα',
    'Τρίτη',
    'Τετάρτη',
    'Πέμπτη',
    'Παρασκευή',
    'Σάββατο',
    'Κυριακή'
  ];
  String dropdownValue = dayList.first;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: DropdownMenu<String>(
        initialSelection: dayList.first,
        onSelected: (String? value) {
          // This is called when the user selects an item.
          setState(() {
            dropdownValue = value!;

            globals.day = (dayList.indexOf(dropdownValue) + 1).toString();
          });
        },
        dropdownMenuEntries:
            dayList.map<DropdownMenuEntry<String>>((String value) {
          return DropdownMenuEntry<String>(value: value, label: value);
        }).toList(),
      ),
    );
  }
}

// Routes
class SearchRouteButton extends StatefulWidget {
  const SearchRouteButton({super.key});

  @override
  State<SearchRouteButton> createState() => _SearchRouteButtonState();
}

class _SearchRouteButtonState extends State<SearchRouteButton> {
  Future<void> buttonAction() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Center(child: CircularProgressIndicator()),
    );

    List<List<String>> resultRoutes;

    // check if there is internet connection
    if (await hasInternetConnection() == false) {
      Navigator.pop(context); // Remove loading

      // Εμφανίζει μύνημα που δηλώνει το πρόβλημα
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              content: Text("Δεν υπάρχει σύνδεση στο διαδίκτυο"),
              actions: [
                TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text("OK"))
              ],
            );
          });

      return;
    }

    // check if cities are selected and inform
    if (globals.departureCity == "" || globals.destinationCity == "") {
      Navigator.pop(context); // Remove loading

      // Εμφανίζει μύνημα που δηλώνει το πρόβλημα
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              content: Text("Η αφαιτερία ή ο προορισμός δεν επιλέχθηκαν."),
              actions: [
                TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text("OK"))
              ],
            );
          });
      return;
    }

    // check if the waiting times are corectly set
    if (globals.minDelayTime.inMinutes >= globals.maxDelayTime.inMinutes) {
      Navigator.pop(context); // Remove loading

      showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              content: Text(
                  "Δεν μπορεί ο ελάχιστος χρόνος αναμονής να είναι μεγαλύτερος απο τον μέγιστο χρόνο αναμομής."),
              actions: [
                TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text("OK"))
              ],
            );
          });
      return;
    }

    resultRoutes = await searchRoute();

    Navigator.pop(context); // Remove loading

    // Go to next page
    Navigator.push(context,
        MaterialPageRoute(builder: (context) => RoutesPage(resultRoutes)));
  }

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      onPressed: () => buttonAction(),
      child: const Text("Αναζήτηση"),
    );
  }
}

class CitiesList extends StatefulWidget {
  final String cityDef;

  const CitiesList({super.key, required this.cityDef});

  @override
  State<CitiesList> createState() => _CitiesListState();
}

class _CitiesListState extends State<CitiesList> {
  List<String> filteredCities = [];
  String fullCityDef = "";
  // Προς το παρών λείπει η θεσσαλονίκη απο την λίστα μιας και η εφαρμογή
  // δεν είναι σχεδιασμενή για αυτόν τον σκοπό
  final List<String> citiesListArray = [
    'Άγιος Πέτρος',
    'Άμφισσα',
    'Άργος',
    'Άρτα ',
    'Αγρίνιο',
    'Αδάμ',
    'Αθήνα (Κηφισός)',
    'Αθήνα (Π.Άρεως)',
    'Αθήνα (Πειραιάς)',
    'Αιγίνιο',
    'Αιδηψός',
    'Αλεξανδρούπολη',
    'Αλιβέρι',
    'Αμαλιάδα',
    'Αμύνταιο',
    'Ανδραβίδα',
    'Αξιούπολη',
    'Αριδαία',
    'Ασπροβάλτα',
    'Βάρδα',
    'Βέροια',
    'Βρασνά',
    'Βόλος',
    'Γαλαξίδι',
    'Γαστούνη',
    'Γιαννιτσά',
    'Γουμένισσα',
    'Γρεβενά',
    'Δελφοί',
    'Διδυμότειχο',
    'Δράμα',
    'Έδεσσα',
    'Ελασσόνα',
    'Εύρωπος ',
    'Ζάκυνθος',
    'Ζαγκλιβέρι',
    'Ηγουμενίτσα',
    'Ηράκλεια',
    'Ηράκλειο',
    'Ηράκλειο',
    'Θήβα',
    'Ισθμός',
    'Ιτέα',
    'Ιωάννινα',
    'Κέρκυρα',
    'Καβάλα',
    'Καλαμάτα',
    'Καλαμπάκα',
    'Καλαμωτό',
    'Καρδίτσα',
    'Καστοριά',
    'Κατερίνη',
    'Κιάτο',
    'Κιλκίς',
    'Κοζάνη',
    'Κολινδρός',
    'Κομοτηνή',
    'Κορμίστα, Παγγαίο',
    'Κρύα Βρύση',
    'Κόρινθος',
    'Λάρισα',
    'Λήμνος',
    'Λαμία',
    'Λαμία',
    'Λεπτοκαρυά',
    'Λευκάδα',
    'Λεχαινά',
    'Λιτόχωρο',
    'Μακρύγιαλος',
    'Μαυροθάλασσα',
    'Μεθώνη',
    'Μεσολόγγι',
    'Μυτιλήνη',
    'Ν.Πόρροι',
    'Νάουσα',
    'Νέα Απολλωνία',
    'Νέα Μανωλάδα',
    'Ναύπλιο',
    'Νιγρίτα',
    'Ξάνθη',
    'Ολυμπιάδα',
    'Ορεστιάδα',
    'Πάργα',
    'Πάτρα',
    'Παλιά Πέλλα',
    'Πετροκέρασα',
    'Πλαταμώνας',
    'Πολύκαστρο',
    'Πρέβεζα',
    'Προβατώνας',
    'Πτολεμαΐδα',
    'Πύργος',
    'Ρεντίνα',
    'Ροδολίβος',
    'Σέρρες',
    'Σαββάλια',
    'Σιδηρόκαστρο',
    'Σκύδρα',
    'Σουφλί',
    'Σπάρτη',
    'Σταυρός',
    'Τούμπα',
    'Τρίκαλα',
    'Τρίπολη',
    'Φέρες',
    'Φιλιππιάδα',
    'Φλώρινα',
    'Χαλκίδα',
    'Χανιά',
    'Χανιά',
  ];

  @override
  void initState() {
    filteredCities = citiesListArray;

    if (widget.cityDef == "depart") {
      fullCityDef = "Αφαιτερία";
    } else {
      fullCityDef = "Προορισμός";
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          flex: 10,
          child: ListView.builder(
            reverse: true,
            itemCount: filteredCities.length,
            itemBuilder: (context, index) {
              return ListTile(
                  tileColor: colorSelectedCityTile(filteredCities[index]),
                  title: Text(filteredCities[index]),
                  onTap: () {
                    setCity(filteredCities[index]);
                    setState(() {});
                  });
            },
          ),
        ),
        Expanded(
          child: Container(
            color: Theme.of(context).colorScheme.background,
            child: TextField(
              onChanged: (value) => runFilter(value),
              decoration: InputDecoration(
                  contentPadding: EdgeInsets.all(10),
                  hintText: fullCityDef,
                  suffixIcon: const Icon(Icons.search_outlined)),
            ),
          ),
        )
      ],
    );
  }

  void runFilter(String keyword) {
    List<String> resutls = [];
    if (keyword.isEmpty) {
      resutls = citiesListArray;
    } else {
      resutls = citiesListArray
          .where((element) =>
              element.toLowerCase().contains(keyword.toLowerCase()))
          .toList();
    }

    setState(() {
      filteredCities = resutls;
      setState(() {});
    });
  }

  void setCity(String cityName) {
    if (widget.cityDef == "depart") {
      globals.departureCity = cityName;
    } else {
      globals.destinationCity = cityName;
    }
  }

  Color colorSelectedCityTile(String cityName) {
    // returns a different color from the other tiles, if the title of the tile
    // (name of the city) is the selected city

    if (widget.cityDef == "depart") {
      if (cityName == globals.departureCity) {
        return Theme.of(context).colorScheme.tertiary;
      }
    } else {
      if (cityName == globals.destinationCity) {
        return Theme.of(context).colorScheme.tertiary;
      }
    }
    return Theme.of(context).colorScheme.background;
  }
}

// Checks for internet connection
Future<bool> hasInternetConnection() async {
  var connectivityResult = await Connectivity().checkConnectivity();

  if (connectivityResult == ConnectivityResult.none) {
    return false; // No connection at all
  }

  // Optional: check if there's actual internet access
  try {
    final result = await InternetAddress.lookup('google.com');
    if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
      return true;
    }
  } on SocketException catch (_) {
    return false;
  }

  return false;
}

Future<List<List<String>>> searchRoute() async {
  var departureCity = globals.departureCity;
  var arrivalCity = globals.destinationCity;
  var day = globals.day;
  int minWaitTime = globals.minDelayTime.inMinutes.toInt();
  int maxWaitTime = globals.maxDelayTime.inMinutes.toInt();

  // print("departure city: $departureCity arrival city: $arrivalCity day: $day");
  // print("minWaitTime: $minWaitTime, maxWaitTimt: $maxWaitTime");

  var departureCityData = await findCityCodes(departureCity);
  var printURL =
      "https://ktelmacedonia.gr/gr/routes/ajaxroutes/modonly=1&lsid=${departureCityData['tid']}&print=1&from=${departureCityData['cityID']}&to=0";
  var page = await http.get(Uri.parse(printURL));
  var soup = parse(page.body);
  var departureCityRoutes = parsePrintPage(soup);

  var arrivalCityData = await findCityCodes(arrivalCity);
  printURL =
      "https://ktelmacedonia.gr/gr/routes/ajaxroutes/modonly=1&lsid=${arrivalCityData['tid']}&print=1&from=0&to=${arrivalCityData['cityID']}";
  page = await http.get(Uri.parse(printURL));
  soup = parse(page.body);
  var arrivalCityRoutes = parsePrintPage(soup);

  arrivalCityRoutes = keepOnlyActiveRoutes(arrivalCityRoutes, day);
  departureCityRoutes = keepOnlyActiveRoutes(departureCityRoutes, day);

  var depCityArrs = departureCityRoutes.map((route) => route[2]).toList();
  var arrCityDeps = arrivalCityRoutes.map((route) => route[0]).toList();

  List<List<String>> minDiffIndex = [];

  for (var i = 0; i < depCityArrs.length; i++) {
    var midArrival = depCityArrs[i];
    for (var j = 0; j < arrCityDeps.length; j++) {
      var midDep = arrCityDeps[j];
      var diff = timeDifference(midArrival, midDep);
      if (diff == -1) {
        continue;
      }
      if (diff >= minWaitTime && diff <= maxWaitTime) {
        // var tmp =
        //     "${departureCityRoutes[i][0]}, ${departureCityRoutes[i][2]}, ${arrivalCityRoutes[j][0]}, ${arrivalCityRoutes[j][2]}, $diff";
        minDiffIndex.add([
          departureCityRoutes[i][0],
          departureCityRoutes[i][2],
          arrivalCityRoutes[j][0],
          arrivalCityRoutes[j][2],
          diff.toString()
        ]);
      }
    }
  }

  // print("routes:");
  // for (var i in minDiffIndex) {
  //   print(i);
  // }
  return minDiffIndex;
}

List<List<dynamic>> parsePrintPage(var soup) {
  List<List<dynamic>> data = [];
  var table = soup.querySelector('table');
  var tableBody = table.querySelector('tbody');
  var rows = tableBody.querySelectorAll('tr');

  for (var row in rows) {
    var cols =
        row.querySelectorAll('td').map((ele) => ele.text.trim()).toList();
    data.add([
      for (var ele in cols)
        if (ele != null && ele != "") ele
    ]);
  }
  data = data.sublist(2);

  List<List<dynamic>> timeTable = [];
  for (var row in data) {
    //  If they have a an warning about the timetables they place it above
    //  the times and it gets parsed as a row.
    if (row[0][0].contains(RegExp(r'[a-zA-Z]'))) {
      // print("Text/warning detected, skipping text= $row");
      // the warning can be passed to the main program and also be shown there
      continue;
    }
    var tmp = [];
    tmp.add(row[0]);
    var daysTmp = [];

    for (var day in row.sublist(1, 8)) {
      daysTmp.add(day);
    }
    tmp.add(daysTmp);
    tmp.add(row[8]);
    timeTable.add(tmp);
  }

  return timeTable;
}

Future<Map<String, dynamic>> findCityCodes(String searchCity) async {
  int cityID = -1;
  String cityKey = "";

  final String response = await rootBundle.loadString('assets/citiesDB.json');
  final countyDict = await json.decode(response);
  var searchColumns;

  for (var key in countyDict.keys) {
    if (countyDict[key][0] == "-") {
      searchColumns = [];
    } else {
      searchColumns = countyDict[key].sublist(2);
    }
    for (var cityIndex = 0; cityIndex < searchColumns.length; cityIndex++) {
      if (searchColumns[cityIndex].contains(searchCity)) {
        cityID = int.parse(searchColumns[cityIndex - 1]);
        cityKey = key;
        break;
      }
    }
    if (cityID != -1) {
      break;
    }
  }

  if (cityID == -1) {
    return {'tid': -1, 'cityID': -1};
  } else {
    var tid = countyDict[cityKey][0];
    return {'tid': tid, 'cityID': cityID};
  }
}

List<List<dynamic>> keepOnlyActiveRoutes(
    List<List<dynamic>> routes, String day) {
  List<List<dynamic>> activeRoutesTmp = [];
  for (var route in routes) {
    if (route[1].contains(day)) {
      activeRoutesTmp.add(route);
    }
  }
  return activeRoutesTmp;
}

int timeDifference(String t1, String t2) {
  if (t1.contains('-') || t2.contains('-')) {
    return -1;
  }
  var t1Parts = t1
      .split(':')
      .map((e) => int.parse(e.replaceAll(RegExp(r','), '')))
      .toList();
  var t2Parts = t2
      .split(':')
      .map((e) => int.parse(e.replaceAll(RegExp(r','), '')))
      .toList();
  var t1Minutes = t1Parts[0] * 60 + t1Parts[1];
  var t2Minutes = t2Parts[0] * 60 + t2Parts[1];
  var wait = t2Minutes - t1Minutes;
  if (wait <= 0) {
    return -1;
  } else {
    return wait;
  }
}
