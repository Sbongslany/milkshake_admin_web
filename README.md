
Milkshake Admin Web App

This is the admin web application for Milkshake, built with Flutter Web. The app connects to a Node.js backend locally for testing and is also deployed for production.

1. API Configuration

The app communicates with the backend using a base URL, defined in:

lib/core/constants.dart


You can choose between production and local:

/// Production (Hosted on Render)
const String baseUrl = 'https://milkshake-app-backend.onrender.com/api';

/// Local (replace with your machine IP)
const String baseUrl = 'http://192.168.0.181:5001/api';


Notes:

Use the production URL for the live app.

Use the local URL for development or testing. Replace 192.168.0.181 with your local machine IP.

Make sure the backend is running before using the local URL.

2. Running Locally (Flutter Web)

Ensure the Node.js backend is running locally:

cd backend
npm install
npm run dev


Run the Flutter web app in Chrome:

flutter run -d chrome


The app will open in your browser at http://localhost:xxxx and connect to your local backend.

3. Production

The app is already deployed and available at the Render-hosted URL.

The production version automatically connects to:

https://milkshake-app-backend.onrender.com/api

4. Login Credentials (Test / Local)

Use the following credentials for testing locally or accessing the admin panel:

Field	Value
Email	manager@gmail.com

Password	12345678

✅ Tip: Always start the backend first when running locally, and make sure your machine IP is correct in the baseUrl.# milkshake_admin_web
