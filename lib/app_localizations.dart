import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show SynchronousFuture;

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static Map<String, Map<String, String>> _localizedValues = {
    'en': {
      'title': 'Airline Reservation System',
      'addReservation': 'Add Reservation',
      'reservationDetails': 'Reservation Details',
      'customer': 'Customer',
      'flight': 'Flight',
      'date': 'Date',
      'delete': 'Delete',
      'ok': 'OK',
      'instructions': 'Instructions',
      'instructionsDetails': "Welcome to the Airline Reservation System! Follow the steps below to navigate through the app and make reservations:\n\n1. **Home Page (Reservation List)**:\n   - **Purpose**: The home page displays a list of all your current reservations.\n   - **Features**:\n     - **View Reservations**: See a list of existing reservations, each displaying the customer's name and flight details.\n     - **Select Reservation**: Tap on any reservation to view its detailed information.\n     - **Add New Reservation**: Use the 'Add Reservation' button to navigate to the reservation creation page.\n\n2. **Adding a New Reservation**:\n   - **Navigate**: Click the 'Add Reservation' button on the home page.\n   - **Steps**:\n     1. **Enter Customer Name**: Fill in the name of the customer.\n     2. **Select Departure City**: Choose the city from which the flight will depart.\n     3. **Select Destination City**: Choose the city where the flight will arrive.\n     4. **Select Flight**: Based on your city choices, select from the available flights.\n     5. **Enter Date**: Input the date of the flight in the format DD-MM-YYYY.\n     6. **Submit**: Press the 'Submit Reservation' button to save your reservation.\n\n   - **Validation**:\n     - Ensure all fields are filled.\n     - The date must be in the correct format (DD-MM-YYYY).\n\n3. **Viewing Reservation Details**:\n   - **Select Reservation**: Tap on a reservation from the home page list to view details.\n   - **Details Shown**: Customer Name, Flight Number, Route, and Date.\n\nEnjoy using the app!",
      'enterCustomerName': 'Enter Customer Name',
      'selectDepartureCity': 'Select Departure City',
      'selectDestinationCity': 'Select Destination City',
      'selectFlight': 'Select Flight',
      'dateFormat': 'Date (DD-MM-YYYY)',
      'submitReservation': 'Submit Reservation',
      'fillAllFields': 'Please fill all fields',
      'invalidDateFormat': 'Invalid date format. Use DD-MM-YYYY.',
    },
    'fr': {
      'title': 'Système de réservation aérienne',
      'addReservation': 'Ajouter une réservation',
      'reservationDetails': 'Détails de la réservation',
      'customer': 'Client',
      'flight': 'Vol',
      'date': 'Date',
      'delete': 'Supprimer',
      'ok': 'OK',
      'instructions': 'Instructions',
      'instructionsDetails': "Bienvenue dans le Système de Réservation Aérienne ! Suivez les étapes ci-dessous pour naviguer dans l'application et faire des réservations :\n\n1. **Page d'accueil (Liste des Réservations)** :\n   - **But** : La page d'accueil affiche une liste de toutes vos réservations actuelles.\n   - **Fonctionnalités** :\n     - **Voir les Réservations** : Consultez une liste des réservations existantes, affichant chacune le nom du client et les détails du vol.\n     - **Sélectionner une Réservation** : Appuyez sur une réservation pour voir ses informations détaillées.\n     - **Ajouter une Nouvelle Réservation** : Utilisez le bouton 'Ajouter une Réservation' pour accéder à la page de création de réservation.\n\n2. **Ajouter une Nouvelle Réservation** :\n   - **Naviguer** : Cliquez sur le bouton 'Ajouter une Réservation' sur la page d'accueil.\n   - **Étapes** :\n     1. **Entrez le Nom du Client** : Remplissez le nom du client.\n     2. **Sélectionnez la Ville de Départ** : Choisissez la ville de départ du vol.\n     3. **Sélectionnez la Ville de Destination** : Choisissez la ville d'arrivée du vol.\n     4. **Sélectionnez le Vol** : En fonction de vos choix de ville, sélectionnez parmi les vols disponibles.\n     5. **Entrez la Date** : Entrez la date du vol au format JJ-MM-AAAA.\n     6. **Soumettre** : Appuyez sur le bouton 'Soumettre la Réservation' pour enregistrer votre réservation.\n\n   - **Validation** :\n     - Assurez-vous que tous les champs sont remplis.\n     - La date doit être au bon format (JJ-MM-AAAA).\n\n3. **Voir les Détails de la Réservation** :\n   - **Sélectionner une Réservation** : Appuyez sur une réservation dans la liste de la page d'accueil pour voir les détails.\n   - **Détails Affichés** : Nom du client, numéro de vol, itinéraire et date.\n\nProfitez de l'application !",
      'enterCustomerName': 'Entrez le nom du client',
      'selectDepartureCity': 'Sélectionnez la ville de départ',
      'selectDestinationCity': 'Sélectionnez la ville de destination',
      'selectFlight': 'Sélectionnez le vol',
      'dateFormat': 'Date (JJ-MM-AAAA)',
      'submitReservation': 'Soumettre la réservation',
      'fillAllFields': 'Veuillez remplir tous les champs',
      'invalidDateFormat': 'Format de date invalide. Utilisez JJ-MM-AAAA.',
    },
  };

  String? getTranslatedValue(String key) {
    return _localizedValues[locale.languageCode]?[key];
  }

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
  _AppLocalizationsDelegate();
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['en', 'fr'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(AppLocalizations(locale));
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
