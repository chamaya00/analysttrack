import { initializeApp } from 'firebase/app';
import { getFirestore } from 'firebase/firestore';
import { getAuth } from 'firebase/auth';

const firebaseConfig = {
  apiKey: "AIzaSyDQ239cCldZFoEr65UQQRmkb7skemZuOsk",
  authDomain: "analysttrack.firebaseapp.com",
  projectId: "analysttrack",
  storageBucket: "analysttrack.firebasestorage.app",
  messagingSenderId: "1016637620117",
  appId: "1:1016637620117:web:26277b7a9cc420ccaa809c",
  measurementId: "G-Z9N5RVDF14"
};

// Initialize Firebase
const app = initializeApp(firebaseConfig);

// Initialize Firebase services
export const db = getFirestore(app);
export const auth = getAuth(app);

export default app;
