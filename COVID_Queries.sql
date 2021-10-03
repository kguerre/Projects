SELECT *
FROM PortfolioProject..CovidDeaths
ORDER BY 3,4

--SELECT *
--FROM PortfolioProject..CovidVaccinations
--ORDER BY 3,4

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
ORDER BY 1,2

--Looking at Total Cases vs Total Deaths
--Shows percentage of Covid cases that resulted in death per country

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as death_percentage
FROM PortfolioProject..CovidDeaths
WHERE location like '%states%'
ORDER BY 1,2

--Looking at Total Cases vs Population
--Shows what percentage of poulation contracted Covid

SELECT location, date, total_cases, population, (total_cases/population)*100 as covid_percentage
FROM PortfolioProject..CovidDeaths
WHERE location = 'India'
ORDER BY 1,2

--Looking at countries with highest infection rate compared to population

SELECT location, population, MAX(total_cases) as highest_infection_count, MAX((total_cases/population))*100 as percent_population_infected
FROM PortfolioProject..CovidDeaths
GROUP BY location, population
ORDER BY percent_population_infected DESC

--Showing countries with the highest death count per country

SELECT location, MAX(cast(total_deaths as int)) as total_death_count
FROM PortfolioProject..CovidDeaths
WHERE continent is NOT null
GROUP BY location
ORDER BY total_death_count DESC

--Showing death counts by continent

SELECT location, MAX(cast(total_deaths as int)) as total_death_count
FROM PortfolioProject..CovidDeaths
WHERE continent is null
GROUP BY location
ORDER BY total_death_count DESC

SELECT continent, MAX(cast(total_deaths as int)) as total_death_count
FROM PortfolioProject..CovidDeaths
WHERE continent is NOT null
GROUP BY continent
ORDER BY total_death_count DESC

--Global Numbers

SELECT date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths , (SUM(cast(new_deaths as int))/SUM(new_cases))*100 as death_percentage 
FROM PortfolioProject..CovidDeaths
WHERE continent is NOT null
GROUP BY date
ORDER BY 1,2

--Looking at Total Population vs Vaccinations by country 

SELECT *
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
ON dea.location = vac.location
AND dea.date = vac.date

SELECT dea.continent, dea.location, dea.date, dea.population, vac.people_vaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent is NOT null
ORDER BY 2,3


SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(cast(vac.new_vaccinations as int)) 
OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as rolling_vaccination_count
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent is NOT null
ORDER BY 2,3

--Using CTE

WITH pop_vs_vac (continent, location, date, population, new_vaccinations, people_vaccinated, rolling_vaccination_count)
AS
(SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, vac.people_vaccinated,  
SUM(cast(vac.new_vaccinations as int)) 
OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as rolling_vaccination_count
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent is NOT null
)

SELECT *, (people_vaccinated/population)*100
FROM pop_vs_vac
WHERE location = 'Canada'


--Creating View to store data for later visualizations
CREATE VIEW GlobalNumbers as
SELECT date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths , (SUM(cast(new_deaths as int))/SUM(new_cases))*100 as death_percentage 
FROM PortfolioProject..CovidDeaths
WHERE continent is NOT null
GROUP BY date
