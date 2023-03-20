
SELECT *
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
order by 3,4

--SELECT *
--FROM PortfolioProject..CovidVaccinations
--order by 3,4

SELECT Location, date, total_cases, new_cases,total_deaths, population
FROM PortfolioProject..CovidDeaths
order by 1,2

-- looking at total cases vs total deaths
-- shows the likelihood of death from covid
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE location like 'india'
order by 1,2

-- cases vs population
SELECT location, date, population,total_cases, total_deaths, (total_cases/population)*100 AS CasesforPopulation
FROM PortfolioProject..CovidDeaths
WHERE location like 'india'
order by 1,2

-- looking at countries with highest infection rate to population
SELECT location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 AS CasesforPopulation
FROM PortfolioProject..CovidDeaths
GROUP by location, population
order by CasesforPopulation DESC

--Showing countries with highest death count per population
SELECT location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
GROUP by location
order by TotalDeathCount desc

-- Break by continent

-- showing continents with highest deathcount

SELECT location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent is null
GROUP by location
order by TotalDeathCount desc

-- global numbers
Select date, SUM(new_cases)as totalcases, SUM(cast(new_deaths as int)) as totaldeaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
where continent is not null
Group by date
order by 1,2

-- looking at totl population vs vaccination
SELECT dea.continent, dea.location, dea.date, dea.population,vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location , dea.date) as rollingcountvaccination
FROM PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null --and dea.location like '%states%'
order by 2,3

--use cte

with PopvsVac(Continent, location,date,population,new_vaccination,rollingcountvaccination)
as(
SELECT dea.continent, dea.location, dea.date, dea.population,vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location , dea.date) as rollingcountvaccination
FROM PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null --and dea.location like 'india'
--order by 2,3
)
Select *, (rollingcountvaccination/population)*100
FROM PopvsVac



-- temp table
DROP TABLE IF EXISTS #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
New_vaccination numeric,
rollingcountvaccination numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population,vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location , dea.date) as rollingcountvaccination
FROM PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null --and dea.location like 'india'
--order by 2,3
Select *, (rollingcountvaccination/population)*100
FROM #PercentPopulationVaccinated



create view PercentPopulationVaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population,vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location , dea.date) as rollingcountvaccination
FROM PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null --and dea.location like 'india'
--order by 2,3

SELECT *
FROM PercentPopulationVaccinated