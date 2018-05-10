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

BULK INSERT SchoolsTemp
    FROM 'C:\CSVData\Schools.csv'
    WITH
    (
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',  --CSV field delimiter
    ROWTERMINATOR = '\n',   --Use to shift the control to next row
    ERRORFILE = 'C:\CSVDATA\SchoolsErrorRows.csv',
    TABLOCK
    )