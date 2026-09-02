use role ACCOUNTADMIN;

create or replace warehouse COMPUTE_WH
    warehouse_size = 'XSMALL'
    auto_suspend = 60
    auto_resume = true
    initially_suspended = true;

create or replace database OLIST_DB;

create or replace schema OLIST_DB.RAW;

create or replace file format OLIST_CSV_FORMAT
    type = CSV
    field_delimiter = ','
    skip_header = 1
    field_optionally_enclosed_by = '"'
    empty_field_as_null = true
    null_if = ('', 'NULL')
    encoding = 'UTF8'
    multi_line = true;

create or replace stage OLIST_RAW_STAGE
file_format = OLIST_CSV_FORMAT;

list @OLIST_DB.RAW.OLIST_RAW_STAGE;

create or replace table OLIST_DB.RAW.CUSTOMERS (
    customer_id varchar,
    customer_unique_id varchar,
    customer_zip_code_prefix varchar,
    customer_city varchar,
    customer_state varchar
);   

create or replace table OLIST_DB.RAW.GEOLOCATION ( 
    geolocation_zip_code_prefix varchar,
    geolocation_lat float,
    geolocation_lng float,
    geolocation_city varchar,
    geolocation_state varchar
);

create or replace table OLIST_DB.RAW.ORDER_ITEMS ( 
    order_id varchar,
    order_item_id int,
    product_id varchar,
    seller_id varchar,
    shipping_limit_date datetime,
    price numeric(10,2),
    freight_value numeric(10,2)
);

create or replace table OLIST_DB.RAW.ORDER_PAYMENTS ( 
    order_id varchar,
    payment_sequential int,
    payment_type varchar,
    payment_installments int,
    payment_value numeric(10,2)
);

create or replace table OLIST_DB.RAW.ORDER_REVIEWS ( 
    review_id varchar,
    order_id varchar,
    review_score int,
    review_comment_title varchar,
    review_comment_message varchar,
    review_creation_date datetime,
    review_answer_timestamp datetime
);

create or replace table OLIST_DB.RAW.ORDERS ( 
    order_id varchar,
    customer_id varchar,
    order_status varchar,
    order_purchase_timestamp datetime,
    order_approved_at datetime,
    order_delivered_carrier_date datetime,
    order_delivered_customer_date datetime,
    order_estimated_delivery_date datetime
);

create or replace table OLIST_DB.RAW.PRODUCTS ( 
    product_id varchar,
    product_category_name varchar,
    product_name_lenght int,
    product_description_lenght int,
    product_photos_qty int,
    product_weight_g int,
    product_length_cm int,
    product_height_cm int,
    product_width_cm int
);

create or replace table OLIST_DB.RAW.SELLERS ( 
    seller_id varchar,
    seller_zip_code_prefix varchar,
    seller_city varchar,
    seller_state varchar
);

create or replace table OLIST_DB.RAW.PRODUCT_CATEGORY_NAME ( 
    product_category_name varchar,
    product_category_name_english varchar
);

copy into OLIST_DB.RAW.CUSTOMERS
from @OLIST_DB.RAW.OLIST_RAW_STAGE
files = ('olist_customers_dataset.csv');

copy into OLIST_DB.RAW.GEOLOCATION
from @OLIST_DB.RAW.OLIST_RAW_STAGE
files = ('olist_geolocation_dataset.csv');

copy into OLIST_DB.RAW.ORDER_ITEMS
from @OLIST_DB.RAW.OLIST_RAW_STAGE
files = ('olist_order_items_dataset.csv');

copy into OLIST_DB.RAW.ORDER_PAYMENTS
from @OLIST_DB.RAW.OLIST_RAW_STAGE
files = ('olist_order_payments_dataset.csv');

copy into OLIST_DB.RAW.ORDER_REVIEWS
from @OLIST_DB.RAW.OLIST_RAW_STAGE
files = ('olist_order_reviews_dataset.csv');

copy into OLIST_DB.RAW.ORDERS
from @OLIST_DB.RAW.OLIST_RAW_STAGE
files = ('olist_orders_dataset.csv');

copy into OLIST_DB.RAW.PRODUCTS
from @OLIST_DB.RAW.OLIST_RAW_STAGE
files = ('olist_products_dataset.csv');

copy into OLIST_DB.RAW.SELLERS
from @OLIST_DB.RAW.OLIST_RAW_STAGE
files = ('olist_sellers_dataset.csv');

copy into OLIST_DB.RAW.PRODUCT_CATEGORY_NAME
from @OLIST_DB.RAW.OLIST_RAW_STAGE
files = ('product_category_name_translation.csv');