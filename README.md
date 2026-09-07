## Data Source

This project uses the [Brazilian E-Commerce Public Dataset by Olist](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce), published on Kaggle.

The dataset contains approximately 100,000 anonymised e-commerce orders placed between 2016 and 2018. It includes information about customers, sellers, products, order items, payments, reviews, delivery timestamps, and customer and seller locations.

The following source files were used:

* `olist_customers_dataset.csv`
* `olist_geolocation_dataset.csv`
* `olist_order_items_dataset.csv`
* `olist_order_payments_dataset.csv`
* `olist_order_reviews_dataset.csv`
* `olist_orders_dataset.csv`
* `olist_products_dataset.csv`
* `olist_sellers_dataset.csv`
* `product_category_name_translation.csv`

## Power BI Dashboard

The Power BI report translates the transformed Olist data into three
interactive business-analysis pages.

### Dashboard pages

1. **Business Overview**  
   Tracks revenue, orders, customers, customer mix and performance trends.

2. **Fulfilment and Delivery Performance**  
   Examines delivery-cycle duration, on-time performance, geographic
   differences and the relationship between delivery performance and customer
   feedback.

3. **Order Payment Reconciliation**  
   Compares expected order totals with recorded payments and identifies fully
   paid, underpaid, unpaid and exceptional orders.

### Download

