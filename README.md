# Arsemed

### App Development
- **Flutter** (`v3.32.x+`) 
- **Dart** (`v3.8.x+`) 

## How to Use the Project

Assure that Flutter is already installed on your computer.

1. Clone the project
```
git clone https://github.com/adolforosas/Flutter-Dashboard.git
```

2. Open the project on your preferred IDE and add dependencies:
```
flutter pub get
```

3. Run the project:

* Open an Android emulator.
  
* Run the following command to build and run the project in development mode:
```
flutter build apk --debug --flavor development -t lib/main_development.dart
```

* To create a release version of the application run the command:
```
flutter build apk release --flavor production -t lib/main_production.dart
```

* To get the AAB of the project, run the command:
```
flutter build appbundle --flavor production -t lib/main_production.dart
```

Once built, your .aab file will be located at:

```
arsemed/build/app/outputs/bundle/productionRelease/app-production-release.aab
```
You can now upload this .aab file to the Google Play Console for release or testing.
