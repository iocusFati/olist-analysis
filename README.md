# 📊 Business Model Analysis of the Olist Marketplace

---

## 🏢 About the Project

This project is based on an analysis of the **Olist Brazilian E-Commerce** dataset — open data from a Brazilian marketplace.

The analysis examines Olist's business model: where revenue comes from, whether customers return, and what factors influence these metrics. The goal of the study was to identify the marketplace's main revenue sources, learn more about its customers, and determine the impact of various factors — in particular, delivery speed and review ratings — on the company's performance.

Insights are provided along the following key directions:

- **How many customers return for repeat purchases, and how quickly they "drop off"**
- **Where revenue actually comes from** — a large number of small orders or a small number of expensive ones
- **What types of customers exist** and how valuable they are to the business
- **What affects (and what doesn't) repeat purchases** — review quality, delivery speed, product characteristics

## 🗂 Data Structure

The analysis is based on the `olist` dataset, which contains **99,441 orders** and several related tables:

- **orders** — one order = one row; contains the purchase date, current status (delivered, canceled, in transit, etc.), as well as the estimated and actual delivery dates
- **customers** — a separate `customer_id` is created for each order, while `customer_unique_id` identifies the actual person and repeats if they buy again; also contains the customer's city/state
- **order_items** — one product line item within an order = one row (an order with multiple products will have multiple rows); item price and shipping cost are recorded separately
- **products** — product characteristics: category, name/description length, number of photos added
- **order_payments** — how exactly the customer paid for the order: payment type (card, cash, etc.), number of installments, amount
- **order_reviews** — the customer's review of the order: rating from 1 to 5 and the date the review was left

## 🧹 Data Cleaning

All raw tables remain unchanged in the `public` schema. A separate **`clean`** schema was created for the analysis, containing views on top of the raw data — this keeps the cleaning logic transparent, separated from the original data, and easily reproducible.

Main cleaning steps:

- **Dates** converted from timestamps to the `date` type (`orders`)
- **A separate `clean.active_orders` view** created specifically for analysis — it excludes canceled and unavailable orders, leaving only those that actually took place. This view is used across all subsequent analyses so that metrics (retention, revenue, segments) reflect real customer behavior rather than canceled transactions
- **Delivery status** added as a separate field — based on comparing the actual and estimated delivery dates, it determines whether an order arrived on time, was late, or was never delivered at all
- **Duplicate reviews** (`review_id` repeating with different data) removed — only the most recent record is kept for each `review_id`
- **Missing values** in product characteristics (name/description length, number of photos) replaced with 0; empty or missing product category labeled as `unknown`

## 📌 Overview

Olist's revenue grew steadily throughout 2017 — from ~120K in January to a peak of over 1 million in November 2017, after which it fluctuates in the 850K–1M range with no clear upward trend throughout 2018.

The number of new customers by month shows an almost identical shape — growth throughout 2017, a peak at the end of the year, and a plateau in the range of 6,000–7,000 new customers per month throughout 2018. These two charts visually correlate, confirming that revenue dynamics are almost entirely driven by the pace of new customer acquisition.
This leads to the key conclusion of the analysis: Olist's business relies on continuously acquiring new customers rather than building long-term relationships with existing ones. Only **3.04%** of customers make a repeat purchase.

<p align="center">
  <img width="500" height="300" alt="image" src="https://github.com/user-attachments/assets/71be196c-e332-49ae-a8d2-082d4e237602" />
  <img width="500" height="300" alt="image" src="https://github.com/user-attachments/assets/7a8b7bdc-58ee-4bfa-8b79-23863d208443" />
</p>

### 🔄 Customer Segmentation

Customer retention on Olist is extremely low — only **3.04%** make more than one purchase. Low retention is observed across all customer categories — from low spenders to those who spend significant amounts.

More interesting is the value breakdown via RFM segmentation:

<p align="center">
  <img width="595" height="363" alt="image" src="https://github.com/user-attachments/assets/4c910fe9-bb5b-4d1f-b335-8f20937e7558" />
</p>

**High-Value Recent Newbies** and **Lost High-Value Shoppers** together make up **30.32%** of the customer base — almost a third of customers have already proven willing to spend significant amounts, having done so only once.

### 💰 Revenue Structure

Orders were split into price segments to compare each range's share of orders against its share of revenue:

<p align="center">
  <img width="901" height="159" alt="image" src="https://github.com/user-attachments/assets/19991eac-160a-4564-8a1f-8558c79ca784" />
</p>

The most expensive segment (269.90+) accounts for only **9.93%** of orders but generates **40.85%** of all revenue. More broadly: orders priced above **86.90** make up just 50% of all orders, yet they generate over **80% (83.13%)** of total revenue. Revenue is heavily concentrated in a relatively small number of expensive orders rather than being evenly distributed across sales volume.

**On average, an order contains only one item** (1.02–1.38 depending on the segment) — Olist customers rarely build a multi-item cart in a single purchase. So expensive orders are expensive because of the item's price itself, not because the customer added more units to the cart.

### ⭐ Factors Behind Repeat Purchases

Checked whether review rating and delivery quality explain why customers don't return — by comparing a customer's first-order rating/delivery status against whether they placed a second order.

**Review rating:** a repeat purchase occurs in **2.49%** of cases when the first order received a rating of 1, and in **3.06%** of cases with a rating of 5. The difference is statistically significant (z ≈ 3.11) but very small in absolute terms (0.6 pp) — review rating is not a meaningful retention factor.

<p align="center">
  <img width="565" height="126" alt="image" src="https://github.com/user-attachments/assets/727942d8-8799-4c23-8f8a-5938b4ed9ca5" />
</p>

**Late delivery:** among customers whose first order arrived on time, **3.08%** make a repeat purchase; among those whose first order was late, **2.4%** do. The difference points in the intuitively expected direction (a late delivery slightly reduces return rate), but it's small enough (0.68 pp) that it can't be considered a meaningful factor.

<p align="center">
  <img width="579" height="78" alt="image" src="https://github.com/user-attachments/assets/1a50587e-aca0-4ab9-9082-5fe32363952b" />
</p>

### 📦 Product Factors

**Product rating isn't just feedback — it's a sales factor.** Products with a higher average rating sell noticeably more often:

<p align="center">
  <img width="403" height="104" alt="image" src="https://github.com/user-attachments/assets/21214b2d-271b-4670-ac05-6d699f52f329" />
</p>

Products with the worst ratings (1–2) sell almost half as often as products with the best ratings — a product's reputation directly affects how many times it gets bought. Interestingly, the peak sales frequency doesn't occur at the highest rating (4–5), but in the 3–4 segment — meaning the relationship isn't linear: "good but not perfect" actually sells even better than "excellent." By revenue, however, the 4–5 segment dominates unambiguously — simply because the vast majority of products on the platform have high ratings.

If product rating matters this much for sales, a logical question arises: what influences the rating itself? The hypothesis was that an insufficiently detailed description or too few photos might mislead the customer about the product, later leading to disappointment and a lower rating.

**The hypothesis was not confirmed:** the average rating stays stable at **4.0–4.1** regardless of the number of photos or description length — no noticeable relationship.

**Instead, the real driver is delivery delay:** orders delivered on time receive an average rating of **4.3**, while late orders receive only **2.3**. The difference is nearly twofold — delivery delay has a much stronger and more obvious effect on rating than any product listing characteristic.

## 🚀 Recommendations

- **Investigate the causes of delivery delays.** Lateness nearly halves a product's rating — it's the strongest factor affecting customer satisfaction. Worth identifying which regions, sellers, or product categories are late most often.

- **Try to win customers back after their first purchase** — for example, through a loyalty program or reminders. Since neither reviews nor delivery explain why customers don't return, the problem likely can't be solved through quality improvements alone — dedicated win-back mechanisms are needed.

- **Implement a related-products recommendation system.** Currently an order contains on average just one item — there's room to grow revenue through larger carts, not only through new customers.

- **Leverage higher-priced orders to grow revenue.** Orders above 86.90 generate over 80% of revenue; it's worth testing ways to nudge customers toward purchasing in this range.

## ⚠️ Assumptions and Caveats

- **Canceled and unavailable orders are excluded from the entire analysis** (`clean.active_orders`) — metrics reflect only transactions that actually took place.
- **2016 is excluded from trend analyses** (revenue dynamics, new customer acquisition pace) — the platform had just launched, and order volume in those months is orders of magnitude lower than normal and not representative.
- **The Frequency score in RFM was calculated manually rather than via `NTILE`**, since the distribution of customers by order count is too skewed (the vast majority have only one purchase), and an even quintile split would not reflect the real picture.
- **Reviews with duplicate `review_id`** were cleaned — only the most recent record is kept for each `review_id`.
