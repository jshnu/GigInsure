import pandas as pd
import numpy as np

def generate_gig_data(n_samples=60000):
    np.random.seed(42)

    # 1. Generate Basic Features
    day_of_week = np.random.randint(0, 7, n_samples)
    hour = np.random.randint(0, 24, n_samples)
    duration = np.random.uniform(1, 10, n_samples) # 1 to 10 hour shifts

    # Environment (Skewed towards low rain/traffic but with extreme tails)
    # Using gamma/beta distributions for more realistic non-uniformity
    rain_intensity = np.random.gamma(shape=0.5, scale=15.0, size=n_samples)
    rain_intensity = np.clip(rain_intensity, 0, 100) # Up to 100mm

    traffic_index = np.random.beta(a=2, b=2, size=n_samples) # 0 to 1
    demand_index = np.random.beta(a=5, b=2, size=n_samples)  # Skewed towards high demand

    zone = np.random.randint(0, 5, n_samples)

    # 2. Define "Normal" Earnings (Deterministic Base)
    # Base rate per hour
    base_rate = 250

    # Peak hour effect (+40%)
    is_peak = ((hour >= 12) & (hour <= 14)) | ((hour >= 19) & (hour <= 21))
    peak_mult = np.where(is_peak, 1.4, 1.0)

    # Weekend effect (+20%)
    weekend_mult = np.where(day_of_week >= 5, 1.2, 1.0)

    # Zone multiplier
    zone_map = {0: 1.0, 1: 1.2, 2: 0.8, 3: 1.1, 4: 0.9}
    zone_mult = np.array([zone_map[z] for z in zone])

    # Normal earnings before environmental disruptions
    # Also depends on demand (high demand = more volume)
    normal_earnings = duration * base_rate * peak_mult * weekend_mult * zone_mult * (0.5 + demand_index * 0.5)

    # 3. Environmental Impact Logic (Multiplicative & Aggressive)

    # Rain Impact: Heavy rain reduces earnings significantly
    # Reduction starts after 20mm
    rain_penalty = np.where(rain_intensity > 20,
                            np.clip(1.0 - (rain_intensity / 130.0), 0.3, 1.0),
                            1.0)

    # Traffic Impact: High traffic reduces earnings
    traffic_penalty = np.where(traffic_index > 0.6,
                               np.clip(1.0 - (traffic_index * 0.6), 0.4, 1.0),
                               1.0)

    # Demand Impact: Low demand reduces earnings
    demand_penalty = np.where(demand_index < 0.4,
                              np.clip(demand_index * 2.5, 0.3, 1.0),
                              1.0)

    # Interaction Effects
    # Extreme conditions multiply
    combo_penalty = np.where((rain_intensity > 60) & (traffic_index > 0.8), 0.6, 1.0)

    # 4. Calculate Actual Earnings
    actual_earnings = normal_earnings * rain_penalty * traffic_penalty * demand_penalty * combo_penalty

    # 5. Target Variable: Earnings Drop Percentage (Loss %)
    # This makes the model learn the RELATIVE risk
    loss_pct = (normal_earnings - actual_earnings) / normal_earnings
    loss_pct = np.clip(loss_pct, 0, 1.0)

    # 6. Add Realistic Noise (+- 15%)
    noise = np.random.normal(1.0, 0.15, n_samples)
    actual_earnings = actual_earnings * noise

    # Floor at ₹50
    actual_earnings = np.maximum(actual_earnings, 50)

    # 7. Final DataFrame
    df = pd.DataFrame({
        'day_of_week': day_of_week,
        'hour': hour,
        'duration': duration,
        'rain_intensity': rain_intensity,
        'traffic_index': traffic_index,
        'demand_index': demand_index,
        'zone': zone,
        'normal_earnings': normal_earnings,
        'loss_pct': loss_pct,
        'earnings': actual_earnings
    })

    return df

if __name__ == "__main__":
    df = generate_gig_data()
    df.to_csv("gig_earnings_data.csv", index=False)
    print(f"Generated {len(df)} samples with HIGH VARIANCE.")
    print(f"Earnings: ₹{df['earnings'].min():.0f} to ₹{df['earnings'].max():.0f}")
    print(f"Avg Loss %: {df['loss_pct'].mean()*100:.1f}%")
