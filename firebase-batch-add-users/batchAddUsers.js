const admin = require('firebase-admin');
const serviceAccount = require('./login-page-data-1916c-firebase-adminsdk-hoxcb-2ab8c28248.json');  // replace with the correct path

// Initialize Firebase Admin SDK
admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
  databaseURL: 'https://console.firebase.google.com/project/login-page-data-1916c'  // replace with your database URL
});

const defaultPassword = 'acro1234'; // A strong initial password

const emails = [
    'pawanmakhija@acropolis.in',
    'ankitaagrawal@acropolis.in',
    'kapilsahu@acropolis.in',
    'prashantlakkadwala@acropolis.in',
    'brajeshchaturvedi@acropolis.in'
];

emails.forEach(async (email) => {
  try {
    const userRecord = await admin.auth().createUser({
      email: email,
      password: defaultPassword,
    });

    console.log('Successfully created user:', userRecord.uid);
  } catch (error) {
    console.error('Error creating user:', error);
  }
});
