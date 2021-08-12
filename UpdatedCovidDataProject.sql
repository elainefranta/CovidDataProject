Select *
From CovidDataProjectUpdated..CovidDeathsUpdated
Where continent is not null
order by 3,4

--Select *
--From CovidDataProjectUpdated..CovidVaccinationsUpdated
--order by 3,4


--Select Data that we are going to be using

Select Location, date, total_cases, new_cases, total_deaths, population
From CovidDataProjectUpdated..CovidDeathsUpdated
order by 1,2


--Looking at Total Cases vs Total Deaths
--Shows likelihood of dying if you contract covid in your country
Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From CovidDataProjectUpdated..CovidDeathsUpdated
--Where location like '%states%'
order by 1,2


--Looking at the Total Cases vs Population
--Shows percentage of population got covid
Select Location, date, total_cases, population, (total_cases/population)*100 as CasesPercentage
From CovidDataProjectUpdated..CovidDeathsUpdated
--Where location like '%states%'
order by 1,2


--Looking at countries with highest infection rate compared to population
Select Location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
From CovidDataProjectUpdated..CovidDeathsUpdated
--Where location like '%states%'
Group by Location, Population
order by PercentPopulationInfected DESC

--Showing the countries with the highest death count per Population

Select Location, MAX(cast(total_deaths as int)) as TotalDeathCount
From CovidDataProjectUpdated..CovidDeathsUpdated
--Where location like '%states%'
Where continent is not null
Group by Location
order by TotalDeathCount DESC



--BREAK THINGS DOWN BY CONTINENT

Select Location, MAX(cast(total_deaths as int)) as TotalDeathCount
From CovidDataProjectUpdated..CovidDeathsUpdated
--Where location like '%states%'
Where continent is null
Group by Location
order by TotalDeathCount DESC


--Showing the continents with the highest death count

Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From CovidDataProjectUpdated..CovidDeathsUpdated
--Where location like '%states%'
Where continent is not null
Group by continent
order by TotalDeathCount DESC


-- GLOBAL NUMBERS

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, (SUM(cast(new_deaths as int))/SUM(new_cases))*100 as DeathPercentage
From CovidDataProjectUpdated..CovidDeathsUpdated
--Where location like '%states%'
Where continent is not null
--Group By date
order by 1,2


Select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, (SUM(cast(new_deaths as int))/SUM(new_cases))*100 as DeathPercentage
From CovidDataProjectUpdated..CovidDeathsUpdated
--Where location like '%states%'
Where continent is not null
Group By date
order by 1,2



--Looking at Total Population vs Vaccinations 

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From CovidDataProjectUpdated..CovidDeathsUpdated dea
Join CovidDataProjectUpdated..CovidVaccinationsUpdated vac
	On dea.location = vac.location
	and dea.date=vac.date
where dea.continent is not null
order by 2,3 



--USE CTE

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as 
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From CovidDataProjectUpdated..CovidDeathsUpdated dea
Join CovidDataProjectUpdated..CovidVaccinationsUpdated vac
	On dea.location = vac.location
	and dea.date=vac.date
where dea.continent is not null
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac



--TEMP TABLE

Drop Table if exists #PercentPopulationVaccinated
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
From CovidDataProjectUpdated..CovidDeathsUpdated dea
Join CovidDataProjectUpdated..CovidVaccinationsUpdated vac
	On dea.location = vac.location
	and dea.date=vac.date
where dea.continent is not null

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated



--CREATING VIEW TO STORE DATA FOR LATER VISUALIZATIONS


Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From CovidDataProjectUpdated..CovidDeathsUpdated dea
Join CovidDataProjectUpdated..CovidVaccinationsUpdated vac
	On dea.location = vac.location
	and dea.date=vac.date
where dea.continent is not null

Select *
From PercentPopulationVaccinated