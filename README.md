# Cattle Manager

Cattle Manager is a comprehensive Flutter application designed to help farmers and ranchers efficiently manage their cattle operations. The app provides tools for tracking cattle, milk production, health events, feed costs, and generating reports.

## Problem Statement
Indian dairy farmers rely heavily on traditional, manual record-keeping methods. This leads to:
- Errors in tracking milk deliveries and payments.
- Missed pregnancy cycles, heat tracking, and vaccinations.
- Increased workload, reducing efficiency.
- Paid livestock management apps that are expensive and inaccessible for small farmers.

## Our Solution
We are developing a free, user-friendly livestock management app designed specifically for Indian farmers. Our app will help farmers:
- **Digitally track milk deliveries:** Automatically update records when milk is delivered or skipped.
- **Manage finances effortlessly:** Generate bills and calculate payments instantly.
- **Monitor livestock health:** Get reminders for vaccinations, pregnancy cycles, and heat tracking.
- **Offline Access:** Farmers in rural areas can use it without needing continuous internet.
- **Multi-language Support:** Available in Hindi, Gujarati, Marathi, and other regional languages to ensure ease of use.

## Why Us?
- **Focused on affordability:** Unlike existing paid apps, ours is free for farmers.
- **Localized for Indian farmers:** Designed with simple Hindi/Gujarati/Marathi interface options.
- **Practical and efficient:** Built based on real challenges faced by farmers like my uncle.
- **Scalable and Expandable:** Future updates can include AI-based health monitoring, predictive analytics for milk yield, and integration with government schemes.

## Market Potential & Scalability
India has over 75 million dairy farmers, and the dairy industry contributes significantly to the economy. With increasing smartphone penetration in rural areas, our app has the potential to reach millions of farmers, improving productivity and profitability.

## Conclusion
With our app, we aim to revolutionize livestock management for Indian farmers, making dairy farming smarter, more efficient, and stress-free. By leveraging technology to solve real problems, we can help farmers focus on growth rather than manual work.

## Features

### Cattle Management
- Add, edit, and delete cattle records.
- Track individual cattle details including tag number, breed, date of birth, gender, and weight.
- Add notes and additional information for each animal.

### Milk Production Tracking
- Record daily milk production data.
- View milk production history and trends.
- Track production by individual cattle or the entire herd.

### Events Tracking
- Log health events, vaccinations, treatments, and other important activities.
- Set reminders for upcoming events.
- Filter events by cattle, date, or event type.

### Feed Cost Management
- Track all feed-related expenses.
- Categorize by feed type (hay, grain, silage, etc.).
- Calculate costs per animal and per day.
- Filter expenses by date range and feed type.

### Reports
- Generate comprehensive reports on cattle performance.
- Analyze milk production data.
- Track expenses and profitability.
- Export data for record-keeping.

### Multilingual Support
- English, Hindi, Marathi, and Gujarati language support.
- Easy language switching through the settings screen.
- Localized interface for improved user experience.

## Getting Started

### Prerequisites
- Flutter SDK (^3.5.0)
- Dart SDK
- Android Studio / VS Code with Flutter extensions

### Installation
1. Clone the repository:
```bash
git clone  https://github.com/srykaran/passhumitra.git 
```
2. Navigate to the project directory:
```bash
cd cattle-manager
```
3. Install dependencies:
```bash
flutter pub get
```
4. Run the app:
```bash
flutter run
```

## Usage

### Home Screen
The app provides a dashboard with quick access to all major features:
- Cattle inventory management.
- Milk production tracking.
- Event management.
- Reports generation.
- Feed cost tracking.
- Trade information.

Each tile displays the number of items in that category, giving you a quick overview of your farm data.

### Settings
Access the settings page by tapping the gear icon in the app bar. Here you can:
- Change the app language (English, Marathi).
- Configure other app preferences.

## Data Storage
The app stores all data locally on your device using SharedPreferences. This ensures:
- Your data is always accessible, even without an internet connection.
- No subscription fees or cloud storage required.
- Complete privacy of your farm data.

## Future Plans
- **Cloud Backup & Syncing**: Allow users to back up their data securely.
- **AI-Based Health Monitoring**: Use AI to predict cattle health issues.
- **Predictive Analytics for Milk Yield**: Help farmers optimize milk production.
- **Integration with Government Schemes**: Provide financial and advisory benefits.

## Development

### Project Structure
- `lib/models/` - Data models (Cattle, Event, FeedCost, etc.).
- `lib/screens/` - UI screens for different features.
- `lib/services/` - Business logic and data handling.
- `lib/utils/` - Utility functions and constants.
- `assets/lang/` - Localization files.

### Localization
The app uses JSON files for translation. To add a new language:
1. Create a new JSON file in `assets/lang/` with the language code (e.g., `fr.json`).
2. Add the new locale to the supported locales in `main.dart`.
3. Update the `isSupported` method in `app_localizations.dart`.



## Acknowledgements
- The Flutter team for the amazing framework.
- All contributors who have helped with the development.

