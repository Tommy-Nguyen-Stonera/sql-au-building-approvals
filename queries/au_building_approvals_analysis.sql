-- ============================================================================
-- AUSTRALIAN BUILDING APPROVALS ANALYSIS
-- Dataset: Australian Bureau of Statistics (ABS) — Building Approvals, Australia
-- Period: 2001–2025 (monthly data)
-- Author: Tommy Nguyen
-- ============================================================================

-- ============================================================================
-- SETUP: Create table and import data
-- After importing the ABS data into a table, adjust column names as needed.
-- Expected columns: Period (date), State, DwellingType, Sector, NumberOfApprovals, ValueOfApprovals
-- ============================================================================

-- ============================================================================
-- QUERY 1: National Overview — Total Approvals by Year
-- Purpose: How has construction activity changed over time nationally?
-- ============================================================================

WITH YearlyTotals AS (
    SELECT
        YEAR(Period) AS ApprovalYear,
        SUM(NumberOfApprovals) AS TotalApprovals,
        ROUND(SUM(ValueOfApprovals) / 1000000, 1) AS TotalValue_M
    FROM BuildingApprovals
    GROUP BY YEAR(Period)
),
WithGrowth AS (
    SELECT
        ApprovalYear,
        TotalApprovals,
        TotalValue_M,
        LAG(TotalApprovals) OVER (ORDER BY ApprovalYear) AS PrevYearApprovals,
        LAG(TotalValue_M) OVER (ORDER BY ApprovalYear) AS PrevYearValue
    FROM YearlyTotals
)
SELECT
    ApprovalYear,
    TotalApprovals,
    TotalValue_M,
    CASE
        WHEN PrevYearApprovals IS NOT NULL
        THEN ROUND((TotalApprovals - PrevYearApprovals) * 100.0 / PrevYearApprovals, 1)
        ELSE NULL
    END AS Approval_Growth_Pct,
    CASE
        WHEN PrevYearValue IS NOT NULL
        THEN ROUND((TotalValue_M - PrevYearValue) * 100.0 / PrevYearValue, 1)
        ELSE NULL
    END AS Value_Growth_Pct
FROM WithGrowth
ORDER BY ApprovalYear;


-- ============================================================================
-- QUERY 2: State Comparison — Ranking by Total Approvals and Value
-- Purpose: Which states drive the most construction? Market share analysis.
-- ============================================================================

WITH StateTotals AS (
    SELECT
        State,
        SUM(NumberOfApprovals) AS TotalApprovals,
        ROUND(SUM(ValueOfApprovals) / 1000000, 1) AS TotalValue_M
    FROM BuildingApprovals
    GROUP BY State
),
GrandTotal AS (
    SELECT
        SUM(TotalApprovals) AS NationalApprovals,
        SUM(TotalValue_M) AS NationalValue
    FROM StateTotals
)
SELECT
    s.State,
    s.TotalApprovals,
    RANK() OVER (ORDER BY s.TotalApprovals DESC) AS ApprovalRank,
    ROUND(s.TotalApprovals * 100.0 / g.NationalApprovals, 1) AS ApprovalShare_Pct,
    s.TotalValue_M,
    RANK() OVER (ORDER BY s.TotalValue_M DESC) AS ValueRank,
    ROUND(s.TotalValue_M * 100.0 / g.NationalValue, 1) AS ValueShare_Pct
FROM StateTotals s
CROSS JOIN GrandTotal g
ORDER BY s.TotalApprovals DESC;


-- ============================================================================
-- QUERY 3: NSW vs Other Major States — Year-over-Year Trend
-- Purpose: How does NSW construction compare to VIC, QLD, and WA over time?
-- ============================================================================

