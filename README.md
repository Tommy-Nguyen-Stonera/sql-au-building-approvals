# Australian Building Approvals Analysis (T-SQL)

## Problem Statement

Australia's construction sector is a key economic indicator, and building approval data reveals where and what type of construction is happening across the country. This project analyses 20+ years of monthly building approval data from the Australian Bureau of Statistics (ABS) to uncover trends in residential vs non-residential construction, state-level performance, and seasonal patterns.

As someone who has worked in building materials sales across Sydney, Canberra, Newcastle, and Wollongong, I wanted to explore the data behind the industry I know — and answer questions that would matter to a building materials supplier or construction company.

## Why This Dataset?

The ABS Building Approvals dataset is the official government record of every building approval issued in Australia. It covers:
- Monthly data going back to 2001
- Breakdowns by state/territory, dwelling type, and sector (public/private)
- Both count (number of approvals) and value ($) data

This is the kind of data a sales operations or reporting analyst in the construction industry would actually work with.

## Business Questions

1. **How has construction activity changed over time?** Are approvals trending up or down nationally?
2. **Which states drive the most construction?** How does NSW compare to VIC, QLD, and WA?
3. **Residential vs non-residential** — where is the growth happening?
4. **Are there seasonal patterns?** Do approvals spike at certain times of year?
5. **How did COVID-19 impact building approvals?** Was there a dip, and how fast was the recovery?
6. **Which dwelling types are growing?** Houses vs apartments vs townhouses — what's the trend?

## Analysis Structure

The analysis follows a top-down approach:

1. **National Overview** — Total approvals and value over time, year-over-year growth rates
2. **State Comparison** — Ranking states by approval volume and value, market share analysis
3. **Dwelling Type Breakdown** — Houses vs other residential (apartments, townhouses), trend shifts
4. **Seasonal Analysis** — Monthly patterns using PIVOT queries to compare months across years
5. **COVID Impact** — Pre-COVID vs COVID vs recovery period comparison
6. **Growth Rate Analysis** — Rolling averages and year-over-year change by state

## SQL Techniques Used

- Common Table Expressions (CTEs)
- Window functions: `ROW_NUMBER()`, `RANK()`, `LAG()`, `SUM() OVER()`
- `PIVOT` queries for cross-tab analysis
- `DATEPART` and date-based aggregations
- `CASE` expressions for period classification
- Percentage calculations and growth rates
- Rolling averages using window frames

## Tools

- **SQL Server** — all queries run in SSMS
- **T-SQL** — CTEs, window functions, PIVOT, aggregations
- **Source data** — Australian Bureau of Statistics (ABS)

## Files

| File | Description |
|---|---|
| `queries/au_building_approvals_analysis.sql` | Full T-SQL query file — all analysis queries |
| `data/` | Source data files from ABS |
| `README.md` | This file — project overview and findings |

## How to Run

1. Install [SQL Server Express](https://www.microsoft.com/en-us/sql-server/sql-server-downloads) (free)
2. Import the data files from `data/` as tables
3. Open `queries/au_building_approvals_analysis.sql` in SSMS
4. Run each query block in sequence

## A Note on AI Tools

I used Claude and Gemini when I hit syntax issues or needed a second opinion on query structure. The analysis approach, business questions, and all interpretations are my own work.

---

**Tommy Nguyen** | [GitHub](https://github.com/Tommy-Nguyen-Stonera) · [Portfolio](https://tommy-nguyen-stonera.vercel.app)
