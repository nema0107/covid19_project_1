SELECT * FROM Covid_DB..CovidDeaths
WHERE continent is not null
ORDER BY 3,4

SELECT * FROM Covid_DB..CovidVaccinations
ORDER BY 3,4

---Select Data that I am going to be using

SELECT Location,date, total_cases, new_cases,total_deaths,population
FROM Covid_DB..CovidDeaths
ORDER BY 1,2


---Looking at total cases vs total deaths

SELECT Location,date, total_cases,total_deaths, (total_deaths/total_cases)*100 as Deathpercentage
FROM Covid_DB..CovidDeaths
WHERE Location like '%States%'
ORDER BY 1,2


---Looking at total cases vs Population
---shows what percentage of population got covid

SELECT Location,date, Population,total_cases, (total_cases/Population)*100 as PercentPopulationInfected
FROM Covid_DB..CovidDeaths
WHERE Location like '%States%'
ORDER BY 1,2


---Looking at Countries with highest Infection rate compared to Population

SELECT Location, Population,MAX(total_cases) As highestInfectionCount, MAX( (total_cases/Population))*100 as PercentPopulationInfected
FROM Covid_DB..CovidDeaths
GROUP BY Location, Population
ORDER BY PercentPopulationInfected DESC

---Showing Countries with highest Deaths count per Population

SELECT Location, MAX(cast (total_deaths As int)) As TotalDeathCount
FROM Covid_DB..CovidDeaths
WHERE continent is not null
GROUP BY Location
ORDER BY TotalDeathCount DESC


---Let's break things down by continent

---Showing Continents with the highest death count per population


SELECT Continent, MAX(cast (total_deaths As int)) As TotalDeathCount
FROM Covid_DB..CovidDeaths
WHERE continent is not null
GROUP BY continent
ORDER BY TotalDeathCount DESC


---Global Numbers


SELECT  SUM(new_cases) As totalcases, SUM(cast(new_deaths as int)) as totaldeaths, SUM(cast(new_deaths as int))/SUM (new_cases) *100 as Deathpercentage
FROM Covid_DB..CovidDeaths
WHERE continent is not null
ORDER BY 1,2

---total population vs vaccinations by using Joins

SELECT death.continent, death.location, death.date, death.population, vaccine. new_vaccinations FROM Covid_DB..CovidDeaths death
JOIN  Covid_DB..CovidVaccinations vaccine
ON death.location = vaccine.location
and death.date = vaccine.date
WHERE death.continent IS NOT NULL
ORDER BY 1,2,3



SELECT death.continent, death.location, death.date, death.population, vaccine. new_vaccinations, 
SUM(CONVERT(int, vaccine.new_vaccinations)) over (Partition by death.location ORDER BY death.location, death.date) as rollingpeoplevaccinated
FROM Covid_DB..CovidDeaths death
JOIN  Covid_DB..CovidVaccinations vaccine
ON death.location = vaccine.location
and death.date = vaccine.date
WHERE death.continent IS NOT NULL
ORDER BY 1,2,3

---USE CTE

WITH popvsvac (Continent, Location, date,population, new_vaccinations, rollingpeoplevaccinated)
as 
(
SELECT death.continent, death.location, death.date, death.population, vaccine. new_vaccinations, 
SUM(CONVERT(int, vaccine.new_vaccinations)) over (Partition by death.location ORDER BY death.location, death.date) as rollingpeoplevaccinated
FROM Covid_DB..CovidDeaths death
JOIN  Covid_DB..CovidVaccinations vaccine
ON death.location = vaccine.location
and death.date = vaccine.date
WHERE death.continent IS NOT NULL

)
SELECT * FROM popvsvac

---TEMP TABLE

Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date Datetime,
Population Numeric,
New_Vaccinations Numeric,
rollingpeoplevaccinated Numeric
)

Insert into #PercentPopulationVaccinated
SELECT death.continent, death.location, death.date, death.population, vaccine. new_vaccinations, 
SUM(CONVERT(int, vaccine.new_vaccinations)) over (Partition by death.location ORDER BY death.location, death.date) as rollingpeoplevaccinated
FROM Covid_DB..CovidDeaths death
JOIN  Covid_DB..CovidVaccinations vaccine
ON death.location = vaccine.location
and death.date = vaccine.date
WHERE death.continent IS NOT NULL

DROP Table if exists #PercentPopulationVaccinated


---Create View 

Create view PercentPopulationVaccinated as
SELECT death.continent, death.location, death.date, death.population, vaccine. new_vaccinations, 
SUM(CONVERT(int, vaccine.new_vaccinations)) over (Partition by death.location ORDER BY death.location, death.date) as rollingpeoplevaccinated
FROM Covid_DB..CovidDeaths death
JOIN  Covid_DB..CovidVaccinations vaccine
ON death.location = vaccine.location
and death.date = vaccine.date
WHERE death.continent IS NOT NULL


SELECT * FROM PercentPopulationVaccinated