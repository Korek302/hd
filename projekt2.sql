CREATE TABLE AtpMatches
(
	tourney_id VARCHAR(15),
	tourney_name VARCHAR(30),
	surface VARCHAR(10),
	 draw_size INT,
	 tourney_level VARCHAR(1),
	 tourney_date INT,
	 match_num INT,
	 winner_id INT,
	 winner_seed INT,
	 winner_entry VARCHAR(5),
	 winner_name VARCHAR(50),
	 winner_hand VARCHAR(1),
	 winner_ht INT,
	 winner_ioc VARCHAR(3),
	 winner_age FLOAT,
	 winner_rank INT,
	 winner_rank_points INT,
	 loser_id INT,
	 loser_seed INT,
	 loser_entry VARCHAR(5),
	 loser_name VARCHAR(50),
	 loser_hand VARCHAR(1),
	 loser_ht INT,
	 loser_ioc VARCHAR(3),
	 loser_age FLOAT,
	 loser_rank INT,
	 loser_rank_points INT,
	 score VARCHAR(15),
	 best_of INT,
	 [round] VARCHAR(4),
	 [minutes] INT,
	 w_ace INT,
	 w_df INT,
	 w_svpt INT,
	 w_1stIn INT,
	 w_1stWon INT,
	 w_2ndWon INT,
	 w_SvGms INT,
	 w_bpSaved INT,
	 w_bpFaced INT,
	 l_ace INT,
	 l_df INT,
	 l_svpt INT,
	 l_1stIn INT,
	 l_1stWon INT,
	 l_2ndWon INT,
	 l_SvGms INT,
	 l_bpSaved INT,
	 l_bpFaced INT
);

BULK INSERT [dbo].[AtpMatches]
FROM 'D:\Documents\atp-matches-dataset\atp_matches_2000.csv'
WITH
(
	FIRSTROW = 2,
	FIELDTERMINATOR = ',',  --CSV field delimiter
	ROWTERMINATOR = '\n',   --Use to shift the control to next row
	ERRORFILE = 'D:\Documents\atp-matches-dataset\SchoolsErrorRows.csv',
	TABLOCK
);

SELECT COUNT(*) FROM dbo.atp_matches_2000;

DROP TABLE IF EXISTS blady.FACT_MATCHES;
DROP TABLE IF EXISTS blady.DIM_PLAYER;
DROP TABLE IF EXISTS blady.DIM_TOURNEY;
DROP TABLE IF EXISTS blady.DIM_SCORE;
DROP TABLE IF EXISTS blady.DIM_STATS;
DROP TABLE IF EXISTS blady.DIM_TIME;

CREATE SCHEMA [blady];

CREATE TABLE [blady].FACT_MATCHES 
(
	[Date] int NOT NULL, 
	[WinnerID] int NOT NULL, 
	[LoserID] int NOT NULL, 
	[TourneyID] int NOT NULL,
	[WinnerStatsID] int NOT NULL, 
	[LoserStatsID] int NOT NULL, 
	[ScoreID] int NOT NULL, 
	[Round] varchar(4) NULL, 
	[Duration] int NULL, 
	[BestOf] int NULL
);
CREATE TABLE [blady].DIM_PLAYER 
(
	[PlayerID] int IDENTITY NOT NULL, 
	[PlayerName] varchar(100) NOT NULL, 
	[DominantHand] varchar(100) NULL, 
	[Height] int NULL, 
	[Age] int NULL, 
	[Rank] int NULL, 
	[Nationality] varchar(100) NULL
);
DBCC CHECKIDENT ('[blady].DIM_PLAYER', RESEED, 0);
CREATE TABLE [blady].DIM_TIME 
(
	[PK_TIME] int NOT NULL, 
	[Year] int NOT NULL, 
	[Month] int NOT NULL, 
	[Day] int NOT NULL
);
CREATE TABLE [blady].DIM_TOURNEY 
(
	[TourneyID] int IDENTITY NOT NULL, 
	[TourneyName] varchar(50) NOT NULL, 
	[TourneyLevel] char(1) NULL, 
	[DrawSize] int NULL, 
	[Surface] varchar(10) NULL
);
DBCC CHECKIDENT ('[blady].DIM_TOURNEY', RESEED, 0);
CREATE TABLE [blady].DIM_STATS 
(
	[StatsID] int IDENTITY NOT NULL, 
	[Aces] int NULL, 
	[BreakpointsWon] int NULL, 
	[BreakpointsFaced] int NULL, 
	[FirstServeWon] int NULL, 
	[DoubleFaults] int NULL
);
DBCC CHECKIDENT ('[blady].DIM_STATS', RESEED, 0);
CREATE TABLE [blady].DIM_SCORE 
(
	[ScoreID] int IDENTITY NOT NULL, 
	[Set1] varchar(10) NULL, 
	[Set2] varchar(10) NULL, 
	[Set3] varchar(10) NULL, 
	[Set4] varchar(10) NULL, 
	[Set5] varchar(10) NULL
);
DBCC CHECKIDENT ('[blady].DIM_SCORE', RESEED, 0);

