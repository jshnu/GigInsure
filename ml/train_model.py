import pandas as pd
import numpy as np
import joblib
from xgboost import XGBRegressor
from sklearn.model_selection import train_test_split
from sklearn.metrics import mean_absolute_error, r2_score

def train_dynamic_model():
    # 1. Load Data
    try:
        df = pd.read_csv("gig_earnings_data.csv")
    except FileNotFoundError:
        print("Data file not found. Run data_generator.py first.")
        return

    # 2. Define Features EXPLICITLY (Crucial fix)
    # We must not include 'normal_earnings' or 'loss_pct' as features
    features = [
        'day_of_week',
        'hour',
        'duration',
        'rain_intensity',
        'traffic_index',
        'demand_index',
        'zone'
    ]

    X = df[features]
    y = df['earnings']

    # 3. Split Data
    X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2, random_state=42)

    # 4. Train XGBoost
    print("Training Dynamic Earnings Model (XGBoost)...")
    model = XGBRegressor(
        n_estimators=200,
        learning_rate=0.05,
        max_depth=8,
        random_state=42
    )

    model.fit(X_train, y_train)

    # 5. Evaluate
    preds = model.predict(X_test)
    mae = mean_absolute_error(y_test, preds)
    print(f"Model Trained - MAE: ₹{mae:.2f}")

    # 6. Save Model and exact feature list for predictor
    joblib.dump(model, 'gig_earnings_model.joblib')
    joblib.dump(features, 'model_features.joblib')
    print("Model and Features saved successfully.")

if __name__ == "__main__":
    train_dynamic_model()
