import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app_localizations.dart';

/// A page that allows users to add a reservation.
class AddReservationPage extends StatefulWidget {
  /// Callback for changing the language.
  final Function(Locale) onLanguageChanged;

  /// Callback for when a reservation is added.
  final Function(Map<String, String>) onReservationAdded;

  /// Indicates if the view is desktop.
  final bool isDesktopView;

  /// The reservation to edit, if any.
  final Map<String, dynamic>? reservation;

  /// Creates an instance of [AddReservationPage].
  AddReservationPage({
    required this.onLanguageChanged,
    required this.onReservationAdded,
    required this.isDesktopView,
    this.reservation,
  });

  @override
  _AddReservationPageState createState() => _AddReservationPageState();
}

class _AddReservationPageState extends State<AddReservationPage> {
  final TextEditingController _customerController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _flightController = TextEditingController();

  List<Map<String, String>> _flights = [];
  List<Map<String, String>> _filteredFlights = [];
  String? _selectedFlight;
  String? _departureCity;
  String? _destinationCity;
  Map<String, String>? _editingFlight;

  final List<String> _cities = [
    'Toronto',
    'Vancouver',
    'Montreal',
    'Calgary',
    'Ottawa'
  ];

  @override
  void initState() {
    super.initState();
    _loadFlights();

    if (widget.reservation != null) {
      _editingFlight = widget.reservation as Map<String, String>?;
      _customerController.text = widget.reservation!['customer'];
      _dateController.text = widget.reservation!['date'];
      _flightController.text = widget.reservation!['flight'];
    }
  }

