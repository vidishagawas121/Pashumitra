# Cattle Manager

Cattle Manager is a comprehensive Flutter application designed to help farmers and ranchers efficiently manage their cattle operations. The app provides tools for tracking cattle, milk production, health events, feed costs, and generating reports.

## Features

### Cattle Management
- Add, edit, and delete cattle records
- Track individual cattle details including tag number, breed, date of birth, gender, and weight
- Add notes and additional information for each animal

### Milk Production Tracking
- Record daily milk production data
- View milk production history and trends
- Track production by individual cattle or the entire herd

### Events Tracking
- Log health events, vaccinations, treatments, and other important activities
- Set reminders for upcoming events
- Filter events by cattle, date, or event type

### Feed Cost Management
- Track all feed-related expenses
- Categorize by feed type (hay, grain, silage, etc.)
- Calculate costs per animal and per day
- Filter expenses by date range and feed type

### Reports
- Generate comprehensive reports on cattle performance
- Analyze milk production data
- Track expenses and profitability
- Export data for record-keeping

### Multilingual Support
- English and Marathi language support
- Easy language switching through the settings screen
- Localized interface for improved user experience

## Getting Started

### Prerequisites
- Flutter SDK (^3.5.0)
- Dart SDK
- Android Studio / VS Code with Flutter extensions

### Installation
1. Clone the repository
```bash
git clone https://github.com/your-username/cattle-manager.git
```

2. Navigate to the project directory
```bash
cd cattle-manager
```

3. Install dependencies
```bash
flutter pub get
```

4. Run the app
```bash
flutter run
```

## Usage

### Home Screen
The app provides a dashboard with quick access to all major features:
- Cattle inventory management
- Milk production tracking
- Event management
- Reports generation
- Feed cost tracking
- Trade information

Each tile displays the number of items in that category, giving you a quick overview of your farm data.

### Settings
Access the settings page by tapping the gear icon in the app bar. Here you can:
- Change the app language (English/Marathi)
- Configure other app preferences

## Data Storage
The app stores all data locally on your device using SharedPreferences. This ensures:
- Your data is always accessible, even without an internet connection
- No subscription fees or cloud storage required
- Complete privacy of your farm data

## Development

### Project Structure
- `lib/models/` - Data models (Cattle, Event, FeedCost, etc.)
- `lib/screens/` - UI screens for different features
- `lib/services/` - Business logic and data handling
- `lib/utils/` - Utility functions and constants
- `assets/lang/` - Localization files

### Localization
The app uses JSON files for translation. To add a new language:
1. Create a new JSON file in `assets/lang/` with the language code (e.g., `fr.json`)
2. Add the new locale to the supported locales in `main.dart`
3. Update the `isSupported` method in `app_localizations.dart`

## Contributing
Contributions are welcome! Please feel free to submit a Pull Request.

## License
This project is licensed under the MIT License - see the LICENSE file for details.

## Acknowledgements
- The Flutter team for the amazing framework
- All contributors who have helped with the development
