# 🔥 Strategic Revenue & Pricing Intelligence Audit (MySQL)

## 📌 Project Overview

This project is a full-scale revenue and pricing intelligence audit conducted on a hospitality listings dataset (3,465 properties | 14 structured attributes), including:

* Room Type
* Bed Configuration & Capacity
* Location
* Price
* Rating
* Premium Features (Sea View, Balcony, Bathroom Type, etc.)

The objective was not to compute averages — but to evaluate whether the revenue engine behind this portfolio is structurally optimised for scalability, pricing efficiency, and long-term growth.

All analysis was performed entirely in **MySQL 8**, using CTEs, window functions, statistical formulas, and segmentation logic.

---

## 🎯 Business Questions Addressed

* Is revenue overly concentrated in a small cluster of listings?
* Is pricing aligned with customer-perceived value?
* Where does demand start weakening as prices increase?
* Are high-rated listings under-monetised?
* Is inventory mix aligned with revenue density?
* Which features truly drive price premium?
* Which geographic clusters are expansion-ready?
* Where does pricing inefficiency introduce risk exposure?

---

## 🧠 Key Insights Uncovered

### Revenue Architecture

* Revenue shows concentration within a limited segment of listings, indicating portfolio risk exposure.
* Revenue density varies significantly by room category.
* Location-based revenue quartile analysis reveals uneven economic distribution.

### Pricing Intelligence

* Weak-to-moderate correlation between price and rating suggests structural misalignment.
* Demand elasticity tightens beyond premium price tiers.
* Identified listings priced above median but rated below median — signalling pricing inefficiency.
* High-rated listings below market median price reveal monetisation opportunity.

### Inventory Optimisation

* Higher bed capacity does not proportionally increase revenue.
* Certain room categories outperform others in revenue per unit efficiency.
* Supply distribution shows an imbalance between premium and standard inventory.

### Feature-Level Monetisation

* Sea View and Balcony features demonstrate measurable price premiums.
* Shared bathroom listings show rating compression and reduced pricing power.
* Feature segmentation highlights which amenities drive true revenue impact versus cosmetic differentiation.

### Geographic Strategy

* Revenue efficiency varies across locations.
* Volatility analysis highlights stable vs risk-prone regions.
* Identified expansion-ready zones based on revenue-per-listing performance.

---

## 📊 Analytical Depth

This project includes:

* Revenue decile and quintile modelling
* Median-based pricing inefficiency detection
* Pearson correlation implementation in SQL
* Elasticity approximation via bucketed demand analysis
* Revenue volatility measurement
* Portfolio risk quadrant classification

No visualisation tools were used — all insights were derived directly through SQL logic.

---

## 💼 What This Demonstrates

* Strong command over advanced MySQL (CTEs, window functions, statistical calculations)
* Ability to translate structured data into strategic business insights
* Understanding of pricing architecture and revenue concentration risk
* Business-first analytical thinking beyond surface-level metrics

---

**Core Principle:**
Data analysis should not stop at “what happened.”
It should evaluate whether the system itself is economically sound.

---

**Abhishek Singh**
Data-driven revenue intelligence & strategic analytics.
