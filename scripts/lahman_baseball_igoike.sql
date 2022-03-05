/*What range of years for baseball games played does the provided database cover?*/
select DISTINCT yearid
from teams;



/*Find the name and height of the shortest player in the database. How many games did he play in? What is the name of the team for which he played?*/
select
p.namefirst,
p.namelast,
sum(t.g) as number_games,
t.teamidbr as team_name,
min(height) as height
from people as p 
join managershalf as m
on m.playerid = p.playerid
join teams as t
on t.teamid = m.teamid
group by namefirst,namelast,team_name
order by height
LIMIT 1;

select*
from teams

/*Find all players in the database who played at Vanderbilt University. Create a list showing each player’s first and last names as well as the total salary they earned in the major leagues. Sort this list in descending order by the total salary earned. Which Vanderbilt player earned the most money in the majors? Answer: David Price,245553888 */
select
namefirst,
namelast,
sum(salary) as total_salary
from salaries as s
join people as p
on p.playerid = s.playerid
join collegeplaying as c
on c.playerid = p.playerid
join schools as sch
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

/*Find the average number of strikeouts per game by decade since 1920. Round the numbers you report to 2 decimal places. Do the same for home runs per game. Do you see any trends?  USE TEAMS TABLE*/




/*Find the player who had the most success stealing bases in 2016, where success is measured as the percentage of stolen base attempts which are successful. (A stolen base attempt results either in a stolen base or being caught stealing.) Consider only players who attempted at least 20 stolen bases.*/

/*From 1970 – 2016, what is the largest number of wins for a team that did not win the world series? What is the smallest number of wins for a team that did win the world series? Doing this will probably result in an unusually small number of wins for a world series champion – determine why this is the case. Then redo your query, excluding the problem year. How often from 1970 – 2016 was it the case that a team with the most wins also won the world series? What percentage of the time?*/

/*Using the attendance figures from the homegames table, find the teams and parks which had the top 5 average attendance per game in 2016 (where average attendance is defined as total attendance divided by number of games). Only consider parks where there were at least 10 games played. Report the park name, team name, and average attendance. Repeat for the lowest 5 average attendance.*/

/*Which managers have won the TSN Manager of the Year award in both the National League (NL) and the American League (AL)? Give their full name and the teams that they were managing when they won the award.*/

/*Find all players who hit their career highest number of home runs in 2016. Consider only players who have played in the league for at least 10 years, and who hit at least one home run in 2016. Report the players' first and last names and the number of home runs they hit in 2016.*/
