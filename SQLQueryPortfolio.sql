--select *
--from PortfolioProject..CovidDeaths$
--order by 3,4

--select *
--from PortfolioProject..CovidVaccinations$
--order by 3,4

-- Select data that we are going to use

Select location, location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..CovidDeaths$
 where continent is not null
order by 1,2

-- Looking at total cases vs total deaths
-- shows the likelihood if you contract covid in your country

Select location, location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths$
where location like '%nigeria%'
order by 1,2

-- Looking at total cases vs Population
-- WHat percentae of population got covid

Select location, date, population, total_cases, (total_cases/population)*100 as CovidPercentage
from PortfolioProject..CovidDeaths$
where location like '%nigeria%' and continent is not null
order by 1,2

-- Looiking at countries with the highest infection rate compared to the population

Select location, continent, population, max(total_cases) as HighestInfectionCount, max(total_cases/population)*100 as InfectedPercentage
from PortfolioProject..CovidDeaths$
-- where location like '%nigeria%'
where continent is not null
group by location, continent, population
order by InfectedPercentage desc

-- Looking at countries with the highest death count per population

Select location, continent, max(cast(total_deaths as int)) as HighestDeathCount
from PortfolioProject..CovidDeaths$
-- where location like '%nigeria%'
where continent is not null
group by location, continent, population
order by HighestDeathCount desc

--BREAKING THINGS DOWN BY CONTINENT
-- Looking at continents with the highest death count per population

Select continent, max(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths$
-- where location like '%nigeria%'
where continent is not null
group by continent
order by TotalDeathCount desc


-- Global Numbers

Select date, SUM(new_cases) as TotalCases, SUM(cast(new_deaths as int)) as TotalDeaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths$
-- where location like '%nigeria%'
where continent is not null
group by date
order by 1,2

-- Total Cases vs Total Deaths vs DeathPercentage

Select SUM(new_cases) as TotalCases, SUM(cast(new_deaths as int)) as TotalDeaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths$
-- where location like '%nigeria%'
where continent is not null
--group by date
order by 1,2


-- Looking at total population vs vaccination

select distinct dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(bigint, vac.new_vaccinations)) over (partition by dea.location order by dea.date, dea.location) as TotalVaccinations --(TotalVaccinations/population)*100
from PortfolioProject..CovidDeaths$ dea
join PortfolioProject..CovidVaccinations$ vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
group by dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
order by 2,3


-- USE CTE

with PopvsVac (continent, Location, Date, Population, new_vaccinations, TotalVaccinations)
as
(
select distinct dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(bigint, vac.new_vaccinations)) over (partition by dea.location order by dea.date, dea.location) as TotalVaccinations --(TotalVaccinations/population)*100
from PortfolioProject..CovidDeaths$ dea
join PortfolioProject..CovidVaccinations$ vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
group by dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
--order by 2,3
)
select *, (TotalVaccinations/population)*100 as PercentagePopulationVac
from PopvsVac

-- TEMP TABLE

drop table if exists #PercentagePopulationVac
create table #PercentagePopulationVac
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
TotalVaccinations numeric
)
insert into #PercentagePopulationVac

select distinct dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(bigint, vac.new_vaccinations)) over (partition by dea.location order by dea.date, dea.location) as TotalVaccinations --(TotalVaccinations/population)*100
from PortfolioProject..CovidDeaths$ dea
join PortfolioProject..CovidVaccinations$ vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
group by dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
--order by 2,3

select *, (TotalVaccinations/Population)*100 as PercPopVac
from #PercentagePopulationVac

--Creating Views to store data for later viz
create View PerPopVac as
select distinct dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(bigint, vac.new_vaccinations)) over (partition by dea.location order by dea.date, dea.location) as TotalVaccinations --(TotalVaccinations/population)*100
from PortfolioProject..CovidDeaths$ dea
join PortfolioProject..CovidVaccinations$ vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
group by dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations

select *
from PerPopVac