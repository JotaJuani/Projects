SELECT * 
FROM CovidAnalisys.dbo.CovidDeaths
ORDER BY 3,4
--SELECT * 
--FROM CovidAnalisys.dbo.CovidVaccinations
--ORDER BY 3,4

SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM CovidAnalisys.dbo.CovidDeaths
ORDER BY 1,2;

--calculation cases vs deaths 
SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM CovidAnalisys.dbo.CovidDeaths
where location like '%Argentina%'
ORDER BY 1,2;

--calculation cases vs population 
SELECT Location, date, population,  total_cases,(total_cases/population)*100 AS casePercentage
FROM CovidAnalisys.dbo.CovidDeaths
ORDER BY 1,2;

--HIGHEST INFECTION RATE 
SELECT Location, population,  MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population))*100 AS InfectedPercentage
FROM CovidAnalisys.dbo.CovidDeaths
GROUP BY Location, population
ORDER BY InfectedPercentage DESC;

--HIGHESt death count vs population
SELECT Location, MAX(CAST(Total_deaths AS INT)) AS TotalDeathCount
FROM CovidAnalisys.dbo.CovidDeaths
WHERE continent IS NOT NULL
GROUP BY Location
ORDER BY TotalDeathCount DESC
;

--PERCETAGES BY CONTINENT 
SELECT continent, MAX(CAST(Total_deaths AS INT)) AS TotalDeathCount
FROM CovidAnalisys.dbo.CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC
;


--GLOBAL NUMBERS
SELECT  SUM(new_cases) AS total_Cases, SUM(CAST(new_deaths AS INT)) AS total_deaths, SUM(CAST(new_deaths AS INT))/SUM(new_cases)*100 AS DeathPercentage
FROM CovidAnalisys.dbo.CovidDeaths
WHERE continent IS NOT NULL
--GROUP BY date
ORDER BY 1,2;

--total population vs vaccinations in the world

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations AS INT)) OVER (PARTITION BY dea.location order by dea.location, dea.Date) AS RollingPeopleVaccinated
FROM CovidAnalisys..CovidDeaths dea
JOIN CovidAnalisys..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
	where dea.continent IS NOT NULL
order by 2,3

--temp 
DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date DATETIME,
Population NUMERIC,
New_Vaccinations NUMERIC,
RollingPeopleVaccinated NUMERIC
)
INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations AS INT)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.Date) AS RollingPeopleVaccinated
FROM CovidAnalisys..CovidDeaths dea
JOIN CovidAnalisys..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date

SELECT *, (RollingPeopleVaccinated/Population)*100
FROM #PercentPopulationVaccinated

--CREATING VIEW TO STORE DATA FOR LATER VISUALIZATIONS
CREATE VIEW PercentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations AS INT)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.Date) AS RollingPeopleVaccinated
FROM CovidAnalisys..CovidDeaths dea
JOIN CovidAnalisys..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
