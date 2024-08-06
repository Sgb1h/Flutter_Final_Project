import 'package:flutter/material.dart';
import 'database_helper.dart';
import 'shared_preferences_helper.dart';
import 'customer.dart';
import 'Homepage.dart'; // Import HomePage

class CustomerListPage extends StatefulWidget {
  @override
  _CustomerListPageState createState() => _CustomerListPageState();
}

class _CustomerListPageState extends State<CustomerListPage> {
  late DatabaseHelper _dbHelper;
  late SharedPreferencesHelper _prefsHelper;
  List<Customer> _customers = [];

  @override
  void initState() {
    super.initState();
    _dbHelper = DatabaseHelper.instance;
    _prefsHelper = SharedPreferencesHelper();
    _refreshCustomerList();
  }

  Future<void> _refreshCustomerList() async {
    final data = await _dbHelper.readAllCustomers();
    setState(() {
      _customers = data;
    });
  }

  void _addOrEditCustomer({Customer? customer}) async {
    final customerData = customer != null
        ? {
      'firstName': customer.firstName,
      'lastName': customer.lastName,
      'address': customer.address,
      'birthday': customer.birthday,
    }
        : await _prefsHelper.loadCustomerData();

    final firstNameController =
    TextEditingController(text: customerData['firstName']);
    final lastNameController =
    TextEditingController(text: customerData['lastName']);
    final addressController =
    TextEditingController(text: customerData['address']);
    final birthdayController =
    TextEditingController(text: customerData['birthday']);

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
                  customer == null ? 'Add Customer' : 'Edit Customer',
                  style: TextStyle(
                    fontSize: 20.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 16.0),
                TextField(
                  controller: firstNameController,
                  decoration: InputDecoration(labelText: 'First Name'),
                ),
                TextField(
                  controller: lastNameController,
                  decoration: InputDecoration(labelText: 'Last Name'),
                ),
                TextField(
                  controller: addressController,
                  decoration: InputDecoration(labelText: 'Address'),
                ),
                TextField(
                  controller: birthdayController,
                  decoration: InputDecoration(labelText: 'Birthday'),
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
                        final newCustomer = Customer(
                          id: customer?.id,
                          firstName: firstNameController.text,
                          lastName: lastNameController.text,
                          address: addressController.text,
                          birthday: birthdayController.text,
                        );

                        if (customer == null) {
                          await _dbHelper.create(newCustomer);
                        } else {
                          await _dbHelper.update(newCustomer);
                        }

                        await _prefsHelper.saveCustomerData(
                          firstName: newCustomer.firstName,
                          lastName: newCustomer.lastName,
                          address: newCustomer.address,
                          birthday: newCustomer.birthday,
                        );

                        _refreshCustomerList();
                        Navigator.of(context).pop();
                      },
                      child: Text(
                        customer == null ? 'Add' : 'Save',
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

  void _deleteCustomer(int id) async {
    await _dbHelper.delete(id);
    _refreshCustomerList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Customer List'),
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
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text('Instructions'),
                  content: Text(
                      'Use this page to add, view, update, or delete customers.'),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: Text('Close'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: _customers.length,
                  itemBuilder: (context, index) {
                    final customer = _customers[index];
                    return ListTile(
                      title: Text('${customer.firstName} ${customer.lastName}'),
                      subtitle: Text(
                          '${customer.address}\nBirthday: ${customer.birthday}'),
                      isThreeLine: true,
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(Icons.edit),
                            onPressed: () {
                              _addOrEditCustomer(customer: customer);
                            },
                          ),
                          IconButton(
                            icon: Icon(Icons.delete),
                            onPressed: () {
                              _deleteCustomer(customer.id!);
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
            bottom: 20,
            left: 0,
            right: 0,
            child: Center(
              child: ElevatedButton(
                onPressed: () {
                  _addOrEditCustomer();
                },
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: Text(
                  'Add Customer',
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
