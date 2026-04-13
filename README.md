# Australian Building Approvals Analysis (T-SQL)

[View Interactive Report](https://htmlpreview.github.io/?https://raw.githubusercontent.com/Tommy-Nguyen-Stonera/sql-au-building-approvals/main/report/au_building_approvals_report.html)

## Overview

This project analyses 16 years of ABS monthly building approval data to understand where residential construction demand is heading and how it has responded to economic shocks and government stimulus. It covers 3.1 million dwelling approvals across all states and territories from 2010 to 2026.

## Dataset

- Source: ABS 8731.0 Building Approvals
- Record count: 3.1 million+ individual dwelling approvals
- Time period: January 2010 to January 2026
- Key columns: Period, State, DwellingType, Sector, NumberOfApprovals, ValueOfApprovals
- Single flat table, no joins required

## Research Questions

1. Is the national approval count growing, stable, or contracting across the full period?
2. Which states drive the majority of national approvals?
3. How has NSW compared to VIC, QLD, and WA over time, and is the gap widening?
4. Is the dwelling type mix shifting toward higher density (apartments over houses)?
5. Which months consistently see the lowest approval volumes (seasonal dead zone)?
6. How did COVID lockdowns and the HomeBuilder stimulus affect approval volumes?
7. What does the rolling 12-month approval trend look like by state?
8. Is approval value growing faster than approval count, and what does that signal?
9. Which states grew or shrank between the 2015-2019 and 2020-2024 periods?

## Data Model

Single flat table: BuildingApprovals. Each row is one monthly observation per state, dwelling type, and sector combination, with approval count and dollar value. All analysis runs from this one table with no joins.

## What Was Analysed

- National approval count trend from 2010 to 2026 with year-over-year growth
- State ranking by total approvals and share of national volume
- NSW vs VIC, QLD, WA comparison over time with indexed trend lines
- Dwelling type mix split: houses vs apartments vs townhouses by year
- Monthly seasonal index across the full dataset to find low-activity periods
- COVID dip and HomeBuilder stimulus spike quantified by month and state
- Rolling 12-month approval count by state
- Average approval value per dwelling tracked annually
- State growth comparison between 2015-2019 and 2020-2024 five-year blocks

## Key Insights

1. Victoria leads with 31% of national approvals, ahead of NSW at 28%. NSW has fallen 41% from its 2016 peak and has not recovered.
2. The 2021 HomeBuilder stimulus spike was real but short-lived: approvals surged 29.7% then crashed 28.2% the following year as the program ended.
3. Average approval value more than doubled from $439K in 2010 to $1.02M in 2025, meaning value growth is running well ahead of unit count growth.
4. January is the seasonal dead zone, running 28% below November volumes on average. This is the most predictable soft patch in the calendar.
5. Tasmania and South Australia are the only two states that grew approval volumes between the 2015-2019 and 2020-2024 comparison periods. Every other state contracted or was flat.
6. The dwelling type mix has shifted steadily toward higher density. Apartments now make up a larger share of new approvals than they did in 2010, particularly in VIC and NSW.

## Recommendations

1. Use Victoria as the primary demand indicator for national residential activity. It drives 31% of approvals and has maintained that share more consistently than NSW.
2. Do not use government stimulus spikes as a baseline for demand forecasting. The 2021 HomeBuilder surge was followed by an equally sharp contraction. Strip stimulus periods out of trend models.
3. Plan for the January slow period in supply and logistics. Approval volumes drop 28% from November. Inventory and staff planning should account for this every year.
4. Investigate Tasmania and South Australia as growth markets. They are the only states that have grown across both five-year periods, which makes them underserved relative to their trajectory.

## Tools

SQL Server, T-SQL, ABS Open Data

## Files

- `queries/au_building_approvals_analysis.sql` - 9 query blocks
- `report/au_building_approvals_report.html` - Interactive report
- `data/` - building_approvals_full.csv, building_approvals_raw.csv
