import 'package:flutter/material.dart';
import 'airplane.dart';
import 'database_helper.dart';

class AirplaneListPage extends StatefulWidget {
  @override
  _AirplaneListPageState createState() => _AirplaneListPageState();
}

class _AirplaneListPageState extends State<AirplaneListPage> {
  late DatabaseHelper _dbHelper;
  List<Airplane> _airplanes = [];

  @override
  void initState() {
    super.initState();
    _dbHelper = DatabaseHelper.instance;
    _refreshAirplaneList();
  }

  Future<void> _refreshAirplaneList() async {
    final data = await _dbHelper.readAllAirplanes();
    setState(() {
      _airplanes = data;
    });
  }

  void _addOrEditAirplane({Airplane? airplane}) {
    final typeController = TextEditingController();
    final passengersController = TextEditingController();
    final speedController = TextEditingController();
    final rangeController = TextEditingController();

    if (airplane != null) {
      typeController.text = airplane.type;
      passengersController.text = airplane.numberOfPassengers.toString();
      speedController.text = airplane.maxSpeed.toString();
      rangeController.text = airplane.range.toString();
    }

    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          child: Container(
            padding: EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  airplane == null ? 'Add Airplane' : 'Edit Airplane',
                  style: TextStyle(
                    fontSize: 20.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 16.0),
                TextField(
                  controller: typeController,
                  decoration: InputDecoration(labelText: 'Airplane Type'),
                ),
                TextField(
                  controller: passengersController,
                  decoration: InputDecoration(labelText: 'Number of Passengers'),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  controller: speedController,
                  decoration: InputDecoration(labelText: 'Max Speed'),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  controller: rangeController,
                  decoration: InputDecoration(labelText: 'Range'),
                  keyboardType: TextInputType.number,
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
                        style: TextStyle(color: Colors.blue),
                      ),
                    ),
                    TextButton(
                      onPressed: () async {
                        final newAirplane = Airplane(
                          id: airplane?.id,
                          type: typeController.text,
                          numberOfPassengers:
                          int.tryParse(passengersController.text) ?? 0,
                          maxSpeed: int.tryParse(speedController.text) ?? 0,
                          range: int.tryParse(rangeController.text) ?? 0,
                        );

                        if (airplane == null) {
                          await _dbHelper.create(newAirplane);
                        } else {
                          await _dbHelper.update(newAirplane);
                        }

                        _refreshAirplaneList();
                        Navigator.of(context).pop();
                      },
                      child: Text(
                        airplane == null ? 'Add' : 'Save',
                        style: TextStyle(color: Colors.blue),
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

  void _deleteAirplane(int id) async {
    await _dbHelper.delete(id);
    _refreshAirplaneList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                    'Airplane List',
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
                  itemCount: _airplanes.length,
                  itemBuilder: (context, index) {
                    final airplane = _airplanes[index];
                    return ListTile(
                      title: Text(airplane.type),
                      subtitle: Text('Passengers: ${airplane.numberOfPassengers}, '
                          'Max Speed: ${airplane.maxSpeed} km/h, '
                          'Range: ${airplane.range} km'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(Icons.edit),
                            onPressed: () {
                              _addOrEditAirplane(airplane: airplane);
                            },
                          ),
                          IconButton(
                            icon: Icon(Icons.delete),
                            onPressed: () {
                              _deleteAirplane(airplane.id!);
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
                  _addOrEditAirplane();
                },
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: Text(
                  'Add Airplane',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
