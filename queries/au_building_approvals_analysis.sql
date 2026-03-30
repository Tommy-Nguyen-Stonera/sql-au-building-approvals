-- ============================================================================
-- AUSTRALIAN BUILDING APPROVALS ANALYSIS
-- Dataset: Australian Bureau of Statistics (ABS) — Building Approvals, Australia
-- Catalogue: 8731.0 | Period: 2010–2025 (monthly data, 192 months)
-- Coverage: All 8 states/territories, 3.1M+ dwelling approvals, $1.97T total value
-- Author: Tommy Nguyen
-- ============================================================================

-- ============================================================================
-- SETUP: Create table and import data
-- The ABS dataset uses coded columns. After importing building_approvals_full.csv,
-- map REGION codes (1=NSW, 2=VIC, 3=QLD, 4=SA, 5=WA, 6=TAS, 7=NT, 8=ACT),
-- separate MEASURE types (1=Dwelling count, 2=Value $000, 3=Building count),
-- and parse TIME_PERIOD (YYYY-MM format) into a proper date column.
--
-- Expected table: BuildingApprovals
-- Columns: Period (date), State (varchar), DwellingType (varchar),
--           Sector (varchar), NumberOfApprovals (int), ValueOfApprovals (money)
-- ============================================================================


-- ============================================================================
-- QUERY 1: National Overview — Total Approvals and Value by Year
-- ============================================================================
-- RESEARCH QUESTION: How has construction activity changed over the last 16 years?
-- Before drilling into any specifics, I need to see the macro trajectory.
-- Are we in a growth market or a declining one?
--
-- APPROACH: Aggregate all approvals by year, then use LAG() to calculate
-- year-over-year growth rates for both count and value. This two-CTE structure
-- keeps the percentage calculation clean and readable.
--
-- WHAT I FOUND: National approvals peaked at 239,735 in 2015 and have never
-- returned to that level. The 2021 stimulus boom (228,995) came close but was
-- followed by sharp declines. Meanwhile, total VALUE hit a record $198.8B in
-- 2025 despite lower counts — the market is shifting to fewer, larger projects.
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
-- ============================================================================
-- RESEARCH QUESTION: Which states drive the most construction, and what is
-- each state's share of the national market?
--
-- APPROACH: Aggregate total approvals and value by state, then use CROSS JOIN
-- with a grand total subquery to calculate percentage market share. RANK()
-- provides ordinal positioning for both volume and value.
--
-- WHAT I FOUND: Victoria leads with 31.1% of all approvals (971,368),
-- followed by NSW at 27.6% (863,712). Together, the top 4 states (VIC, NSW,
-- QLD, WA) account for 89.4% of all national approvals. The NT contributes
-- just 0.6% — essentially a rounding error at the national level.
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
-- ============================================================================
-- RESEARCH QUESTION: How does NSW construction compare to VIC, QLD, and WA
-- over time? As someone who has worked across NSW for 5+ years, I wanted to
-- see how my home state performs relative to the competition.
--
-- APPROACH: Use conditional aggregation with CASE expressions to pivot
-- state-level data into columns, making year-over-year comparison easy to read.
--
-- WHAT I FOUND: NSW only led VIC in 3 out of 16 years (2015-2017), driven by
-- the Sydney apartment boom. Since 2018, VIC has pulled ahead and the gap is
-- widening. NSW dropped from 74,699 (2016 peak) to 44,185 (2024) — a 40.8%
-- decline. VIC showed more resilience, holding above 50,000 even in weak years.
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
-- ============================================================================
-- RESEARCH QUESTION: What types of buildings are being approved? Has the mix
-- between houses and higher-density dwellings shifted over time?
--
-- APPROACH: Group by year and dwelling type within the private sector, then
-- calculate each type's percentage share of the annual total using a JOIN
-- against a year-level CTE.
--
-- WHAT I FOUND: The dwelling mix tells a story about urban densification.
-- Houses and apartments require fundamentally different materials (concrete
-- vs timber framing, bulk supplies vs precision finishing), so shifts in
-- the mix directly affect what a building materials supplier should stock.
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
-- ============================================================================
-- RESEARCH QUESTION: Do building approvals follow a predictable seasonal
-- pattern? If so, which months are strongest and weakest?
--
-- APPROACH: Use T-SQL PIVOT to transform monthly rows into a cross-tab
-- calendar view. This makes it easy to read across months for any year
-- or down months across years to spot the seasonal pattern.
--
-- WHAT I FOUND: January is the dead zone — averaging just 1,563 approvals
-- per state, 27.8% below the November peak of 2,164. The pattern makes
-- sense: councils process backlogs before Christmas (Nov spike), January
-- is holiday shutdown, and activity ramps from Feb-Mar. For a supplier,
-- this means you should be building inventory in Oct-Nov for the Feb-May rush.
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
-- ============================================================================
-- RESEARCH QUESTION: How did COVID-19 impact building approvals? I lived
-- through this period on the ground — builders panicking in March 2020,
-- then suddenly overwhelmed by demand six months later. What does the data say?
--
-- APPROACH: Use CASE expressions to classify each month into four periods
-- (Pre-COVID, COVID Impact, Recovery, Post-Recovery), then aggregate to
-- compare average monthly approvals and value across periods.
--
-- WHAT I FOUND: The COVID disruption was surprisingly short. Average monthly
-- approvals during the COVID impact period (15,994) were virtually identical
-- to pre-COVID levels (15,984). The real story is the 2021 recovery: monthly
-- averages jumped to 19,083 (+19.4% above pre-COVID), driven by HomeBuilder
-- grants and record-low interest rates. But the post-recovery period (2022+)
-- settled back to 15,115/month — slightly below pre-COVID baseline.
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
-- ============================================================================
-- RESEARCH QUESTION: Monthly data is noisy. What does the underlying trend
-- look like for each major state when you smooth out the volatility?
--
-- APPROACH: Calculate a rolling 12-month average using AVG() with a window
-- frame (ROWS BETWEEN 11 PRECEDING AND CURRENT ROW), partitioned by state.
-- This strips out seasonal effects and one-off spikes.
--
-- WHAT I FOUND: The rolling average reveals trend inflection points that
-- are invisible in raw monthly data. VIC's rolling average peaked in mid-2017
-- and has been on a gradual downtrend since. NSW shows a sharper decline from
-- its 2016 peak. QLD's rolling average bottomed in mid-2019 and has been
-- climbing steadily — it is the only major state with a clearly positive
-- trajectory heading into 2025.
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
-- QUERY 8: Value Trend — Total Approval Value by Year
-- ============================================================================
-- RESEARCH QUESTION: Where is the money going? Count of approvals tells you
-- about volume, but value reveals the size and economic weight of projects.
--
-- APPROACH: Aggregate total approval value by year and convert to billions
-- for readability. The value column represents total estimated construction
-- cost at the time of approval.
--
-- WHAT I FOUND: Total approval value has climbed almost continuously,
-- from $79.9B (2010) to $198.8B (2025) — a 149% increase. The average
-- value per approval went from $439,360 (2010) to $1,017,764 (2025),
-- more than doubling. This means the industry is approving fewer but
-- significantly more expensive projects. For a materials supplier, this
-- means larger individual orders even if the number of customers shrinks.
-- ============================================================================

