# Hospital Kiosk System

## Overview
The Hospital Kiosk System is an interactive solution designed to streamline patient appointment booking and lab test management in a hospital setting. Patients can use the kiosk to register, book appointments with specialists based on symptoms, pay consultation fees, and manage lab tests prescribed by doctors. The system integrates with a doctor-facing mobile app called **CareLink**, enabling seamless communication between patients, doctors, and lab personnel.

## Features

### Patient Kiosk Interface
1. **Registration and Login**
   - Patients register or log in using personal details and OTP verification.
   - Secure authentication ensures patient data privacy.
2. **Welcome Screen**
   - Displays a welcome message post-login.
   - Provides two options: **Chatbot** and **Lab Test**.
3. **Chatbot for Appointment Booking**
   - Interactive chatbot collects patient symptoms.
   - Uses a dataset mapping symptoms to specialists.
   - Recommends a specialist if three or more symptoms match.
   - Redirects to payment via Razorpay for consultation fees.
   - Post-payment, displays the doctor's name and sends an SMS to the patient with the doctor's name and room number.
4. **Lab Test Management**
   - Allows patients to select prescribed lab tests after login.
   - Processes payment for lab tests via Razorpay.
   - Displays guidelines (dos and don’ts) for the selected test.
   - Sends an SMS confirmation to the patient upon payment.

### CareLink Doctor App
1. **Doctor Registration**
   - Doctors register with details like experience, qualifications, and age.
   - Secure login with username and password.
2. **Doctor Profile**
   - Displays doctor’s details and a list of patients with appointments for the day.
3. **Notifications**
   - Doctors receive SMS notifications when a patient books an appointment, including patient details.
4. **Lab Test Integration**
   - Lab personnel have limited access to upload test reports.
   - Doctors can view uploaded lab reports within the app.

### Notifications
- **Patient Notifications**: SMS sent to patients with appointment details (doctor’s name, room number) and lab test confirmations.
- **Doctor Notifications**: SMS sent to doctors when appointments are booked.

## Technology Stack
- **Frontend**: React, MUI
- **Backend**: Node.js, Python
- **Database**: MongoDB]
- **Payment Gateway**: Razorpay for secure transactions
- **SMS Service**: Twilio
- **Chatbot**: Custom-built with symptom-specialist dataset
- **Mobile App**: CareLink (Flutter)

## Installation

### Prerequisites
- Node.js, Python, database software
- Razorpay account for payment integration
- SMS service API key
  

## Usage
1. **Patient Kiosk**
   - Approach the kiosk and register/login using personal details and OTP.
   - Use the chatbot to input symptoms and book an appointment.
   - Pay the consultation fee to receive doctor details via SMS.
   - For lab tests, select the prescribed test, pay, and follow displayed guidelines.
2. **CareLink App**
   - Doctors log in to view their profile and patient appointments.
   - Lab personnel upload test reports via restricted access.
   - Doctors review reports and manage patient care.

## Team Members
The Hospital Kiosk System was developed by the following team members:

| Name              | Role                | GitHub Profile                              | LinkedIn Profile                                      |
|-------------------|---------------------|---------------------------------------------|-----------------------------------------------------|
| Varun A L   | Frontend Developer | [GitHub](https://github.com/varun-al)    | [LinkedIn](https://www.linkedin.com/in/varun-a-l-1099ba228/)      |
| K Rakshitha   | Backend Developer  | [GitHub](https://github.com/Rakshitha037)    | [LinkedIn](https://www.linkedin.com/in/k-rakshitha-131157229/)      |
| Ashish Goswami   | Mobile App Developer | [GitHub](https://github.com/ashish6298)  | [LinkedIn](https://www.linkedin.com/in/ashish-goswami-58797a24a/)      |
| Anjali P Nambiar   | UI/UX Designer     | [GitHub](https://github.com/2003anjali)    | [LinkedIn](https://www.linkedin.com/in/anjali-p-nambiar-9ab453241/)      |

## Future Enhancements
- Additional kiosk features (e.g., multilingual support, teleconsultation).
- Enhanced chatbot capabilities with AI-driven diagnostics.
- Integration with hospital management systems for real-time scheduling.
- Patient feedback system post-consultation.
