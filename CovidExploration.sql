SELECT *
FROM Covid.dbo.CovidDeaths
ORDER BY 3,4


SELECT *
FROM Covid.dbo.CovidDeaths
WHERE continent is not null
ORDER BY 3,4

--Select *
--From Covid.dbo.CovidVaccinations
--order by 3,4

-- Select Data that we are going to be using
SELECT location, date, total_cases, new_cases, total_deaths, population
FROM Covid.dbo.CovidDeaths
WHERE continent is not null
ORDER BY 1,2

-- Mortality Rate
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS MortalityRate
FROM Covid.dbo.CovidDeaths
WHERE continent is not null
ORDER BY 1,2

-- Infection Rate in the Philippines
SELECT location, date, total_cases, population, (total_cases/population)*100 AS InfectionRate
FROM Covid.dbo.CovidDeaths
WHERE location ='Philippines' 
ORDER BY 1,2

--Looking at Countries with Highest Infection Rate
SELECT location, Max(total_cases) as HighestInfectionCount, population, max((total_cases/population))*100 AS InfectionRate
FROM Covid.dbo.CovidDeaths
GROUP BY location, population
ORDER BY InfectionRate DESC

-- Showing Countries with Highest Death Count per population
SELECT location, Max(cast(total_deaths as int)) as TotalDeathCount, max((total_deaths/population))*100 AS HighestDeathRate
FROM Covid.dbo.CovidDeaths
WHERE continent is not null
GROUP BY location
ORDER BY HighestDeathRate DESC

-- BY CONTINENT
-- Showing continents with highest death count
SELECT continent, Max(cast(total_deaths as int)) as TotalDeathCount
FROM Covid.dbo.CovidDeaths
WHERE continent is not null
GROUP BY continent
ORDER BY TotalDeathCount DESC

-- GLOBAL NUMBERS
--death percentage by continent
SELECT continent, max(total_cases) AS maxtotalcases, max(total_deaths) AS maxtotaldeath, (max(total_deaths)/max(total_cases))*100 AS DeathPercentage
FROM Covid.dbo.CovidDeaths
WHERE continent is not null
GROUP BY continent
ORDER BY 4 DESC



--total cases and deaths per day global
SELECT date, sum(new_cases) as totalcasesperday, sum(cast(new_deaths as int)) as totaldeathsperday
FROM Covid.dbo.CovidDeaths
WHERE continent is not null
GROUP BY date
ORDER BY 1,2

-- Global death percentage per day
SELECT date, sum(new_cases) as totalcases, sum(cast(new_deaths as int)) as totaldeaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
FROM Covid..CovidDeaths
WHERE continent is not null
GROUP BY date
ORDER BY 1,2


-- Global death percentage TOTAL ~ 1 row
SELECT sum(new_cases) as totalcases, sum(cast(new_deaths as int)) as totaldeaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
FROM Covid..CovidDeaths
WHERE continent is not null

--Looking at total population vs vaccinations with window function
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(cast(vac.new_vaccinations AS bigint)) OVER (PARTITION BY dea.Location ORDER BY dea.Location, dea.date) AS Rolling_Vaccinated_Count
FROM Covid..CovidDeaths AS dea
JOIN  Covid..CovidVaccinations AS vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 2,3

-- use CTE
WITH PopvsVac (Continent, Location, Date, Population, new_vaccinations, Rolling_Vaccinated_Count)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(cast(vac.new_vaccinations as bigint)) OVER (PARTITION BY dea.Location ORDER BY dea.Location, dea.date) AS Rolling_Vaccinated_Count
FROM Covid..CovidDeaths AS dea
JOIN  Covid..CovidVaccinations AS vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
)

SELECT *, (Rolling_Vaccinated_Count/Population)*100 AS PercentVaccinated 
FROM PopvsVac


-- temp table

DROP TABLE IF exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255), 
Location nvarchar(255), 
Date datetime, 
Population numeric, 
New_vaccinations numeric, 
Rolling_Vaccinated_Count numeric 
)


INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.Location Order by dea.Location, dea.date) AS Rolling_Vaccinated_Count
FROM Covid..CovidDeaths AS dea
JOIN  Covid..CovidVaccinations AS vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null

SELECT *, (Rolling_Vaccinated_Count/Population)*100 PercentVaccinatedPerDay
FROM #PercentPopulationVaccinated

-- Creating view to store data for later visualizations

CREATE VIEW PercentPopulationVaccinated AS 
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(cast(vac.new_vaccinations AS bigint)) OVER (Partition by dea.Location Order by dea.Location, dea.date) as Rolling_Vaccinated_Count
FROM Covid..CovidDeaths AS dea
JOIN  Covid..CovidVaccinations AS vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null


SELECT *
FROM dbo.PercentPopulationVaccinated


CREATE VIEW MortalityRate AS 
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS MortalityRate
FROM Covid.dbo.CovidDeaths
WHERE continent is not null
ORDER BY 1,2 offset 0 rows

CREATE VIEW PHInfectionRate AS
SELECT location, date, total_cases, population, (total_cases/population)*100 AS InfectionRate
FROM Covid.dbo.CovidDeaths
WHERE location ='Philippines' 
ORDER BY 1,2 offset 0 rows

CREATE VIEW HighestInfectionRate AS
SELECT location, Max(total_cases) as HighestInfectionCount, population, max((total_cases/population))*100 AS InfectionRate
FROM Covid.dbo.CovidDeaths
GROUP BY location, population
ORDER BY InfectionRate DESC offset 0 rows

CREATE VIEW HighestDateRate AS
SELECT location, Max(cast(total_deaths as int)) as TotalDeathCount, max((total_deaths/population))*100 AS HighestDeathRate
FROM Covid.dbo.CovidDeaths
WHERE continent is not null
GROUP BY location
ORDER BY HighestDeathRate DESC offset 0 rows

CREATE VIEW HighestDeathCount AS
SELECT continent, Max(cast(total_deaths as int)) as TotalDeathCount
FROM Covid.dbo.CovidDeaths
WHERE continent is not null
GROUP BY continent
ORDER BY TotalDeathCount DESC offset 0 rows


CREATE VIEW ContHighestRate AS
SELECT continent, max(total_cases) AS maxtotalcases, max(total_deaths) AS maxtotaldeath, (max(total_deaths)/max(total_cases))*100 AS DeathPercentage
FROM Covid.dbo.CovidDeaths
WHERE continent is not null
GROUP BY continent
ORDER BY 4 DESC offset 0 rows



CREATE VIEW GloCaseDeath AS--total cases and deaths per day global
SELECT date, sum(new_cases) as totalcasesperday, sum(cast(new_deaths as int)) as totaldeathsperday
FROM Covid.dbo.CovidDeaths
WHERE continent is not null
GROUP BY date
ORDER BY 1,2 offset 0 rows

CREATE VIEW GloDeathRate AS
SELECT date, sum(new_cases) as totalcases, sum(cast(new_deaths as int)) as totaldeaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
FROM Covid..CovidDeaths
WHERE continent is not null
GROUP BY date
ORDER BY 1,2 offset 0 rows


CREATE VIEW DeathRateJune2022 AS
SELECT sum(new_cases) as totalcases, sum(cast(new_deaths as int)) as totaldeaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
FROM Covid..CovidDeaths
WHERE continent is not null