Select *
From PortfolioProject.dbo.CovidDeaths
order by 3,4

--Select *
--From PortfolioProject.dbo.CovidVaccinations
--order by 3,4

-- Select the data that we are going to be using

SELECT location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..CovidDeaths
Order by 1,2

-- Looking at total cases vs total deaths
-- Shows the mortality rate if you contract covid in pakistan(country)
SELECT location, date, total_cases,total_deaths,(total_deaths/total_cases)*100 AS deathpercentage
from PortfolioProject..CovidDeaths
Where location like '%Pak%'
Order by 1,2

-- looking at total cases vs population
-- shows what percentage of population got covid
SELECT location, date, total_cases,population,(total_cases/population)*100 AS Populationpercentage
from PortfolioProject..CovidDeaths
Where location like '%Pak%'
Order by 1,2

-- looking at countries with highest infection rate compared to population
SELECT location, population, Max(total_cases)as HighestInfectionCount,Max((total_cases/population))*100 AS PercentagePopulationInfected
from PortfolioProject..CovidDeaths
--Where location like '%Pak%'
Group by location,population
Order by PercentagePopulationInfected desc


--showing Countries with highest death count per population
SELECT location, Max(Cast(total_deaths as int)) as totaldeathcount
from PortfolioProject..CovidDeaths
--Where location like '%Pak%'
where continent is not null
Group by location
Order by totaldeathcount desc

--LETS BREAK THING DOWN BY CONTINENT

SELECT location, Max(Cast(total_deaths as int)) as totaldeathcount
from PortfolioProject..CovidDeaths
--Where location like '%Pak%'
where continent is  null
Group by location
Order by totaldeathcount desc

-- Right query but wrong result. above query works better than this following one.
SELECT continent, Max(Cast(total_deaths as int)) as totaldeathcount
from PortfolioProject..CovidDeaths
--Where location like '%Pak%'
where continent is not null
Group by continent
Order by totaldeathcount desc

-- Showing continents with the highest death count per population

SELECT continent, Max(Cast(total_deaths as int)) as totaldeathcount
from PortfolioProject..CovidDeaths
--Where location like '%Pak%'
where continent is not null
Group by continent
Order by totaldeathcount desc

-- Global numbers
SELECT Sum(new_cases) as total_cases, Sum(cast(new_deaths as int)) as total_deaths,
sum(cast(new_deaths as int))/sum(new_cases)*100 as deathpercentage
from PortfolioProject..CovidDeaths
--Where location like '%Pak%'
where continent is not null
Order by 1,2

-- Global numbers Datewise
Select date,sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as totaldeaths,
sum(cast(new_deaths as int))/sum(new_cases)*100 as deathpercentage
from PortfolioProject..CovidDeaths
where continent is not null
Group by date
order by 1,2

-- join
Select *
From PortfolioProject..CovidDeaths As dea
Join PortfolioProject..CovidVaccinations As vac
  On dea.location = vac.location
  and dea.date = vac.date

--looking at total population vs vaccinations
Select dea.continent, dea.location, dea.date,dea.population,vac.new_vaccinations
From PortfolioProject..CovidDeaths As dea
Join PortfolioProject..CovidVaccinations As vac
  On dea.location = vac.location
  and dea.date = vac.date
Where dea.continent is not null
order by dea.location,dea.date

--Rolling Vaccination count
Select dea.continent, dea.location, dea.date,dea.population,vac.new_vaccinations
,Sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location,dea.date) AS RollingVaccinationcount
From PortfolioProject..CovidDeaths As dea
Join PortfolioProject..CovidVaccinations As vac
  On dea.location = vac.location
  and dea.date = vac.date
Where dea.continent is not null
order by dea.location,dea.date

--Use CTE 
with popvsvac (continent, location, date, population, new_vaccinations, RollingVaccinationcount)
as
(
Select dea.continent, dea.location, dea.date,dea.population,vac.new_vaccinations
,Sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location,dea.date) AS RollingVaccinationcount
From PortfolioProject..CovidDeaths As dea
Join PortfolioProject..CovidVaccinations As vac
  On dea.location = vac.location
  and dea.date = vac.date
Where dea.continent is not null
--order by dea.location,dea.date
)
Select *,(RollingVaccinationcount/population)*100 AS totalpercentageVaccinated
From popvsvac

-- USE Temp table
Drop table if Exists #percentpopulationvaccinated
Create Table #percentpopulationvaccinated
(
Continent nvarchar(255),
location nvarchar(255),
Date datetime,
population numeric,
new_vaccinations numeric,
RollingVaccinationcount numeric
)
Insert Into #percentpopulationvaccinated
Select dea.continent, dea.location, dea.date,dea.population,vac.new_vaccinations
,Sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location,dea.date) AS RollingVaccinationcount
From PortfolioProject..CovidDeaths As dea
Join PortfolioProject..CovidVaccinations As vac
  On dea.location = vac.location
  and dea.date = vac.date
Where dea.continent is not null
--order by dea.location,dea.date

Select *,(RollingVaccinationcount/population)*100 AS totalpercentageVaccinated
From #percentpopulationvaccinated

-- Creating view to store data for later visualizations
Create View percentpopulationvaccinated As
Select dea.continent, dea.location, dea.date,dea.population,vac.new_vaccinations
,Sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location,dea.date) AS RollingVaccinationcount
From PortfolioProject..CovidDeaths As dea
Join PortfolioProject..CovidVaccinations As vac
  On dea.location = vac.location
  and dea.date = vac.date
Where dea.continent is not null
--order by dea.location,dea.date

Select *
From percentpopulationvaccinated