SELECT
    YEAR(Period) AS ApprovalYear,
    SUM(CASE WHEN State = 'New South Wales' THEN NumberOfApprovals ELSE 0 END) AS NSW,
    SUM(CASE WHEN State = 'Victoria' THEN NumberOfApprovals ELSE 0 END) AS VIC,
    SUM(CASE WHEN State = 'Queensland' THEN NumberOfApprovals ELSE 0 END) AS QLD,
    SUM(CASE WHEN State = 'Western Australia' THEN NumberOfApprovals ELSE 0 END) AS WA,
    SUM(NumberOfApprovals) AS National
FROM BuildingApprovals
GROUP BY YEAR(Period)
ORDER BY ApprovalYear;


-- ============================================================================
-- QUERY 4: Dwelling Type Breakdown — Houses vs Apartments vs Other
-- Purpose: What types of buildings are being approved? How has the mix changed?
-- ============================================================================

WITH DwellingTrend AS (
    SELECT
        YEAR(Period) AS ApprovalYear,
        DwellingType,
        SUM(NumberOfApprovals) AS TypeApprovals
    FROM BuildingApprovals
    WHERE Sector = 'Private'
    GROUP BY YEAR(Period), DwellingType
),
YearTotal AS (
    SELECT
        ApprovalYear,
        SUM(TypeApprovals) AS YearApprovals
    FROM DwellingTrend
    GROUP BY ApprovalYear
)
SELECT
    d.ApprovalYear,
    d.DwellingType,
    d.TypeApprovals,
    ROUND(d.TypeApprovals * 100.0 / y.YearApprovals, 1) AS Share_Pct
FROM DwellingTrend d
JOIN YearTotal y ON d.ApprovalYear = y.ApprovalYear
ORDER BY d.ApprovalYear, d.TypeApprovals DESC;


-- ============================================================================
-- QUERY 5: Seasonal Patterns — Monthly Pivot Table
-- Purpose: Do approvals spike at certain times of year?
-- ============================================================================

SELECT
    PivotYear,
    ISNULL([1], 0) AS Jan, ISNULL([2], 0) AS Feb, ISNULL([3], 0) AS Mar,
    ISNULL([4], 0) AS Apr, ISNULL([5], 0) AS May, ISNULL([6], 0) AS Jun,
    ISNULL([7], 0) AS Jul, ISNULL([8], 0) AS Aug, ISNULL([9], 0) AS Sep,
    ISNULL([10], 0) AS Oct, ISNULL([11], 0) AS Nov, ISNULL([12], 0) AS Dec
FROM (
    SELECT
        YEAR(Period) AS PivotYear,
        MONTH(Period) AS PivotMonth,
        NumberOfApprovals
    FROM BuildingApprovals
) AS SourceData
PIVOT (
    SUM(NumberOfApprovals)
    FOR PivotMonth IN ([1],[2],[3],[4],[5],[6],[7],[8],[9],[10],[11],[12])
) AS PivotTable
ORDER BY PivotYear;


-- ============================================================================
-- QUERY 6: COVID Impact Analysis — Pre-COVID vs COVID vs Recovery
-- Purpose: How did COVID-19 impact building approvals? How fast was recovery?
-- ============================================================================

WITH PeriodClassified AS (
    SELECT
        *,
        CASE
            WHEN Period < '2020-03-01' THEN 'Pre-COVID (2018-2019)'
            WHEN Period BETWEEN '2020-03-01' AND '2020-12-31' THEN 'COVID Impact (Mar-Dec 2020)'
            WHEN Period BETWEEN '2021-01-01' AND '2021-12-31' THEN 'Recovery (2021)'
            WHEN Period >= '2022-01-01' THEN 'Post-Recovery (2022+)'
        END AS CovidPeriod
    FROM BuildingApprovals
    WHERE Period >= '2018-01-01'
),
PeriodStats AS (
    SELECT
        CovidPeriod,
        COUNT(DISTINCT FORMAT(Period, 'yyyy-MM')) AS MonthsCovered,
        SUM(NumberOfApprovals) AS TotalApprovals,
        ROUND(AVG(CAST(NumberOfApprovals AS FLOAT)), 0) AS AvgMonthlyApprovals,
        ROUND(SUM(ValueOfApprovals) / 1000000, 1) AS TotalValue_M
    FROM PeriodClassified
    GROUP BY CovidPeriod
)
SELECT
    CovidPeriod,
    MonthsCovered,
    TotalApprovals,
    AvgMonthlyApprovals,
    TotalValue_M,
    ROUND(TotalValue_M / MonthsCovered, 1) AS AvgMonthlyValue_M
