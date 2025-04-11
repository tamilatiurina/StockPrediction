-- PR 1 the same
CREATE PROCEDURE AddStockToPortfolio
    @UserId INT,
    @StockId INT,
    @Quantity INT,
    @PurchasePrice DECIMAL(18, 2),
    @PurchaseDate DATE,
    @SellPrice DECIMAL(18, 2) = NULL,
    @SellDate DATE = NULL
AS
BEGIN
    DECLARE @UserExists INT;
    DECLARE @StockExists INT;
    DECLARE @StockInPortfolio INT;

    SELECT @UserExists = COUNT(*)
    FROM [User]
    WHERE User_ID = @UserId;

    IF @UserExists = 0
    BEGIN
        PRINT 'User does not exist';
        RETURN;
    END

    SELECT @StockExists = COUNT(*)
    FROM Stock
    WHERE Stock_ID = @StockId;

    IF @StockExists = 0
    BEGIN
        PRINT 'Stock does not exist';
        RETURN;
    END

    SELECT @StockInPortfolio = COUNT(*)
    FROM Portfolio
    WHERE [User] = @UserId AND Stock = @StockId;

    IF @StockInPortfolio > 0
    BEGIN
        UPDATE Portfolio
        SET Quantaty = Quantaty + @Quantity,
            Purchase_Price = ((Purchase_Price * Quantaty) + (@PurchasePrice * @Quantity)) / (Quantaty + @Quantity),
            Purchase_Date = CASE
                                WHEN Purchase_Date > @PurchaseDate THEN Purchase_Date
                                ELSE @PurchaseDate
                            END,
            Sell_Price = @SellPrice,
            Sell_Date = @SellDate
        WHERE [User] = @UserId AND Stock = @StockId;

        PRINT 'Stock ' + CAST(@StockId AS VARCHAR(10)) + ' quantity updated for user ' + CAST(@UserId AS VARCHAR(10));
    END
    ELSE
    BEGIN
        INSERT INTO Portfolio (Stock, [User], Quantaty, Purchase_Date, Purchase_Price, Sell_Price, Sell_Date)
        VALUES (@StockId, @UserId, @Quantity, @PurchaseDate, @PurchasePrice, @SellPrice, @SellDate);

        PRINT 'Stock ' + CAST(@StockId AS VARCHAR(10)) + ' added to portfolio of user ' + CAST(@UserId AS VARCHAR(10)) + ', quantity: ' + CAST(@Quantity AS VARCHAR(10));
    END
END;

-- User doesn't exist
EXEC AddStockToPortfolio 100, 2, 50, 98.6, '2024-06-10', NULL, NULL;
-- Stock doesn't exist
EXEC AddStockToPortfolio 1, 15, 6, 100.05, '2025-08-19';
-- The stock is added to the portfolio for the first time
EXEC AddStockToPortfolio 1, 3, 1500, 500.81, '2025-01-23';
-- The quantity of stock is updated
EXEC AddStockToPortfolio 1, 2, 777, 231, '2025-01-22';
SELECT * FROM Portfolio;

DROP PROCEDURE AddStockToPortfolio;

--PR 2
CREATE PROCEDURE UpdatePortfolioBasedOnAI
    @UserId INT,
    @StockId INT
AS
BEGIN
    DECLARE @PredictedAction CHAR(1);
    DECLARE @PredictedValue DECIMAL(18, 2);
    DECLARE @ConfidenceLevel DECIMAL(18, 2);
    DECLARE @Quantity INT;
    DECLARE @PurchasePrice DECIMAL(18, 2);
    DECLARE @NewQuantity INT;
    DECLARE @UserExists INT;
    DECLARE @StockExists INT;

    SELECT @UserExists = COUNT(*)
    FROM [User]
    WHERE User_ID = @UserId;

    IF @UserExists = 0
    BEGIN
        PRINT 'User does not exist';
        RETURN;
    END

    SELECT @StockExists = COUNT(*)
    FROM Stock
    WHERE Stock_ID = @StockId;

    IF @StockExists = 0
    BEGIN
        PRINT 'Stock does not exist';
        RETURN;
    END

    SELECT @PredictedAction = Recommended_Action,
           @PredictedValue = Prediction_Value,
           @ConfidenceLevel = Confidence_Level
    FROM AI_Model_Result
    WHERE Stock_ID = @StockId
    AND [Date] = (SELECT MAX([Date]) FROM AI_Model_Result WHERE Stock_ID = @StockId);

    SELECT @Quantity = Quantaty, @PurchasePrice = Purchase_Price
    FROM Portfolio
    WHERE [User] = @UserId
    AND Stock = @StockId;

    IF @PredictedAction = 'B'
    BEGIN
        SET @NewQuantity = @Quantity + 10;
        UPDATE Portfolio
        SET Quantaty = @NewQuantity,
            Purchase_Price = (@PurchasePrice * @Quantity + @PredictedValue * 10) / @NewQuantity
        WHERE [User] = @UserId AND Stock = @StockId;
        PRINT 'Stock ' + CAST(@StockId AS VARCHAR(10)) + ' quantity updated to ' + CAST(@NewQuantity AS VARCHAR(10)) + ' (Bought 10 units)';
    END

    ELSE IF @PredictedAction = 'S'
    BEGIN
        IF @Quantity >= 5
        BEGIN
            SET @NewQuantity = @Quantity - 5;
            UPDATE Portfolio
            SET Quantaty = @NewQuantity
            WHERE [User] = @UserId AND Stock = @StockId;
            PRINT 'Stock ' + CAST(@StockId AS VARCHAR(10)) + ' quantity updated to ' + CAST(@NewQuantity AS VARCHAR(10)) + ' (Sold 5 units)';
        END
        ELSE
        BEGIN
            PRINT 'Not enough quantity to sell for Stock ' + CAST(@StockId AS VARCHAR(10));
        END
    END


    ELSE IF @PredictedAction = 'H'
    BEGIN
        PRINT 'No action taken for Stock ' + CAST(@StockId AS VARCHAR(10)) + ' (Hold)';
    END
