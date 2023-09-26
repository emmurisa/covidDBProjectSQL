
SELECT * 
FROM PortafolioProject.dbo.CovidDeaths
WHERE continent is not null
ORDER BY 3,4

--SELECT * 
--FROM PortafolioProject.dbo.CovidVaccinations
--ORDER BY 3,4

-- Select Data that we are going to be using

SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM PortafolioProject..CovidDeaths
ORDER BY 1,2


-- Looking at a Total Cases vs Total Deaths
-- Shows likehood if dying if you contract covid in your country

SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as Death_Percentage
FROM PortafolioProject..CovidDeaths
WHERE location like '%costa%'
ORDER BY 1,2



--Looking the Total Cases  vs Population
-- Shows what percentage of population got Covid

SELECT Location, date, population, total_cases, (total_cases/population)*100 as Percent_Population_Infected
FROM PortafolioProject..CovidDeaths
--WHERE location like '%costa%'
ORDER BY 1,2


-- Looking at Countries with highest Infection Rate compared to Population

SELECT location, population, MAX(total_cases) AS Highest_Infection_Count, MAX((total_cases/population))*100 as Percent_Population_Infected
FROM PortafolioProject..CovidDeaths
--WHERE location like '%costa%'
GROUP BY location, population
ORDER BY Percent_Population_Infected DESC

-- Showing Countries with Highest Death Count per Population

SELECT location, MAX(CAST(Total_deaths AS INT)) AS Total_Death_Count
FROM PortafolioProject..CovidDeaths
--WHERE location like '%costa%'
WHERE continent is not null
GROUP BY location, population
ORDER BY Total_Death_Count DESC


-- Let's break things down by continent 

-- Showing continents with the highest death count per population (Version One)

SELECT continent, MAX(CAST(Total_deaths AS INT)) AS Total_Death_Count
FROM PortafolioProject..CovidDeaths
--WHERE location like '%costa%'
WHERE continent is not null
GROUP BY continent
ORDER BY Total_Death_Count DESC

-- Showing continents with the highest death count per population (Version Two)

SELECT location, MAX(CAST(Total_deaths AS INT)) AS Total_Death_Count
FROM PortafolioProject..CovidDeaths
--WHERE location like '%costa%'
WHERE continent is null
GROUP BY location
ORDER BY Total_Death_Count DESC


-- Global Numbers

--By Date
SELECT date, SUM(new_cases) AS Total_Cases, SUM(CAST(new_deaths AS INT)) AS Total_Deaths, SUM(CAST(new_deaths AS INT))/SUM(new_cases)*100 AS Death_Percentage
FROM PortafolioProject..CovidDeaths
--WHERE location like '%costa%'
WHERE continent is not null
GROUP BY date
ORDER BY 1,2

-- Totals
SELECT SUM(new_cases) AS Total_Cases, SUM(CAST(new_deaths AS INT)) AS Total_Deaths, SUM(CAST(new_deaths AS INT))/SUM(new_cases)*100 AS Death_Percentage
FROM PortafolioProject..CovidDeaths
--WHERE location like '%costa%'
WHERE continent is not null
ORDER BY 1,2


--Looking at Total Population vs Vaccinations

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(INT, vac.new_vaccinations)) 
OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS Rolling_People_Vaccinated
--, (Rolling_People_Vaccinated/dea.population (Error)
FROM PortafolioProject.dbo.CovidDeaths dea
JOIN PortafolioProject.dbo.CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 2,3


-- Use CTE

WITH PopvsVac (Continent, Location, Date, Population, New_Vaccinations, Rolling_People_Vaccinated)
AS 
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(INT, vac.new_vaccinations)) 
OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS Rolling_People_Vaccinated
--, (Rolling_People_Vaccinated/dea.population (Error)
FROM PortafolioProject.dbo.CovidDeaths dea
JOIN PortafolioProject.dbo.CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3
)
SELECT *, (Rolling_People_Vaccinated/Population)*100
FROM PopvsVac


-- Use TEMP TABLE

DROP TABLE IF EXISTS #Percent_Population_Vaccinated
CREATE TABLE #Percent_Population_Vaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
Rolling_People_Vaccinated numeric
)

INSERT INTO #Percent_Population_Vaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(INT, vac.new_vaccinations)) 
OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS Rolling_People_Vaccinated
--, (Rolling_People_Vaccinated/dea.population (Error)
FROM PortafolioProject.dbo.CovidDeaths dea
JOIN PortafolioProject.dbo.CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
--WHERE dea.continent is not null
--ORDER BY 2,3

SELECT *, (Rolling_People_Vaccinated/Population)*100
FROM #Percent_Population_Vaccinated


-- Creating view to store data for later visualizations

CREATE VIEW Percent_Population_Vaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(INT, vac.new_vaccinations)) 
OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS Rolling_People_Vaccinated
--, (Rolling_People_Vaccinated/dea.population (Error)
FROM PortafolioProject.dbo.CovidDeaths dea
JOIN PortafolioProject.dbo.CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
--WHERE dea.continent is not null
--ORDER BY 2,3

