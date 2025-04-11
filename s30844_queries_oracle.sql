--PROCEDURE 1
-- AddStockToPortfolio procedure adds a stock to a user's portfolio.
-- If the stock is already in the portfolio,
-- it updates the quantity and calculates the average purchase price.
-- Otherwise, it inserts a new stock into the portfolio.
-- It validates stock and portfolio existence and ensures the quantity is greater than 0
CREATE OR REPLACE PROCEDURE AddStockToPortfolio (
    v_UserId IN NUMBER,
    v_StockId IN NUMBER,
    v_Quantity IN NUMBER,
    v_PurchasePrice IN NUMBER,
    v_PurchaseDate IN DATE,
    v_SellPrice IN NUMBER DEFAULT NULL,
    v_SellDate IN DATE DEFAULT NULL
) AS
    v_UserExists NUMBER;
    v_StockExists NUMBER;
    v_StockInPortfolio NUMBER;
BEGIN
    SELECT COUNT(*)
    INTO v_UserExists
    FROM "User"
    WHERE User_ID = v_UserId;

    IF v_UserExists = 0 THEN
        DBMS_OUTPUT.PUT_LINE('User does not exist');
        RETURN;
    END IF;

    SELECT COUNT(*)
    INTO v_StockExists
    FROM Stock
    WHERE Stock_ID = v_StockId;

    IF v_StockExists = 0 THEN
        DBMS_OUTPUT.PUT_LINE('Stock does not exist');
        RETURN;
    END IF;

    SELECT COUNT(*)
    INTO v_StockInPortfolio
    FROM Portfolio
    WHERE "User" = v_UserId AND Stock = v_StockId;

    IF v_StockInPortfolio > 0 THEN
        UPDATE Portfolio
        SET Quantaty = Quantaty + v_Quantity,
            Purchase_Price = ((Purchase_Price * Quantaty) + (v_PurchasePrice * v_Quantity)) / (Quantaty + v_Quantity),
            Purchase_Date = CASE
                                WHEN Purchase_Date > v_PurchaseDate THEN Purchase_Date
                                ELSE v_PurchaseDate
                            END,
            Sell_Price = v_SellPrice,
            Sell_Date = v_SellDate
        WHERE "User" = v_UserId AND Stock = v_StockId;

        DBMS_OUTPUT.PUT_LINE('Stock ' || v_StockId || ' quantity updated for user ' || v_UserId);
    ELSE
        INSERT INTO Portfolio (Stock, "User", Quantaty, Purchase_Date, Purchase_Price, Sell_Price, Sell_Date)
        VALUES (v_StockId, v_UserId, v_Quantity, v_PurchaseDate, v_PurchasePrice, v_SellPrice, v_SellDate);

        DBMS_OUTPUT.PUT_LINE('Stock ' || v_StockId || ' added to portfolio of user ' || v_UserId || ', quantity: ' || v_Quantity);
    END IF;
END;

--User doesn't exist
CALL AddStockToPortfolio(100, 2,50, 98.6, TO_DATE('2024-06-10','YYYY-MM-DD'), NULL, NULL);
--Stock doesn't exist
CALL AddStockToPortfolio(1, 15,6, 100.05, TO_DATE('2025-08-19','YYYY-MM-DD'));
--The stock is added to the portfolio at the first time
CALL AddStockToPortfolio(1, 3,1500, 500.81, TO_DATE('2025-01-23','YYYY-MM-DD'));
--The quantity of stock is updated
CALL AddStockToPortfolio(1, 2,777, 231, TO_DATE('2025-01-22','YYYY-MM-DD'));

select * from PORTFOLIO;

DROP PROCEDURE AddStockToPortfolio;

--PROCEDURE 2
-- UpdatePortfolioBasedOnAI procedure automatically rebalances a user's portfolio based on
-- AI predictions about stock performance and the actual performance of stocks
-- in the portfolio over time.
-- Rebalancing can involve buying more of stocks that have performed well
-- and selling stocks that have underperformed or just hold them
CREATE OR REPLACE PROCEDURE UpdatePortfolioBasedOnAI (
    v_UserId IN NUMBER,
    v_StockId IN NUMBER
) AS
    v_PredictedAction CHAR(1);
    v_PredictedValue NUMBER;
    v_ConfidenceLevel NUMBER;
    v_Quantity NUMBER;
    v_PurchasePrice NUMBER;
    v_NewQuantity NUMBER;
    v_UserExists NUMBER;
    v_StockExists NUMBER;
