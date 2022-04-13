/*What range of years for baseball games played does the provided database cover?*/
select DISTINCT 
min(yearid),
max(yearid)
from batting;

/*Find the name and height of the shortest player in the database. How many games did he play in? What is the name of the team for which he played?*/
select
p.namefirst as First_Name,
p.namelast as Last_Name,
p.height,
a.g_all as total_games,
t.teamidbr as team_name
from people as p
left join appearances as a
on a.playerid = p.playerid
left join teams as t
on t.teamid = a.teamid
order by height
LIMIT 1;

/*Find all players in the database who played at Vanderbilt University. Create a list showing each player's first and last names as well as the total salary they earned in the major leagues. Sort this list in descending order by the total salary earned. Which Vanderbilt player earned the most money in the majors? Answer: David Price,81851296 */
select
namefirst,
namelast,
sum(DISTINCT salary) as total_salary
from salaries as s
left join people as p
using (playerid)
left join collegeplaying as c
using (playerid)
left join schools as sch
on sch.schoolid= c.schoolid
WHERE schoolname = 'Vanderbilt University'
group by namefirst,namelast
order by total_salary DESC;


/*Using the fielding table, group players into three groups based on their position: label players with position OF as "Outfield", those with position "SS", "1B", "2B", and "3B" as "Infield", and those with position "P" or "C" as "Battery". Determine the number of putouts made by each of these three groups in 2016.*/
select
sum(PO),
case 
when pos = 'OF'  then 'Outfield'
when pos = 'SS' or pos = '1B' or  pos = '2B' or pos = '3B' then 'Infield'
when pos = 'P' or pos = 'C'  then 'Battery'
END as Position
from fielding
where yearid = 2016
group by position;

/*Find the average number of strikeouts per game by decade since 1920. Round the numbers you report to 2 decimal places. Do the same for home runs per game. Do you see any trends?*/
select 
sum(COALESCE(so,0)) as total_strikeouts,
sum(COALESCE(hr,0)) as total_homeruns,
sum(g/2) as total_games,
ROUND((1.0*sum(COALESCE(so,0))/sum(g/2)),2) as avg_strikeouts_per_game,
ROUND((1.0*sum(COALESCE(hr,0))/sum(g/2)),2) as avg_homeruns_per_game,
CASE
WHEN yearid between 1920 and 1929 then '1920s'
WHEN yearid between 1930 and 1939 then '1930s'
WHEN yearid between 1940 and 1949 then '1940s'
WHEN yearid between 1950 and 1959 then '1950s'
WHEN yearid between 1960 and 1969 then '1960s'
WHEN yearid between 1970 and 1979 then '1970s'
WHEN yearid between 1980 and 1989 then '1980s'
WHEN yearid between 1990 and 1999 then '19990s'
WHEN yearid >= 2000 then '2000s'
END as decade 
from teams
WHERE yearid>=1920
group by decade
order by decade;


/*Find the player who had the most success stealing bases in 2016, where success is measured as the percentage of stolen base attempts which are successful. (A stolen base attempt results either in a stolen base or being caught stealing.) Consider only players who attempted at least 20 stolen bases.*/
select
playerid,
namefirst,
namelast,
sb as stolen_base,
cs as caught_stealing,
ROUND(CAST(sb as decimal)/CAST((sum(sb) + sum(cs)) as decimal),2) as perc
from batting
left join people
using (playerid)
group by namefirst,namelast,playerid,yearid,stolen_base,caught_stealing
having (sum(sb) + sum(cs)) >= 20 and yearid = 2016
order by perc DESC;


/*From 1970-2016, what is the largest number of wins for a team that did not win the world series? What is the smallest number of wins for a team that did win the world series? Doing this will probably result in an unusually small number of wins for a world series champion-determine why this is the case. Then redo your query, excluding the problem year. How often from 1970 -2016 was it the case that a team with the most wins also won the world series? What percentage of the time?*/

