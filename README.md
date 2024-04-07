**Face Recognition App with Geolocation and Geofencing**

**Introduction:**
      This Flutter app combines face recognition technology with location tracking and geofencing to enhance security measures. It leverages the device's camera to capture a user's face and sends the captured image to a backend service for identification. Simultaneously, it utilizes geolocation to continuously monitor the user's device location.

**Key Features:**
  1) Face Recognition: Captures a user's face and sends the image to a backend service for identification, ensuring authorized access.
  2) Location Tracking: Continuously monitors the user's device location using geolocation, providing real-time location awareness.
  3) Geofencing: Restricts face recognition to specific geographic areas, allowing face authentication only within designated zones, enhancing security measures.

**Requirements:**
  1) Flutter SDK for mobile app development
  2) Backend service with face recognition capabilities for user identification
  3) API key for the backend service to facilitate communication
  4) Google Maps API key for geolocation and geofencing functionalities

**Installation**
  1) Ensure Flutter SDK is installed and up-to-date on your system.
  2) Clone the repository to your local machine.
  3) Obtain a Google Maps API key and add it to the project's configuration.
  4) Run the following command from the project directory to build and run the app:
        **Bash**
        flutter run
        Use code with caution. Learn more
        **Usage**
            * Launch the app on your mobile device.
            * Point the device's camera at a user's face to capture an image.
            * The app will send the captured face image to the backend service for recognition.
            * If the user is within a designated geofenced area and face recognition is successful, the app will grant access.
            * If the user is outside the geofenced area or face recognition fails, access will be denied.

**Backend Service Integration:**
      The app utilizes a backend service with face recognition capabilities to authenticate users. The service receives the captured face image, processes it for identification, and returns a response indicating whether the face matches a known user.

**Geofencing Implementation:**
      Geofencing enables the app to restrict face recognition to specific geographic areas. This enhances security by ensuring that face authentication can only be performed within designated zones. The app leverages Google Maps API for geofencing functionalities.


![Screenshot from 2024-04-07 20-55-31](https://github.com/rahulavion/GeoAt/assets/87518013/c58b5025-76ea-4a25-af2f-13dd9c8e50c0)
![Screenshot from 2024-04-07 20-48-49](https://github.com/rahulavion/GeoAt/assets/87518013/da5432e1-d5be-48c7-b146-48a441ef0ded)
![Screenshot from 2024-04-07 20-46-54](https://github.com/rahulavion/GeoAt/assets/87518013/6e0ad874-dfc3-45ac-917c-cbbe7c4a9526)
![Screenshot from 2024-04-07 20-45-46](https://github.com/rahulavion/GeoAt/assets/87518013/54e5989e-6c1c-4525-a1c3-28faac9fbc46)
