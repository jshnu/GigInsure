from fastapi import FastAPI, HTTPException
from pydantic import BaseModel, Field
from typing import Dict, Any
import sys
import os
import logging

# Ensure the ML directory is in the path for imports
sys.path.append(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
from ml.predictor import predict_earnings

# Setup logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

app = FastAPI(title="GigInsure API", version="1.1.0")

# --- DATA MODELS ---

class EarningsInput(BaseModel):
    day_of_week: int = Field(..., ge=0, le=6, description="0=Mon, 6=Sun")
    hour: int = Field(..., ge=0, le=23, description="0-23")
    duration: float = Field(..., gt=0, description="Hours worked")
    rain_intensity: float = Field(..., ge=0, description="mm of rain")
    traffic_index: float = Field(..., ge=0, le=1.0, description="0.0 to 1.0")
    demand_index: float = Field(..., ge=0, le=1.0, description="0.0 to 1.0")
    zone: int = Field(..., description="Categorical zone ID")

class ClaimInput(EarningsInput):
    coverage_ratio: float = Field(0.8, ge=0, le=1.0, description="Percentage of loss covered")
    coverage_limit: float = Field(1500.0, gt=0, description="Maximum payout allowed")

# --- UTILS ---

def get_risk_level(loss: float) -> str:
    if loss < 200:
        return "LOW"
    elif 200 <= loss <= 500:
        return "MEDIUM"
    else:
        return "HIGH"

def fallback_loss_calculation(rain: float, traffic: float, demand: float) -> float:
    """
    Deterministic fallback: score-based loss estimation.
    Score ranges from 0 to 1.0
    """
    score = (min(rain, 100) / 100.0 * 0.4) + (traffic * 0.3) + ((1.0 - demand) * 0.3)
    # Assume base expected earnings of 1200 for score calculation
    return score * 1200.0

# --- ENDPOINTS ---

@app.post("/predict-earnings")
async def get_prediction(data: EarningsInput):
    logger.info(f"PREDICT-EARNINGS INPUT: {data.model_dump()}")
    try:
        prediction = predict_earnings(data.model_dump())
        return {
            "input": data.model_dump(),
            "expected_earnings": prediction
        }
    except Exception as e:
        logger.error(f"Prediction Error: {e}")
        raise HTTPException(status_code=500, detail=str(e))

@app.post("/calculate-claim")
async def calculate_claim(data: ClaimInput):
    input_dict = data.model_dump()
    logger.info(f"CALCULATE-CLAIM INPUT: {input_dict}")

    try:
        # 1. Normal Conditions
        normal_data = input_dict.copy()
        normal_data["rain_intensity"] = 0.0
        normal_data["traffic_index"] = 0.2
        normal_data["demand_index"] = max(0.8, input_dict["demand_index"])

        # 2. ML Prediction
        normal_earnings = predict_earnings(normal_data)
        disrupted_earnings = predict_earnings(input_dict)

        # 3. Compute ML Loss
        ml_loss = max(0.0, normal_earnings - disrupted_earnings)

        # 4. Fallback/Hybrid Logic
        fallback_loss = fallback_loss_calculation(
            input_dict["rain_intensity"],
            input_dict["traffic_index"],
            input_dict["demand_index"]
        )

        # Hybrid approach: use ML but ensure it's not deviating wildly from deterministic reality
        # For now, let's take the higher of the two if ML seems stuck
        final_loss = max(ml_loss, fallback_loss * 0.5)

        # 5. Payout Logic with safety constraints
        payout = min(final_loss * data.coverage_ratio, data.coverage_limit)
        payout = max(0.0, payout) # No negative payouts

        response = {
            "input_received": input_dict,
            "normal_earnings": round(normal_earnings, 2),
            "disrupted_earnings": round(disrupted_earnings, 2),
            "ml_predicted_loss": round(ml_loss, 2),
            "fallback_loss": round(fallback_loss, 2),
            "final_calculated_loss": round(final_loss, 2),
            "payout": round(payout, 2),
            "risk_level": get_risk_level(final_loss),
            "status": "Claimable" if payout > 0 else "No Loss Detected"
        }

        logger.info(f"CALCULATE-CLAIM RESPONSE: {response}")
        return response

    except Exception as e:
        logger.error(f"Claim Calculation Error: {e}")
        # Return fallback only if ML fails completely
        fallback_loss = fallback_loss_calculation(
            input_dict["rain_intensity"],
            input_dict["traffic_index"],
            input_dict["demand_index"]
        )
        payout = min(fallback_loss * 0.8, data.coverage_limit)
        return {
            "input_received": input_dict,
            "error": "ML Model failed, used fallback engine",
            "payout": round(payout, 2),
            "risk_level": get_risk_level(fallback_loss)
        }

@app.get("/health")
async def health_check():
    return {"status": "online", "model_loaded": True}

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)
