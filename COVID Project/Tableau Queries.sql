--Queries for Tableau
-- Total Cases, Deaths, and Percentage
Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as bigint)) as total_deaths,
	SUM(cast(new_deaths as bigint))/SUM(new_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
where continent is not null
order by 1,2

--Total Death count based on location (continent)
Select location, SUM(cast(new_deaths as bigint)) as TotalDeathCount
From PortfolioProject..CovidDeaths
where continent is null
and location not in ('World', 'European Union', 'International', 'Upper middle income', 'High income', 'Lower middle income', 'Low income')
Group by location
order by TotalDeathCount desc

-- MAX number of population infected (+ percentage infected) by location
Select location, population, MAX(total_cases) as HighestInfectionCount,
	MAX((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
group by location, population
order by PercentPopulationInfected desc

Select location, population, date, MAX(total_cases) as HighestInfectionCount,
	MAX((total_cases/population))*100 as PercentPopulationInfected
from PortfolioProject..CovidDeaths
group by location, population, date
order by PercentPopulationInfected desc