BEGIN

    SELECT COUNT(*) INTO v_UserExists
    FROM "User"
    WHERE User_ID = v_UserId;

    IF v_UserExists = 0 THEN
        RAISE_APPLICATION_ERROR(-20001, 'User does not exist');
    END IF;

    SELECT COUNT(*) INTO v_StockExists
    FROM Stock
    WHERE Stock_ID = v_StockId;

    IF v_StockExists = 0 THEN
        RAISE_APPLICATION_ERROR(-20002, 'Stock does not exist');
    END IF;

    SELECT Recommended_Action, Prediction_Value, Confidence_Level
    INTO v_PredictedAction, v_PredictedValue, v_ConfidenceLevel
    FROM AI_Model_Result
    WHERE Stock_ID = v_StockId
    AND ("Date" = (SELECT MAX("Date") FROM AI_Model_Result WHERE Stock_ID = v_StockId));

    SELECT Quantaty, Purchase_Price
    INTO v_Quantity, v_PurchasePrice
    FROM Portfolio
    WHERE "User" = v_UserId
    AND Stock = v_StockId;

    IF v_PredictedAction = 'B' THEN
        v_NewQuantity := v_Quantity + 10;
        UPDATE Portfolio
        SET Quantaty = v_NewQuantity,
            Purchase_Price = (v_PurchasePrice * v_Quantity + v_PredictedValue * 10) / v_NewQuantity -- Update purchase price
        WHERE "User" = v_UserId
        AND Stock = v_StockId;
        DBMS_OUTPUT.PUT_LINE('Stock ' || v_StockId || ' quantity updated to ' || v_NewQuantity || ' (Bought 10 units)');

    ELSIF v_PredictedAction = 'S' THEN
        IF v_Quantity >= 5 THEN
            v_NewQuantity := v_Quantity - 5;
            UPDATE Portfolio
            SET Quantaty = v_NewQuantity
            WHERE "User" = v_UserId
            AND Stock = v_StockId;
            DBMS_OUTPUT.PUT_LINE('Stock ' || v_StockId || ' quantity updated to ' || v_NewQuantity || ' (Sold 5 units)');
        ELSE
            DBMS_OUTPUT.PUT_LINE('Not enough quantity to sell for Stock ' || v_StockId);
        END IF;

    ELSIF v_PredictedAction = 'H' THEN
        DBMS_OUTPUT.PUT_LINE('No action taken for Stock ' || v_StockId || ' (Hold)');
    END IF;
END;

--User doesn't exist
CALL UpdatePortfolioBasedOnAI(100, 1);
--Stock doesn't exist
CALL UpdatePortfolioBasedOnAI(1, 100);
--AI predicted to buy
CALL UpdatePortfolioBasedOnAI(7, 6);
--AI predicted to sell
CALL UpdatePortfolioBasedOnAI(1, 6);
--AI predicted to hold
CALL UpdatePortfolioBasedOnAI(3, 5);

select * from PORTFOLIO;

DROP PROCEDURE UpdatePortfolioBasedOnAI;

--TRIGGER 1
--This BEFORE INSERT OR UPDATE trigger prevent user to have insert the feedback of the AI result
-- if the user had already given the feedback on these specific result, or if they gave invalid score
--which is not between 1 and 5 or if the given AI result doesn't exist
CREATE TRIGGER trg_feedback_BIU
BEFORE INSERT OR UPDATE ON USER_FEEDBACK
FOR EACH ROW
DECLARE
    feedback_exists NUMBER;
    prediction_exists NUMBER;
BEGIN
    SELECT COUNT(*)
    INTO prediction_exists
    FROM AI_Model_Result
    WHERE Result_ID = :NEW.AI_Result_ID;

    IF prediction_exists = 0 THEN
        RAISE_APPLICATION_ERROR(
            -20002,
            'Invalid AI Result ID. The prediction does not exist in the system'
        );
    END IF;

    SELECT COUNT(*)
    INTO feedback_exists
    FROM User_Feedback
    WHERE User_ID = :NEW.User_ID
      AND AI_Result_ID = :NEW.AI_Result_ID
      AND ID != :NEW.ID;

    IF feedback_exists > 0 THEN
        RAISE_APPLICATION_ERROR(
            -20003,
            'Duplicate feedback is not allowed. A user can rate an AI result only once'
        );
    END IF;

    IF TO_NUMBER(:NEW.Rating_Score) < 1 OR TO_NUMBER(:NEW.Rating_Score) > 5 THEN
        RAISE_APPLICATION_ERROR(
            -20004,
            'Invalid Rating Score. Rating must be between 1 and 5'
        );
    END IF;
END;

--No trigger
INSERT INTO USER_FEEDBACK (ID, Rating_Score, AI_Result_ID, User_ID) VALUES (9, 5, 9, 5);
--Invalid AI result ID
INSERT INTO USER_FEEDBACK (ID, Rating_Score, AI_Result_ID, User_ID) VALUES (10, 5, 200, 5);
--Duplicating feedback on the same AI result ny the same user
INSERT INTO USER_FEEDBACK (ID, Rating_Score, AI_Result_ID, User_ID) VALUES (12, 3, 9, 5);
--Invalid Score
INSERT INTO USER_FEEDBACK (ID, Rating_Score, AI_Result_ID, User_ID) VALUES (13, 0, 3, 3);

DROP TRIGGER trg_feedback_BIU;

