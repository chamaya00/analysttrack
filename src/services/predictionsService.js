import { 
  collection, 
  addDoc, 
  getDocs, 
  query, 
  orderBy, 
  where,
  updateDoc,
  doc,
  onSnapshot,
  getDoc,
  writeBatch,
  increment
} from 'firebase/firestore';
import { db } from '../firebase/config';

export const predictionsService = {
  async createPrediction(predictionData) {
    try {
      const batch = writeBatch(db);
      
      const predictionRef = doc(collection(db, 'predictions'));
      const prediction = {
        ...predictionData,
        createdAt: new Date(),
        status: 'active',
        views: 0,
        likes: 0
      };
      
      batch.set(predictionRef, prediction);
      
      const userRef = doc(db, 'users', predictionData.userId);
      batch.update(userRef, {
        'stats.totalPredictions': increment(1)
      });
      
      await batch.commit();
      return predictionRef.id;
    } catch (error) {
      console.error('Error creating prediction:', error);
      throw error;
    }
  },

  subscribeToAllPredictions(callback) {
    const q = query(
      collection(db, 'predictions'), 
      orderBy('createdAt', 'desc')
    );
    
    return onSnapshot(q, async (snapshot) => {
      const predictions = [];
      
      for (const docSnapshot of snapshot.docs) {
        const predictionData = docSnapshot.data();
        
        try {
          const userDoc = await getDoc(doc(db, 'users', predictionData.userId));
          const analystData = userDoc.exists() ? userDoc.data() : {};
          
          predictions.push({
            id: docSnapshot.id,
            ...predictionData,
            analyst: analystData.name || 'Unknown Analyst',
            analystSpecialty: analystData.specialty || '',
            analystRating: analystData.stats?.rating || 0,
            createdAt: predictionData.createdAt?.toDate() || new Date()
          });
        } catch (error) {
          console.error('Error fetching analyst data:', error);
          predictions.push({
            id: docSnapshot.id,
            ...predictionData,
            analyst: 'Unknown Analyst',
            createdAt: predictionData.createdAt?.toDate() || new Date()
          });
        }
      }
      
      callback(predictions);
    });
  }
};
