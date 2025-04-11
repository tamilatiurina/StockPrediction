# 📈 AI-Powered Stock Prediction Platform

## 🧠 Techniques Used

- Relational database design (Oracle & MS SQL)
- Entity-Relationship Diagram (ERD) reflecting business and AI requirements
- Normalized schema with advanced domain modeling:
  - Users, portfolios, stocks, watchlists, market news, predictions, performance metrics
- Data Definition Language (DDL) and Data Manipulation Language (DML) scripts
- Stored Procedures (Oracle PL/SQL & MS SQL T-SQL):
  - Example: Insert stock purchase, log AI prediction
- Triggers:
  - Includes `FOR EACH ROW` trigger (PL/SQL requirement)
  - Example: Trigger to auto-update prediction history
- Cursor Usage:
  - PL/SQL: Cursor used inside a procedure
  - T-SQL: Cursor used in a procedure or trigger
- Sentiment analysis integration on market news with score classification (positive, negative, neutral)
- AI prediction logging with:
  - Prediction type (e.g., Up/Down)
  - Confidence level
  - Recommended action (Buy/Sell/Hold)
- Ratings system for AI performance with user feedback loop
- Data tracking:
  - Evolution of AI prediction accuracy
  - Portfolio performance
- Fully executable SQL scripts with no compilation errors
- Test data:
  - Minimum 5 records per table for demonstration purposes
- Comments included in all procedures, triggers, and test cases for clarity

## 📄 Project Structure

- `requirements.txt` – Database schema and logic description
- `ERD_Diagram.pdf` – Entity-Relationship Diagram (Oracle & MS SQL compatible)
- `oracle_scripts.sql` – DDL, DML, procedures, triggers, test code (Oracle)
- `sql_server_scripts.sql` – DDL, DML, procedures, triggers, test code (MS SQL)
- `README.md` – This documentation file

## 🧪 Testing & Validation

- Each procedure and trigger comes with:
  - Descriptive comment header
  - Executable test code demonstrating functionality
- Built-in validation for AI prediction accuracy updates and user feedback impacts

## ✅ Requirements

- Oracle DB 21c+ or Microsoft SQL Server 2019+
- SQL Developer / SSMS for script execution
- Optional: Integration with Python or Java-based frontend for GUI and AI model interfacing

---

> ⚠️ Note: All scripts compile without error. Ensure that necessary permissions and user roles are granted in both environments before execution.
