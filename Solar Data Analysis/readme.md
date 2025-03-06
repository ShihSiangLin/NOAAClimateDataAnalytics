# Exploratory Data Analysis (EDA) on Solar Energy Data

## Overview
This project focuses on performing Exploratory Data Analysis (EDA) on solar energy data using Jupyter Notebooks. The analysis involves cleaning, visualizing, and extracting insights from solar power generation, weather patterns, and other influencing factors. By leveraging Python libraries such as Pandas, Matplotlib, and Seaborn, we aim to uncover trends, correlations, and potential optimizations for solar energy utilization.

## Contents
1. [FortMartin_Data_Analysis](./FortMartin_Data_Analysis/) contains:
    - an excel spreadsheet with **real data** provided from the Solar Development Team in one the largest utility company in the United States. [This spreadsheet](./FortMartin_Data_Analysis/Requested_Measurement_List_FTM_v2.xlsx) records 51 solar system variables in Fort Martin Solar site. The data is collected from 9/1/2024 12:00:00 AM to 9/29/2024 11:59:00 PM with 1 minute interval. 

    - a [jupyter notebook](./FortMartin_Data_Analysis/EDA_FM_Data.ipynb) that does the exploratory data analysis on the Fort Martin Solar data.

2. [Solcast_Data_Analysis](./Solcast_Data_Analysis/) contains:

    - [Historical solar and climate data](./Solcast_Data_Analysis/data/Solcast_FortMartin_20200101_20240805.csv) is requested from [Solcast](https://solcast.com/). It has 31 climate and solar variables, collected from 2020-01-01T01:00:00-06:00 to 2024-08-06T00:00:00-06:00 with 60 mins interval.

    - [This jupyter notebook](./Solcast_Data_Analysis/EDA_FortMartin_Historic.ipynb) performs exploratory data analysis on the climate and solar data from Solcast.

    - [This jupyter notebook](./Solcast_Data_Analysis/FM_Solar_Weather_Data.ipynb) documents different solar related datasets from multiple sources and little demonstration of accessing the data.