END;

-- User doesn't exist
EXEC UpdatePortfolioBasedOnAI 100, 1;
-- Stock doesn't exist
EXEC UpdatePortfolioBasedOnAI 1, 100;
-- AI predicted to buy
EXEC UpdatePortfolioBasedOnAI 7, 6;
-- AI predicted to sell
EXEC UpdatePortfolioBasedOnAI 1, 6;
-- AI predicted to hold
EXEC UpdatePortfolioBasedOnAI 3, 5;

SELECT * FROM Portfolio;

DROP PROCEDURE UpdatePortfolioBasedOnAI;

--Trigger 1
CREATE TRIGGER trg_feedback_BIU
ON USER_FEEDBACK
INSTEAD OF INSERT, UPDATE
AS
BEGIN
    DECLARE @feedback_exists INT;
    DECLARE @prediction_exists INT;
    DECLARE @rating_score INT;

    SELECT @prediction_exists = COUNT(*)
    FROM AI_Model_Result
    WHERE Result_ID = (SELECT AI_Result_ID FROM INSERTED);

    IF @prediction_exists = 0
    BEGIN
        RAISERROR('Invalid AI Result ID. The prediction does not exist in the system', 16, 1);
        RETURN;
    END

    SELECT @feedback_exists = COUNT(*)
    FROM USER_FEEDBACK
    WHERE User_ID = (SELECT User_ID FROM INSERTED)
      AND AI_Result_ID = (SELECT AI_Result_ID FROM INSERTED)
      AND ID != (SELECT ID FROM INSERTED);

    IF @feedback_exists > 0
    BEGIN
        RAISERROR('Duplicate feedback is not allowed. A user can rate an AI result only once', 16, 1);
        RETURN;
    END

    SELECT @rating_score = (SELECT Rating_Score FROM INSERTED);

    IF @rating_score < 1 OR @rating_score > 5
    BEGIN
        RAISERROR('Invalid Rating Score. Rating must be between 1 and 5', 16, 1);
        RETURN;
    END


    IF EXISTS (SELECT * FROM INSERTED)
    BEGIN
        INSERT INTO USER_FEEDBACK (ID, Rating_Score, AI_Result_ID, User_ID)
        SELECT ID, Rating_Score, AI_Result_ID, User_ID
        FROM INSERTED;
    END


    IF EXISTS (SELECT * FROM DELETED)
    BEGIN
        UPDATE USER_FEEDBACK
        SET Rating_Score = (SELECT Rating_Score FROM INSERTED),
            AI_Result_ID = (SELECT AI_Result_ID FROM INSERTED),
            User_ID = (SELECT User_ID FROM INSERTED)
        WHERE ID = (SELECT ID FROM INSERTED);
    END
END;


-- No trigger
INSERT INTO USER_FEEDBACK (ID, Rating_Score, AI_Result_ID, User_ID) VALUES (9, 5, 9, 5);
-- Invalid AI result ID
INSERT INTO USER_FEEDBACK (ID, Rating_Score, AI_Result_ID, User_ID) VALUES (10, 5, 200, 5);
-- Duplicating feedback on the same AI result by the same user
INSERT INTO USER_FEEDBACK (ID, Rating_Score, AI_Result_ID, User_ID) VALUES (12, 3, 9, 5);
-- Invalid Rating Score
INSERT INTO USER_FEEDBACK (ID, Rating_Score, AI_Result_ID, User_ID) VALUES (13, 0, 3, 3);

