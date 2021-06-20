--Followed Alex the Analyst tutorials at https://www.youtube.com/watch?v=qfyynHBFOsM--
--Queries--
select * from CovidDeaths

SELECT Location, date,total_cases,total_deaths,(total_deaths/total_cases)*100 as deathpercentage
FROM CovidDeaths
WHERE location like '%India%'
ORDER BY 1,2

---Looking at total cases vs total deaths
---Likelihood of dying if you contract covid in your country
SELECT Location, date,total_cases,total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
FROM CovidDeaths
WHERE location like '%India%'
ORDER BY 1,2

---Total cases vs population
---What percentage of population got COVID
SELECT Location, date,population,total_cases,(total_cases/population)*100 as PercentPopulationInfected
FROM CovidDeaths
WHERE location like '%India%'
ORDER BY 1,2

---Look up countries with the highest infection rate compared to population
SELECT Location,population,max(total_cases) as HighestInfectionCount,Max((total_cases/population))*100 as PercentPopulationInfected
FROM CovidDeaths
GROUP BY Location,population
--WHERE location like '%India%'
ORDER BY PercentPopulationInfected desc

---Showing coyuntries with the highest death count per population
SELECT location,MAX(cast(total_deaths as int)) as TotalDeathCount
FROM CovidDeaths
WHERE continent is null
GROUP BY location
ORDER BY TotalDeathCount desc

--showing the continents with highest death count

SELECT continent,MAX(cast(total_deaths as int)) as TotalDeathCount
FROM CovidDeaths
WHERE continent is not null
GROUP BY continent
ORDER BY TotalDeathCount desc

--GLOBAL NUMBERS

SELECT sum(new_cases) as totalcases,sum(cast(new_deaths as int)) as totaldeaths,(sum(cast(new_deaths as int))/sum(new_cases)*100) as DeathPercentage
FROM CovidDeaths
WHERE continent is not null
--GROUP BY date
ORDER BY 1,2

SELECT date,sum(new_cases) as totalcases,sum(cast(new_deaths as int)) as totaldeaths,(sum(cast(new_deaths as int))/sum(new_cases)*100) as DeathPercentage
FROM CovidDeaths
WHERE continent is not null
GROUP BY date
ORDER BY 1,2

---COVID VACCINATIONS
select * from CovidVaccinations

---Looking at total population vs vaccination--Number of people vaccinated
SELECT cd.continent,cd.location,cd.date,cd.population, cv.new_vaccinations
,SUM(CONVERT(int,cv.new_vaccinations)) OVER(Partition by cd.location ORDER BY cd.Location,cd.date) as RollingPeopleVaccinated
FROM CovidDeaths cd JOIN CovidVaccinations cv
ON cd.location = cv.location AND
cd.date = cv.date
WHERE cd.continent is not null
ORDER BY 1,2,3

--USING CTE
WITH POPvsVAC (Continent,Location,Date,Population,New_vaccinations,RollingPeopleVaccinated)
as
(
SELECT cd.continent,cd.location,cd.date,cd.population, cv.new_vaccinations
,SUM(CONVERT(int,cv.new_vaccinations)) OVER(Partition by cd.location ORDER BY cd.Location,cd.date) as RollingPeopleVaccinated
FROM CovidDeaths cd JOIN CovidVaccinations cv
ON cd.location = cv.location AND
cd.date = cv.date
WHERE cd.continent is not null
--ORDER BY 1,2,3
)
SELECT *,(RollingPeopleVaccinated/population)*100 from POPvsVAC


--CREATING VIEWS
CREATE VIEW PercentPopulationVaccinated as
SELECT cd.continent,cd.location,cd.date,cd.population, cv.new_vaccinations
,SUM(CONVERT(int,cv.new_vaccinations)) OVER(Partition by cd.location ORDER BY cd.Location,cd.date) as RollingPeopleVaccinated
FROM CovidDeaths cd JOIN CovidVaccinations cv
ON cd.location = cv.location AND
cd.date = cv.date
WHERE cd.continent is not null
--ORDER BY 2,3