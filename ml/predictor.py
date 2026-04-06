import joblib
import pandas as pd
import numpy as np
import os

# Ensure paths are relative to this script's directory for reliability
BASE_DIR = os.path.dirname(os.path.abspath(__file__))
MODEL_PATH = os.path.join(BASE_DIR, 'gig_earnings_model.joblib')
FEATURES_PATH = os.path.join(BASE_DIR, 'model_features.joblib')

class GigEarningsPredictor:
    def __init__(self):
        self.model = None
        self.features = None
        self._load_model()

    def _load_model(self):
        """Load the pre-trained XGBoost model and feature list."""
        if os.path.exists(MODEL_PATH) and os.path.exists(FEATURES_PATH):
            self.model = joblib.load(MODEL_PATH)
            self.features = joblib.load(FEATURES_PATH)
            print(f"ML Model loaded successfully from {MODEL_PATH}")
            print(f"Features expected: {self.features}")
        else:
            print(f"Error: Model files not found at {MODEL_PATH}. Please run train_model.py first.")

    def predict(self, input_data):
        """
        Predict earnings based on input features.
        """
        if self.model is None or self.features is None:
            return 0.0

        # Ensure input is a DataFrame with correct feature order
        df_input = pd.DataFrame([input_data])

        # Reorder columns to match training data
        # This will fail if features in the model are not in the input_data
        try:
            df_input = df_input[self.features]
        except KeyError as e:
            print(f"Prediction Error: Missing features in input: {e}")
            return 0.0

        prediction = self.model.predict(df_input)
        return float(np.round(max(0.0, prediction[0]), 2))

# --- PRODUCTION-READY INTERFACE ---

# Initialize a singleton predictor for performance
_predictor = GigEarningsPredictor()

def predict_earnings(input_features):
    return _predictor.predict(input_features)

if __name__ == "__main__":
    # Test
    test_input = {
        "day_of_week": 5,
        "hour": 20,
        "duration": 5.0,
        "rain_intensity": 10.0,
        "traffic_index": 0.7,
        "demand_index": 0.9,
        "zone": 1
    }
    result = predict_earnings(test_input)
    print(f"Test Result: ₹{result}")
