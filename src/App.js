import React, { useState, useEffect } from 'react';
import { TrendingUp, TrendingDown, User, Target, Award, Plus, LogOut } from 'lucide-react';
import { useAuth } from './hooks/useAuth';
import { predictionsService } from './services/predictionsService';
import { analystsService } from './services/analystsService';
import LoginForm from './components/LoginForm';
import './App.css';

const Navigation = ({ activeTab, setActiveTab, user, userProfile, onLogout }) => (
  <div style={{ background: 'white', padding: '20px', borderBottom: '1px solid #ccc', marginBottom: '20px' }}>
    <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
      <div style={{ display: 'flex', alignItems: 'center', gap: '10px' }}>
        <Target size={32} color="#2563eb" />
        <h1 style={{ margin: 0, fontSize: '28px', color: '#333' }}>AnalystTrack</h1>
      </div>
      
      <div style={{ display: 'flex', alignItems: 'center', gap: '20px' }}>
        <button
          onClick={() => setActiveTab('browse')}
          style={{ backgroundColor: activeTab === 'browse' ? '#dbeafe' : 'transparent', color: activeTab === 'browse' ? '#1d4ed8' : '#666' }}
        >
          Browse Analysts
        </button>
        <button
          onClick={() => setActiveTab('predictions')}
          style={{ backgroundColor: activeTab === 'predictions' ? '#dbeafe' : 'transparent', color: activeTab === 'predictions' ? '#1d4ed8' : '#666' }}
        >
          All Predictions
        </button>
        <button
          onClick={() => setActiveTab('submit')}
          style={{ backgroundColor: activeTab === 'submit' ? '#dbeafe' : 'transparent', color: activeTab === 'submit' ? '#1d4ed8' : '#666' }}
        >
          Submit Prediction
        </button>
        
        {userProfile && (
          <div style={{ display: 'flex', alignItems: 'center', gap: '10px', borderLeft: '1px solid #ccc', paddingLeft: '20px' }}>
            <div>
              <p style={{ margin: 0, fontWeight: 'bold' }}>{userProfile.name}</p>
              <p style={{ margin: 0, fontSize: '12px', color: '#666' }}>
                {userProfile.stats?.accuracy || 0}% accuracy
              </p>
            </div>
            <button onClick={onLogout} style={{ background: 'transparent', color: '#666' }}>
              <LogOut size={20} />
            </button>
          </div>
        )}
      </div>
    </div>
  </div>
);

const BrowseAnalystsScreen = () => {
  const [analysts, setAnalysts] = useState([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    const unsubscribe = analystsService.subscribeToTopAnalysts((analysts) => {
      setAnalysts(analysts);
      setLoading(false);
    });
    return () => unsubscribe();
  }, []);

  if (loading) {
    return <div style={{ textAlign: 'center', padding: '50px' }}>Loading...</div>;
  }

  return (
    <div className="container">
      <h2>Top Performing Analysts</h2>
      <p>Discover analysts with proven track records</p>
      
      {analysts.length === 0 ? (
        <div className="card" style={{ textAlign: 'center' }}>
          <p>No analysts found. Be the first to make predictions!</p>
        </div>
      ) : (
        <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fit, minmax(300px, 1fr))', gap: '20px' }}>
          {analysts.map((analyst) => (
            <div key={analyst.id} className="card">
              <div style={{ display: 'flex', alignItems: 'center', gap: '10px', marginBottom: '15px' }}>
                <User size={24} color="#2563eb" />
                <div>
                  <h3 style={{ margin: 0 }}>{analyst.name}</h3>
                  <p style={{ margin: 0, color: '#666', fontSize: '14px' }}>{analyst.specialty}</p>
                </div>
              </div>
              <div>
                <p>Accuracy: {analyst.stats?.accuracy || 0}%</p>
                <p>Predictions: {analyst.stats?.correctPredictions || 0}/{analyst.stats?.totalPredictions || 0}</p>
                <p>Avg Return: +{analyst.stats?.avgReturn?.toFixed(1) || 0}%</p>
              </div>
            </div>
          ))}
        </div>
      )}
    </div>
  );
};

const PredictionsScreen = ({ predictions, loading }) => {
  if (loading) {
    return <div style={{ textAlign: 'center', padding: '50px' }}>Loading...</div>;
  }

  return (
    <div className="container">
      <h2>Recent Predictions</h2>
      <p>Track all analyst predictions and outcomes</p>
      
      {predictions.length === 0 ? (
        <div className="card" style={{ textAlign: 'center' }}>
          <p>No predictions yet. Be the first to submit a stock prediction!</p>
        </div>
      ) : (
        <div>
          {predictions.map((prediction) => (
            <div key={prediction.id} className="card">
              <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
                <div>
                  <h3 style={{ margin: 0 }}>{prediction.analyst}</h3>
                  <p style={{ margin: '5px 0', fontWeight: 'bold' }}>{prediction.stock}</p>
                  <p style={{ margin: '5px 0' }}>
                    ${prediction.currentPrice?.toFixed(2)} → ${prediction.targetPrice?.toFixed(2)}
                  </p>
                  <p style={{ margin: '5px 0', fontSize: '14px', color: '#666' }}>{prediction.reasoning}</p>
                </div>
                <div style={{ textAlign: 'right' }}>
                  <p style={{ margin: 0, fontSize: '12px' }}>{prediction.timeframe}</p>
                  <p style={{ margin: 0, fontSize: '12px' }}>{prediction.confidence} confidence</p>
                  <p style={{ margin: 0, fontSize: '12px' }}>{prediction.status}</p>
                </div>
              </div>
            </div>
          ))}
        </div>
      )}
    </div>
  );
};

