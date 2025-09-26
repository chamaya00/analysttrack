import { 
  collection, 
  getDocs, 
  query, 
  orderBy, 
  where,
  doc,
  getDoc,
  updateDoc,
  onSnapshot
} from 'firebase/firestore';
import { db } from '../firebase/config';

export const analystsService = {
  subscribeToTopAnalysts(callback, limit = 20) {
    const q = query(
      collection(db, 'users'),
      where('stats.totalPredictions', '>=', 1),
      orderBy('stats.accuracy', 'desc'),
      orderBy('stats.totalPredictions', 'desc')
    );
    
    return onSnapshot(q, (snapshot) => {
      const analysts = snapshot.docs.map(doc => ({
        id: doc.id,
        ...doc.data()
      }));
      callback(analysts);
    });
  },

  async getAnalystProfile(userId) {
    try {
      const userDoc = await getDoc(doc(db, 'users', userId));
      if (userDoc.exists()) {
        return {
          id: userDoc.id,
          ...userDoc.data()
        };
      }
      return null;
    } catch (error) {
      console.error('Error fetching analyst profile:', error);
      throw error;
    }
  }
};
