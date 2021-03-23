-- This is an example of a cut down game system
-- Can you figure out what the game is?
-- Put comments in describing the SQL and its purpose.
--
DROP DATABASE if exists sapodb ;
CREATE DATABASE sapodb;
USE sapodb; -- REPLACE sapodb WITH YOUR DATABASE NAME


DROP USER if exists 'sapo'@'localhost';
CREATE USER 'sapo'@'localhost' IDENTIFIED BY '53211';
GRANT ALL ON sapodb.* TO 'sapo'@'localhost';
DROP TABLE IF EXISTS tblClickTarget;
CREATE TABLE tblClickTarget(
   UserName varchar(50) PRIMARY KEY,
   X INT , Y INT, 
   Strength INT DEFAULT 10
);
-- The CREATE TABLE and all other table specific DML could be put
-- into a PROCEDURE. I would expect you to do that for your Milestone One.

DROP PROCEDURE IF EXISTS AddUserName;
DELIMITER $$
CREATE PROCEDURE AddUserName(pUserName VARCHAR(50))
BEGIN
  IF EXISTS (SELECT * 
     FROM tblClickTarget
     WHERE Username = pUserName) THEN
  BEGIN
     SELECT 'NAME EXISTS' AS MESSAGE;
  END;
  ELSE 
     INSERT INTO tblClickTarget(UserName,X,Y)
     VALUE (pUserName, 100,100); -- Need to check the X,Y location
     SELECT 'PLAY' AS MESSAGE;
  END IF;
  
END $$
DELIMITER ;
DROP PROCEDURE IF EXISTS PlayerQuit;
DELIMITER $$
CREATE PROCEDURE PlayerQuit(pUserName VARCHAR(50))
BEGIN
	IF EXISTS ( SELECT * FROM tblClickTarget WHERE UserName = pUserName) THEN
     DELETE FROM tblClickTarget WHERE UserName = pUserName;
     SELECT 'QUIT' AS MESSAGE;
	ELSE
     SELECT 'PLAYER DOES NOT EXIST' AS MESSAGE;
	END IF;
END$$ -- PlayerQuit

DROP PROCEDURE IF EXISTS HitFrom$$
CREATE PROCEDURE HitFrom(pUserName varchar (50), pX integer, pY integer)
BEGIN
   IF EXISTS (SELECT * FROM tblClickTarget WHERE Username = pUserName) THEN
   BEGIN
      -- Target area is within 20 of the click at (X,Y)
      SELECT count(*) 
      FROM tblClickTarget
      WHERE 
        (pX >=  X - 10 AND pX <= X + 10 ) AND
        (pY >= Y - 10 AND pY <= Y + 10) AND 
        Username <> pUserName
	  INTO @HitCount;
      
      UPDATE tblClickTarget
      SET Strength = Strength + @HitCount
      WHERE 
            (NOT @HitCount IS NULL AND @HitCount <> 0 ) AND
            Username = pUsername;
            
	 UPDATE tblClickTarget
     Set Strength = Strength -1
     WHERE
        (pX >=  X - 10 AND pX <= X + 10 ) AND
        (pY >= Y - 10 AND pY <= Y + 10) AND 
        Username <> pUserName;
      
      DELETE FROM tblClickTarget
      WHERE Strength <= 0;
      
      SELECT 'PLAYED ' AS MESSAGE;
   END;
   ELSE
    SELECT 'PLAYER GONE' AS MESSAGE;
   END IF;
END$$



DROP PROCEDURE IF EXISTS GetAllPlayers$$
CREATE PROCEDURE GetAllPlayers()
BEGIN
	SELECT UserName, Strength, X, Y
    FROM tblClickTarget ;
END$$
DELIMITER $$
DROP PROCEDURE IF EXISTS Move$$
CREATE PROCEDURE Move(pMaxX INT, pMaxY INT)
BEGIN
  -- MOVES +/- 50 pixels, this might be boring, 
  -- also it does not check it the target
  -- moves out of bounds, presumes MinX and MinY are 0.
  UPDATE tblClickTarget
  SET 
      X =  X + ROUND(RAND() * 20) - 10  , 
      Y =  Y +  ROUND(RAND() * 20) - 10 ;
END$$
--
-- TESTING AREA

-- This procedure is "work in progress" 
DROP PROCEDURE IF EXISTS TestPlay$$
CREATE PROCEDURE TestPlay(pNumberOfPlayers INT)
BEGIN
      DECLARE counter INT DEFAULT 0;
       REPEAT
		 SET @NewName = CONCAT('Asterix', counter);
         CALL AddUserName(@NewName);
         SET counter = counter + 1;
       UNTIL counter > pNumberOfPlayers
       END REPEAT ;
END$$

DELIMITER ;
-- Call TestPlay(100);

Call AddUserName('Asterix');
Call AddUserName('Obelix');
Call AddUserName('Obelix');
Call HitFrom('Asterix',95,110);
Call HitFrom('Asterix',1,1);
Call HitFrom('Obelix',95,110);
Call HitFrom('Obelix',95,100);

CALL Move(1024,1024);

-- SELECT * 
-- FROM tblClickTarget;
Call GetAllPlayers();

Call PlayerQuit('Asterix');