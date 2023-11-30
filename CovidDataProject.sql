select * from PortfolioProject1CovidData..CovidDeaths ORDER BY 3,4;
GO
--select * from PortfolioProject1CovidData..CovidVaccinations ORDER BY 3,4 ;
GO

--Finding totalcases,new_cases and total death
select Location,date,total_cases, new_cases,total_deaths, population from PortfolioProject1CovidData..CovidDeaths order by 1,2; GO
GO

--Finding total case, death cases and death percentage
select Location,date,total_cases,total_deaths, convert(float,total_deaths,0)/nullif(convert(float,total_cases),0)*100 "Death Percentage" from PortfolioProject1CovidData..CovidDeaths where location='india' order by 1,2 ;
GO

--Finding total cases,death cases as per location
select Location,sum(convert(float,total_cases)) "Total Cases" ,  sum(convert(float,total_deaths)) "Total Deaths" from PortfolioProject1CovidData..CovidDeaths group by location;
GO

--Finding total cases vs population
select location,total_cases,population, (total_cases/population)*100 "cases percentage per population" from PortfolioProject1CovidData..CovidDeaths where location= 'india';
GO

--Finding the country with the highest infection rate
select location, population,max(total_cases) as "max total cases" ,max(total_cases/population)*100 PercentPopulationInfected from PortfolioProject1CovidData..CovidDeaths group by location,population order by PercentPopulationInfected desc;
GO



--Finding the countries with maximum death count in descending order and their continents.
select continent,location,max(cast(total_deaths as int)) "maximum death" from PortfolioProject1CovidData..CovidDeaths  where continent is not null and continent not like 'Oceania' group by location,continent order by "maximum death" desc;
go

--showing the continents with highest death count
select continent,max(cast(total_deaths as int)) DEADCOUNT from PortfolioProject1CovidData..CovidDeaths where continent is not null and continent not like 'oceania'  group by continent ORDER BY DEADCOUNT desc;  
Go

--global numbers.
select sum(new_cases) as totalcases,sum(cast(new_deaths as int)) totalDeaths,sum(cast(new_deaths as int))/nullif(sum(new_cases),0)*100 as deathpercentage from PortfolioProject1CovidData..CovidDeaths where continent is not null --group by date 
order by 1,2;go

--Covid Vaccination
select * from PortfolioProject1CovidData..CovidDeaths ORDER BY 3,4;
select * from PortfolioProject1CovidData..CovidVaccinations ORDER BY 3,4 ;


go
--joining the tables 
select * from PortfolioProject1CovidData..CovidDeaths Deaths join PortfolioProject1CovidData..CovidVaccinations Vac on Deaths.location=Vac.location and Deaths.date=Vac.date;
go

--People vaccinated vs population
with popvsvac (continent,date,location,population,new_vaccinations,RollingPeopleVaccinated) as
( 
select Deaths.continent, Deaths.date,Deaths.location,Deaths.population,Vac.new_vaccinations, sum(cast(Vac.new_vaccinations as bigint)) over (partition by Deaths.location order by Deaths.location,Deaths.date ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) as RollingPeopleVaccinated 
from PortfolioProject1CovidData..CovidDeaths Deaths join PortfolioProject1CovidData..CovidVaccinations Vac on Deaths.location=Vac.location and Deaths.date=Vac.date where Deaths.continent is not null
)
select *,(RollingPeopleVaccinated/Population)*100 from popvsvac
go

---temp table
create table percentagepopulationvaccinated(continent nvarchar(255),date nvarchar(255),location nvarchar(255),population nvarchar(255),RollingPeopleVaccinated nvarchar(255),new_vaccinations nvarchar(255))
go

insert into percentagepopulationvaccinated select Deaths.continent,Deaths.date,Deaths.location,Deaths.population,Vac.new_vaccinations, sum(cast(Vac.new_vaccinations as bigint)) over (partition by Deaths.location order by Deaths.location,Deaths.date ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) as RollingPeopleVaccinated  
from PortfolioProject1CovidData..CovidDeaths Deaths join PortfolioProject1CovidData..CovidVaccinations Vac on Deaths.location=Vac.location and Deaths.date=Vac.date where Deaths.continent is not null
go

select * from percentagepopulationvaccinated;
go

select *, (RollingPeopleVaccinated/convert(float,Population))*100 from percentagepopulationvaccinated;
go


--creating view for later visualizating
 create view percentagepopulationvaccinatedview as select Deaths.continent, Deaths.date,Deaths.location,Deaths.population,Vac.new_vaccinations, sum(cast(Vac.new_vaccinations as bigint)) over (partition by Deaths.location order by Deaths.location,Deaths.date ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) as RollingPeopleVaccinated 
from PortfolioProject1CovidData..CovidDeaths Deaths join PortfolioProject1CovidData..CovidVaccinations Vac on Deaths.location=Vac.location and Deaths.date=Vac.date where Deaths.continent is not null
go

select * from  percentagepopulationvaccinatedview;
go
