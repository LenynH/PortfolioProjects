Select *
From
	PortfolioProject.dbo.CovidDeaths
Where continent is not null
Order By 3,4

--Select *
--From
--	PortfolioProject.dbo.CovidVaccinations
--Order By 3, 4

Select 
	Location,
	date,
	total_cases,
	new_cases,
	total_deaths,
	population
From
	PortfolioProject.dbo.CovidDeaths
Order By 1, 2


-- Looking at Total Cases vs Total Deaths
-- Shows the Likelihood of Dying if You Contract Covid in Your Country

Select 
	Location,
	date,
	total_cases,
	total_deaths,
	(total_deaths/total_cases)*100 AS DeathPercentage
From
	PortfolioProject.dbo.CovidDeaths
Where location like '%states%'
Order By 1, 2

-- Looking at the Total Cases vs Population
-- Shows What Percentage of Population got Covid

Select 
	Location,
	date,
	population,
	total_cases,
	(total_cases/population)*100 AS InfectionPercentage
From
	PortfolioProject.dbo.CovidDeaths
Where location like '%states%'
Order By 1, 2


-- Looking at Countries with Highest Infection Rate Compared to Population

Select 
	Location,
	population,
	Max(total_cases) AS HighestInfectionCount,
	Max((total_cases/population))*100 AS InfectionPercentage
From
	PortfolioProject.dbo.CovidDeaths
Group By location, population
Order By InfectionPercentage Desc


-- Showing Countries with highest Death Count per Population

Select 
	Location,
	MAX(cast(total_deaths as int)) as TotalDeathCount
From
	PortfolioProject.dbo.CovidDeaths
Where continent is not null
Group By location
Order By TotalDeathCount Desc

-- Showing the Continents with the Highest Death Count

Select 
	continent,
	MAX(cast(total_deaths as int)) as TotalDeathCount
From
	PortfolioProject.dbo.CovidDeaths
Where continent is not null
Group By continent
Order By TotalDeathCount Desc


-- Global Numbers

Select 
	Sum(new_cases) as total_cases,
	Sum(cast(new_deaths as int)) as total_deaths,
	Sum(cast(new_deaths as int))/ Sum(new_cases)*100 as DeathPercentage
From
	PortfolioProject.dbo.CovidDeaths
--Where location like '%states%'
Where continent is not null
--Group By date
Order By 1, 2


-- Looking at Total Population vs Vaccinations

Select 
	dea.continent,
	dea.location,
	dea.date,
	population,
	vac.new_vaccinations,
	SUM(Cast(vac.new_vaccinations as int)) Over (Partition by dea.location 
	Order by dea.location, dea.date) as RollingPeopleVaccinated,
	(RollingPeopleVaccinated/population)*100
From 
	PortfolioProject.dbo.CovidDeaths as dea
Join PortfolioProject.dbo.CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
Order by 2, 3


-- Use CTE

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as 
(
Select 
	dea.continent,
	dea.location,
	dea.date,
	population,
	vac.new_vaccinations,
	SUM(Cast(vac.new_vaccinations as int)) Over (Partition by dea.location 
	Order by dea.location, dea.date) as RollingPeopleVaccinated
	--(RollingPeopleVaccinated/population)*100
From 
	PortfolioProject.dbo.CovidDeaths as dea
Join PortfolioProject.dbo.CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
-- Order by 2, 3
)
Select 
	*,
	(RollingPeopleVaccinated/Population)*100
From PopvsVac


-- Temp Table

Drop Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
rollingpeoplevaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select 
	dea.continent,
	dea.location,
	dea.date,
	population,
	vac.new_vaccinations,
	SUM(Cast(vac.new_vaccinations as int)) Over (Partition by dea.location 
	Order by dea.location, dea.date) as RollingPeopleVaccinated
	--(RollingPeopleVaccinated/population)*100
From 
	PortfolioProject.dbo.CovidDeaths as dea
Join PortfolioProject.dbo.CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
Order by 2, 3
Select 
	*,
	(RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated



-- Creating View to Store Data for later Visualizations

Create View PercentPopulationVaccinated as 
Select 
	dea.continent,
	dea.location,
	dea.date,
	population,
	vac.new_vaccinations,
	SUM(Cast(vac.new_vaccinations as int)) Over (Partition by dea.location 
	Order by dea.location, dea.date) as RollingPeopleVaccinated
	--(RollingPeopleVaccinated/population)*100
From 
	PortfolioProject.dbo.CovidDeaths as dea
Join PortfolioProject.dbo.CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--Order by 2, 3
