SELECT * 
FROM PortfolioProject..CovidDeaths
ORDER BY 3, 4 

--SELECT * 
--FROM PortfolioProject..CovidVaccinations
--ORDER BY 3, 4 

SELECT location, date, total_cases, new_cases, total_cases, population
FROM PortfolioProject..CovidDeaths
ORDER BY 1, 2


-- Looking at Total Cases vs Total Deaths 
-- Shows liklihood of dying if you contract covid in Papua New Guinea

SELECT location, date, total_cases, total_deaths, (total_deaths / total_cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE location like '%Papua New Guinea%'
ORDER BY 1, 2

-- Looking at Total Cases vs Population 
-- Shows what percentage of population got Covid

SELECT location, date, Population, total_cases, total_deaths, (total_deaths / population)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE location like '%Papua New Guinea%'
ORDER BY 1, 2

-- Looking at Countries with Highest Infection Rate compared to Population 

Select Location, Population, MAX(total_cases) AS HighestInfectionCount, Max((total_cases/population))*100 AS PercentagePopulationInfected
FROM PortfolioProject..CovidDeaths
-- Where location like '%Papua New Guinea%'
GROUP BY Location, Population 
ORDER BY PercentagePopulationInfected DESC


-- Showing Continents with Highest Death Count per Population
Select continent, MAX(total_deaths) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
-- Where location like '%Papua New Guinea%'
WHERE continent IS NOT NULL 
GROUP BY continent
ORDER BY TotalDeathCount DESC


-- GLOBAL NUMBERS

-- Total Cases globally by Date

SELECT date, SUM(new_cases) AS total_cases, SUM(new_deaths) AS total_deaths, SUM(CAST(new_deaths AS FLOAT))/SUM(new_cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
-- WHERE location like '%Papua New Guinea%'
WHERE continent IS NOT NULL 
GROUP BY date 
ORDER BY 1, 2

-- Total Cases globally 

SELECT SUM(new_cases) AS total_cases, SUM(new_deaths) AS total_deaths, SUM(CAST(new_deaths AS FLOAT))/SUM(new_cases)*100 
AS DeathPercentage
FROM PortfolioProject..CovidDeaths
-- WHERE location like '%Papua New Guinea%'
WHERE continent IS NOT NULL 
ORDER BY 1, 2

-- Looking at Total Population vs Vaccinations

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (PARTITION BY dea.Location ORDER BY dea.location, dea.Date) AS RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths dea 
JOIN PortfolioProject..CovidVaccinations vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent IS NOT NULL 
ORDER BY 2,3

-- Using CTE 

WITH PopvsVac (Continent, Location, Date, Population, new_vaccinations, RollingPeopleVaccinated) 
AS 
(SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(FLOAT,vac.new_vaccinations)) OVER (PARTITION BY dea.Location ORDER BY dea.location, dea.Date) AS RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths dea 
JOIN PortfolioProject..CovidVaccinations vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent IS NOT NULL 
)

SELECT *, (RollingPeopleVaccinated/Population)*100 
FROM PopvsVac

-- TEMP TABLE

DROP TABLE IF EXISTS #PercentPopulationVaccinated 
CREATE TABLE #PercentPopulationVaccinated 
(Continent NVARCHAR (255), 
Location NVARCHAR (255),
Date datetime,
Population FLOAT, 
new_vaccinations FLOAT,
RollingPeopleVaccinated FLOAT)

INSERT INTO #PercentPopulationVaccinated 
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(FLOAT,vac.new_vaccinations)) OVER (PARTITION BY dea.Location ORDER BY dea.location, dea.Date) AS RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths dea 
JOIN PortfolioProject..CovidVaccinations vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent IS NOT NULL 
-- order by 2,3

SELECT *, (RollingPeopleVaccinated/Population)*100 
FROM #PercentPopulationVaccinated 


-- Creating View to store data for later visualizations 

CREATE VIEW PercentPopulationVaccinated AS 
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(FLOAT,vac.new_vaccinations)) OVER (PARTITION BY dea.Location ORDER BY dea.location, dea.Date) AS RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths dea 
JOIN PortfolioProject..CovidVaccinations vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent IS NOT NULL 
-- order by 2,3

CREATE VIEW TotalPopulationVsVaccinations AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (PARTITION BY dea.Location ORDER BY dea.location, dea.Date) AS RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths dea 
JOIN PortfolioProject..CovidVaccinations vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent IS NOT NULL 
-- ORDER BY 2,3

CREATE VIEW TotalCasesGlobally AS
SELECT SUM(new_cases) AS total_cases, SUM(new_deaths) AS total_deaths, SUM(CAST(new_deaths AS FLOAT))/SUM(new_cases)*100 
AS DeathPercentage
FROM PortfolioProject..CovidDeaths
-- WHERE location like '%Papua New Guinea%'
WHERE continent IS NOT NULL 
-- ORDER BY 1, 2

CREATE VIEW TotalCasesGloballyByDate AS
SELECT date, SUM(new_cases) AS total_cases, SUM(new_deaths) AS total_deaths, SUM(CAST(new_deaths AS FLOAT))/SUM(new_cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
-- WHERE location like '%Papua New Guinea%'
WHERE continent IS NOT NULL 
GROUP BY date 
-- ORDER BY 1, 2

CREATE VIEW TotalCasesvsPopulationInPNG AS 
SELECT location, date, total_cases, total_deaths, (total_deaths / total_cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE location like '%Papua New Guinea%'