FROM PeriodStats
ORDER BY
    CASE CovidPeriod
        WHEN 'Pre-COVID (2018-2019)' THEN 1
        WHEN 'COVID Impact (Mar-Dec 2020)' THEN 2
        WHEN 'Recovery (2021)' THEN 3
        WHEN 'Post-Recovery (2022+)' THEN 4
    END;


-- ============================================================================
-- QUERY 7: Rolling 12-Month Average by State
-- Purpose: Smooth out monthly volatility to see underlying trend by state
-- ============================================================================

WITH MonthlyByState AS (
    SELECT
        Period,
        State,
        SUM(NumberOfApprovals) AS MonthlyApprovals
    FROM BuildingApprovals
    GROUP BY Period, State
)
SELECT
    Period,
    State,
    MonthlyApprovals,
    ROUND(AVG(CAST(MonthlyApprovals AS FLOAT)) OVER (
        PARTITION BY State
        ORDER BY Period
        ROWS BETWEEN 11 PRECEDING AND CURRENT ROW
    ), 0) AS Rolling12M_Avg
FROM MonthlyByState
WHERE State IN ('New South Wales', 'Victoria', 'Queensland', 'Western Australia')
ORDER BY State, Period;


-- ============================================================================
-- QUERY 8: Residential vs Non-Residential Value Trend
-- Purpose: Where is the money going — residential or non-residential builds?
-- ============================================================================

SELECT
    YEAR(Period) AS ApprovalYear,
    ROUND(SUM(CASE WHEN Sector = 'Residential' THEN ValueOfApprovals ELSE 0 END) / 1000000, 1) AS Residential_Value_M,
    ROUND(SUM(CASE WHEN Sector = 'Non-Residential' THEN ValueOfApprovals ELSE 0 END) / 1000000, 1) AS NonResidential_Value_M,
    ROUND(SUM(ValueOfApprovals) / 1000000, 1) AS Total_Value_M,
    ROUND(
        SUM(CASE WHEN Sector = 'Residential' THEN ValueOfApprovals ELSE 0 END) * 100.0
        / NULLIF(SUM(ValueOfApprovals), 0), 1
    ) AS Residential_Share_Pct
FROM BuildingApprovals
GROUP BY YEAR(Period)
ORDER BY ApprovalYear;


-- ============================================================================
-- QUERY 9: Top Growth States — Fastest Growing in Last 5 Years vs Prior 5 Years
-- Purpose: Which states are seeing the biggest acceleration in approvals?
-- ============================================================================

WITH RecentPeriod AS (
    SELECT
        State,
        SUM(NumberOfApprovals) AS RecentApprovals
    FROM BuildingApprovals
    WHERE YEAR(Period) BETWEEN 2020 AND 2024
    GROUP BY State
),
PriorPeriod AS (
    SELECT
        State,
        SUM(NumberOfApprovals) AS PriorApprovals
    FROM BuildingApprovals
    WHERE YEAR(Period) BETWEEN 2015 AND 2019
    GROUP BY State
)
SELECT
    r.State,
    p.PriorApprovals AS Approvals_2015_2019,
    r.RecentApprovals AS Approvals_2020_2024,
    r.RecentApprovals - p.PriorApprovals AS Change,
    ROUND((r.RecentApprovals - p.PriorApprovals) * 100.0 / NULLIF(p.PriorApprovals, 0), 1) AS Growth_Pct
FROM RecentPeriod r
JOIN PriorPeriod p ON r.State = p.State
ORDER BY Growth_Pct DESC;
