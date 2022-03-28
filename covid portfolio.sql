select  * 
From DataVizPortfolioProject..['covid-deaths$']
order by 3,4

select  * 
From DataVizPortfolioProject..['covid-vaccination$']
order by 3,4

--select data that we going to be using
select location, date, total_cases, new_cases, total_deaths,population
From DataVizPortfolioProject..['covid-deaths$']
order by 1,2

-- look at total cases vs total deaths
-- shows likelihood of dying from contracting covid in Sri Lanka
select location, date, total_cases, total_deaths, (total_deaths / total_cases)*100 as deathPercentage
From DataVizPortfolioProject..['covid-deaths$']
where location like '%lanka%'
order by 1,2

-- look at total cases vs population
-- shows what percentage of population got covid
select location, date, total_cases, population, (total_cases / population)*100 as totalCasePercentage
From DataVizPortfolioProject..['covid-deaths$']
where location like '%lanka%'
order by 1,2

-- look at countries with highest infection rate compared to population
select location,population, Max(total_cases) as highestInfectionCount, Max((total_cases / population))*100 as totalCasePercentage
From DataVizPortfolioProject..['covid-deaths$']
group by location, population
order by totalCasePercentage desc

-- show countries with highest death count per population
select location, Max(cast(total_deaths as int)) as highestTotalDeathCount
From DataVizPortfolioProject..['covid-deaths$']
where continent is not null
group by location
order by highestTotalDeathCount desc

-- Global numbers
select sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths,  (sum(cast(new_deaths as int)) / sum(new_cases))*100 as deathPercentage
From DataVizPortfolioProject..['covid-deaths$']
where continent is not null
-- group by date
order by 1,2

-- look at total population vs vaccination
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	sum(convert(int, vac.new_vaccinations)) over (partition by dea.location, dea.date 
	order by dea.location ,dea.date) as rollingPeopleVaccinated
From DataVizPortfolioProject..['covid-deaths$'] dea
join DataVizPortfolioProject..['Covid-vaccination$'] vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3

--Use CTE
with PopvsVac (continent, location, date, population, new_vaccinations, rollingPeopleVaccinated)
as(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	sum(convert(int, vac.new_vaccinations)) over (partition by dea.location,dea.date 
	order by dea.location ,dea.date) as rollingPeopleVaccinated
From DataVizPortfolioProject..['covid-deaths$'] dea
join DataVizPortfolioProject..['Covid-vaccination$'] vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
-- order by 2,3
)
select *, (rollingPeopleVaccinated/population)*100
from PopvsVac

--temp table
drop table if exists #PercentPopulationVaccinated -- drop if needed
create table #PercentPopulationVaccinated(
	continent nvarchar(255),
	location nvarchar(255),
	date datetime,
	population numeric,
	new_vaccinations numeric,
	rollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	sum(convert(int, vac.new_vaccinations)) over (partition by dea.location, dea.date 
	order by dea.location ,dea.date) as rollingPeopleVaccinated
From DataVizPortfolioProject..['covid-deaths$'] dea
join DataVizPortfolioProject..['Covid-vaccination$'] vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null	

select *, (rollingPeopleVaccinated/population)*100
from #PercentPopulationVaccinated

PRINT 'Creating Player View'
GO

-- create view to store data for later visualizaions
drop view if exists PercentPopulationVaccinated -- drop if needed

Create View PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	sum(convert(int, vac.new_vaccinations)) over (partition by dea.location, dea.date 
	order by dea.location ,dea.date) as rollingPeopleVaccinated
From DataVizPortfolioProject..['covid-deaths$'] dea
join DataVizPortfolioProject..['Covid-vaccination$'] vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null

Create View PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	sum(convert(int, vac.new_vaccinations)) over (partition by dea.location, dea.date 
	order by dea.location ,dea.date) as rollingPeopleVaccinated
From DataVizPortfolioProject..['covid-deaths$'] dea
join DataVizPortfolioProject..['Covid-vaccination$'] vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null

-- work table
select * 
from PercentPopulationVaccinated

-- 1.

select sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths,  (sum(cast(new_deaths as int)) / sum(new_cases))*100 as deathPercentage
From DataVizPortfolioProject..['covid-deaths$']
where continent is not null
-- group by date
order by 1,2

-- 2. 

-- We take these out as they are not inluded in the above queries and want to stay consistent

Select location, SUM(cast(new_deaths as int)) as TotalDeathCount
From DataVizPortfolioProject..['covid-deaths$']
--Where location like '%states%'
Where continent is null 
and location not in ('World', 'European Union', 'International','High Income','Upper middle income','Low income','Lower middle income')
Group by location
order by TotalDeathCount desc


-- 3.

Select Location, Population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From DataVizPortfolioProject..['covid-deaths$']
--Where location like '%states%'
Group by Location, Population
order by PercentPopulationInfected desc

-- 4.


Select Location, Population,date, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From DataVizPortfolioProject..['covid-deaths$']
--Where location like '%states%'
Group by Location, Population, date
order by PercentPopulationInfected desc