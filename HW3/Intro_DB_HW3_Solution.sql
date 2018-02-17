-- Query1:
SELECT nameFirst as 'First Name', nameLast as 'Last Name' from master
WHERE masterID in (SELECT appearances.masterID 
				   FROM appearances 
                  JOIN teams 
                   ON appearances.teamID=teams.teamID
                 WHERE teams.name='Los Angeles Dodgers');

  
-- Query2:
SELECT nameFirst as 'First Name', nameLast as 'Last Name'
FROM master where masterID in
(SELECT masterID 
FROM appearances 
WHERE teamID in ('BRO','LAN')
and masterID not in (SELECT masterID 
                     FROM appearances 
					 WHERE teamID!= 'BRO' and teamID!='LAN'));

-- Query3:
create or replace view LAD as
SELECT distinct masterID,yearID 
FROM appearances 
WHERE teamID in (SELECT distinct teamID
                 FROM teams 
				 WHERE name='los angeles dodgers');
SELECT distinct nameFirst as 'First Name',nameLast as 'Last Name',awardsplayers.yearID as Year,notes as 'Position (notes field)'
FROM awardsplayers,master,LAD 
WHERE awardsplayers.masterID = master.masterID and awardID = 'Gold Glove' and master.masterID = LAD.masterID and LAD.yearID=awardsplayers.yearID 
order by awardsplayers.yearID,nameLast; 

-- Query4:
SELECT name as 'Team Name',count(WSWin) as 'World Series Won'
FROM teams
WHERE WSWin='Y'
group by name
order by count(WSWin),name;

-- Query5:
SELECT  batting.H/batting.AB as Average, batting.H as Hits, batting.AB as 'At Bats', master.nameFirst as 'First Name', master.nameLast as 'Last Name', batting.yearID as Year
FROM master
inner join batting 
ON master.masterID = batting.masterID
inner join schoolsplayers
ON batting.masterID = schoolsplayers.masterID
inner join schools
on schoolsplayers.schoolID = schools.schoolID
WHERE schools.SchoolName = "Utah State University"
group by nameFirst, nameLast, Average 
order by batting.yearID;

-- Query6:
SELECT  teams.name as 'Team Name', Sal3.lgID as 'League' ,  Sal3.year as 'Previous Year',Salary as 'Previous Salary',Year, Salary, round((previoussalary-Salary)/Salary*100+100) as 'Percent Increase'
FROM (SELECT Sal1.teamID, Sal1.lgID , Sal1.yearID as previousyear, Sal1.salary as previoussalary, Sal2.yearID as Year, Sal2.salary as salary  
FROM (SELECT yearID,teamID,lgID, Sum(salary) salary 
      FROM salaries
	  group by yearID,teamID,lgID)Sal1
inner join (SELECT yearID,teamID,Sum(salary) salary, lgID 
            FROM salaries 
            group by yearID,teamID,lgID)Sal2 
on Sal1.yearID=sal2.yearID+1 and Sal1.teamID=Sal2.teamID and Sal1.lgID=Sal2.lgID 
WHERE Sal1.salary>=Sal2.salary*1.5)Sal3
inner join teams 
on Sal3.year=teams.yearID and Sal3.teamID=teams.teamID and Sal3.lgID=Teams.lgID
order by year, name;
       
-- Query7:
create or replace view BRS as
SELECT masterID,yearID 
FROM batting
WHERE teamID in
(SELECT teamID 
FROM teams
WHERE name='Boston Red Sox');
create or replace view BRS1 as
SELECT a.masterID,b.yearID 
FROM BRS a,BRS b
WHERE a.masterID=b.masterID and a.yearID=b.yearID+1;
create or replace view BRS2 as
SELECT a.masterID,b.yearID 
FROM BRS1 a,BRS1 b
WHERE a.masterID=b.masterID and a.yearID=b.yearID+1;
create or replace view BRS3 as
SELECT a.masterID,b.yearID
FROM BRS2 a,BRS2 b
WHERE a.masterID=b.masterID and a.yearID=b.yearID+1;
SELECT distinct nameFirst as 'First Name', nameLast as 'Last Name'
FROM master,BRS3
WHERE master.masterID=BRS3.masterID
order by nameLast;

-- Query8:
create or replace view HRS as
SELECT max(HR) as HR,yearID as year 
FROM batting 
group by yearID;
SELECT batting.yearID as Year,nameFirst as 'First Name',nameLast as 'Last Name', batting.HR as 'Home Runs'
FROM HRS 
inner join batting on HRS.year=batting.yearID
inner join master on master.masterID=batting.masterID and HRS.HR=batting.HR
order by yearID;

