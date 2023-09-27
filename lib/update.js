



const firebase = require("firebase/app");
require("firebase/firestore");

// Initialize Firebase (you must have already added your Firebase config here)
const firebaseConfig = {

    apiKey: "AIzaSyBK3gnzLAA7lQlDh88GCdBwFQeLhj8es78",
    authDomain: "login-page-data-1916c.firebaseapp.com",
    projectId: "login-page-data-1916c",
    storageBucket: "login-page-data-1916c.appspot.com",
    
    appId: "1:302231550683:android:953e257ae8c86fda662afe"
   

  
};
firebase.initializeApp(firebaseConfig);

const db = firebase.firestore();

// Generate array of maps
const mapArray = [];
for (let i = 0; i <= 500; i++) {
  mapArray.push({ value: i });
}

// Save to Firestore
db.collection('students').doc('DS_3rd_YR').set({
  data: mapArray
}).then(() => {
  console.log("Document successfully written!");
}).catch((error) => {
  console.error("Error writing document: ", error);
});
