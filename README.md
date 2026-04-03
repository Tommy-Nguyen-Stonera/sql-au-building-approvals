# Australian Building Approvals Analysis (T-SQL)

[View Interactive Report](https://htmlpreview.github.io/?https://raw.githubusercontent.com/Tommy-Nguyen-Stonera/sql-au-building-approvals/main/report/au_building_approvals_report.html)

16 years of ABS monthly building approval data (2010-2026) across all 8 states and territories. 3.1 million dwelling units and $1.97 trillion in approvals analysed to understand where construction activity is heading.

## Key Findings

- Victoria leads with 31% of national approvals, ahead of NSW at 28%
- NSW has fallen 41% from its 2016 peak and hasn't recovered
- The 2021 HomeBuilder stimulus boom was real but temporary (29.7% spike, then -28.2% crash)
- Average approval value more than doubled from $439K (2010) to $1.02M (2025)
- January approvals run 28% below November (seasonal dead zone)
- Tasmania and SA are the only states that grew between 2015-2019 and 2020-2024

## Tools

SQL Server, T-SQL, ABS Open Data

## Files

- `queries/au_building_approvals_analysis.sql` - 9 query blocks
- `report/au_building_approvals_report.html` - Interactive report
- `data/` - building_approvals_full.csv, building_approvals_raw.csv
