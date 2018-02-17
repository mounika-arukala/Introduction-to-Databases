1
The default number of at bats is 20

ALTER TABLE teams ALTER COLUMN ab SET DEFAULT 20;

INSERT INTO `teams` VALUES (1871,'NA','BS1','BNA',NULL,3,31,NULL,20,10,NULL,NULL,'N',NULL,401,1372,426,70,37,3,60,19,73,NULL,NULL,NULL,303,109,3.55,22,1,3,828,367,2,42,23,225,NULL,0.83,'Boston Red Stockings','South End Grounds I',NULL,103,98,'BOS','BS1','BS1')
---------------------------------------------------------------------------------------
2
A player cannot have more hits than at bats
ALTER TABLE teams ADD CONSTRAINT hc CHECK (h < ab)
INSERT INTO `teams` VALUES (1871,'NA','BS1','BNA',NULL,3,31,NULL,20,10,NULL,NULL,'N',NULL,401,1372,426,70,37,3,60,19,73,NULL,NULL,NULL,303,109,3.55,22,1,3,828,367,2,42,23,225,NULL,0.83,'Boston Red Stockings','South End Grounds I',NULL,103,98,'BOS','BS1','BS1')
-------------------------------------------------------------------------------
3
The league can be only one of the values: NL or AL
ALTER TABLE teams ADD CONSTRAINT NL CHECK (lgid = 'NL' OR lgid = 'AL')
INSERT INTO `teams` VALUES (1871,'NA','BS1','BNA',NULL,3,31,NULL,20,10,NULL,NULL,'N',NULL,401,1372,426,70,37,3,60,19,73,NULL,NULL,NULL,303,109,3.55,22,1,3,828,367,2,42,23,225,NULL,0.83,'Boston Red Stockings','South End Grounds I',NULL,103,98,'BOS','BS1','BS1')
-------------------------------------------------------------------------------
4
When a team loses more than 161 games in a season, the fans want to forget about the team forever so all batting records for the team for that year should be deleted
CREATE OR REPLACE FUNCTION losers_func() RETURNS trigger AS $losers_func$
	BEGIN
		IF NEW.l > 161 THEN
		DELETE FROM batting
		WHERE batting.teamid = NEW.teamid;
		END IF;
		RETURN NEW;
	END;
$losers_func$ LANGUAGE plpgsql;

CREATE TRIGGER losers_trig AFTER UPDATE ON teams FOR EACH ROW EXECUTE PROCEDURE losers_func();
----------------------------------------------------------------------------------------------------------------
5
If a player wins the MVP, WS MVP, and a Gold Glove in the same season, 
they are automatically inducted into the Hall of Fame
CREATE OR REPLACE FUNCTION hall_of_fame() RETURNS trigger AS $hall_of_fame$
	BEGIN
		IF NEW.masterid IN (
			SELECT masterid FROM
			(SELECT masterid, yearid, COUNT(awardid)
			FROM
			(SELECT DISTINCT awardid, masterid, yearid FROM awardsplayers
			WHERE awardid = 'Most Valuable Player' OR awardid = 'World Series MVP' OR awardid = 'Gold Glove'
			) AS filter
			GROUP BY yearid, masterid
			HAVING COUNT(awardid) = 3) AS fame
		) THEN
		INSERT INTO halloffame VALUES(NEW.masterid, NEW.yearid, 'CS5800 Students', 100, 100, 100, 'N', 'Player', NEW.notes);
		END IF;
		RETURN NEW;
	END;
$hall_of_fame$ LANGUAGE plpgsql;

CREATE TRIGGER fame_trigger AFTER INSERT ON awardsplayers FOR EACH ROW EXECUTE PROCEDURE hall_of_fame();
----------------------------------------------------------------------------------------------------------------------------------
6
All teams must have some name, i.e., it cannot be null.

ALTER TABLE teams ADD CONSTRAINT nch CHECK (name IS NOT NULL);
INSERT INTO `teams` VALUES (1871,'NA','BS1','BNA',NULL,3,31,NULL,20,10,NULL,NULL,'N',NULL,401,1372,426,70,37,3,60,19,73,NULL,NULL,NULL,303,109,3.55,22,1,3,828,367,2,42,23,225,NULL,0.83,'Boston Red Stockings','South End Grounds I',NULL,103,98,'BOS','BS1','BS1')
-----------------------------------------------------------------------------------------------------------------
7

Everybody has a unique name (combined first and last names).

ALTER TABLE teams ADD CONSTRAINT nc UNIQUE name;
INSERT INTO `teams` VALUES (1871,'NA','BS1','BNA',NULL,3,31,NULL,20,10,NULL,NULL,'N',NULL,401,1372,426,70,37,3,60,19,73,NULL,NULL,NULL,303,109,3.55,22,1,3,828,367,2,42,23,225,NULL,0.83,'Boston Red Stockings','South End Grounds I',NULL,103,98,'BOS','BS1','BS1')
----------------------------------------------------------------------
ALTER TABLE teams ADD CONSTRAINT ncheck UNIQUE name;