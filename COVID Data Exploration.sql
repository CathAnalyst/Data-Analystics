---Covid Data Exploration---


--Checking data
Select *
From PortfolioProject..CovidDeaths
where continent is not null
order by location, date

Select *
From PortfolioProject..CovidVaccinations
where continent is not null
order by location, date



--Show Specific Data
Select location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
where continent is not null
order by location, date



--Show Total Cases vs Total Deaths: Likelihood of Dying
Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
where continent is not null
order by location, date



--Show Total Cases vs Population: Percentage of Population Infected
Select location, date, total_cases, population, (total_cases/population)*100 as PercentagePopulationInfected
From PortfolioProject..CovidDeaths
where continent is not null
order by location, date



--Show Countries with Highest Infection Rate vs Population
Select location, population, max(total_cases) as HighestInfectionCount, 
	max((total_cases/population))*100 as PercentagePopulationInfected
From PortfolioProject..CovidDeaths
Where continent is not null
Group by location, population
Order by PercentagePopulationInfected desc



--Show Countries with Highest Death Count
Select location, max(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
Where continent is not null
Group by location
Order by TotalDeathCount desc



--Show Continent with Highest Death Count
Select continent, max(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
Where continent is not null
Group by continent
Order by TotalDeathCount desc



--Show Global Cases and Deaths by Date
Select date, sum(new_cases) as NumberOfCases, sum(cast(new_deaths as int)) as NumberOfDeaths, 
	(sum(cast(new_deaths as int))/sum(new_cases))*100 as PercentageDeathPerCase
From PortfolioProject..CovidDeaths
Where continent is not null
Group by date
Order by date



--Show Total Global Cases and Deaths
Select sum(new_cases) as NumberOfCases, sum(cast(new_deaths as int)) as NumberOfDeaths, 
	(sum(cast(new_deaths as int))/sum(new_cases))*100 as PercentageDeathPerCase
From PortfolioProject..CovidDeaths
Where continent is not null



--Join CovidDeaths and CovidVaccinations Data Table
Select *
From PortfolioProject..CovidDeaths death
Join PortfolioProject..CovidVaccinations vaccine
	On death.location = vaccine.location
	and death.date = vaccine.date
Where death.continent is not null



--Show Total Population vs Total Vaccination per Country per Date
Select death.continent, death.location, death.date, death.population, vaccine.new_vaccinations
From PortfolioProject..CovidDeaths death
Join PortfolioProject..CovidVaccinations vaccine
	On death.location = vaccine.location
	and death.date = vaccine.date
Where death.continent is not null
Order by 2,3



--Show Total Population vs Total Vaccination: Rolling Count of Vaccinated People per Country
Select death.continent, death.location, death.date, death.population, vaccine.new_vaccinations, 
	sum(cast(vaccine.new_vaccinations as bigint)) 
	Over (Partition by death.location Order by death.location, death.date) as RollingPeopleVaccinated,
From PortfolioProject..CovidDeaths death
Join PortfolioProject..CovidVaccinations vaccine
	On death.location = vaccine.location
	and death.date = vaccine.date
Where death.continent is not null
Order by 2,3



---USING CTE - Show Total Population vs Total Vaccination: Rolling Percentage of Vaccinated People per Country
With PopulationVsVaccination (Continent, Location, Date, Population, New_vaccinations, RollingPeopleVaccinated)
as
(
	Select death.continent, death.location, death.date, death.population, vaccine.new_vaccinations, 
		sum(cast(vaccine.new_vaccinations as bigint)) 
		Over (Partition by death.location Order by death.location, death.date) as RollingPeopleVaccinated
	From PortfolioProject..CovidDeaths death
	Join PortfolioProject..CovidVaccinations vaccine
		On death.location = vaccine.location
		and death.date = vaccine.date
	Where death.continent is not null
)
Select *, (RollingPeopleVaccinated/Population)*100 as RollingPercentagePopulationVaccinated
From PopulationVsVaccination



---USING Temp Table - Show Total Population vs Total Vaccination: Rolling Percentage of Vaccinated People per Country
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
	Select death.continent, death.location, death.date, death.population, vaccine.new_vaccinations, 
		sum(cast(vaccine.new_vaccinations as bigint)) 
		Over (Partition by death.location Order by death.location, death.date) as RollingPeopleVaccinated
	From PortfolioProject..CovidDeaths death
	Join PortfolioProject..CovidVaccinations vaccine
		On death.location = vaccine.location
		and death.date = vaccine.date
	Where death.continent is not null

Select *, (RollingPeopleVaccinated/Population)*100 as RollingPercentagePopulationVaccinated
From #PercentPopulationVaccinated



--Create View to Store Needed Data for Later Visualization
Create View PercentPopulationVaccinated as
Select death.continent, death.location, death.date, death.population, vaccine.new_vaccinations, 
	sum(cast(vaccine.new_vaccinations as bigint)) 
	Over (Partition by death.location Order by death.location, death.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths death
Join PortfolioProject..CovidVaccinations vaccine
	On death.location = vaccine.location
	and death.date = vaccine.date
Where death.continent is not null

Select*
From PercentPopulationVaccinated



---END---