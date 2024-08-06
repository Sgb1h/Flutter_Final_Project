import 'package:flutter/material.dart';
import 'database_helper.dart';
import 'shared_preferences_helper.dart';
import 'flight.dart';
import 'Homepage.dart'; // Import your HomePage

class FlightListPage extends StatefulWidget {
  @override
  _FlightListPageState createState() => _FlightListPageState();
}

class _FlightListPageState extends State<FlightListPage> {
  late DatabaseHelper _dbHelper;
  late SharedPreferencesHelper _prefsHelper;
  List<Flight> _flights = [];

  @override
  void initState() {
    super.initState();
    _dbHelper = DatabaseHelper.instance;
    _prefsHelper = SharedPreferencesHelper();
    _refreshFlightList();
  }

  Future<void> _refreshFlightList() async {
    final data = await _dbHelper.readAllFlights();
    setState(() {
      _flights = data;
    });
  }

  void _addOrEditFlight({Flight? flight}) async {
    final flightData = flight != null
        ? {
      'departureCity': flight.departureCity,
      'destinationCity': flight.destinationCity,
      'departureTime': flight.departureTime,
      'arrivalTime': flight.arrivalTime,
    }
        : await _prefsHelper.loadFlightData();

    final departureCityController =
    TextEditingController(text: flightData['departureCity']);
    final destinationCityController =
    TextEditingController(text: flightData['destinationCity']);
    final departureTimeController =
    TextEditingController(text: flightData['departureTime']);
    final arrivalTimeController =
    TextEditingController(text: flightData['arrivalTime']);

    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          child: Container(
            padding: EdgeInsets.all(20.0), // Increased padding for better spacing
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  flight == null ? 'Add Flight' : 'Edit Flight',
                  style: TextStyle(
                    fontSize: 24.0, // Slightly larger font size
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 20.0), // Increased spacing
                TextField(
                  controller: departureCityController,
                  decoration: InputDecoration(
                    labelText: 'Departure City',
                    border: OutlineInputBorder(), // Added border for input fields
                  ),
                ),
                SizedBox(height: 10.0), // Space between fields
                TextField(
                  controller: destinationCityController,
                  decoration: InputDecoration(
                    labelText: 'Destination City',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 10.0),
                TextField(
                  controller: departureTimeController,
                  decoration: InputDecoration(
                    labelText: 'Departure Time',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 10.0),
                TextField(
                  controller: arrivalTimeController,
                  decoration: InputDecoration(
                    labelText: 'Arrival Time',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 20.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: Text(
                        'Cancel',
                        style: TextStyle(
                          color: Colors.red, // Changed color for better visibility
                        ),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        final newFlight = Flight(
                          id: flight?.id,
                          departureCity: departureCityController.text,
                          destinationCity: destinationCityController.text,
                          departureTime: departureTimeController.text,
                          arrivalTime: arrivalTimeController.text,
                        );

                        if (flight == null) {
                          await _dbHelper.create(newFlight);
                        } else {
                          await _dbHelper.update(newFlight);
                        }

                        await _prefsHelper.saveFlightData(
                          departureCity: newFlight.departureCity,
                          destinationCity: newFlight.destinationCity,
                          departureTime: newFlight.departureTime,
                          arrivalTime: newFlight.arrivalTime,
                        );

                        _refreshFlightList();
                        Navigator.of(context).pop();
                      },
                      child: Text(
                        flight == null ? 'Add' : 'Save',
                        style: TextStyle(color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue, // Consistent button color
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _deleteFlight(int id) async {
    await _dbHelper.delete(id);
    _refreshFlightList();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Flight deleted')),
    );
  }

  void _showInstructions() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Instructions'),
          content: Text(
              'To use this page:\n\n'
                  '1. Add a new flight using the "Add Flight" button.\n'
                  '2. Edit a flight by tapping the edit icon next to the flight in the list.\n'
                  '3. Delete a flight by tapping the delete icon next to the flight in the list.\n'
                  '4. View flight details by tapping on the flight item.\n\n'
                  'All changes will be saved in the database and will persist even after the app is closed.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Close'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Flight List'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => HomePage()),
                  (Route<dynamic> route) => false,
            ); // Navigates back to the HomePage and clears the stack
          },
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.info_outline),
            onPressed: _showInstructions, // Show instructions dialog
          ),
        ],
      ),
      body: Stack(
        children: [
          Column(
            children: [
              Container(
                width: double.infinity,
                height: 200.0,
                color: Colors.blue,
                child: Center(
                  child: Text(
                    'Flight List',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 30.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 50), // Adjust the space between banner and list
              Expanded(
                child: ListView.builder(
                  itemCount: _flights.length,
                  itemBuilder: (context, index) {
                    final flight = _flights[index];
                    return ListTile(
                      title: Text(
                          '${flight.departureCity} to ${flight.destinationCity}'),
                      subtitle: Text(
                          'Departure: ${flight.departureTime}, Arrival: ${flight.arrivalTime}'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(Icons.edit),
                            onPressed: () {
                              _addOrEditFlight(flight: flight);
                            },
                          ),
                          IconButton(
                            icon: Icon(Icons.delete),
                            onPressed: () {
                              _deleteFlight(flight.id!);
                            },
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
          Positioned(
            top: 160,
            left: 0,
            right: 0,
            child: Center(
              child: ElevatedButton(
                onPressed: () {
                  _addOrEditFlight();
                },
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15), // Increased padding for a larger button
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: Text(
                  'Add Flight',
                  style: TextStyle(fontSize: 18), // Slightly larger font size
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
