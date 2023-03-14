-- checkiing the content of each table
select * from dbo.country_wise_latest

select * from dbo.covid_19_clean_complete

select * from dbo.full_grouped

select * from dbo.worldometer_data

-- Summarazing number of confiremd cases, deaths, recovered patients and active cases per country
select Country_Region, SUM(cast(Confirmed as int)) as SumConfirmed, SUM(cast(Deaths as int)) as SumDeaths, 
SUM(cast(Recovered as int)) as SumRecovered, SUM(cast(Active as int)) as SumActive
from dbo.full_grouped
group by Country_Region
order by SumConfirmed desc

-- Summarazing number of confiremd cases, deaths, recovered patients and active cases per country in Europe
select Country_Region, SUM(cast(Confirmed as int)) as SumConfirmed, SUM(cast(Deaths as int)) as SumDeaths, 
SUM(cast(Recovered as int)) as SumRecovered, SUM(cast(Active as int)) as SumActive
from dbo.full_grouped
where WHO_Region = 'Europe'
group by Country_Region
order by SumConfirmed desc

-- finding the death rate and recovered rate per confirmed cases
with TempTable (CountryRegion, SumConfirmed, SumDeaths, SumRecovered, SumActive)
as (
select Country_Region, SUM(cast(Confirmed as float)) as SumConfirmed, SUM(cast(Deaths as float)) as SumDeaths, 
SUM(cast(Recovered as float)) as SumRecovered, SUM(cast(Active as float)) as SumActive
from dbo.full_grouped
where WHO_Region = 'Europe'
group by Country_Region
)
select *, ROUND((SumDeaths/SumConfirmed)*100,2) as DeathRatePercent, 
ROUND((SumRecovered/SumConfirmed)*100, 2) as RecoveredRatePercent, 
ROUND((SumActive/SumConfirmed)*100,2) as ActiveRatePercent
from TempTable
order by DeathRatePercent desc

-- Cases, Deaths, Recovered and Active per Continent Population
select Continent, SUM(cast(Population as float)) as Population, 
(SUM(cast(TotalCases as float))/SUM(cast(Population as float))) * 100 as CasesPerPopulationPercent,
(SUM(cast(TotalDeaths as float))/SUM(cast(Population as float))) * 100 as DeathsPerPopulationPercent,
(SUM(cast(TotalRecovered as float))/SUM(cast(Population as float))) * 100 as RecoveredPerPopulationPercent,
(SUM(cast(ActiveCases as float) )/SUM(cast(Population as float))) * 100 as ActivePerPopulation,
(SUM(cast(Serious_Critical as float))/SUM(cast(Population as float))) * 100 as CriticalPerPopulationPercent
from dbo.worldometer_data
where continent is not NULL
group by continent
order by CasesPerPopulationPercent desc

-- looking for chaning statistics during the time
select date, SUM(cast(Confirmed as int)) as Confirmed, 
SUM(cast(Deaths as int)) as Deaths, 
SUM(cast(Recovered as int)) as Recovered, 
SUM(cast(Active as int)) as Active
from dbo.covid_19_clean_complete
group by date
order by date asc

--tracking covid statistics through time by continent
select ccd.Date, wd.Continent, SUM(cast(ccd.Confirmed as int)) as Confirmed, 
SUM(cast(ccd.Deaths as int)) as Deaths, 
SUM(cast(ccd.Recovered as int)) as Recovered, 
SUM(cast(ccd.Active as int)) as Active
from dbo.worldometer_data wd
join dbo.covid_19_clean_complete ccd
on wd.Country_Region = ccd.Country_Region
group by ccd.Date, wd.Continent
order by ccd.Date asc