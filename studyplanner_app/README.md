# Study Planner Mobile App

A Flutter mobile application that serves as a WebView wrapper for the Study Planner web application.

## Overview

This Flutter application is designed to display the Study Planner web application running at http://localhost:8080 within a native mobile app container. It provides a seamless mobile experience for users of the Study Planner platform.

## Features

- WebView integration to display the Study Planner web app
- Loading indicator while the web content is being loaded
- Refresh button to reload the web content
- Support for both Android and iOS platforms

## Setup and Running

### Prerequisites

- Flutter SDK installed
- Android Studio or Xcode for device emulation
- The Study Planner web server running on http://localhost:8080

### Running the App

1. Ensure the Study Planner web server is running on http://localhost:8080
2. Connect a device or start an emulator
3. Run the app using the following command:

```bash
flutter run
```

## Technical Details

- Uses the `webview_flutter` package for WebView functionality
- Configured to allow cleartext (HTTP) traffic for local development
- Handles loading states and web resource errors
