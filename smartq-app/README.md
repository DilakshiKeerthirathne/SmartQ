<h1 align="center"> SmartQ</h1>
<h3 align="center">AI-Powered Hospital Queue Management System</h3>

<p align="center">
SmartQ is a modern hospital queue management system designed to reduce patient waiting time and improve hospital efficiency.
Built using Flutter and Firebase, the system provides real-time queue tracking, role-based dashboards, and an integrated AI assistant.
</p>

<hr>

<h2> Key Features</h2>

<h3>🔹 Smart Queue Management</h3>
<ul>
  <li>Real-time ticket generation and tracking</li>
  <li>Automatic queue ordering (Emergency + Time priority)</li>
  <li>Live queue updates for patients and admins</li>
</ul>

<h3>🔹 Multi-Role System</h3>
<ul>
  <li><b>Patients</b> – Book and track queue</li>
  <li><b>Admins</b> – Manage queue flow</li>
  <li><b>Doctors</b> – View assigned patients</li>
</ul>

<h3>🔹 Real-Time Queue Status</h3>
<ul>
  <li>View position in queue</li>
  <li>See number of people ahead</li>
  <li>Estimated waiting time calculation</li>
  <li>Instant updates using Firebase</li>
</ul>

<h3>🔹 Admin Control Panel</h3>
<ul>
  <li>Call next patient</li>
  <li>Pause / Resume queue</li>
  <li>View all ticket statuses (Waiting, Called, Completed, Cancelled)</li>
  <li>Manage doctors</li>
</ul>

<h3>🔹 AI Assistant </h3>
<ul>
  <li>Hybrid AI system (Local + Real AI ready)</li>
  <li>Helps users understand queue status</li>
  <li>Provides guidance and system support</li>
  <li>Future-ready for advanced AI integration</li>
</ul>

<h3>🔹 Notifications System</h3>
<ul>
  <li>Alerts when it’s the user’s turn</li>
  <li>Real-time updates on queue changes</li>
</ul>

<h3>🔹 Modern UI/UX</h3>
<ul>
  <li>Clean and responsive Flutter interface</li>
  <li>User-friendly navigation</li>
  <li>Smooth interactions</li>
</ul>

<hr>

<h2> Tech Stack</h2>

<h3> Frontend</h3>
<ul>
  <li>Flutter</li>
</ul>

<h3> Backend</h3>
<ul>
  <li>Firebase Firestore</li>
  <li>Firebase Authentication</li>
</ul>

<h3> Architecture</h3>
<ul>
  <li>MVVM (Model-View-ViewModel)</li>
  <li>Repository Pattern</li>
</ul>

<h3> State Management</h3>
<ul>
  <li>Provider</li>
</ul>

<hr>

<h2> Getting Started</h2>

<pre>
git clone https://github.com/DilakshiKeerthirathne/SmartQ.git
cd SmartQ
flutter pub get
flutter run
</pre>

<hr>

<h2> Project Structure</h2>

<pre>
lib/
 ├── models/
 ├── viewmodels/
 ├── repositories/
 ├── services/
 ├── views/
 │    ├── user/
 │    ├── admin/
 │    └── auth/
 ├── navigation/
 ├── ai_service.dart
 └── main.dart
</pre>

<hr>

<h2> Challenges & Solutions</h2>
<ul>
  <li><b>Real-Time Data Handling</b> – Managed using Firebase streams</li>
  <li><b>Missing Database Fields</b> – Solved using null safety</li>
  <li><b>Queue Synchronization</b> – Implemented priority-based logic</li>
</ul>

<hr>

<h2> Future Improvements</h2>
<ul>
  <li>Voice-based AI assistant </li>
  <li>Multi-language support </li>
  <li>Advanced AI integration</li>
  <li>Appointment scheduling system</li>
</ul>

<hr>

<h2> Acknowledgement</h2>
<p>Developed with dedication to improve hospital efficiency and patient experience.</p>
