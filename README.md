# GigInsure

**AI-Powered Parametric Micro-Insurance for Gig Economy Workers**

## Summary

In the rapidly growing gig economy, food delivery partners are the backbone of urban logistics. However, their daily wages are entirely dependent on outdoor mobility. GigInsure is a mobile-first, AI-driven parametric insurance platform designed to provide an automated financial safety net for delivery workers. By leveraging real-time environmental data and AI risk scoring, we protect their income from uncontrollable external disruptions like extreme weather, civic lockdowns, or platform outages.

## The Problem: Gig Economy Vulnerability

Food delivery partners in metropolitan hubs like Bangalore operate without traditional employee benefits. External disruptions directly translate to lost working hours and unrecoverable income.

Currently, there is no automated, accessible financial safety net for these workers. Traditional insurance models are too slow, require manual claim processing, and are not designed for hourly wage loss.

**The Everyday Scenario (The User Persona):**

- **Profile:** Ramesh, Delivery Partner (Swiggy/Zomato) in Bangalore.
- **Working Metrics:** Works 8 hours daily, earning an average of ₹800/day (approx. ₹100/hour).
- **The Disruption:** Sudden, intense rainfall causes severe waterlogging in his assigned delivery zone. Ramesh is forced to halt deliveries for 4 hours.
- **The Impact:** He loses ₹400 for the day, a significant blow to his weekly livelihood.

## GigInsure

GigInsure introduces Parametric Micro-Insurance to the gig economy. "Parametric" means claims are validated automatically by real-world data events, eliminating the need for manual claim validation and investigations.

**Core Value Pillars:**

- **Weekly Micro-Subscriptions:** Ultra-affordable premium packages designed for gig worker cash flows.
- **AI-Driven Dynamic Pricing:** Premiums are tailored to the hyper-local risks of a worker's specific delivery zone.
- **Zero-Friction Claims:** Automatic claim validation based on API data (weather, traffic, news).
- **Instant Payouts:** Funds are directly deposited into the worker's wallet the moment a disruption threshold is crossed.

## Application Workflow

1. **Smart Onboarding:** The worker registers via the GigInsure App and selects their primary delivery zones and vehicle type (Bike/EV/Cycle).
2. **Risk Profiling:** The app analyzes historical earning estimates and zone data to create a risk profile.
3. **Dynamic Quote Generation:** The AI engine calculates a personalized weekly premium based on hyper-local risk forecasts (weather, pollution, traffic).
4. **Active Monitoring:** Once subscribed, the system continuously monitors third-party APIs for disruption triggers in the worker's active zone.
5. **Auto-Claim & Payout:** If a claim is triggered then an automatic validation of the claim (e.g., severe flooding), the claim is auto-approved and the compensated amount is instantly credited to the user's wallet via Razorpay.

## Business Innovation: Hyper-Local Premium Model

Traditional insurance uses static pricing. GigInsure uses a dynamic, risk-based formula updated weekly.

**Dynamic Premium Calculation (Example):**
| Component | Cost |
| :--- | :--- |
| **Base Rate** | ₹25 |
| **Weather Risk (Monsoon)** | +₹8 |
| **Pollution Risk (AQI)** | +₹5 |
| **Zone Traffic/Civic Risk** | +₹4 |
| **Total Weekly Premium** | **₹42** |

**The ROI for the Worker:** For a mere ₹42 premium, the worker secures coverage protecting up to ₹1,600 of potential weekly income loss, creating massive value and peace of mind.

## Parametric Disruption Triggers (The Engine)

Payouts are algorithmic, transparent, and objective. Claims when triggered are automatically validated and approved when API data crosses predefined thresholds:

- **Environmental:** Rainfall > 70mm within 3 hours, Temperature > 42°C, AQI > 350.
- **Civic:** Verified flood alerts or government-declared curfews.
- **Technological:** Major delivery platform server outages (simulated via mock API).
- **Mobility:** Traffic congestion index reaching absolute gridlock levels.

## AI Integration (The Technical Edge)

Our AI implementation is highly practical, balancing predictive capabilities with security to impress hackathon evaluators.

- **Time-Series Risk Prediction (Python/Prophet):** Analyzes historical weather patterns, seasonal trends, and past zone disruption frequencies to predict the probability of future disruptions.
- **Dynamic Pricing Algorithm (Scikit-learn):** A machine learning model that continuously adjusts the micro-premium weekly based on shifting risk variables.
- **Fraud & Anomaly Detection System:** Protects platform integrity by identifying GPS spoofing, fake platform inactivity, duplicate claims from the same device, or claims generated from non-affected zones.

## Technology Stack

- **Frontend (Mobile App):** Flutter (Cross-platform, high performance)
- **Backend & API:** Node.js / FastAPI
- **Database:** Firebase Firestore
- **AI/ML Layer:** Python (Scikit-learn, Prophet, Pandas)
- **Third-Party APIs:** Mateo API, Google MAPS SDK API Traffic
- **Payment Gateway:** Razorpay Sandbox (for instant payout simulation)

## Adversarial Defense & Anti-Spoofing Strategy

To handle a GPS spoofing the market crash (a sudden spike in claims), we implement a tiered payout logic:

**Tier 1 (Normal):** Trust Score > 95. Instant Payout.

**Tier 2 (Anomalous Spike):** If claims in a zone exceed 300% of the historical average, the system triggers a "Proof-of-Disruption" review.

- **The Review:** The app asks the worker to take a 3-second video of their surroundings.
- **The Logic:** An AI vision model (Gemini Flash) verifies if it's raining/flooded. A fraud ring sitting in a room with 500 phones cannot provide 500 unique, time-stamped videos of a Bangalore flood.

Along with secondary verification, most fraud rings use emulators or "hardened" Android devices with Mock Location settings. We stop them before they even see a "Claim" button.

- **Hardware-Backed Verdicts:** Integrate the Google Play Integrity API (Android) and App Attest (iOS). These provide a cryptographically signed "Verdict" from the OS that confirms:
  - The app is the original version (not a tampered/hooked APK).
  - The device is a real, physical phone (not an emulator/server).
- **The Logic:** If a device fails this "Integrity Check" even once, their "Insurance Active" status is revoked.

- **The "Hyper-Active" Flag:** Fraud rings often cycle through 500 accounts on a few physical devices. We flag any device (via IMEI/MAC fingerprinting) that has logged into more than two unique insurance IDs in 24 hours.

