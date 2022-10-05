Select *
From PortfolioProject..CovidDeaths
Where continent is not null 
Order by 3,4

--Select *
--From PortfolioProject..CovidVaccinations
--Order by 3,4

--Select data that we are going to be using 

Select Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
Where continent is not null 
Order by 1,2

-- Looking at total cases vs total deaths in the US 

Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage 
From PortfolioProject..CovidDeaths
Where continent is not null 
	and location like '%states%'
Order by 1,2

-- Looking at total cases vs population 
-- Shows what percentage of the population got Covid

Select Location, date, total_cases, population, (total_cases/population)*100 as PopulationInfectedPercentage 
From PortfolioProject..CovidDeaths
Where continent is not null 
	--and location like '%states%'
Order by 1,2

-- Looking at countries with Highest Infection Rate compared to Population  

Select Location, population, MAX(total_cases) as HighestInfectionCount, Max((total_cases/population))*100 as PopulationInfectedPercentage
From PortfolioProject..CovidDeaths
Where continent is not null 
	--and location like '%states%'
Group by Population, Location 
Order by PopulationInfectedPercentage desc

-- Showing the countries with the highest death count per population 

Select Location, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
Where continent is not null
	--and location like '%states%'
Group by Location 
Order by TotalDeathCount desc

-- BREAK DOWN BY CONTINENT 

-- Showing continents with the highest death count per population 

Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
Where continent is not null
	--and location like '%states%'
Group by continent
Order by TotalDeathCount desc

-- Global Numbers 

Select SUM(new_cases) as TotalCases, SUM(cast(new_deaths as int)) as TotalDeaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage 
From PortfolioProject..CovidDeaths
Where continent is not null 
	-- and location like '%states%'
--Group By date 
Order by 1,2

--Global Numbers by Date 

Select date, SUM(new_cases) as TotalCases, SUM(cast(new_deaths as int)) as TotalDeaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage 
From PortfolioProject..CovidDeaths
Where continent is not null -- and location like '%states%'
Group by date 
Order by 1,2

-- Total Vaccination vs Population 

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location
, dea.date) as RollingPeopleVaccinated
-- , (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac 
	On dea.location = vac.location 
	and dea.date = vac.date
Where dea.continent is not null
	and vac.new_vaccinations is not null 
Order by 2,3

--USE CTE

With PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
As
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location
, dea.date) as RollingPeopleVaccinated
-- , (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac 
	On dea.location = vac.location 
	and dea.date = vac.date
Where dea.continent is not null
	and vac.new_vaccinations is not null
--Order by 2,3
)
Select *, (RollingPeopleVaccinated/population)*100
From PopvsVac

-- TEMP TABLE 

Drop Table if exists #PercentPopulationVaccinated 
Create Table #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location
, dea.date) as RollingPeopleVaccinated
-- , (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac 
	On dea.location = vac.location 
	and dea.date = vac.date
Where dea.continent is not null
	and vac.new_vaccinations is not null
--Order by 2,3

Select *, (RollingPeopleVaccinated/population)*100
From #PercentPopulationVaccinated

-- Creating view to store for later visualizations

Drop View if exists PercentPopulationVaccinated
Go
Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location
, dea.date) as RollingPeopleVaccinated
-- , (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac 
	On dea.location = vac.location 
	and dea.date = vac.date
Where dea.continent is not null
	and vac.new_vaccinations is not null
--Order by 2,3


Select *
From PercentPopulationVaccinated