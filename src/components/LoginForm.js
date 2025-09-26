import React, { useState } from 'react';
import { Target, User, Mail, Lock, TrendingUp } from 'lucide-react';
import { useAuth } from '../hooks/useAuth';

const LoginForm = () => {
  const { login, signup } = useAuth();
  const [isLogin, setIsLogin] = useState(true);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState('');
  
  const [formData, setFormData] = useState({
    email: '',
    password: '',
    displayName: '',
    specialty: ''
  });

  const specialties = [
    'Technology Stocks',
    'Healthcare & Biotech',
    'Financial Services',
    'Energy & Utilities',
    'Consumer Goods',
    'Real Estate',
    'Cryptocurrency',
    'International Markets',
    'Small Cap Stocks',
    'ESG Investing'
  ];

  const handleSubmit = async (e) => {
    e.preventDefault();
    setLoading(true);
    setError('');

    try {
      if (isLogin) {
        await login(formData.email, formData.password);
      } else {
        if (!formData.displayName.trim()) {
          throw new Error('Display name is required');
        }
        await signup(
          formData.email, 
          formData.password, 
          formData.displayName.trim(),
          formData.specialty
        );
      }
    } catch (error) {
      setError(error.message);
    } finally {
      setLoading(false);
    }
  };

  const handleInputChange = (field, value) => {
    setFormData(prev => ({
      ...prev,
      [field]: value
    }));
  };

  return (
    <div style={{ 
      minHeight: '100vh', 
      background: 'linear-gradient(135deg, #eff6ff 0%, #dbeafe 100%)', 
      display: 'flex', 
      alignItems: 'center', 
      justifyContent: 'center',
      padding: '20px'
    }}>
      <div style={{ width: '100%', maxWidth: '400px' }}>
        <div style={{ textAlign: 'center', marginBottom: '30px' }}>
          <div style={{ display: 'flex', justifyContent: 'center', alignItems: 'center', gap: '10px', marginBottom: '20px' }}>
            <Target size={48} color="#2563eb" />
            <h1 style={{ margin: 0, fontSize: '36px', color: '#1f2937' }}>AnalystTrack</h1>
          </div>
          <h2 style={{ margin: '0 0 10px 0', color: '#4b5563' }}>
            {isLogin ? 'Sign in to your account' : 'Create your analyst profile'}
          </h2>
          <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'center', gap: '5px', color: '#6b7280', fontSize: '14px' }}>
            <TrendingUp size={16} />
            <span>Track predictions • Build credibility • Gain followers</span>
          </div>
        </div>

        <form onSubmit={handleSubmit}>
          <div style={{ background: 'white', borderRadius: '12px', boxShadow: '0 10px 25px rgba(0,0,0,0.1)', padding: '30px' }}>
            
            {!isLogin && (
              <div style={{ marginBottom: '20px' }}>
                <label style={{ display: 'block', marginBottom: '5px', fontWeight: '500' }}>
                  <User size={16} style={{ display: 'inline', marginRight: '5px' }} />
                  Display Name
                </label>
                <input
                  type="text"
                  required={!isLogin}
                  value={formData.displayName}
                  onChange={(e) => handleInputChange('displayName', e.target.value)}
                  placeholder="Your professional name"
                />
              </div>
            )}

            <div style={{ marginBottom: '20px' }}>
              <label style={{ display: 'block', marginBottom: '5px', fontWeight: '500' }}>
                <Mail size={16} style={{ display: 'inline', marginRight: '5px' }} />
                Email Address
              </label>
              <input
                type="email"
                required
                value={formData.email}
                onChange={(e) => handleInputChange('email', e.target.value)}
                placeholder="analyst@example.com"
              />
            </div>

            <div style={{ marginBottom: '20px' }}>
              <label style={{ display: 'block', marginBottom: '5px', fontWeight: '500' }}>
                <Lock size={16} style={{ display: 'inline', marginRight: '5px' }} />
                Password
              </label>
              <input
                type="password"
                required
                value={formData.password}
                onChange={(e) => handleInputChange('password', e.target.value)}
                placeholder="••••••••"
                minLength={6}
              />
            </div>

            {!isLogin && (
              <div style={{ marginBottom: '20px' }}>
                <label style={{ display: 'block', marginBottom: '5px', fontWeight: '500' }}>
                  Specialty (Optional)
                </label>
                <select
                  value={formData.specialty}
                  onChange={(e) => handleInputChange('specialty', e.target.value)}
                >
                  <option value="">Select your area of expertise</option>
                  {specialties.map(specialty => (
                    <option key={specialty} value={specialty}>
                      {specialty}
                    </option>
                  ))}
                </select>
              </div>
            )}

            {error && (
              <div style={{ 
                background: '#fef2f2', 
                border: '1px solid #fecaca', 
                color: '#dc2626', 
                padding: '10px', 
                borderRadius: '6px', 
                marginBottom: '20px',
                fontSize: '14px'
              }}>
                {error}
              </div>
            )}

            <button
              type="submit"
              disabled={loading}
              style={{ 
                width: '100%', 
                padding: '12px', 
                fontSize: '16px',
                opacity: loading ? 0.5 : 1
              }}
            >
              {loading ? (
                isLogin ? 'Signing in...' : 'Creating account...'
              ) : (
                isLogin ? 'Sign In' : 'Create Account'
              )}
            </button>

            <div style={{ textAlign: 'center', marginTop: '20px' }}>
              <button
                type="button"
                onClick={() => {
                  setIsLogin(!isLogin);
                  setError('');
                  setFormData({
                    email: '',
                    password: '',
                    displayName: '',
                    specialty: ''
                  });
                }}
                style={{ 
                  background: 'transparent', 
                  color: '#2563eb', 
                  fontSize: '14px',
                  textDecoration: 'underline',
                  border: 'none',
                  cursor: 'pointer'
                }}
              >
                {isLogin 
                  ? "Don't have an account? Sign up" 
                  : "Already have an account? Sign in"
                }
              </button>
            </div>
          </div>
        </form>
      </div>
    </div>
  );
};

export default LoginForm;