const SubmitPredictionScreen = ({ user, onAddPrediction }) => {
  const [newPrediction, setNewPrediction] = useState({
    stock: '',
    targetPrice: '',
    timeframe: '3 months',
    reasoning: '',
    confidence: 'Medium'
  });
  const [submitting, setSubmitting] = useState(false);

  const handleSubmit = async () => {
    if (!newPrediction.stock || !newPrediction.targetPrice || !newPrediction.reasoning) {
      alert('Please fill in all required fields');
      return;
    }

    setSubmitting(true);
    
    try {
      const prediction = {
        userId: user.uid,
        stock: newPrediction.stock.toUpperCase(),
        currentPrice: Math.random() * 500 + 50,
        targetPrice: parseFloat(newPrediction.targetPrice),
        timeframe: newPrediction.timeframe,
        reasoning: newPrediction.reasoning,
        confidence: newPrediction.confidence
      };
      
      await onAddPrediction(prediction);
      
      setNewPrediction({
        stock: '',
        targetPrice: '',
        timeframe: '3 months',
        reasoning: '',
        confidence: 'Medium'
      });
      
      alert('Prediction submitted successfully!');
    } catch (error) {
      console.error('Error submitting prediction:', error);
      alert('Failed to submit prediction. Please try again.');
    } finally {
      setSubmitting(false);
    }
  };

  return (
    <div className="container">
      <h2>Submit New Prediction</h2>
      <p>Add your stock price prediction to build your track record</p>
      
      <div className="card" style={{ maxWidth: '600px' }}>
        <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '20px', marginBottom: '20px' }}>
          <div>
            <label>Stock Symbol *</label>
            <input
              type="text"
              value={newPrediction.stock}
              onChange={(e) => setNewPrediction({...newPrediction, stock: e.target.value})}
              placeholder="AAPL"
              disabled={submitting}
            />
          </div>
          <div>
            <label>Target Price ($) *</label>
            <input
              type="number"
              value={newPrediction.targetPrice}
              onChange={(e) => setNewPrediction({...newPrediction, targetPrice: e.target.value})}
              placeholder="210.00"
              step="0.01"
              disabled={submitting}
            />
          </div>
        </div>

        <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '20px', marginBottom: '20px' }}>
          <div>
            <label>Timeframe</label>
            <select
              value={newPrediction.timeframe}
              onChange={(e) => setNewPrediction({...newPrediction, timeframe: e.target.value})}
              disabled={submitting}
            >
              <option value="1 month">1 month</option>
              <option value="3 months">3 months</option>
              <option value="6 months">6 months</option>
              <option value="1 year">1 year</option>
            </select>
          </div>
          <div>
            <label>Confidence Level</label>
            <select
              value={newPrediction.confidence}
              onChange={(e) => setNewPrediction({...newPrediction, confidence: e.target.value})}
              disabled={submitting}
            >
              <option value="Low">Low</option>
              <option value="Medium">Medium</option>
              <option value="High">High</option>
            </select>
          </div>
        </div>

        <div>
          <label>Reasoning *</label>
          <textarea
            value={newPrediction.reasoning}
            onChange={(e) => setNewPrediction({...newPrediction, reasoning: e.target.value})}
            placeholder="Explain your reasoning for this price target..."
            disabled={submitting}
            rows="3"
          />
        </div>

        <button
          onClick={handleSubmit}
          disabled={submitting}
          style={{ width: '100%', padding: '15px' }}
        >
          {submitting ? 'Submitting...' : 'Submit Prediction'}
        </button>
      </div>
    </div>
  );
};

function App() {
  const { user, userProfile, loading, logout } = useAuth();
  const [activeTab, setActiveTab] = useState('browse');
  const [predictions, setPredictions] = useState([]);
  const [predictionsLoading, setPredictionsLoading] = useState(true);

  useEffect(() => {
    if (user) {
      const unsubscribe = predictionsService.subscribeToAllPredictions((predictions) => {
        setPredictions(predictions);
        setPredictionsLoading(false);
      });
      return () => unsubscribe();
    }
  }, [user]);

  const addPrediction = async (predictionData) => {
    try {
      await predictionsService.createPrediction(predictionData);
    } catch (error) {
      console.error('Error adding prediction:', error);
      throw error;
    }
  };

  if (loading) {
    return (
      <div style={{ textAlign: 'center', padding: '100px' }}>
        <p>Loading AnalystTrack...</p>
      </div>
    );
  }

  if (!user) {
    return <LoginForm />;
  }

  return (
    <div style={{ minHeight: '100vh', backgroundColor: '#f5f5f5' }}>
      <Navigation 
        activeTab={activeTab} 
        setActiveTab={setActiveTab}
        user={user}
        userProfile={userProfile}
        onLogout={logout}
      />
      
      {activeTab === 'browse' && <BrowseAnalystsScreen />}
      {activeTab === 'predictions' && (
        <PredictionsScreen 
          predictions={predictions} 
          loading={predictionsLoading}
        />
      )}
      {activeTab === 'submit' && (
        <SubmitPredictionScreen 
          user={user}
          onAddPrediction={addPrediction} 
        />
      )}
    </div>
  );
}

export default App;