--TRIGGER 2
--This BEFORE OR INSERT TRIGGER prevents users to hold more than 1,000 shares of a single stock in their portfolio
--and add a stock to their portfolio if the Confidence_Level of the AI prediction for that stock is below 70%
CREATE OR REPLACE TRIGGER trg_portfolio_BIU
BEFORE INSERT OR UPDATE ON Portfolio
FOR EACH ROW
DECLARE
    total_shares INTEGER := 0;
    recent_confidence NUMBER(7, 2);
BEGIN
    SELECT SUM(Quantaty)
    INTO total_shares
    FROM Portfolio
    WHERE Stock = :NEW.Stock AND "User" = :NEW."User";

    IF total_shares + :NEW.Quantaty > 1000 THEN
        RAISE_APPLICATION_ERROR(-20013, 'Cannot hold more than 1,000 shares of a single stock in the portfolio');
    END IF;

    SELECT Confidence_Level
    INTO recent_confidence
    FROM AI_Model_Result
    WHERE Stock_ID = :NEW.Stock
    ORDER BY "Date" DESC
    FETCH FIRST 1 ROWS ONLY;

    IF recent_confidence < 70 THEN
        RAISE_APPLICATION_ERROR(-20014, 'Cannot add stock with low-confidence AI predictions (below 70%)');
    END IF;
END;


--No trigger
INSERT INTO Portfolio (Quantaty, Purchase_Date, Purchase_Price, Sell_Date, Sell_Price, Stock, "User")
VALUES (11, TO_DATE('2020-06-23','YYYY-MM-DD'), 9.8, NULL, NULL , 6, 3);
--Amount > 1000
INSERT INTO Portfolio (Quantaty, Purchase_Date, Purchase_Price, Sell_Date, Sell_Price, Stock, "User")
VALUES (1001, TO_DATE('2020-06-23','YYYY-MM-DD'), 9.8, NULL, NULL , 1, 3);
--Confidence level <70%
INSERT INTO AI_Model_Result (Result_ID, "Date", Prediction_Value, Confidence_Level, Recommended_Action, Prediction_Type, Stock_ID, Performance_Metric, PAST_RESULT)
VALUES (11, TO_DATE('2025-01-24','YYYY-MM-DD'),  560, 65.7, 'B', 2, 6, 3, 10);

INSERT INTO Portfolio (Quantaty, Purchase_Date, Purchase_Price, Sell_Date, Sell_Price, Stock, "User")
VALUES (43, TO_DATE('2020-06-23','YYYY-MM-DD'), 9.8, NULL, NULL , 6, 2);



--CURSOR  updates the AI model's predictions and confidence levels for stocks in users' portfolios based on performance metrics like accuracy rate, precision
CREATE OR REPLACE PROCEDURE updateModelResult
IS
    CURSOR stock_cursor IS
        SELECT p.Stock, p."User", amr.Prediction_Value, amr.Confidence_Level,
               sm.Metric_ID, sm.Accuracy_Rate, sm.Precision, sm.Recall
        FROM Portfolio p
        JOIN AI_Model_Result amr ON p.Stock = amr.Stock_ID
        JOIN Performance_Metric sm ON amr.Performance_Metric = sm.Metric_ID
        WHERE p.Sell_Date IS NULL;

    v_stock_id Portfolio.Stock%TYPE;
    v_user_id Portfolio."User"%TYPE;
    v_prediction_value AI_Model_Result.Prediction_Value%TYPE;
    v_confidence_level AI_Model_Result.Confidence_Level%TYPE;
    v_metric_id Performance_Metric.Metric_ID%TYPE;
    v_accuracy_rate Performance_Metric.Accuracy_Rate%TYPE;
    v_precision Performance_Metric.Precision%TYPE;
    v_recall Performance_Metric.Recall%TYPE;

    v_new_prediction_value AI_Model_Result.Prediction_Value%TYPE;
    v_new_confidence_level AI_Model_Result.Confidence_Level%TYPE;

BEGIN
    OPEN stock_cursor;
    LOOP
        FETCH stock_cursor INTO v_stock_id, v_user_id, v_prediction_value,
                               v_confidence_level, v_metric_id, v_accuracy_rate,
                               v_precision, v_recall;
        EXIT WHEN stock_cursor%NOTFOUND;

        IF v_accuracy_rate > 80 AND v_precision > 70 THEN
            v_new_prediction_value := v_prediction_value * 1.05;
            v_new_confidence_level := v_confidence_level + 5;
        ELSE
            v_new_prediction_value := v_prediction_value * 0.95;
            v_new_confidence_level := v_confidence_level - 5;
        END IF;

        UPDATE AI_Model_Result
        SET Prediction_Value = v_new_prediction_value,
            Confidence_Level = v_new_confidence_level
        WHERE Stock_ID = v_stock_id AND Prediction_Type = v_metric_id;
    END LOOP;
    CLOSE stock_cursor;
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        DBMS_OUTPUT.PUT_LINE('ERROR');
END;

CALL updateModelResult();