  /// Loads the flight information from shared preferences.
  void _loadFlights() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? flightList = prefs.getStringList('flights');
    if (flightList != null) {
      setState(() {
        _flights = flightList
            .map((e) => Map<String, String>.from(json.decode(e)))
            .toList();
      });
    } else {
      _flights = [
        {'flightNumber': 'AC 456', 'route': 'Toronto to Vancouver', 'time': '08:00 AM'},
        {'flightNumber': 'AC 457', 'route': 'Toronto to Vancouver', 'time': '12:00 PM'},
        {'flightNumber': 'AC 345', 'route': 'Toronto to Vancouver', 'time': '06:00 PM'},
        {'flightNumber': 'AC 123', 'route': 'Toronto to Montreal', 'time': '09:00 AM'},
        {'flightNumber': 'AC 124', 'route': 'Toronto to Montreal', 'time': '03:00 PM'},
        {'flightNumber': 'AC 125', 'route': 'Toronto to Calgary', 'time': '11:00 AM'},
      ];
      _saveFlights();
    }
  }

  /// Saves the flight information to shared preferences.
  void _saveFlights() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> flightList = _flights.map((e) => json.encode(e)).toList();
    prefs.setStringList('flights', flightList);
  }

  /// Filters the flights based on departure and destination cities.
  void _filterFlights() {
    if (_departureCity != null && _destinationCity != null) {
      setState(() {
        _filteredFlights = _flights.where((flight) => flight['route'] == '$_departureCity to $_destinationCity').toList();
        _selectedFlight = null;
      });
    }
  }

  /// Submits the reservation.
  void _submitReservation() async {
    if (_customerController.text.isEmpty || _flightController.text.isEmpty || _dateController.text.isEmpty) {
      _showSnackbar(AppLocalizations.of(context).getTranslatedValue('fillAllFields') ?? 'Please fill all fields');
      return;
    }

    if (!_isValidDate(_dateController.text)) {
      _showSnackbar(AppLocalizations.of(context).getTranslatedValue('invalidDateFormat') ?? 'Invalid date format. Use DD-MM-YYYY.');
      return;
    }

    if (_editingFlight != null) {
      _updateFlight();
    } else {
      _showConfirmationDialog();
    }
  }

  /// Updates the flight information.
  void _updateFlight() async {
    final reservation = {
      'customer': _customerController.text,
      'flight': _flightController.text,
      'date': _dateController.text,
    };

    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> reservations = prefs.getStringList('reservations') ?? [];
    reservations.removeWhere((element) => Map<String, String>.from(json.decode(element))['flight'] == _editingFlight!['flight']);
    reservations.add(json.encode(reservation));
    await prefs.setStringList('reservations', reservations);

    widget.onReservationAdded(reservation);

    _showSnackbar(AppLocalizations.of(context).getTranslatedValue('reservationUpdated') ?? 'Reservation updated successfully!');

    setState(() {
      _editingFlight = null;
      _customerController.clear();
      _dateController.clear();
      _flightController.clear();
      _departureCity = null;
      _destinationCity = null;
      _filteredFlights.clear();
    });
  }

  /// Shows a confirmation dialog before submitting the reservation.
  void _showConfirmationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(AppLocalizations.of(context).getTranslatedValue('confirm') ?? 'Confirm'),
          content: Text(AppLocalizations.of(context).getTranslatedValue('confirmReservation') ?? 'Do you want to submit the reservation?'),
          actions: [
            TextButton(
              child: Text(AppLocalizations.of(context).getTranslatedValue('cancel') ?? 'Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text(AppLocalizations.of(context).getTranslatedValue('submit') ?? 'Submit'),
              onPressed: () async {
                Navigator.of(context).pop();
                final reservation = {
                  'customer': _customerController.text,
                  'flight': _flightController.text,
                  'date': _dateController.text,
                };

                SharedPreferences prefs = await SharedPreferences.getInstance();
                List<String> reservations = prefs.getStringList('reservations') ?? [];
                reservations.add(json.encode(reservation));
                await prefs.setStringList('reservations', reservations);

                widget.onReservationAdded(reservation);

                _showSnackbar(AppLocalizations.of(context).getTranslatedValue('reservationAdded') ?? 'Reservation added successfully!');

                if (!widget.isDesktopView) {
                  Navigator.pop(context);
                } else {
                  // Clear the form fields after submission for desktop view
                  setState(() {
                    _customerController.clear();
                    _dateController.clear();
                    _flightController.clear();
                    _departureCity = null;
                    _destinationCity = null;
                    _filteredFlights.clear();
                  });
                }
              },
            ),
          ],
        );
      },
    );
  }

  /// Validates the date format.
  bool _isValidDate(String date) {
    final regex = RegExp(r'^\d{2}-\d{2}-\d{4}$');
    return regex.hasMatch(date);
  }

  /// Shows a snackbar with the given message.
  void _showSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  /// Changes the language.
  void _changeLanguage(Locale? locale) {
    if (locale != null) {
      widget.onLanguageChanged(locale);
    }
  }

  /// Edits the flight.
  void _editFlight(Map<String, String> flight) {
    setState(() {
      _editingFlight = flight;
      _customerController.text = flight['customer']!;
      _dateController.text = flight['date']!;
      _flightController.text = flight['flight']!;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).getTranslatedValue('addReservation') ?? 'Add Reservation'),
        actions: [
          DropdownButton<Locale>(
            underline: SizedBox(),
            icon: Icon(Icons.language, color: Colors.white),
            onChanged: _changeLanguage,
            items: [
              DropdownMenuItem(
                value: Locale('en'),
                child: Text('English'),
              ),
              DropdownMenuItem(
                value: Locale('fr'),
                child: Text('Français'),
              ),
            ],
          ),
        ],
      ),
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('images/air.jpg'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              children: [
                TextField(
                  controller: _customerController,
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(context).getTranslatedValue('enterCustomerName') ?? 'Enter Customer Name',
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.7),
                  ),
                ),
                SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  value: _departureCity,
                  hint: Text(AppLocalizations.of(context).getTranslatedValue('selectDepartureCity') ?? 'Select Departure City'),
                  items: _cities.map((city) {
                    return DropdownMenuItem<String>(value: city, child: Text(city));
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _departureCity = value;
                      _filterFlights();
                    });
                  },
                  decoration: InputDecoration(filled: true, fillColor: Colors.white.withOpacity(0.7)),
                ),
                SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  value: _destinationCity,
                  hint: Text(AppLocalizations.of(context).getTranslatedValue('selectDestinationCity') ?? 'Select Destination City'),
                  items: _cities.map((city) {
                    return DropdownMenuItem<String>(value: city, child: Text(city));
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _destinationCity = value;
                      _filterFlights();
                    });
                  },
                  decoration: InputDecoration(filled: true, fillColor: Colors.white.withOpacity(0.7)),
                ),
                SizedBox(height: 10),
                TextFormField(
                  controller: _flightController,
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(context).getTranslatedValue('selectFlight') ?? 'Select Flight',
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.7),
                  ),
                ),
                SizedBox(height: 10),
                TextField(
                  controller: _dateController,
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(context).getTranslatedValue('dateFormat') ?? 'Date (DD-MM-YYYY)',
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.7),
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'\d|-')),
                    DateInputFormatter(),
                  ],
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  child: Text(_editingFlight == null
                      ? AppLocalizations.of(context).getTranslatedValue('submitReservation') ?? 'Submit Reservation'
                      : AppLocalizations.of(context).getTranslatedValue('updateReservation') ?? 'Update Reservation'),
                  onPressed: _submitReservation,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class DateInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    var text = newValue.text;
    final newTextLength = newValue.text.length;
    final oldTextLength = oldValue.text.length;

    if (newTextLength > oldTextLength) {
      if (newTextLength == 2 || newTextLength == 5) {
        text += '-';
      }
    } else if (newTextLength < oldTextLength) {
      if (newTextLength == 3 || newTextLength == 6) {
        text = text.substring(0, newTextLength - 1);
      }
    }

    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}
