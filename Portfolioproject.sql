/* Covid19 Data Exploration

Skills Used: Joins, CTE's, Temp Table, Windows Functioins, Converting Data Types
*/


select *
from PortfolioProject.dbo.coviddeaths
order by 3,4


--select *
--from PortfolioProject.dbo.covidvaccinations
--order by 3,4


--Selects Required Data


select location, date, total_cases, new_cases, new_deaths, population
from PortfolioProject.dbo.coviddeaths
order by 1,2


--Total Cases vs Total Deaths

--Percantage of dying if you contract Covid19 In your country

select location, date, total_cases, total_deaths, (convert(decimal,total_deaths)/nullif(convert(decimal,total_cases),0))*100  as DeathPercentage
from PortfolioProject.dbo.coviddeaths
where location like 'Nigeria'
order by 1,2

--Total Cases Vs Population

--Shows what percentage of the population contracted Covid19

select location, date, population, total_cases, (total_cases/population)*100  as PercentofPopulationInfected
from PortfolioProject.dbo.coviddeaths
where location like 'Nigeria'
order by 1,2

--Looking at countries with Highest Infection Rate Vs Population

select location, population, Max(total_cases) as HighestInfectionCount, max((total_cases/population))*100  as PercentofPopulationInfected
from PortfolioProject.dbo.coviddeaths
group by location, population
order by PercentofPopulationInfected desc

-- Showing Countries With Highest Death Count per Population

select location, Max(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject.dbo.coviddeaths
where continent is  not null
group by location
order by TotalDeathCount desc

--Break down by Continent

-- Showing Continents with the Highest Death Count per Population


select continent, Max(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject.dbo.coviddeaths
where continent is  not null
group by continent
order by TotalDeathCount desc

--Total Population Vs Total Vaccination 

-- Shows percentage of Population that has received at least one Covid Vaccine

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(cast(vac.new_vaccinations as bigint)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject.dbo.Coviddeaths dea
join PortfolioProject.dbo.Covidvaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by 1,2,3

--Using CTE to perform calculation on Partition By in previous query

with PopvsVac (continent, location, date, population, new_vaccination, RollingPeopleVaccinated)
as
(

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(cast(vac.new_vaccinations as bigint)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject.dbo.Coviddeaths dea
join PortfolioProject.dbo.Covidvaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
)
select *, ( RollingPeopleVaccinated/population)*100
from PopvsVac


-- Using Temp Table to perform calculation on Partition By in previous query

Drop table if exists #PopPercentageTable 
create table #PopPercentageTable 
(
Continent nvarchar (255),
Location nvarchar (255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)

insert into #PopPercentageTable
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(cast(vac.new_vaccinations as bigint)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject.dbo.Coviddeaths dea
join PortfolioProject.dbo.Covidvaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null


select *, ( RollingPeopleVaccinated/population)*100 as RollingPercentage
from #PopPercentageTable
 
 