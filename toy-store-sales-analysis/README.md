![header](./img/huy-hung-trinh-unsplash.jpg)

# Toy Store Sales Analysis

## Situation

In this project, I performed an analysis of sales and inventory data for a fictitious chain of toy stores in Mexico called Maven Toys.

## Task

The goal of this project is to understand the sales trends and optimize stocking levels for the stores.

## Action

1. **Data Collection**: I began by gathering all the data from [Maven Analytics's Data Playground](https://mavenanalytics.io/data-playground) site. I downloaded the dataset that consists of the sales, stores, products, and the current inventory data for the Maven Toys Store. All the data in the dataset are in `.csv` format.

2. [**Data Preparation and Cleaning**](./sql/data_cleaning.sql): I cleaned the data before performing the analysis by fixing the formatting, checking for duplicates, fixing data types, and spelling errors.

3. [**Sales Analysis**](./sql/analysis.sql): I performed an in-depth sales analysis by looking at the overall sales trends, seasonal trends, and product performances. Using complex queries and statistical methods to identify the impact of holidays on sales, finding the top-performing products/product categories, and top-selling store location.

4. [**Inventory Analysis**](./sql/analysis.sql): Using the latest inventory data, I performed an analysis to understand the overall product inventory value, how many products are out-of-stock by stores, and the total sales potential from those out-of-stock products.

5. [**Sales/Inventory Management Dashboard**](https://public.tableau.com/views/MavenToysSalesDashboard_16958918265180/Overview?:language=en-US&:display_count=n&:origin=viz_share_link): I created a user-friendly dashboard using Tableau to monitor the sales and manage the inventory stocks of Maven Toys.

## Result

Some insights from this project are as follow:

1. A high number of sales happened on holidays, especially the ones that are related to kids, like Children's Day, Three Kings' Day, and Christmas, with sales generated as high as 3 times the normal day's sales on average.

2. Optimize stocks for weekends and holidays to prevent potential sales lost from out-of-stock items.

3. 4.9% of total inventory is out-of-stock across all stores, resulting in a potential sales loss of $52,000.
