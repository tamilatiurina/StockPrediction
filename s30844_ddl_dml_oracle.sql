-- Created by Vertabelo (http://vertabelo.com)
-- Last modification date: 2025-01-23 16:28:06.928

-- tables
-- Table: AI_Model_Result
CREATE TABLE AI_Model_Result (
    Result_ID integer  NOT NULL,
    "Date" date  NOT NULL,
    Prediction_Value number(10,2)  NOT NULL,
    Confidence_Level number(7,2)  NOT NULL,
    Recommended_Action char(1)  NOT NULL,
    Prediction_Type integer  NOT NULL,
    Stock_ID integer  NOT NULL,
    Performance_Metric integer  NOT NULL,
    Past_Result integer  NULL,
    CONSTRAINT check_Recommended_Action CHECK (Recommended_Action IN ('B', 'S', 'H')),
    CONSTRAINT AI_Model_Result_pk PRIMARY KEY (Result_ID)
) ;

-- Table: Industry
CREATE TABLE Industry (
    Industry_ID integer  NOT NULL,
    Name varchar2(50)  NOT NULL,
    CONSTRAINT Industry_pk PRIMARY KEY (Industry_ID)
) ;

-- Table: Market_News
CREATE TABLE Market_News (
    News_ID integer  NOT NULL,
    Name varchar2(30)  NOT NULL,
    CONSTRAINT Market_News_pk PRIMARY KEY (News_ID)
) ;

-- Table: Performance_Metric
CREATE TABLE Performance_Metric (
    Metric_ID integer  NOT NULL,
    Accuracy_Rate number(7,2)  NOT NULL,
    Precision number(7,2)  NOT NULL,
    Recall number(7,2)  NOT NULL,
    CONSTRAINT Performance_Metric_pk PRIMARY KEY (Metric_ID)
) ;

-- Table: Portfolio
CREATE TABLE Portfolio (
    Stock integer  NOT NULL,
    "User" integer  NOT NULL,
    Quantaty number(20,0)  NOT NULL,
    Sell_Price number(13,7)  NULL,
    Purchase_Date date  NOT NULL,
    Purchase_Price number(13,7)  NOT NULL,
    Sell_Date date  NULL,
    CONSTRAINT Portfolio_pk PRIMARY KEY (Stock,"User")
) ;

-- Table: Prediction_Type
CREATE TABLE Prediction_Type (
    ID integer  NOT NULL,
    Name varchar2(40)  NOT NULL,
    CONSTRAINT Prediction_Type_pk PRIMARY KEY (ID)
) ;

-- Table: Stock
CREATE TABLE Stock (
    Stock_ID integer  NOT NULL,
    Name varchar2(50)  NOT NULL,
    Ticker char(4)  NOT NULL,
    Sector char(1)  NOT NULL,
    Industry_ID integer  NOT NULL,
    CONSTRAINT check_Sector CHECK (Sector IN ('P', 'S', 'T', 'Q')),
    CONSTRAINT Stock_pk PRIMARY KEY (Stock_ID)
) ;

-- Table: Stock_News
CREATE TABLE Stock_News (
    News_ID integer  NOT NULL,
    Stock_ID integer  NOT NULL,
    "Date" date  NOT NULL,
    Headline varchar2(70)  NOT NULL,
    Content varchar2(3000)  NOT NULL,
    SentimentScore char(3)  NOT NULL,
    CONSTRAINT check_SentimentScore CHECK (SentimentScore IN ('Pst', 'Ngt', 'Ntr')),
    CONSTRAINT Stock_News_pk PRIMARY KEY (News_ID,Stock_ID)
) ;

-- Table: User
CREATE TABLE "User" (
    User_ID integer  NOT NULL,
    Username varchar2(50)  NOT NULL,
    Email varchar2(100)  NOT NULL,
    Password varchar2(64)  NOT NULL,
    CONSTRAINT User_pk PRIMARY KEY (User_ID)
) ;

-- Table: User_Feedback
CREATE TABLE User_Feedback (
    ID integer  NOT NULL,
    Rating_Score char(1)  NOT NULL,
    AI_Result_ID integer  NOT NULL,
    User_ID integer  NOT NULL,
    CONSTRAINT User_Feedback_pk PRIMARY KEY (ID)
) ;

-- Table: User_Following
CREATE TABLE User_Following (
    User_ID integer  NOT NULL,
    User_ID_Follower integer  NOT NULL,
    CONSTRAINT User_Following_pk PRIMARY KEY (User_ID,User_ID_Follower)
) ;

-- Table: Watchlist
CREATE TABLE Watchlist (
    Watchlist_ID integer  NOT NULL,
    "User" integer  NOT NULL,
    Stock integer  NOT NULL,
    CONSTRAINT Watchlist_pk PRIMARY KEY (Watchlist_ID)
) ;

-- foreign keys
-- Reference: AI_Model_Result_PAst (table: AI_Model_Result)
ALTER TABLE AI_Model_Result ADD CONSTRAINT AI_Model_Result_PAst
    FOREIGN KEY (Past_Result)
    REFERENCES AI_Model_Result (Result_ID);

-- Reference: AI_Model_Results_Stock (table: AI_Model_Result)
ALTER TABLE AI_Model_Result ADD CONSTRAINT AI_Model_Results_Stock
    FOREIGN KEY (Stock_ID)
    REFERENCES Stock (Stock_ID);

-- Reference: AI_Prediction_Type (table: AI_Model_Result)
ALTER TABLE AI_Model_Result ADD CONSTRAINT AI_Prediction_Type
    FOREIGN KEY (Prediction_Type)
    REFERENCES Prediction_Type (ID);

-- Reference: Performance_Metric (table: AI_Model_Result)
ALTER TABLE AI_Model_Result ADD CONSTRAINT Performance_Metric
    FOREIGN KEY (Performance_Metric)
    REFERENCES Performance_Metric (Metric_ID);

-- Reference: Portfolio_Stock (table: Portfolio)
ALTER TABLE Portfolio ADD CONSTRAINT Portfolio_Stock
    FOREIGN KEY (Stock)
    REFERENCES Stock (Stock_ID);

-- Reference: Portfolio_User (table: Portfolio)
ALTER TABLE Portfolio ADD CONSTRAINT Portfolio_User
    FOREIGN KEY ("User")
    REFERENCES "User" (User_ID);

-- Reference: Stock_Industry (table: Stock)
ALTER TABLE Stock ADD CONSTRAINT Stock_Industry
    FOREIGN KEY (Industry_ID)
    REFERENCES Industry (Industry_ID);

-- Reference: Stock_News_Market_News (table: Stock_News)
ALTER TABLE Stock_News ADD CONSTRAINT Stock_News_Market_News
    FOREIGN KEY (News_ID)
    REFERENCES Market_News (News_ID);

-- Reference: Stock_News_Stock (table: Stock_News)
ALTER TABLE Stock_News ADD CONSTRAINT Stock_News_Stock
    FOREIGN KEY (Stock_ID)
    REFERENCES Stock (Stock_ID);

-- Reference: User_Feedback_AI_Model_Result (table: User_Feedback)
ALTER TABLE User_Feedback ADD CONSTRAINT User_Feedback_AI_Model_Result
    FOREIGN KEY (AI_Result_ID)
    REFERENCES AI_Model_Result (Result_ID);

-- Reference: User_Feedback_User (table: User_Feedback)
ALTER TABLE User_Feedback ADD CONSTRAINT User_Feedback_User
    FOREIGN KEY (User_ID)
    REFERENCES "User" (User_ID);

-- Reference: User_Following_User (table: User_Following)
ALTER TABLE User_Following ADD CONSTRAINT User_Following_User
    FOREIGN KEY (User_ID_Follower)
    REFERENCES "User" (User_ID);

-- Reference: User_Following_User2 (table: User_Following)
ALTER TABLE User_Following ADD CONSTRAINT User_Following_User2
    FOREIGN KEY (User_ID)
    REFERENCES "User" (User_ID);

-- Reference: Watchlist_Stock (table: Watchlist)
ALTER TABLE Watchlist ADD CONSTRAINT Watchlist_Stock
    FOREIGN KEY (Stock)
    REFERENCES Stock (Stock_ID);

-- Reference: Watchlist_User (table: Watchlist)
ALTER TABLE Watchlist ADD CONSTRAINT Watchlist_User
    FOREIGN KEY ("User")
    REFERENCES "User" (User_ID);

-- End of file.




-- Insert records into Prediction_Type
INSERT INTO PREDICTION_TYPE (ID, Name) VALUES (1, 'Price go up');
INSERT INTO PREDICTION_TYPE (ID, Name) VALUES (2, 'Price go down');
INSERT INTO PREDICTION_TYPE (ID, Name) VALUES (3, 'Volatility forecast');
INSERT INTO PREDICTION_TYPE (ID, Name) VALUES (4, 'Divident forecast');
INSERT INTO PREDICTION_TYPE (ID, Name) VALUES (5, 'Volume spike');
INSERT INTO PREDICTION_TYPE (ID, Name) VALUES (6, 'Price stagnation');

-- Insert records into Performance_Metric
INSERT INTO Performance_Metric (Metric_ID, Accuracy_Rate, Precision, Recall)
VALUES (1, 98.5, 97.3, 96.4);
INSERT INTO Performance_Metric (Metric_ID, Accuracy_Rate, Precision, Recall)
VALUES (2, 95.4, 94.1, 93.7);
INSERT INTO Performance_Metric (Metric_ID, Accuracy_Rate, Precision, Recall)
VALUES (3, 92.8, 91.5, 90.2);
INSERT INTO Performance_Metric (Metric_ID, Accuracy_Rate, Precision, Recall)
VALUES (4, 89.7, 88.3, 87.5);
INSERT INTO Performance_Metric (Metric_ID, Accuracy_Rate, Precision, Recall)
VALUES (5, 89.7, 88.3, 87.5);


----------------------------------------------------------------------


-- Insert records into Industry
INSERT INTO Industry (Industry_ID, Name) VALUES (1, 'Technology');
INSERT INTO Industry (Industry_ID, Name) VALUES (2, 'Finance');
INSERT INTO Industry (Industry_ID, Name) VALUES (3, 'Real Estate');
INSERT INTO Industry (Industry_ID, Name) VALUES (4, 'Healthcare');
INSERT INTO Industry (Industry_ID, Name) VALUES (5, 'Materials');
INSERT INTO Industry (Industry_ID, Name) VALUES (6, 'Energy');
INSERT INTO Industry (Industry_ID, Name) VALUES (7, 'Communication');


-- Insert records into Stock
INSERT INTO Stock (Stock_ID, Name, Ticker, Sector, Industry_ID)
VALUES (1, 'Conoco Phillips', 'COP', 'P', 6);
INSERT INTO Stock (Stock_ID, Name, Ticker, Sector, Industry_ID)
VALUES (2, 'Canadian Natural Resources Limited', 'CNQ', 'P', 6);
INSERT INTO Stock (Stock_ID, Name, Ticker, Sector, Industry_ID)
VALUES (3, 'Zoetis Inc.', 'ZTS', 'T', 4);
INSERT INTO Stock (Stock_ID, Name, Ticker, Sector, Industry_ID)
VALUES (4, 'Apple Inc.', 'AAPL', 'S', 1);
INSERT INTO Stock (Stock_ID, Name, Ticker, Sector, Industry_ID)
VALUES (5, 'American Tower Corporation', 'AMT', 'T', 3);
INSERT INTO Stock (Stock_ID, Name, Ticker, Sector, Industry_ID)
VALUES (6, 'BlackRock, Inc.', 'BLK', 'Q', 2);

-- Insert records into AI_Model_Result
INSERT INTO AI_Model_Result (Result_ID, "Date", Prediction_Value, Confidence_Level, Recommended_Action, Prediction_Type, Stock_ID, Performance_Metric, PAST_RESULT)
VALUES (1, TO_DATE('2024-06-01','YYYY-MM-DD'), 123.45, 95.5, 'B', 1, 1, 1, NULL);
INSERT INTO AI_Model_Result (Result_ID, "Date", Prediction_Value, Confidence_Level, Recommended_Action, Prediction_Type, Stock_ID, Performance_Metric, PAST_RESULT)
VALUES (2, TO_DATE('2024-06-02','YYYY-MM-DD'), 150.75, 92.3, 'S', 2, 2, 2, NULL);
INSERT INTO AI_Model_Result (Result_ID, "Date", Prediction_Value, Confidence_Level, Recommended_Action, Prediction_Type, Stock_ID, Performance_Metric, PAST_RESULT)
VALUES (3, TO_DATE('2024-06-02','YYYY-MM-DD'), 200.50, 90.2, 'H', 1, 3, 2, NULL);
INSERT INTO AI_Model_Result (Result_ID, "Date", Prediction_Value, Confidence_Level, Recommended_Action, Prediction_Type, Stock_ID, Performance_Metric, PAST_RESULT)
VALUES (4, TO_DATE('2024-06-04','YYYY-MM-DD'),  175.85, 88.9, 'B', 1, 4, 3, NULL);
INSERT INTO AI_MODEL_RESULT (Result_ID, "Date", Prediction_Value, Confidence_Level, Recommended_Action, Prediction_Type, Stock_ID, Performance_Metric, PAST_RESULT)
VALUES (5, TO_DATE('2024-06-05','YYYY-MM-DD'),  210.30, 91.7, 'S', 2, 4, 3, 4);
INSERT INTO AI_Model_Result (Result_ID, "Date", Prediction_Value, Confidence_Level, Recommended_Action, Prediction_Type, Stock_ID, Performance_Metric, PAST_RESULT)
VALUES (6, TO_DATE('2024-06-06','YYYY-MM-DD'),  195.60, 89.8, 'H', 1, 4, 4, 5);
INSERT INTO AI_Model_Result (Result_ID, "Date", Prediction_Value, Confidence_Level, Recommended_Action, Prediction_Type, Stock_ID, Performance_Metric, PAST_RESULT)
VALUES (7, TO_DATE('2024-06-07','YYYY-MM-DD'),  185.20, 92.5, 'B', 1, 5, 5, NULL);
INSERT INTO AI_Model_Result (Result_ID, "Date", Prediction_Value, Confidence_Level, Recommended_Action, Prediction_Type, Stock_ID, Performance_Metric, PAST_RESULT)
VALUES (8, TO_DATE('2024-06-08','YYYY-MM-DD'),  190.75, 87.3, 'S', 2, 5, 2, 7);
INSERT INTO AI_Model_Result (Result_ID, "Date", Prediction_Value, Confidence_Level, Recommended_Action, Prediction_Type, Stock_ID, Performance_Metric, PAST_RESULT)
VALUES (9, TO_DATE('2024-06-09','YYYY-MM-DD'),  220.40, 94.1, 'H', 2, 6, 4, NULL);
INSERT INTO AI_Model_Result (Result_ID, "Date", Prediction_Value, Confidence_Level, Recommended_Action, Prediction_Type, Stock_ID, Performance_Metric, PAST_RESULT)
VALUES (10, TO_DATE('2024-06-10','YYYY-MM-DD'),  205.55, 93.0, 'B', 2, 6, 3, 9);




-- Insert records into Market_News
INSERT INTO Market_News (News_ID) VALUES (1);
INSERT INTO Market_News (News_ID) VALUES (2);
INSERT INTO Market_News (News_ID) VALUES (3);
INSERT INTO Market_News (News_ID) VALUES (4);
INSERT INTO Market_News (News_ID) VALUES (5);
INSERT INTO Market_News (News_ID) VALUES (6);

--------------------------------------------------------------

-- Insert records into "User"
INSERT INTO "User" (User_ID, Username, Email, Password) VALUES (1, 'john_brown', 'john.brown@gmail.com', '1234567890123');
INSERT INTO "User" (User_ID, Username, Email, Password) VALUES (2, 'rose.miller', 'roseee1999@gmail.com', 'rose23051999');
INSERT INTO "User" (User_ID, Username, Email, Password) VALUES (3, 'drake.williams2205', 'williamsdrake2205@gmail.com', 'abcdefghigkL');
INSERT INTO "User" (User_ID, Username, Email, Password) VALUES (4, 'wilson_kate98', 'katykatywilli@gmail.com', 'thebestkate');
INSERT INTO "User" (User_ID, Username, Email, Password) VALUES (5, 'emma.robertss', 'emmaroberts2024@gmail.com', '@robertsJKL');
INSERT INTO "User" (User_ID, Username, Email, Password) VALUES (6, 'gigi_hadid', 'hadid.gigi@gmail.com', 'Gmlk8!5th');
INSERT INTO "User" (User_ID, Username, Email, Password) VALUES (7, 'kyliejenner', 'kyliejenner@gmail.com', 'plk0978PLK');
INSERT INTO "User" (User_ID, Username, Email, Password) VALUES (8, '777.lola', 'lola.09.davis@gmail.com', 'password1');

-- Insert records into Portfolio
INSERT INTO Portfolio (Quantaty, Purchase_Date, Purchase_Price, Sell_Date, Sell_Price, Stock, "User")
VALUES (1000, TO_DATE('2023-01-01','YYYY-MM-DD'), 98.8, TO_DATE('2023-05-07','YYYY-MM-DD'), 100.9, 1, 1);
INSERT INTO Portfolio (Quantaty, Purchase_Date, Purchase_Price, Sell_Date, Sell_Price, Stock, "User")
VALUES (350, TO_DATE('2024-07-10','YYYY-MM-DD'), 47.48 , NULL, NULL, 2, 1);
INSERT INTO Portfolio (Quantaty, Purchase_Date, Purchase_Price, Sell_Date, Sell_Price, Stock, "User")
VALUES (66, TO_DATE('2021-06-23','YYYY-MM-DD'), 95.76, NULL, NULL , 4, 1);

INSERT INTO Portfolio (Quantaty, Purchase_Date, Purchase_Price, Sell_Date, Sell_Price, Stock, "User")
VALUES (2000, TO_DATE('2023-02-01','YYYY-MM-DD'), 98.8, NULL, NULL, 1, 8);
INSERT INTO Portfolio (Quantaty, Purchase_Date, Purchase_Price, Sell_Date, Sell_Price, Stock, "User")
VALUES (1000, TO_DATE('2023-05-01','YYYY-MM-DD'), 100.8, NULL, NULL, 1, 6);

INSERT INTO Portfolio (Quantaty, Purchase_Date, Purchase_Price, Sell_Date, Sell_Price, Stock, "User")
VALUES (1000, TO_DATE('2024-12-4','YYYY-MM-DD'), 198.78, TO_DATE('2024-12-12','YYYY-MM-DD'), 180.3, 5, 7);
INSERT INTO Portfolio (Quantaty, Purchase_Date, Purchase_Price, Sell_Date, Sell_Price, Stock, "User")
VALUES (200, TO_DATE('2023-08-10','YYYY-MM-DD'), 783.65, NULL, NULL , 6, 7);

INSERT INTO Portfolio (Quantaty, Purchase_Date, Purchase_Price, Sell_Date, Sell_Price, Stock, "User")
VALUES (11, TO_DATE('2020-06-23','YYYY-MM-DD'), 9.8, NULL, NULL , 5, 3);




-- Insert records into Stock_News
INSERT INTO Stock_News (News_ID, Stock_ID, "Date", Headline, Content, SentimentScore)
VALUES (1, 5, TO_DATE('2024-06-11','YYYY-MM-DD'), 'Here’s Why American Tower Corporation (AMT) Fell in Q1', 'American Tower Corporation (NYSE:AMT) detracted from performance due to a move higher in interest rates throughout the first quarter. Recall that REITs are viewed as benefitting from lower interest rates and therefore tend to perform poorly as interest rates rise.', 'Ntr');
---------------------------------------------------------------------------------------------------------------------
INSERT INTO Stock_News (News_ID, Stock_ID, "Date", Headline, Content, SentimentScore)
VALUES (2, 2, TO_DATE('2015-10-06','YYYY-MM-DD'), 'Canadian Natural Resources Limited Takes Advantage of ConocoPhillips', 'According to Bloomberg, ConocoPhillips (NYSE:COP) is nearing a deal to sell over $1 billion in Canadian assets, with an agreement expected this week. The major rumoured buyer is Canadian Natural Resources Limited (TSX:CNQ)(NYSE:CNQ). In an environment where most oil majors are looking to offload non-core assets, companies willing to scoop up these various properties could acquire new revenue streams at attractive discounts.', 'Pst');
INSERT INTO Stock_News (News_ID, Stock_ID, "Date", Headline, Content, SentimentScore)
VALUES (2, 1, TO_DATE('2015-10-06','YYYY-MM-DD'), 'Canadian Natural Resources Limited Takes Advantage of ConocoPhillips', 'According to Bloomberg, ConocoPhillips (NYSE:COP) is nearing a deal to sell over $1 billion in Canadian assets, with an agreement expected this week. The major rumoured buyer is Canadian Natural Resources Limited (TSX:CNQ)(NYSE:CNQ). In an environment where most oil majors are looking to offload non-core assets, companies willing to scoop up these various properties could acquire new revenue streams at attractive discounts.', 'Pst');
INSERT INTO Stock_News (News_ID, Stock_ID, "Date", Headline, Content, SentimentScore)
VALUES (5, 6, TO_DATE('2025-01-23','YYYY-MM-DD'), 'BlackRock’s Fink sees potential risks', 'BlackRock CEO Larry Fink said President Donald Trump’s efforts to unleash capital in the private sector could have unintended consequences that would hurt the stock market.', 'Ngt');
INSERT INTO Stock_News (News_ID, Stock_ID, "Date", Headline, Content, SentimentScore)
VALUES (6, 4, TO_DATE('2025-01-23','YYYY-MM-DD'), 'How to use options to play small caps, Apple earnings', 'Small caps (^RUT) have rallied about 18% over the last year. But it has been anything but a smooth ride. To hedge against the downside, BayCrest managing director David Boole recommends buying puts on the iShares Russell 2000 ETF (IWM).', 'Ntr');

-- Insert records into Watchlist
INSERT INTO Watchlist (Watchlist_ID, "User", Stock) VALUES (1, 1, 1);
------------------------------------------------------------------------
INSERT INTO Watchlist (Watchlist_ID, "User", Stock) VALUES (2, 1, 2);
INSERT INTO Watchlist (Watchlist_ID, "User", Stock) VALUES (3, 1, 3);

INSERT INTO Watchlist (Watchlist_ID, "User", Stock) VALUES (4, 2, 4);
INSERT INTO Watchlist (Watchlist_ID, "User", Stock) VALUES (5, 2, 5);
INSERT INTO Watchlist (Watchlist_ID, "User", Stock) VALUES (6, 2, 6);

INSERT INTO Watchlist (Watchlist_ID, "User", Stock) VALUES (7, 3, 1);
INSERT INTO Watchlist (Watchlist_ID, "User", Stock) VALUES (8, 3, 2);
INSERT INTO Watchlist (Watchlist_ID, "User", Stock) VALUES (9, 3, 3);

INSERT INTO Watchlist (Watchlist_ID, "User", Stock) VALUES (10, 4, 4);
INSERT INTO Watchlist (Watchlist_ID, "User", Stock) VALUES (11, 4, 5);
INSERT INTO Watchlist (Watchlist_ID, "User", Stock) VALUES (12, 4, 6);

INSERT INTO Watchlist (Watchlist_ID, "User", Stock) VALUES (13, 5, 1);

INSERT INTO Watchlist (Watchlist_ID, "User", Stock) VALUES (14, 6, 2);

INSERT INTO Watchlist (Watchlist_ID, "User", Stock) VALUES (15, 7, 3);

-- Insert records into User_Following
INSERT INTO USER_FOLLOWING (User_ID, User_ID_Follower) VALUES (1, 2);
INSERT INTO USER_FOLLOWING (User_ID, User_ID_Follower) VALUES (2, 1);
INSERT INTO USER_FOLLOWING (User_ID, User_ID_Follower) VALUES (1, 3);
INSERT INTO USER_FOLLOWING (User_ID, User_ID_Follower) VALUES (4, 5);
INSERT INTO USER_FOLLOWING (User_ID, User_ID_Follower) VALUES (5, 6);
INSERT INTO USER_FOLLOWING (User_ID, User_ID_Follower) VALUES (7, 8);
INSERT INTO USER_FOLLOWING (User_ID, User_ID_Follower) VALUES (8, 7);

-- Insert records into User_Feedback
INSERT INTO USER_FEEDBACK (ID, Rating_Score, AI_Result_ID, User_ID) VALUES (1, 3, 1, 1);
INSERT INTO USER_FEEDBACK (ID, Rating_Score, AI_Result_ID, User_ID) VALUES (2, 4, 1, 3);
INSERT INTO USER_FEEDBACK (ID, Rating_Score, AI_Result_ID, User_ID) VALUES (3, 2, 5, 1);
INSERT INTO USER_FEEDBACK (ID, Rating_Score, AI_Result_ID, User_ID) VALUES (4, 5, 1, 4);
INSERT INTO USER_FEEDBACK (ID, Rating_Score, AI_Result_ID, User_ID) VALUES (5, 4, 5, 8);
INSERT INTO USER_FEEDBACK (ID, Rating_Score, AI_Result_ID, User_ID) VALUES (6, 1, 10, 8);
INSERT INTO USER_FEEDBACK (ID, Rating_Score, AI_Result_ID, User_ID) VALUES (7, 3, 8, 8);
INSERT INTO USER_FEEDBACK (ID, Rating_Score, AI_Result_ID, User_ID) VALUES (8, 5, 10, 5);

select * from "User";