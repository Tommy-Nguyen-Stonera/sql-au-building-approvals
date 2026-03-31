# Australian Building Approvals Analysis (T-SQL)
> **[View Interactive Report](https://htmlpreview.github.io/?https://raw.githubusercontent.com/Tommy-Nguyen-Stonera/sql-au-building-approvals/main/report/au_building_approvals_report.html)** — Full analysis with findings, methodology, and insights


![SQL Server](https://img.shields.io/badge/SQL_Server-CC2927?style=for-the-badge&logo=microsoftsqlserver&logoColor=white)
![T-SQL](https://img.shields.io/badge/T--SQL-003B57?style=for-the-badge&logo=database&logoColor=white)
![ABS Data](https://img.shields.io/badge/ABS_Open_Data-1B365D?style=for-the-badge&logo=data&logoColor=white)
![Status](https://img.shields.io/badge/Status-Complete-brightgreen?style=for-the-badge)

## The Story Behind This Analysis

Having worked in building materials sales across Sydney, Canberra, Newcastle, and Wollongong for over five years, I have spent a lot of time on the ground talking to builders, developers, and project managers. You develop a feel for the market after a while. You notice when quotes slow down, when certain regions go quiet, or when the phone starts ringing about apartment projects instead of house builds. But that is all intuition, and intuition is not something you can put in a sales forecast or present to a manager.

I wanted to see if the data backed up what I had been observing. The ABS Building Approvals dataset is the official record of every building approval issued in Australia, and it goes back over a decade. I pulled 16 years of monthly data (2010-2025) across all eight states and territories to answer the questions that actually matter to someone working in this industry: Where is the work? Is it growing or shrinking? What kind of buildings are getting approved? And most importantly, what should I be paying attention to next?

The analysis follows the way I would actually think through the market if I were advising a building materials supplier on where to focus. Start with the national picture, drill into states, look at what is being built, check for seasonality, and then assess which regions are accelerating.

## Dataset Overview

| Attribute | Detail |
|---|---|
| **Source** | Australian Bureau of Statistics (ABS) - Building Approvals, Australia (Cat. 8731.0) |
| **Period** | January 2010 to January 2026 (192 months) |
| **Geography** | All 8 states and territories |
| **Measures** | Number of dwelling units approved, number of buildings approved, value of approvals ($AUD) |
| **Granularity** | Monthly, by state/territory |
| **Total Records** | 4,632 rows across 3 measures |
| **Total Approvals Analysed** | 3.1 million dwelling units |
| **Total Value Analysed** | $1.97 trillion |

## Business Questions and Thinking Flow

The analysis is structured as a chain of questions, where each finding naturally leads to the next:

1. **How has construction activity changed over time nationally?** This is the starting point. Before looking at anything specific, I needed to see the overall trajectory. Are we in a growth market or a declining one?

2. **Which states drive the most construction?** The national trend showed clear growth from 2010-2015, then a decline that has not fully recovered. That made me wonder: is this a nationwide pattern, or are some states masking the decline of others? If the national number is an average, which states are pulling it up and which are dragging it down? In building materials sales, knowing which state accounts for 31% of all approvals versus 1.4% changes everything about where you allocate resources.

3. **How does NSW compare to VIC, QLD, and WA?** This is personal. I have worked across NSW my entire career, and I wanted to see how the state I know best stacks up against the other major markets. The finding here genuinely surprised me.

4. **What types of buildings are being approved?** Once I understood the state dynamics, I needed to know what is actually being built. Houses and apartments require completely different materials, and the mix shift matters for sales strategy.

5. **Are there seasonal patterns?** Anyone in construction sales knows that January is dead. But I wanted to quantify it - exactly how much of a drop-off is there, and which months should you be ramping up inventory for?

6. **How did COVID-19 impact building approvals?** This was a period I lived through on the ground. Builders were panicking in March 2020, then suddenly the phone would not stop ringing six months later. I wanted to see the data behind what I experienced.

7. **What does the underlying trend look like when you smooth out the noise?** Monthly data is volatile. A rolling 12-month average strips out the noise and shows you the real direction a state is heading.

8. **Where is the money going - residential or non-residential?** Count of approvals tells you about volume, but value tells you about where the big projects are. Sometimes fewer approvals can mean more money if the projects are larger.

9. **Which states are accelerating?** This is the forward-looking question. Comparing the last five years (2020-2024) to the previous five (2015-2019) reveals which markets are growing and which are contracting. This is where I would point a sales team.

## Key Findings

### 1. Victoria dominates, and the gap is wider than you think
Victoria leads the nation with 971,368 total approvals (31.1% market share) compared to NSW at 863,712 (27.6%). What struck me is that VIC has led NSW in 13 out of 16 years. NSW only briefly overtook VIC during the 2015-2017 Sydney apartment boom. For a building materials supplier, VIC is unambiguously the largest market.

What I could not tell from the approval count alone was whether VIC's lead was driven by houses or apartments — a question that became important when I looked at dwelling types in Query 4.

### 2. NSW has fallen 40.8% from its peak and is not recovering
NSW peaked at 74,699 approvals in 2016. By 2024, it was down to 44,185 - just 59.2% of its peak. The 2025 data (52,539) shows some recovery, but NSW remains the worst-performing major state over the last decade, with approvals down 22.9% comparing 2020-2024 to 2015-2019. As someone who works in NSW, this was the hardest finding to see in black and white.

### 3. The 2021 stimulus boom was real but temporary
National approvals jumped from 176,611 in 2019 to 228,995 in 2021, a 29.7% increase driven by HomeBuilder and low interest rates. But the hangover was brutal: approvals crashed back to 164,332 by 2023 (-28.2% from the 2021 peak). The average monthly approval count during the COVID impact period (15,994) was almost identical to pre-COVID levels (15,984), meaning the disruption was shorter than expected.

### 4. The value per approval has more than doubled in 15 years
In 2010, the average approval was worth $439,360. By 2025, it reached $1,017,764 - a 131.7% increase. Even accounting for inflation, this suggests approvals are skewing toward larger, more expensive projects. Total approval value hit $198.8 billion in 2025, the highest year on record, despite approval counts being well below the 2015 peak.

### 5. January is the dead zone - 27.8% below November
The seasonal pattern is stark: January averages just 1,563 approvals per state compared to November at 2,164. This 27.8% swing matters for inventory planning. May (2,161) and October (2,157) are also strong months. The pattern aligns with the construction calendar: councils process backlogs before Christmas, January is holiday shutdown, and activity ramps from February onwards.

The obvious follow-up is whether this pattern varies by state or dwelling type. A January slump in Sydney might look very different from January in Queensland, where the weather does not shut down construction the same way.

### 6. Tasmania and SA are the only growth stories
Only two states grew between 2015-2019 and 2020-2024: Tasmania (+16.2%) and South Australia (+6.8%). Every other state declined. The NT saw the steepest fall (-42.0%), reflecting the end of the mining construction boom. This finding has direct implications for where a national supplier should be expanding.

The obvious follow-up is *why* these two smaller states bucked the national trend. Tasmania's growth coincided with a period of strong interstate migration and relative housing affordability — whether that is cause or coincidence would require linking this data with population and price data.

### 7. Post-recovery value keeps climbing while counts stagnate
Since 2022, approval counts have been flat around 164,000-191,000 per year. But the total value has climbed from $153.8B (2022) to $198.8B (2025). This tells you the market is shifting toward fewer but more expensive projects - think large apartment developments and commercial builds rather than suburban house-and-land packages.

### 8. Western Australia's boom-bust cycle is the most extreme
WA peaked at 33,088 approvals in 2014, collapsed to 14,023 by 2023 (-57.6%), then partially recovered to 24,055 in 2025. No other state shows this level of volatility. For anyone selling into the WA market, the lesson is clear: do not staff or stock based on peak demand.

### 9. The Queensland comeback is underway
QLD dropped from 50,856 (2015) to 31,106 (2019), but has been climbing since - reaching 41,848 in 2025. The infrastructure pipeline for the 2032 Brisbane Olympics is likely a contributing factor. QLD is the state I would be watching most closely for the next five years.

One issue I noticed early was that comparing raw approval counts across states is misleading without adjusting for state population. NSW and VIC look close in absolute terms, but on a per-capita basis, VIC's lead widens significantly. I chose to present absolute numbers because that is what matters for a supplier sizing a market, but the per-capita view tells a different story about building intensity.

## What Surprised Me

The single most surprising finding was the **value-volume disconnect**. I expected that when approval numbers dropped, the total value would drop too. Instead, 2025 set a record for total approval value ($198.8B) despite being 18.5% below the approval count peak. This means the construction industry is not shrinking - it is restructuring toward higher-value projects. For someone selling building materials, this is actually good news: fewer projects, but each one is worth significantly more.

The other surprise was NSW's relative weakness. Working in Sydney, you feel like you are in the centre of everything. The data says otherwise. Victoria has been the dominant construction market for most of the last 16 years, and the gap has been widening since 2018.

## SQL Techniques Used

| Technique | Where Used | Purpose |
|---|---|---|
| **CTEs (Common Table Expressions)** | Queries 1, 2, 4, 6, 7, 9 | Layer calculations for readability |
| **Window Functions** | Queries 1, 2, 7 | `LAG()` for year-over-year growth, `RANK()` for state ranking, `AVG() OVER()` for rolling averages |
| **PIVOT** | Query 5 | Transform monthly rows into a cross-tab calendar view |
| **CASE Expressions** | Queries 3, 6, 8 | Conditional aggregation for state comparison and period classification |
| **DATEPART / YEAR / MONTH** | All queries | Time-based grouping and filtering |
| **CROSS JOIN** | Query 2 | Calculate percentage share against national totals |
| **Rolling Window Frames** | Query 7 | `ROWS BETWEEN 11 PRECEDING AND CURRENT ROW` for 12-month moving average |
| **NULLIF** | Queries 8, 9 | Safe division to avoid divide-by-zero errors |

## Files

| File | Description |
|---|---|
| `queries/au_building_approvals_analysis.sql` | Full T-SQL analysis - 9 query blocks with detailed research question comments |
| `report/au_building_approvals_report.html` | Interactive HTML report with findings, insights, and business implications |
| `data/building_approvals_full.csv` | Primary dataset - ABS Building Approvals monthly data (4,632 rows) |
| `data/building_approvals_raw.csv` | Raw unprocessed ABS data extract |
| `README.md` | This file - project overview, methodology, and findings |

## How to Run

1. Install [SQL Server Express](https://www.microsoft.com/en-us/sql-server/sql-server-downloads) (free)
2. Import `data/building_approvals_full.csv` into a table called `BuildingApprovals`
3. Map columns: `REGION` -> State (1=NSW, 2=VIC, 3=QLD, 4=SA, 5=WA, 6=TAS, 7=NT, 8=ACT), `TIME_PERIOD` -> Period, `OBS_VALUE` -> NumberOfApprovals/ValueOfApprovals based on `UNIT_MEASURE`
4. Open `queries/au_building_approvals_analysis.sql` in SSMS
5. Run each query block sequentially
6. Open `report/au_building_approvals_report.html` in any browser for the interactive findings report

## A Note on AI Tools

I used AI coding assistants when I hit syntax issues or needed a second opinion on query structure. The analysis approach, business questions, and all interpretations are my own work - informed by five years of working in this industry.

---

**Tommy Nguyen** | [GitHub](https://github.com/Tommy-Nguyen-Stonera) | [Portfolio](https://tommy-nguyen-stonera.vercel.app)