-- Seattle Marrines has the largest number of wins (didn't win WS)
select 
DISTINCT name,
yearid,
wswin,
w
from teams
where yearid >= 1970
AND wswin NOT LIKE 'Y'
ORDER by w DESC;

-- LA Dodgers has the smalles number of wins (did win WS). There was a 50 day strike
select 
DISTINCT name,
yearid,
wswin,
w
from teams
where yearid >= 1970
AND wswin LIKE 'Y'
ORDER by w ;

-- With 1981 excluded from query: St.Louis Cardinals had the smallest numbers of wins
select 
DISTINCT name,
yearid,
wswin,
w
from teams
where yearid >= 1970
AND wswin LIKE 'Y'
AND yearid <>1981
ORDER by w;

--How often from 1970 -2016 was it the case that a team with the most wins also won the world series? 
select
DISTINCT yearid,
wswin,
wins,
most_wins,
from(
select 
distinct yearid,
name,
wswin,
w as wins,	
MAX(w) OVER (PARTITION by yearid) as most_wins
from teams
where yearid >= 1970
order by yearid DESC) as subquery
where wswin LIKE 'Y'
AND wins = most_wins
ORDER by yearid DESC;

--What percentage of the time?
select
CAST(count(*) as numeric) as rows,
number_of_years,
ROUND((count(*) / number_of_years),2)*100 as perc
from(
select 
distinct yearid,
CAST((2016-1970) as numeric) as number_of_years,	
name,
wswin,
w as wins,
MAX(w) OVER (PARTITION by yearid) as most_wins
from teams
where yearid >= 1970	
order by yearid DESC) as subquery
where wswin LIKE 'Y' AND wins = most_wins
GROUP by number_of_years;
/*Using the attendance figures from the homegames table, find the teams and parks which had the top 5 average attendance per game in 2016 (where average attendance is defined as total attendance divided by number of games). Only consider parks where there were at least 10 games played. Report the park name, team name, and average attendance. Repeat for the lowest 5 average attendance.*/
select
p.park_name,
team,
CAST(sum(games) as numeric) as total_games,
CAST(sum(attendance) as numeric) as attendance,
CAST(sum(attendance)/sum(games)as numeric) as avg_attendance
from homegames as h
join parks as p 
on p.park = h.park
GROUP by p.park_name,team,h.year
HAVING CAST(sum(games) as numeric) >= 10 AND h.year = 2016
ORDER by avg_attendance DESC
LIMIT 5;

select
p.park_name,
team,
CAST(sum(games) as numeric) as total_games,
CAST(sum(attendance) as numeric) as attendance,
CAST(sum(attendance)/sum(games)as numeric) as avg_attendance
from homegames as h
join parks as p 
on p.park = h.park
GROUP by p.park_name,team,h.year
HAVING CAST(sum(games) as numeric) >= 10 AND h.year = 2016
ORDER by avg_attendance
LIMIT 5;


/*Which managers have won the TSN Manager of the Year award in both the National League (NL) and the American League (AL)? Give their full name and the teams that they were managing when they won the award. SHOULD HAVE 6 rows*/
WITH s_nl as (
select playerid,awardid,lgid,yearid
from awardsmanagers
WHERE awardid = 'TSN Manager of the Year' AND  lgid LIKE 'NL' ),

s_al as (
select playerid,awardid,lgid,yearid
from awardsmanagers
WHERE awardid = 'TSN Manager of the Year' AND  lgid LIKE 'AL' ),

s_winners as
(select s_nl.playerid, namefirst, namelast,
	s_nl.awardid, 
	s_nl.yearid AS nl_year, 
	s_al.yearid AS al_year
from s_nl
join s_al
using(playerid)
left join people
using(playerid))

select sub1.playerid, namefirst, namelast, team, awardid, year, league
from(select nl_year AS year, playerid, namefirst, namelast, awardid
	 from s_winners
	 union
	 select al_year, playerid, namefirst, namelast, awardid
	 from s_winners) AS sub1
left join
(select nl_year AS year, 'nl' AS league
	 from s_winners
	 union
	 select al_year AS year, 'al'
	 from s_winners) AS sub2
using(year)
left join
(select playerid, yearid, teamid, name AS team
from managers
left join teams
using(teamid, yearid)) AS sub3
on sub1.playerid = sub3.playerid AND sub1.year = sub3.yearid
order by year;

/*Find all players who hit their career highest number of home runs in 2016. Consider only players who have played in the league for at least 10 years, and who hit at least one home run in 2016. Report the players' first and last names and the number of home runs they hit in 2016. SHOULD HAVE 9 rows*/

WITH hr_sixteen AS
(SELECT playerid, yearid, SUM(hr) as player_hr_sixteen
FROM batting
WHERE yearid = 2016
GROUP by playerid, yearid
ORDER BY player_hr_sixteen DESC),

yearly_hr AS
(SELECT playerid, yearid, SUM(hr) AS hr_yearly,
 	MAX(SUM(hr)) OVER(PARTITION BY playerid) AS best_year_hrs
FROM batting
GROUP BY playerid, yearid),

yp AS
(SELECT COUNT(DISTINCT yearid) AS years_played, playerid
FROM batting
GROUP BY playerid)

SELECT playerid, namefirst, namelast, hr_yearly AS total_hr_2016, years_played
FROM yearly_hr
INNER JOIN hr_sixteen
USING(playerid)
INNER JOIN yp
USING(playerid)
INNER JOIN people
USING(playerid)
WHERE best_year_hrs = player_hr_sixteen
	AND hr_yearly > 0
	AND yearly_hr.yearid = 2016
	AND years_played >= 10
ORDER BY playerid;