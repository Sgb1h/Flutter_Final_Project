import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:sembast/sembast.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'add_reservation_page.dart';
import 'app_localizations.dart';

/// A page that displays the list of reservations and allows adding, editing, and deleting reservations.
class ReservationPage extends StatefulWidget {
  /// The database instance to store reservations.
  final Database database;

  /// Callback function to change the language.
  final Function(Locale) onLanguageChanged;

  /// Creates a [ReservationPage].
  ReservationPage({required this.database, required this.onLanguageChanged});

  @override
  _ReservationPageState createState() => _ReservationPageState();
}

class _ReservationPageState extends State<ReservationPage> {
  final StoreRef<int, Map<String, dynamic>> store = intMapStoreFactory.store('reservations');
  List<RecordSnapshot<int, Map<String, dynamic>>> _reservations = [];
  bool _isAddingReservation = false;
  final _secureStorage = const FlutterSecureStorage();
  Locale _currentLocale = Locale('en');

  @override
  void initState() {
    super.initState();
    _loadReservations();
    _loadPreferences();
  }

  /// Loads the reservations from the database.
  Future<void> _loadReservations() async {
    final records = await store.find(widget.database);
    setState(() {
      _reservations = records;
    });
  }

  /// Adds a new reservation to the database.
  Future<void> _addReservation(Map<String, String> reservation) async {
    await store.add(widget.database, {
      'customer': reservation['customer']!,
      'flight': reservation['flight']!,
      'date': reservation['date']!,
    });
    _loadReservations();
  }

  /// Updates an existing reservation in the database.
  Future<void> _updateReservation(int id, Map<String, String> reservation) async {
    await store.record(id).update(widget.database, {
      'customer': reservation['customer']!,
      'flight': reservation['flight']!,
      'date': reservation['date']!,
    });
    _loadReservations();
  }

  /// Deletes a reservation from the database.
  Future<void> _deleteReservation(int id) async {
    await store.record(id).delete(widget.database);
    _loadReservations();
  }

  /// Shows the details of a reservation in a dialog.
  void _showReservationDetails(Map<String, dynamic> reservation, int id) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(AppLocalizations.of(context).getTranslatedValue('reservationDetails') ?? 'Reservation Details'),
          content: Text(
              '${AppLocalizations.of(context).getTranslatedValue('customer') ?? 'Customer'}: ${reservation['customer']}\n'
                  '${AppLocalizations.of(context).getTranslatedValue('flight') ?? 'Flight'}: ${reservation['flight']}\n'
                  '${AppLocalizations.of(context).getTranslatedValue('date') ?? 'Date'}: ${reservation['date']}'),
          actions: [
            TextButton(
              child: Text(AppLocalizations.of(context).getTranslatedValue('delete') ?? 'Delete'),
              onPressed: () {
                Navigator.of(context).pop();
                _deleteReservation(id);
              },
            ),
            TextButton(
              child: Text(AppLocalizations.of(context).getTranslatedValue('edit') ?? 'Edit'),
              onPressed: () {
                Navigator.of(context).pop();
                _editReservation(id, reservation);
              },
            ),
            TextButton(
              child: Text(AppLocalizations.of(context).getTranslatedValue('ok') ?? 'OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  /// Edits a reservation by navigating to the [AddReservationPage].
  void _editReservation(int id, Map<String, dynamic> reservation) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddReservationPage(
          onLanguageChanged: widget.onLanguageChanged,
          onReservationAdded: (reservation) {
            _updateReservation(id, reservation);
          },
          isDesktopView: false,
          reservation: Map<String, String>.from(reservation),
        ),
      ),
    );
    if (result != null) {
      await _secureStorage.write(key: 'lastCustomer', value: result['customer']);
      _updateReservation(id, result);
    }
  }

  /// Loads the last customer preference.
  Future<void> _loadPreferences() async {
    String? lastCustomer = await _secureStorage.read(key: 'lastCustomer');
    if (lastCustomer != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Last customer: $lastCustomer')),
      );
    }
  }

  /// Changes the language.
  void _changeLanguage(Locale? locale) {
    if (locale != null) {
      widget.onLanguageChanged?.call(locale);
    }
  }

  /// Callback function when a reservation is added.
  void _onReservationAdded(Map<String, String> reservation) {
    _addReservation(reservation);
  }

  @override
  Widget build(BuildContext context) {
    final isWideScreen = MediaQuery.of(context).size.width > 800;
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).getTranslatedValue('title') ?? 'Airline Reservation System'),
        actions: [
          DropdownButton<Locale>(
            underline: SizedBox(),
            icon: Icon(Icons.language, color: Colors.black),
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
          IconButton(
            icon: Icon(Icons.info),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: Text(AppLocalizations.of(context).getTranslatedValue('instructions') ?? 'Instructions'),
                    content: Text(AppLocalizations.of(context).getTranslatedValue('instructionsDetails') ?? 'Instructions not available.'),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: Text(AppLocalizations.of(context).getTranslatedValue('ok') ?? 'OK'),
                      ),
                    ],
                  );
                },
              );
            },
          )
        ],
      ),
      body: isWideScreen ? _buildWideScreenLayout() : _buildNormalLayout(),
    );
  }

  /// Builds the wide screen layout.
  Widget _buildWideScreenLayout() {
    return Row(
      children: [
        Expanded(
          flex: 1,
          child: _buildReservationList(),
        ),
        VerticalDivider(width: 1),
        Expanded(
          flex: 1,
          child: AddReservationPage(
            onLanguageChanged: widget.onLanguageChanged,
            onReservationAdded: _onReservationAdded,
            isDesktopView: true,
          ),
        ),
      ],
    );
  }

  /// Builds the normal layout for mobile view.
  Widget _buildNormalLayout() {
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage('images/background.jpg'),
              fit: BoxFit.cover,
            ),
          ),
        ),
        if (_isAddingReservation)
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
            child: Container(
              color: Colors.black.withOpacity(0.1),
            ),
          ),
        Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            children: [
              Expanded(
                child: _buildReservationList(),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                child: Text(AppLocalizations.of(context).getTranslatedValue('addReservation') ?? 'Add Reservation'),
                onPressed: () async {
                  setState(() {
                    _isAddingReservation = true;
                  });
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AddReservationPage(
                        onLanguageChanged: widget.onLanguageChanged,
                        onReservationAdded: _onReservationAdded,
                        isDesktopView: false,
                      ),
                    ),
                  );
                  setState(() {
                    _isAddingReservation = false;
                  });
                  if (result != null) {
                    await _secureStorage.write(key: 'lastCustomer', value: result['customer']);
                    _onReservationAdded(result);
                  }
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Builds the list of reservations.
  Widget _buildReservationList() {
    return ListView.builder(
      itemCount: _reservations.length,
      itemBuilder: (context, index) {
        final reservation = _reservations[index];
        return ListTile(
          title: Text('${reservation.value['customer']} - ${reservation.value['flight']}'),
          subtitle: Text(reservation.value['date']),
          onTap: () => _showReservationDetails(reservation.value, reservation.key),
          trailing: IconButton(
            icon: Icon(Icons.edit),
            onPressed: () => _editReservation(reservation.key, reservation.value),
          ),
        );
      },
    );
  }
}