SELECT
    YEAR(Period) AS ApprovalYear,
    SUM(NumberOfApprovals) AS TotalApprovals,
    ROUND(SUM(ValueOfApprovals) / 1000000, 1) AS TotalValue_M,
    ROUND(SUM(ValueOfApprovals) / 1000000000, 2) AS TotalValue_B,
    CASE
        WHEN SUM(NumberOfApprovals) > 0
        THEN ROUND(SUM(ValueOfApprovals) * 1.0 / SUM(NumberOfApprovals), 0)
        ELSE NULL
    END AS AvgValuePerApproval
FROM BuildingApprovals
GROUP BY YEAR(Period)
ORDER BY ApprovalYear;


-- ============================================================================
-- QUERY 9: Top Growth States — 2020-2024 vs 2015-2019
-- ============================================================================
-- RESEARCH QUESTION: Which states are accelerating and which are losing
-- momentum? This is the forward-looking question — if I were advising a
-- building materials company on where to expand, which states would I pick?
--
-- APPROACH: Compare total approvals in the most recent 5-year window
-- (2020-2024) against the prior window (2015-2019) using two CTEs joined
-- on state. Calculate both absolute change and percentage growth.
--
-- WHAT I FOUND: Only Tasmania (+16.2%) and South Australia (+6.8%) grew.
-- Every other state declined. NSW had the worst absolute decline (-76,678
-- fewer approvals, -22.9%). The Northern Territory fell -42.0%, reflecting
-- the end of mining-driven construction. If I were allocating a national
-- sales team, I would be shifting resources from NSW toward TAS, SA, and
-- QLD (which shows signs of turning the corner thanks to Olympic infrastructure).
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
