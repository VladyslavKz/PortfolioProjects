SELECT *
FROM Portfolio_Projects..Covid_deaths
WHERE continent IS NOT NULL
ORDER BY 3,4


--SELECT *
--FROM Portfolio_Projects..Covid_vaccinations
--ORDER BY 3,4

--Select the data that we are going to be using

SELECT location, 
	date, 
	total_cases, 
	new_cases, 
	total_deaths, 
	population
FROM Portfolio_Projects..Covid_deaths
ORDER BY 1,2

--Looking at Total cases vs total deaths

SELECT location, 
	date, 
	total_cases, 
	total_deaths,
	(total_deaths/total_cases)*100 AS death_percentage
FROM Portfolio_Projects..Covid_deaths
WHERE location like '%Poland%'
ORDER BY 1,2


SELECT location, 
	date, 
	population,
	total_cases, 
	(total_cases/population)*100 AS cases_percentage
FROM Portfolio_Projects..Covid_deaths
WHERE location like '%Ukraine%'
ORDER BY 1,2


SELECT location,
	population,
	MAX(total_cases) AS HighestInfectionCount, 
	MAX(total_cases/population)*100 AS cases_percentage
FROM Portfolio_Projects..Covid_deaths
GROUP BY location, population
ORDER BY HighestInfectionCount DESC



SELECT location,
	population,
	MAX(total_deaths) AS HighestDeathsCount, 
	MAX(total_deaths/population)*100 AS deaths_percentage
FROM Portfolio_Projects..Covid_deaths
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY deaths_percentage DESC


SELECT continent,
	MAX(total_deaths) AS HighestDeathsCount 
FROM Portfolio_Projects..Covid_deaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY HighestDeathsCount DESC 



SELECT --date,
SUM(new_cases) AS TotalNewCases,
SUM(new_deaths)AS TotalNewDeaths,
SUM(new_deaths)/SUM(new_cases)*100 AS DeathPercent
FROM Portfolio_Projects..Covid_deaths
WHERE continent IS NOT NULL
--GROUP BY date
ORDER BY 1,2




--Total population vs total population

SELECT de.location,
	MAX(de.population) as totalPopulation,
	MAX(va.total_vaccinations) as totalVaccinations,
	MAX(va.total_vaccinations)/MAX(de.population)*100 as vaccinationPercentage
FROM Portfolio_Projects..Covid_deaths de
JOIN Portfolio_Projects..Covid_vaccinations va
	ON de.location = va.location AND de.date = va.date
WHERE de.continent IS NOT NULL
GROUP BY de.location
ORDER BY 1,2



with VacVsPop (continent, location, date, population, new_vaccinations, rollingPeopleVac)
as
(
SELECT de.continent,
	de.location,
	de.date,
	de.population,
	va.new_vaccinations,
	SUM(CAST(va.new_vaccinations as int)) OVER
	(partition by de.location
	 ORDER BY de.location, de.date) as rollingPeopleVac
FROM Portfolio_Projects..Covid_deaths as de
JOIN Portfolio_Projects..Covid_vaccinations as va
	ON de.location = va.location AND de.date = va.date
Where de.continent IS NOT NULL
)
SELECT *, (rollingPeopleVac/population)*100
FROM VacVsPop



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
SELECT de.continent,
	de.location,
	de.date,
	de.population,
	va.new_vaccinations,
	SUM(CAST(va.new_vaccinations as int)) OVER
	(partition by de.location
	 ORDER BY de.location, de.date) as rollingPeopleVac
FROM Portfolio_Projects..Covid_deaths as de
JOIN Portfolio_Projects..Covid_vaccinations as va
	ON de.location = va.location AND de.date = va.date
Where de.continent IS NOT NULL

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated

CREATE VIEW PercentPopulationVaccinated as
SELECT de.continent,
	de.location,
	de.date,
	de.population,
	va.new_vaccinations,
	SUM(CAST(va.new_vaccinations as int)) OVER
	(partition by de.location
	 ORDER BY de.location, de.date) as rollingPeopleVac
FROM Portfolio_Projects..Covid_deaths as de
JOIN Portfolio_Projects..Covid_vaccinations as va
	ON de.location = va.location AND de.date = va.date
Where de.continent IS NOT NULL

SELECT *
FROM PercentPopulationVaccinated