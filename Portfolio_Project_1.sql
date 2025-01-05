/*
Covid 19 Data Exploration 

Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types

*/

Select *
From CovidDeaths
--Where continent is not null 
order by 3,4


-- Select Data that we are going to be starting with

Select Location, date, total_cases, new_cases, total_deaths, population
From CovidDeaths
Where continent is not null 
order by 1,2


-- Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country

Select Location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From CovidDeaths
Where location like '%states%'
--and continent is not null 
order by 1,2


-- Total Cases vs Population
-- Shows what percentage of population infected with Covid

Select Location, total_cases, Population, (total_cases/Population)*100 as PopulationPercentage
From CovidDeaths
Where Location like '%states%'
order by 1,2


--Looking at Continents with Highest Infection rate 

Select Location, Population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population) * 100) as PercentOfInfectedPopulation
From CovidDeaths
Where continent is null
Group by Location, Population
order by 1,2

--Looking at Countries with Highest Infection rate compared to Population

Select location, Population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/Population) * 100) as PercentOfInfectedPopulation
From CovidDeaths
Where location is not null
Group by location, Population
Order by PercentOfInfectedPopulation desc


--Looking at Countires with Highest Death Count compared to Population

Select Location, Population, MAX(cast (total_deaths as int)) as TotalDeathCount, MAX((total_deaths/Population) * 100) as DeathPercentage
From CovidDeaths
Where Location is not null
Group by location, Population
Order by TotalDeathCount desc


-- GLOBAL NUMBERS

Select SUM(new_cases) as Total_Cases, SUM(cast(new_deaths as int)) as Total_Deaths, (SUM(cast(new_deaths as int)) / SUM(new_cases)) * 100 as DeathPercentage
From CovidDeaths
Where continent is null
--Group by date
Order by 1,2


--Looking at total population vs. total vaciation

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)	
as(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations , 
SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location Order by dea.location ,dea.date) 
as RollingPeopleVaccinated
From CovidDeaths as dea
JOIN CovidVaccinations as vac
ON dea.location = vac.location
and dea.date = vac.date
Where dea.continent is not null
)
Select Continent, Location, Date, Population, New_Vaccinations, (RollingPeopleVaccinated/Population) * 100 as VaccinationPercentage
From PopvsVac
order by 2,3



--using templ table

DROP Table if exists #PercentPopulationVaccinated

Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated


-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 