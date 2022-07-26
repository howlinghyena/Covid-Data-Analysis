select * 
from portfolioproject..covid_deaths
Where continent is not null
order by 3,4


--select * 
--from portfolioproject..covid_vax
--order by 3,4



Select Location, date, total_cases, new_cases, total_deaths, population
from portfolioproject..covid_deaths
Where continent is not null
order by 1,2

--Looking at total cases vs total deaths
-- shows what percent of pop. got covid

Select Location, MAX(total_cases) as HighestInfectionCount, population, MAX((total_cases/population))*100 as PercentPopulationInfected  
from portfolioproject..covid_deaths
Where continent is not null
--Where location like '%states%'
Group by Location, population
order by PercentPopulationInfected desc


--showing countires with highest death count per population

Select Location, MAX(cast(total_deaths as int)) as TotalDeathCount
from portfolioproject..covid_deaths
Where continent is not null
--Where location like '%states%'
Group by Location
order by TotalDeathCount desc


--breakdown by continent

Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
from portfolioproject..covid_deaths
Where continent is not null
--Where location like '%states%'
Group by continent
order by TotalDeathCount desc


--global numbers

Select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From PortfolioProject..covid_deaths
--Where Location like '%states%'
where continent is not null
Group By date
order by 1,2


--looking at total pop. vs vaccination
Select death.continent, death.location , death.date, death.population, vax.new_vaccinations, 
SUM(Convert(bigint,vax.new_vaccinations)) Over (Partition by death.location Order by death.location, death.date ROWS UNBOUNDED PRECEDING) as RollingPeopleVaccinated
From portfolioproject..covid_deaths death
Join portfolioproject..covid_vax vax
	On death.location = vax.location
	and death.date = vax.date
order by 2,3


--use CTE
with PopvsVax (Continent, Location, Date, Population,New_Vaccinations, RollingPeopleVaccinated)
as 
(
Select death.continent, death.location , death.date, death.population, vax.new_vaccinations, 
SUM(Convert(bigint,vax.new_vaccinations)) Over (Partition by death.location Order by death.location, death.date ROWS UNBOUNDED PRECEDING) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From portfolioproject..covid_deaths death
Join portfolioproject..covid_vax vax
	On death.location = vax.location
	and death.date = vax.date
Where death.continent is not null
--order by 2,3
)
Select *,(RollingPeopleVaccinated/Population)*100
From PopvsVax


--Temp Table

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
Select death.continent, death.location , death.date, death.population, vax.new_vaccinations, 
SUM(Convert(bigint,vax.new_vaccinations)) Over (Partition by death.location Order by death.location, death.date ROWS UNBOUNDED PRECEDING) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From portfolioproject..covid_deaths death
Join portfolioproject..covid_vax vax
	On death.location = vax.location
	and death.date = vax.date
Where death.continent is not null
--order by 2,3

Select *,(RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated



--creating view to store data for future visualizations

Create View PercentPopulationVaccinated as
Select death.continent, death.location , death.date, death.population, vax.new_vaccinations, 
SUM(Convert(bigint,vax.new_vaccinations)) Over (Partition by death.location Order by death.location, death.date ROWS UNBOUNDED PRECEDING) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From portfolioproject..covid_deaths death
Join portfolioproject..covid_vax vax
	On death.location = vax.location
	and death.date = vax.date
Where death.continent is not null
--order by 2,3


Create View TotalPeopleInfected as
Select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From PortfolioProject..covid_deaths
--Where Location like '%states%'
where continent is not null
Group By date
--order by 1,2


Create View PercentPopulationDead as
Select Location, MAX(cast(total_deaths as int)) as TotalDeathCount
from portfolioproject..covid_deaths
Where continent is not null
--Where location like '%states%'
Group by Location
--order by TotalDeathCount desc