INSERT INTO [blady].[DIM_PLAYER]
SELECT [name], max(hand) as hand, max(ht) as ht, max(age) as age, max([rank]) as rank, max(ioc) as ioc FROM
(
	SELECT winner_name, max(winner_hand), max(winner_ht), max(CAST(CAST(winner_age AS FLOAT) AS INT)), max(winner_rank), max(winner_ioc)
	FROM dbo.atp_matches
	group by winner_name
	UNION
	SELECT loser_name, max(loser_hand), max(loser_ht), max(CAST(CAST(loser_age AS FLOAT) AS INT)), max(loser_rank), max(loser_ioc)
	FROM dbo.atp_matches
	group by loser_name
) as t([name], hand, ht, age, [rank], ioc)
GROUP BY [name];

select * from blady.DIM_PLAYER ORDER BY PlayerID;


GO
CREATE FUNCTION dbo.NTH_ELEMENT (@Input NVARCHAR(MAX), @Delim CHAR = '-', @N INT = 0)
RETURNS NVARCHAR(MAX)
AS
BEGIN
RETURN (SELECT VALUE FROM STRING_SPLIT(@Input, @Delim) ORDER BY (SELECT NULL) OFFSET @N ROWS FETCH NEXT 1 ROW ONLY)
END
GO

INSERT INTO [blady].[DIM_SCORE]
select distinct
dbo.NTH_ELEMENT(score, ' ', 0),
dbo.NTH_ELEMENT(score, ' ', 1),
dbo.NTH_ELEMENT(score, ' ', 2),
dbo.NTH_ELEMENT(score, ' ', 3),
dbo.NTH_ELEMENT(score, ' ', 4)
from dbo.atp_matches;


SELECT 
	LEFT(score, 3), 
	CASE
		WHEN SUBSTRING(score, 4, 1) ='(' THEN SUBSTRING(score, 8, 3)
		ELSE SUBSTRING(score, 5, 3)
	END, 
	CASE
		WHEN SUBSTRING(score, 4, 1) ='(' THEN
			CASE 
				WHEN SUBSTRING(score, 11, 1) ='(' THEN SUBSTRING(score, 15, 3)
				ELSE SUBSTRING(score, 12, 3)
			END
		ELSE 
			CASE 
				WHEN SUBSTRING(score, 8, 1) ='(' THEN SUBSTRING(score, 12, 3)
				ELSE SUBSTRING(score, 9, 3)
			END
	END,
	CASE
		WHEN SUBSTRING(score, 4, 1) ='(' THEN
			CASE 
				WHEN SUBSTRING(score, 11, 1) ='(' THEN 
					CASE
						WHEN SUBSTRING(score, 18, 1) ='(' THEN SUBSTRING(score, 22, 3)
						ELSE SUBSTRING(score, 19, 3)
					END
				ELSE 
					CASE
						WHEN SUBSTRING(score, 15, 1) ='(' THEN SUBSTRING(score, 19, 3)
						ELSE SUBSTRING(score, 16, 3)
					END
			END
		ELSE 
			CASE 
				WHEN SUBSTRING(score, 8, 1) ='(' THEN 
					CASE
						WHEN SUBSTRING(score, 15, 1) ='(' THEN SUBSTRING(score, 19, 3)
						ELSE SUBSTRING(score, 16, 3)
					END
				ELSE 
					CASE
						WHEN SUBSTRING(score, 12, 1) ='(' THEN SUBSTRING(score, 16, 3)
						ELSE SUBSTRING(score, 13, 3)
					END
			END
	END,
	CASE
		WHEN SUBSTRING(score, 4, 1) ='(' THEN
			CASE 
				WHEN SUBSTRING(score, 11, 1) ='(' THEN 
					CASE
						WHEN SUBSTRING(score, 18, 1) ='(' THEN 
							CASE
								WHEN SUBSTRING(score, 25, 1) ='(' THEN SUBSTRING(score, 29, 6)
								ELSE SUBSTRING(score, 26, 6)
							END
						ELSE 
							CASE 
								WHEN SUBSTRING(score, 22, 1) ='(' THEN SUBSTRING(score, 26, 6)
								ELSE SUBSTRING(score, 23, 6)
							END
					END
				ELSE 
					CASE
						WHEN SUBSTRING(score, 15, 1) ='(' THEN 
							CASE
								WHEN SUBSTRING(score, 22, 1) ='(' THEN SUBSTRING(score, 26, 6)
								ELSE SUBSTRING(score, 23, 6)
							END
						ELSE 
							CASE
								WHEN SUBSTRING(score, 19, 1) ='(' THEN SUBSTRING(score, 23, 6)
								ELSE SUBSTRING(score, 20, 6)
							END
					END
			END
		ELSE 
			CASE 
				WHEN SUBSTRING(score, 8, 1) ='(' THEN 
					CASE
						WHEN SUBSTRING(score, 15, 1) ='(' THEN 
							CASE
								WHEN SUBSTRING(score, 22, 1) ='(' THEN SUBSTRING(score, 26, 6)
								ELSE SUBSTRING(score, 23, 6)
							END
						ELSE 
							CASE
								WHEN SUBSTRING(score, 19, 1) ='(' THEN SUBSTRING(score, 23, 6)
								ELSE SUBSTRING(score, 20, 6)
							END
					END
				ELSE 
					CASE
						WHEN SUBSTRING(score, 12, 1) ='(' THEN 
							CASE
								WHEN SUBSTRING(score, 19, 1) ='(' THEN SUBSTRING(score, 23, 6)
								ELSE SUBSTRING(score, 20, 6)
							END
						ELSE 
							CASE
								WHEN SUBSTRING(score, 16, 1) ='(' THEN SUBSTRING(score, 20, 6)
								ELSE SUBSTRING(score, 17, 6)
							END
					END
			END
	END
