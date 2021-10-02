Select *
From CovidDeaths
Order by 3,4
 
Select *
From CovidVaccin
Order by 3,4

Select location, date, total_cases, new_cases, total_deaths, population
From CovidDeaths
order by 1,2

--Looking total cases and total deaths
--show likelihood of dying if you contract covid in your country
Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From CovidDeaths
Where location like '%viet%'
order by 1,2

Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From CovidDeaths
Where location like '%china%'
order by 1,2

Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From CovidDeaths
Where location like '%state%'
order by 1,2

-- looking total cases vs population
--show what percentage of population get covid
Select location, date, total_cases, population, (total_cases/population)*100 as populationPercentage
From CovidDeaths
Where location like '%viet%'
order by 1,2

Select location, date, total_cases, population, (total_cases/population)*100 as populationPercentage
From CovidDeaths
--Where location like '%state%'
order by 1,2

--looking at country with highest inflection rate compared to population
Select location, population, Max(total_cases) as Highest_Case, Max((total_cases/population))*100 as PercenPopulationInflected
From CovidDeaths
Group by location, population
order by PercenPopulationInflected desc

--Showing country with highest death count per country
Select location, population, Max(total_deaths) as Total_Deaths, Max((total_deaths/population))*100 as PercenPopulationDeath
From CovidDeaths
Group by location, population
order by PercenPopulationDeath desc

--Let's break things down by continent
Select location, Max(cast(total_deaths as int)) as TotalDeathsCount
From CovidDeaths
Where continent is null
Group By location
Order by TotalDeathsCount desc

--Global
Select date, Sum(new_cases) as Total_Case, Sum(cast(new_deaths as int)) as Total_Deaths, Sum(cast(new_deaths as int))/Sum(new_cases)*100 as PercentDeaths
From CovidDeaths
Where continent is not null
Group by date
Order by 1,2


--Check Covid Vaccin
Select * 
From CovidVaccin

--Join 2 tables
--Looking at total population and vaccination
Select vac.continent, vac.location, vac.date, vac.population, vac.new_vaccinations,
Sum(cast(vac.new_vaccinations as int)) over (partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
From CovidDeaths dea
Join CovidVaccin vac
	on dea.location= vac.location
	and dea.date = vac.date
Where vac.continent is not null
Order by 2,3

--Use CTE
With PopvsVac (Continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
Select vac.continent, vac.location, vac.date, vac.population, vac.new_vaccinations,
Sum(cast(vac.new_vaccinations as int)) over (partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
From CovidDeaths dea
Join CovidVaccin vac
	on dea.location= vac.location
	and dea.date = vac.date
Where vac.continent is not null
--Order by 2,3
)
Select *, (RollingPeopleVaccinated/population)* 100
From PopvsVac
Where location like '%viet%'

--Use temp table 
Drop table if exists #PercentPopulationVaccinated
Create table #PercentPopulationVaccinated
(
Continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select vac.continent, vac.location, vac.date, vac.population, vac.new_vaccinations,
Sum(cast(vac.new_vaccinations as int)) over (partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
From CovidDeaths dea
Join CovidVaccin vac
	on dea.location= vac.location
	and dea.date = vac.date
Where vac.continent is not null
--Order by 2,3

Select *, (RollingPeopleVaccinated/population)* 100
From #PercentPopulationVaccinated

--Create view to store data for later visualizations

Create view PercentPopulationVaccinated as 
Select vac.continent, vac.location, vac.date, vac.population, vac.new_vaccinations,
Sum(cast(vac.new_vaccinations as int)) over (partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
From CovidDeaths dea
Join CovidVaccin vac
	on dea.location= vac.location
	and dea.date = vac.date
Where vac.continent is not null
--Order by 2,3

Select * 
From PercentPopulationVaccinated