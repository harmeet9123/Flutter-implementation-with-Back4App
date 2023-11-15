# cpad_assignment

## Description

This is a simple task list (to-do) application built with Flutter and Back4App. Users can add, edit, and delete tasks, and the data is stored on Back4App, providing a scalable backend for the application.

## Features

- Add tasks
- Edit tasks
- Delete tasks
- Store tasks on Back4App

## Technologies Used

- Flutter
- Back4App

## Getting Started

### Prerequisites

- Downlaod and set up flutter from here: https://docs.flutter.dev/get-started/install

- Back4App account and an application set up from here: https://www.back4app.com/

### Installation

1. Clone the repository:

   open git bash
   git clone https://github.com/harmeet9123/Flutter-implementation-with-Back4App.git

2. Install dependencies

    flutter pub get

    #### Configuration

    1. Open the 'lib/config.dart' file.

    2. Replace 'YOUR_PARSE_APP_ID' and 'YOUR_PARSE_SERVER_URL' with your Back4App application ID and server URL.

        const String parseApplicationId = 'YOUR_PARSE_APP_ID';
        const String parseServerUrl = 'YOUR_PARSE_SERVER_URL';

3. Run the application:

    flutter run

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