FROM dbo.atp_matches;

INSERT INTO [blady].[DIM_STATS]
SELECT DISTINCT * FROM
(
	SELECT DISTINCT 
		CASE 
			WHEN w_ace = '' THEN 0
			ELSE w_ace
		END, 
		CASE 
			WHEN w_bpSaved = '' THEN 0
			ELSE w_bpSaved
		END, 
		CASE 
			WHEN w_bpFaced = '' THEN 0
			ELSE w_bpFaced
		END, 
		CASE 
			WHEN w_1stWon = '' THEN 0
			ELSE w_1stWon
		END, 
		CASE 
			WHEN w_df = '' THEN 0
			ELSE w_df
		END
	FROM dbo.atp_matches
	UNION
	SELECT DISTINCT 
	CASE 
			WHEN l_ace = '' THEN 0
			ELSE l_ace
		END, 
		CASE 
			WHEN l_bpSaved = '' THEN 0
			ELSE l_bpSaved
		END, 
		CASE 
			WHEN l_bpFaced = '' THEN 0
			ELSE l_bpFaced
		END, 
		CASE 
			WHEN l_1stWon = '' THEN 0
			ELSE l_1stWon
		END, 
		CASE 
			WHEN l_df = '' THEN 0
			ELSE l_df
		END
	FROM dbo.atp_matches
) as t(a, b, c, d, e);

INSERT INTO [blady].[DIM_TIME]
SELECT DISTINCT tourney_date, SUBSTRING(tourney_date, 1, 4), SUBSTRING(tourney_date, 5, 2), SUBSTRING(tourney_date, 7, 2)
FROM dbo.atp_matches;

INSERT INTO [blady].[DIM_TOURNEY]
SELECT DISTINCT tourney_name, tourney_level, draw_size, surface
FROM dbo.atp_matches;