--TRIGGER 2
CREATE TRIGGER trg_portfolio_BIU
ON Portfolio
INSTEAD OF INSERT, UPDATE
AS
BEGIN
    DECLARE @total_shares INT;
    DECLARE @recent_confidence DECIMAL(7, 2);

    SELECT @total_shares = SUM(Quantaty)
    FROM Portfolio
    WHERE Stock = (SELECT Stock FROM INSERTED) AND [User] = (SELECT [User] FROM INSERTED);

    IF @total_shares + (SELECT Quantaty FROM INSERTED) > 1000
    BEGIN
        RAISERROR('Cannot hold more than 1,000 shares of a single stock in the portfolio', 16, 1);
        RETURN;
    END

    SELECT @recent_confidence = Confidence_Level
    FROM AI_Model_Result
    WHERE Stock_ID = (SELECT Stock FROM INSERTED)
    ORDER BY [Date] DESC
    OFFSET 0 ROWS FETCH NEXT 1 ROWS ONLY;

    IF @recent_confidence < 70
    BEGIN
        RAISERROR('Cannot add stock with low-confidence AI predictions (below 70%)', 16, 1);
        RETURN;
    END

    INSERT INTO Portfolio (Quantaty, Purchase_Date, Purchase_Price, Sell_Date, Sell_Price, Stock, [User])
    SELECT Quantaty, Purchase_Date, Purchase_Price, Sell_Date, Sell_Price, Stock, [User]
    FROM INSERTED;
END;

--No trigger
INSERT INTO Portfolio (Quantaty, Purchase_Date, Purchase_Price, Sell_Date, Sell_Price, Stock, [User])
VALUES (11, '2020-06-23', 9.8, NULL, NULL, 6, 3);
--Amount > 1000
INSERT INTO Portfolio (Quantaty, Purchase_Date, Purchase_Price, Sell_Date, Sell_Price, Stock, [User])
VALUES (1001, '2020-06-23', 9.8, NULL, NULL, 1, 3);
--Confidence level <70%
DELETE FROM AI_Model_Result
WHERE Result_ID = 11;
INSERT INTO AI_Model_Result (Result_ID, [Date], Prediction_Value, Confidence_Level, Recommended_Action, Prediction_Type, Stock_ID, Performance_Metric, PAST_RESULT)
VALUES (11, CAST('2025-01-24' AS DATE), 560, 65.7, 'B', 2, 6, 3, 10);
INSERT INTO Portfolio (Quantaty, Purchase_Date, Purchase_Price, Sell_Date, Sell_Price, Stock, [User])
VALUES (43, CAST('2020-06-23' AS DATE), 9.8, NULL, NULL, 6, 2);

DROP TRIGGER trg_portfolio_BIU;



CREATE PROCEDURE updateModelResult
AS
BEGIN
    DECLARE @v_stock_id INT;
    DECLARE @v_user_id INT;
    DECLARE @v_prediction_value DECIMAL(18, 2);
    DECLARE @v_confidence_level DECIMAL(5, 2);
    DECLARE @v_metric_id INT;
    DECLARE @v_accuracy_rate DECIMAL(5, 2);
    DECLARE @v_precision DECIMAL(5, 2);
    DECLARE @v_recall DECIMAL(5, 2);
    DECLARE @v_new_prediction_value DECIMAL(18, 2);
    DECLARE @v_new_confidence_level DECIMAL(5, 2);

    DECLARE stock_cursor CURSOR FOR
    SELECT p.Stock, p.[User], amr.Prediction_Value, amr.Confidence_Level,
           sm.Metric_ID, sm.Accuracy_Rate, sm.Precision, sm.Recall
    FROM Portfolio p
    JOIN AI_Model_Result amr ON p.Stock = amr.Stock_ID
    JOIN Performance_Metric sm ON amr.Performance_Metric = sm.Metric_ID
    WHERE p.Sell_Date IS NULL;

    OPEN stock_cursor;

    FETCH NEXT FROM stock_cursor
    INTO @v_stock_id, @v_user_id, @v_prediction_value, @v_confidence_level,
         @v_metric_id, @v_accuracy_rate, @v_precision, @v_recall;

    WHILE @@FETCH_STATUS = 0
    BEGIN

        IF @v_accuracy_rate > 80 AND @v_precision > 70
        BEGIN
            SET @v_new_prediction_value = @v_prediction_value * 1.05;
            SET @v_new_confidence_level = @v_confidence_level + 5;
        END
        ELSE
        BEGIN
            SET @v_new_prediction_value = @v_prediction_value * 0.95;
            SET @v_new_confidence_level = @v_confidence_level - 5;
        END

        UPDATE AI_Model_Result
        SET Prediction_Value = @v_new_prediction_value,
            Confidence_Level = @v_new_confidence_level
        WHERE Stock_ID = @v_stock_id AND Prediction_Type = @v_metric_id;

        FETCH NEXT FROM stock_cursor
        INTO @v_stock_id, @v_user_id, @v_prediction_value, @v_confidence_level,
             @v_metric_id, @v_accuracy_rate, @v_precision, @v_recall;
    END

    CLOSE stock_cursor;
    DEALLOCATE stock_cursor;

END;


EXEC updateModelResult;
