💼 WKIS Database Transaction Processor 💰
This repository contains a PL/SQL script designed to process transactions within the WKIS database. It includes functionality to handle various transaction types and maintain accurate account balances.

📝 Instructions
Setup: Ensure that the database is properly configured and accessible.

Execution: Run the script in a PL/SQL environment connected to the WKIS database.

Monitoring: Monitor the output for any errors or exceptions during the transaction processing.

📋 Description
The script performs the following tasks:

Deletes existing transaction details and history to reset for new transactions.
Processes transactions from the new_transactions table.
Validates transaction details such as non-null transaction number and non-negative transaction amount.
Updates account balances based on transaction types (credit or debit).
Logs any errors encountered during processing into the wkis_error_log table.
🚀 Usage Notes
Ensure proper configuration of the WKIS database and access rights before execution.
Monitor the output for any unexpected errors or exceptions.
Regularly review the wkis_error_log table for any logged issues during transaction processing.