INSERT INTO [blady].[FACT_MATCHES]
SELECT tourney_date, w.PlayerID, l.PlayerID, TourneyID, ws.StatsID, ls.StatsID, ScoreID, [round], [minutes], best_of
FROM dbo.atp_matches 
	LEFT JOIN blady.DIM_SCORE ON COALESCE(Set1, '0') = COALESCE(dbo.NTH_ELEMENT(score, ' ', 0), '0') 
		AND COALESCE(Set2, '0') = COALESCE(dbo.NTH_ELEMENT(score, ' ', 1), '0') 
		AND COALESCE(Set3, '0') = COALESCE(dbo.NTH_ELEMENT(score, ' ', 2), '0') 
		AND COALESCE(Set4, '0') = COALESCE(dbo.NTH_ELEMENT(score, ' ', 3), '0') 
		AND COALESCE(Set5, '0') = COALESCE(dbo.NTH_ELEMENT(score, ' ', 4), '0')
	LEFT JOIN blady.DIM_PLAYER w ON w.PlayerName = winner_name
	LEFT JOIN blady.DIM_PLAYER l ON l.PlayerName = loser_name
	LEFT JOIN blady.DIM_TOURNEY t ON COALESCE(TourneyName, '0') = COALESCE(tourney_name, '0') 
		AND COALESCE(TourneyLevel, '0') = COALESCE(TourneyLevel, '0')
		AND COALESCE(DrawSize, 0) = COALESCE(draw_size, 0)
		AND COALESCE(t.Surface, '0') = COALESCE(t.surface, '0')
	LEFT JOIN blady.DIM_STATS ws ON ws.Aces = CASE WHEN w_ace = '' THEN 0 ELSE w_ace END
		AND ws.BreakpointsWon = CASE WHEN w_bpSaved = '' THEN 0 ELSE w_bpSaved END
		AND ws.BreakpointsFaced = CASE WHEN w_bpFaced = '' THEN 0 ELSE w_bpFaced END
		AND ws.FirstServeWon = CASE WHEN w_1stWon = '' THEN 0 ELSE w_1stWon END
		AND ws.DoubleFaults = CASE WHEN w_df = '' THEN 0 ELSE w_df END
	LEFT JOIN blady.DIM_STATS ls ON ls.Aces = CASE WHEN l_ace = '' THEN 0 ELSE l_ace END
		AND ls.BreakpointsWon = CASE WHEN l_bpSaved = '' THEN 0 ELSE l_bpSaved END
		AND ls.BreakpointsFaced = CASE WHEN l_bpFaced = '' THEN 0 ELSE l_bpFaced END
		AND ls.FirstServeWon = CASE WHEN l_1stWon = '' THEN 0 ELSE l_1stWon END
		AND ls.DoubleFaults = CASE WHEN l_df = '' THEN 0 ELSE l_df END
;

select * FROM blady.DIM_PLAYER;
select * from blady.DIM_TOURNEY;
select * from blady.DIM_SCORE order by ScoreID;
select * from blady.DIM_STATS;

select * from blady.DIM_PLAYER a
where PlayerName IN (select PlayerName from blady.DIM_PLAYER b where b.PlayerID != a.PlayerID);

select * from dbo.atp_matches;

ALTER TABLE blady.DIM_SCORE ADD CONSTRAINT pk_score_id PRIMARY KEY (ScoreID);
ALTER TABLE blady.DIM_TOURNEY ADD CONSTRAINT pk_tourney_id PRIMARY KEY (TourneyID);
ALTER TABLE blady.DIM_PLAYER ADD CONSTRAINT pk_player_id PRIMARY KEY (PlayerID);
ALTER TABLE blady.DIM_STATS ADD CONSTRAINT pk_stats_id PRIMARY KEY (StatsID);
ALTER TABLE blady.DIM_TIME ADD CONSTRAINT pk_time_id PRIMARY KEY (PK_TIME);
ALTER TABLE blady.FACT_MATCHES ADD CONSTRAINT fk_fm_scoreID FOREIGN KEY (ScoreID) REFERENCES blady.DIM_SCORE (ScoreID);
ALTER TABLE blady.FACT_MATCHES ADD CONSTRAINT fk_fm_winnerID FOREIGN KEY (WinnerID) REFERENCES blady.DIM_PLAYER (PlayerID);
ALTER TABLE blady.FACT_MATCHES ADD CONSTRAINT fk_fm_loserID FOREIGN KEY (LoserID) REFERENCES blady.DIM_PLAYER (PlayerID);
ALTER TABLE blady.FACT_MATCHES ADD CONSTRAINT fk_fm_wStatsID FOREIGN KEY (WinnerStatsID) REFERENCES blady.DIM_STATS (StatsID);
ALTER TABLE blady.FACT_MATCHES ADD CONSTRAINT fk_fm_lStatsID FOREIGN KEY (LoserStatsID) REFERENCES blady.DIM_STATS (StatsID);
ALTER TABLE blady.FACT_MATCHES ADD CONSTRAINT fk_fm_time FOREIGN KEY ([Date]) REFERENCES blady.DIM_TIME (PK_TIME);
ALTER TABLE blady.FACT_MATCHES ADD CONSTRAINT fk_fm_tourneyID FOREIGN KEY (TourneyID) REFERENCES blady.DIM_TOURNEY (TourneyID);