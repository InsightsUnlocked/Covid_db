SELECT location,date,total_cases,new_cases,total_deaths,population
FROM covid_db..CovidDeaths
ORDER BY 1,2

--Total cases vs death--

--likelihood of dying if you contract covid--
SELECT location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as death_percentage
FROM covid_db..CovidDeaths
ORDER BY 1,2


--Population vs the cases--
--Amount of population got covid--
SELECT location,date,population,total_cases,(total_cases/population)*100 as percent_populationInfected
FROM covid_db..CovidDeaths
ORDER BY 1,2


--Highest infection rate compared to population--
SELECT location,population,MAX(total_cases) AS highest_infection_count,MAX((total_cases/population))*100 as percent_populationInfected
FROM covid_db..CovidDeaths
GROUP BY location,population
ORDER BY percent_populationInfected DESC


--Highest death rate count--
SELECT location,MAX(CAST(total_deaths AS INT)) as total_death_count 
FROM covid_db..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY total_death_count DESC


--By continent--
SELECT continent,MAX(CAST(total_deaths AS INT)) as total_death_count 
FROM covid_db..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY total_death_count DESC


--Global Numbers--
SELECT SUM(CAST(total_deaths AS INT)) as total_death_count, SUM(new_cases) AS total_new_cases,SUM(CAST(total_deaths AS INT))/SUM(new_cases) as death_percentage
FROM covid_db..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1,2

--Total population vs vaccinations using CTE--
WITH PopvsVac as(
SELECT dea.continent,dea.location,dea.date,  dea.population,vac.new_vaccinations, 
       SUM(CONVERT(INT,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location,dea.date) as rolling_count 
FROM covid_db..[Covid Vaccinations] AS vac
JOIN covid_db..CovidDeaths AS dea ON vac.date = dea.date 
AND vac.location = dea.location
WHERE dea.continent IS NOT NULL
)
SELECT *,rolling_count/population FROM PopvsVac




--Dropping table --
DROP TABLE IF EXISTS #percentpopulationvaccinated 

--Total population vs vaccinations using Temp table--
CREATE TABLE #percentpopulationvaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccination numeric,
rolling_count numeric
)

INSERT INTO #percentpopulationvaccinated
SELECT dea.continent,dea.location,dea.date,  dea.population,vac.new_vaccinations, 
       SUM(CONVERT(INT,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location,dea.date) as rolling_count 
FROM covid_db..[Covid Vaccinations] AS vac
JOIN covid_db..CovidDeaths AS dea ON vac.date = dea.date 
AND vac.location = dea.location
WHERE dea.continent IS NOT NULL


SELECT *,rolling_count/population FROM #percentpopulationvaccinated



--Total population vs vaccinations using Views--
CREATE VIEW PercentagePopulationVaccinated AS
SELECT dea.continent,dea.location,dea.date,  dea.population,vac.new_vaccinations, 
       SUM(CONVERT(INT,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location,dea.date) as rolling_count 
FROM covid_db..[Covid Vaccinations] AS vac
JOIN covid_db..CovidDeaths AS dea ON vac.date = dea.date 
AND vac.location = dea.location
WHERE dea.continent IS NOT NULL