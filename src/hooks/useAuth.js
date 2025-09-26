import { useState, useEffect } from 'react';
import { 
  onAuthStateChanged, 
  signInWithEmailAndPassword, 
  createUserWithEmailAndPassword, 
  signOut,
  updateProfile
} from 'firebase/auth';
import { doc, setDoc, getDoc } from 'firebase/firestore';
import { auth, db } from '../firebase/config';

export const useAuth = () => {
  const [user, setUser] = useState(null);
  const [loading, setLoading] = useState(true);
  const [userProfile, setUserProfile] = useState(null);

  useEffect(() => {
    const unsubscribe = onAuthStateChanged(auth, async (user) => {
      if (user) {
        try {
          const userDoc = await getDoc(doc(db, 'users', user.uid));
          if (userDoc.exists()) {
            setUserProfile(userDoc.data());
          }
        } catch (error) {
          console.error('Error fetching user profile:', error);
        }
      } else {
        setUserProfile(null);
      }
      setUser(user);
      setLoading(false);
    });

    return unsubscribe;
  }, []);

  const login = async (email, password) => {
    try {
      const result = await signInWithEmailAndPassword(auth, email, password);
      return result.user;
    } catch (error) {
      throw error;
    }
  };

  const signup = async (email, password, displayName, specialty = '') => {
    try {
      const result = await createUserWithEmailAndPassword(auth, email, password);
      
      await updateProfile(result.user, {
        displayName: displayName
      });

      const userProfile = {
        uid: result.user.uid,
        name: displayName,
        email: email,
        specialty: specialty,
        bio: '',
        profileImage: '',
        verified: false,
        createdAt: new Date(),
        stats: {
          totalPredictions: 0,
          correctPredictions: 0,
          accuracy: 0,
          avgReturn: 0,
          rating: 0,
          followers: 0,
          following: 0
        }
      };

      await setDoc(doc(db, 'users', result.user.uid), userProfile);
      setUserProfile(userProfile);

      return result.user;
    } catch (error) {
      throw error;
    }
  };

  const logout = async () => {
    try {
      await signOut(auth);
      setUserProfile(null);
    } catch (error) {
      throw error;
    }
  };

  return { 
    user, 
    userProfile, 
    loading, 
    login, 
    signup, 
    logout 
  };
};