[Download the interactive Power BI dashboard](https://github.com/Inesh172/olist_analytics/releases/tag/Power-BI-v1.0.0)

> Download the ZIP, extract the PBIX file and open it using Power BI Desktop.
> The report uses an imported data model, so access to the original Snowflake
> trial account is not required.

## Python Analysis

The Power BI dashboard provided the initial overview of Olist's business,
fulfilment, delivery and customer-feedback performance. Although most orders
were delivered successfully, the dashboard raised a more focused question:

> Although late deliveries represent a minority of orders, do they generate a
> disproportionate amount of severe customer dissatisfaction?

Two Python notebooks were developed after the dashboard to investigate this
question.

The analysis follows this sequence:

1. Discover recurring customer-experience themes from Portuguese review text.
2. Reconcile reported delivery problems with structured order timestamps.
3. Test whether objective delivery lateness is associated with poor feedback.
4. Identify whether failures developed before or after carrier handover.
5. Locate high-impact sellers and state routes.
6. Translate the findings into operational pilots and what-if scenarios.

### 1. Customer Review Text Analysis

**Notebook:**
[olist_review_text_customer_experience_analysis.ipynb](analysis/olist_review_text_customer_experience_analysis.ipynb)

The review-text analysis converts written Portuguese reviews into order-level
documents and applies topic modelling to identify recurring
customer-experience themes.

The analysis:

* Removes duplicate review text without discarding distinct customer comments.
* Creates interpretable English labels for discovered topics and subtopics.
* Selects coherent business families using transparent coverage and relevance
  rules.
* Examines named themes among 1–2-star reviews.
* Reconciles customer comments reporting non-receipt with actual order and
  delivery timestamps.

Among the named themes from 1–2-star reviews in the selected topic families,
non-receipt and late or slow delivery represented a substantial concentration
of severe feedback.

The non-receipt audit identified 1,036 orders where customers reported that
their products had not arrived. These reports did not represent one uniform
operational problem:

* 427 orders were eventually delivered late after the review.
* 391 reviews were submitted after the system had already recorded delivery.
* 128 orders had no recorded delivery.
* The remaining cases included canceled or unavailable orders, multiple
  comments requiring review and a small number of other timing outcomes.

This reconciliation separated actual delivery delays from potential
delivery-confirmation discrepancies. It also provided the operational handoff
for the delivery-reliability analysis.

> Topic-model findings are used for issue discovery and prioritisation. They do
> not establish that a particular operational failure caused every negative
> review. Unassigned and low-information comments remain in the coverage
> reporting but are not treated as one coherent business theme.

### 2. Delivery Reliability Analysis

**Notebook:**
[olist_delivery_reliability_analysis.ipynb](analysis/olist_delivery_reliability_analysis.ipynb)

The delivery analysis combines the review findings with curated Snowflake/dbt
orders, items, customers, sellers, products and review data.

It investigates whether the delivery concerns found in customer comments
correspond to measurable operational failures and where those failures
developed.

#### Main findings

* 96,470 delivered orders had sufficient timestamps for analysis.
* 6,534 orders were delivered late, producing a 6.77% late-delivery rate.
* The overall on-time delivery rate was 93.23%.
* The low-review rate was 62.42% for late deliveries compared with 9.27% for
  on-time deliveries.
* Late deliveries were associated with a 53.15 percentage-point increase in
  the low-review rate and 6.74 times the low-review risk.
* Late deliveries represented only 6.77% of delivered orders but accounted for
  32.46% of 1–2-star reviews and 36.69% of 1-star reviews among delivered
  orders with recorded feedback.
* Median lateness was seven days.
* 43.80% of late orders arrived more than seven days late.
* 21.18% arrived more than fourteen days after the estimated delivery date.

These findings indicate that Olist does not have a platform-wide delivery
failure. However, the smaller late-delivery group generates a disproportionate
amount of severe customer dissatisfaction.

#### Fulfilment-stage diagnosis

The analysis compares the seller's carrier-handover deadline with the actual
carrier-handover timestamp and the final customer-delivery outcome.

Among late deliveries with sufficient stage information:

* 27.79% followed a late seller handover.
* 72.21% were handed to the carrier on time but still reached the customer
  late.

The low-review rate was approximately 62%–63% whenever the final delivery was
late, regardless of whether the seller handover had been completed on time.

This indicates that seller reminders alone would not address most observable
late deliveries. In-transit route monitoring, carrier milestone information
and proactive exception management would also be required.

#### Seller and state-route priorities

Sellers are ranked using excess late-order volume rather than late-delivery
rate alone. This prevents small sellers with unusually high percentages from
being prioritised ahead of sellers affecting more customers.

The state-route analysis identified **SP → RJ** as the largest operational
priority:

* 8,048 delivered orders.
* 1,147 late deliveries.
* 14.25% late-delivery rate.
* 134 reconciled non-receipt reports.
* Approximately 596 excess late orders relative to the comparison rate.

Other high-impact routes included SP → BA, SP → ES, SP → CE and SP → SC.

These results support targeted route-level investigation instead of applying
the same intervention to every order.

#### Cross-state marketplace context

The analysis also evaluates whether cross-state purchasing may provide value
to customers through access to products not historically observed from sellers
in their own state.

Among cross-state purchases:

* 61,898 orders contained cross-state items.
* 98.22% of those items had no historical sale of the exact product from a
  seller in the customer's state.
* Only 0.30% had a same-month, exact-product local price comparison.

This suggests that cross-state commerce may provide important assortment
access. However, historical transactions do not prove that a product was
unavailable locally at the exact time of purchase.

The limited same-month comparison coverage also means that the data cannot
support a strong conclusion that customers purchased cross-state primarily
because of lower prices.

The operational recommendation is therefore to improve high-risk routes rather
than discourage cross-state purchasing.

### Recommended Operational Pilots

The analysis proposes three targeted experiments.

#### 1. Seller deadline alerts

Notify selected sellers 24 hours before the carrier-handover deadline when no
handover has been recorded. Escalate unresolved orders six hours before the
deadline.

The primary metric is the missed-handover rate. Secondary metrics include the
final late-delivery rate, days late and low-review rate.

#### 2. In-transit route monitoring

Introduce route-specific delivery milestones, logistics escalation and
proactive customer communication for high-volume routes with excess late
deliveries.

The primary metric is the final late-delivery rate. Secondary metrics include
days late, customer-support contacts and low-review rate.

#### 3. Delivery-confirmation integrity

Strengthen proof-of-delivery requirements and provide a rapid resolution
process for customers reporting non-receipt after an order is marked delivered.

The primary metric is the post-delivery non-receipt report rate. Refunds,
support contacts and resolution time should be monitored as guardrail metrics.

### What-If Impact Analysis

The what-if analysis estimates the potential results of reducing historically
targetable delivery failures.

If in-transit monitoring prevented 20% of historically targetable in-transit
delays, the scenario estimates:

* Approximately 942 fewer late deliveries.
* A reduction in the overall late-delivery rate from 6.77% to 5.80%.
* An increase in the on-time delivery rate from 93.23% to 94.20%.
* Approximately 500 fewer excess low reviews under the stated assumptions.

At the same 20% reduction level, the seller-handover intervention would produce
approximately:

* 362 fewer late deliveries.
* A reduction in the overall late-delivery rate from 6.77% to 6.40%.
* An increase in the on-time delivery rate from 93.23% to 93.60%.
* Approximately 193 fewer excess low reviews under the stated assumptions.

The in-transit intervention therefore has a larger addressable reach, while
seller alerts remain appropriate for sellers with elevated missed-handover
rates.

These results are transparent planning scenarios rather than causal forecasts.
Controlled pilots are required to measure the actual effect of each
intervention.

### Business Conclusion

The dashboard established the overall performance context. The review-text
analysis then identified delivery-related themes within severe customer
feedback, while the delivery-reliability analysis confirmed that late orders
were associated with substantially worse customer ratings.

Olist does not require a costly delivery intervention across every order.
Instead, the evidence supports a targeted delivery-reliability programme
focused on:

* High-impact state routes.
* Sellers with elevated missed-handover rates and sufficient order volume.
* In-transit delivery exceptions.
* Delivery-confirmation discrepancies.

This approach concentrates operational resources where the greatest number of
failures may be prevented while preserving the assortment benefits of Olist's
cross-state marketplace network.
