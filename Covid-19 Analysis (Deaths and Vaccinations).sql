Select *
From [Portfolio Project]..CovidDeaths
Where continent is not null
order by 3,4

--Select *
--From [Portfolio Project]..CovidVaccinations
--order by 3,4

-- Select Data that we are going to be using

Select  Location, date, total_cases, new_cases, total_deaths, population
From [Portfolio Project]..CovidDeaths
Where continent is not null
order by 1,2

-- Looking at Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in the USA
Select  Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From [Portfolio Project]..CovidDeaths
Where location like '%states%'
order by 1,2


-- Looking at Total Cases vs Population
-- Shows what percentage of people in the UK contracted covid
Select  Location, Population, date, total_cases, (total_cases/population)*100 as PercentPopulationInfected
From [Portfolio Project]..CovidDeaths
--Where location like '%kingdom%'
order by 1,2

-- Looking at Countries with Highest Infection Rate compared to Population
Select  Location, Population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
From [Portfolio Project]..CovidDeaths
Group by Location, Population
order by PercentPopulationInfected desc


-- Break things down by Continent


Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From [Portfolio Project]..CovidDeaths
Where continent is not null
Group by continent
order by TotalDeathCount desc


-- Global Numbers

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From [Portfolio Project]..CovidDeaths
where continent is not null
--Group by date
order by 1,2

--Comparing Total Population vs Vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location,
 dea.date) as RollingPeopleVaccinated
 --, (RollingPeopleVaccinated/population)*100
From [Portfolio Project]..CovidDeaths dea
join [Portfolio Project]..CovidVaccinations vac
       On dea.location = vac.location
       and dea.date = vac.date
where dea.continent is not null
order by 2,3


-- USE CTE

with PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location,
 dea.date) as RollingPeopleVaccinated
 --, (RollingPeopleVaccinated/population)*100
From [Portfolio Project]..CovidDeaths dea
join [Portfolio Project]..CovidVaccinations vac
       On dea.location = vac.location
       and dea.date = vac.date
where dea.continent is not null
--order by 2,3
 )
 Select *, (RollingPeopleVaccinated/Population)*100
 From PopvsVac


 -- Temp Table

 DROP TABLE if exists #PercentPopulationVaccinated
 Create Table #PercentPopulationVaccinated
 (
 Continent nvarchar(255),
 Location nvarchar(255),
 Date datetime,
 Population numeric,
 New_Vaccinations numeric,
 RollingPeopleVaccinated numeric
 )

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(BIGINT,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location,
 dea.date) as RollingPeopleVaccinated
 --, (RollingPeopleVaccinated/population)*100
From [Portfolio Project]..CovidDeaths dea
join [Portfolio Project]..CovidVaccinations vac
       On dea.location = vac.location
       and dea.date = vac.date
--where dea.continent is not null
--order by 2,3
 
 Select *, (RollingPeopleVaccinated/Population)*100
 From #PercentPopulationVaccinated


-- Creating View to store data for later visualisations

Create view PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location,
 dea.date) as RollingPeopleVaccinated
 --, (RollingPeopleVaccinated/population)*100
From [Portfolio Project]..CovidDeaths dea
join [Portfolio Project]..CovidVaccinations vac
       On dea.location = vac.location
       and dea.date = vac.date
where dea.continent is not null
--order by 2,3

Select *
From PercentPopulationVaccinated