-- Query9:
create or replace view view1 as
SELECT yearID, max(HR) as max1
FROM batting
group by yearID;
create or replace view view2 as
SELECT batting.yearID, max(HR) as max2
FROM batting, view1
WHERE batting.yearID=view1.yearID and HR!=max1
group by batting.yearID;
create or replace view view3 as
SELECT batting.yearID, max(HR) as max3
FROM batting, view1, view2
WHERE batting.yearID=view1.yearID and batting.yearID=view2.yearID and HR!=max2 and HR!=max1
group by batting.yearID;
create or replace view view4 as
SELECT masterID,batting.yearID, HR
FROM batting, view3
WHERE batting.yearID=view3.yearID and HR=max3;
SELECT nameFirst as 'First Name', nameLast as 'Last Name', yearID as Year, HR as HRs
FROM master,view4
WHERE master.masterID=view4.masterID 
order by yearID;

-- Query10:
SELECT batting.yearID as Year, teams.name as 'Team Name', master.nameFirst as 'First Name', master.nameLast as 'Last Name', batting.3B as Triples, nameFirst as 'Teammate First Name', nameLast as 'Teammate Last Name', batting.3B as 'Teammate Triples' 
FROM batting 
inner join master
ON batting.masterID = master.masterID
inner join teams
ON batting.teamID = teams.teamID
WHERE batting.3B >= 10
group by batting.yearID, teams.teamID
having count(*)>=2;

-- Query11:
create or replace view WIN as
SELECT name,sum(W) as Win,sum(L) as Loss,sum(W)/(sum(L)+sum(W)) as Win_Per 
FROM teams 
group by name 
order by Win_Per desc;
SELECT name as 'Team Name',@rank := @rank+1 as Rank,Win_Per as 'Win Percentage',Win as 'Total Wins',Loss as 'Total Losses'
FROM WIN,(SELECT @rank := 0) r;

-- Query 12:
create or replace view CSP as
SELECT distinct managers.masterID, managers.yearID as year, managers.teamID, teams.name as teamname, master.nameFirst as managerfirstname, master.nameLast as managerlastname 
FROM managers 
inner join master 
ON  managers.masterID = master.masterID
inner join teams 
ON managers.teamID=teams.teamID and managers.yearID=teams.yearID
WHERE master.nameFirst='Casey' and master.nameLast='Stengel';
SELECT distinct 'Team Name', Year, master.nameFirst as 'Pitcher First Name', master.nameLast as 'Pitcher Last Name', 'Manager First Name', 'Manager Last Name'
FROM pitching 
inner join CSP
ON CSP.teamId=pitching.teamID and Year=pitching.yearID
inner join master 
ON master.masterID=pitching.masterID 
order by Year , master.nameLast; 


-- Query 13:
SELECT Berra3.nameFirst as 'First Name', Berra3.nameLast as 'Last Name' from master Berra3
inner join 
(SELECT distinctrow Berra2.masterID
FROM appearances Berra2
inner join
(SELECT distinctrow Berra1.teamID, Berra1.yearID,  Berra1.masterID 
FROM appearances Berra1
inner join 
(SELECT appearances.masterID , appearances.YearID 
 FROM appearances 
inner join
(SELECT appearances.teamID , appearances.yearID , master.masterID  
FROM  master ,appearances 
WHERE master.nameFirst="Yogi" and master.nameLast="Berra" and master.masterID=appearances.masterID)Yogi1
ON appearances.teamID=Yogi1.TeamID and appearances.YearID=Yogi1.yearID  and appearances.masterID!=Yogi1.masterID )Yogi2
ON Berra1.masterID =Yogi2.masterID)Yogi3 
ON  Berra2.teamID=Yogi3.TeamID and Berra2.yearID=Yogi3.yearID)Yogi4 
ON Berra3.masterID=Yogi4.masterID;

-- Query14:
create or replace view travel as
SELECT masterID 
FROM master
WHERE nameFirst='Rickey' and nameLast='Henderson';
create or replace view travel1 as
SELECT distinct teamID 
FROM teams
WHERE yearID in
(SELECT yearID
 FROM appearances 
WHERE masterID in (select * from travel))
and teamID not in
(SELECT distinct teamID 
FROM appearances 
WHERE masterID in (SELECT* 
                   FROM travel));
create or replace view travel2 as
SELECT distinct teams.teamID,name 
FROM teams,travel1 
WHERE teams.teamID=travel1.teamID
group by teams.teamID;
SELECT distinct name as 'Team Name' 
FROM travel2 
order by name;

