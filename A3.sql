SET SERVEROUTPUT ON

DELETE FROM transaction_detail;
DELETE FROM transaction_history;
-- should also reset account_balance in account table

-- Group Assignment 2: Develop and Test a Coded Solution 
-- Using the WKIS database
-- Matt Yackel, Ana Alarcon, Ori Bermudez, Sergei

DECLARE
	-- Variables
	v_transaction_no NUMBER;
	v_transaction_date DATE;
	v_description VARCHAR2(100);
	v_account_no NUMBER;
	v_transaction_type CHAR(1);
	v_transaction_amount NUMBER;

	--Constants
	c_credit CHAR(1) := 'C';
	c_debit CHAR(1) := 'D';


	--Exception
	v_error_msg VARCHAR2(50);
	e_transaction_no_null EXCEPTION;
	e_transaction_amount_negative EXCEPTION;
	
	v_row_exists NUMBER;
	
	v_account_balance NUMBER;
	v_default_trans_type CHAR(1);
	
	-- Cursor
	
	CURSOR c_new_transaction IS
		SELECT *
		FROM new_transactions;
BEGIN
	FOR r_new_transaction IN c_new_transaction LOOP
		-- Fetch values into variables
		v_transaction_no := r_new_transaction.transaction_no;
		DBMS_OUTPUT.PUT_LINE('Transaction No: ' || v_transaction_no);
		v_transaction_date := r_new_transaction.transaction_date;
		v_description := r_new_transaction.description;
		v_account_no := r_new_transaction.account_no;
		v_transaction_type := r_new_transaction.transaction_type;
		v_transaction_amount := r_new_transaction.transaction_amount;
		DBMS_OUTPUT.PUT_LINE('Transaction desc: ' || v_description);
		dbms_output.put_line('Transaction amount: ' || v_transaction_amount);

		--Check if transaction_amount is negative
		IF r_new_transaction.transaction_amount < 0 THEN
			RAISE e_transaction_amount_negative;
		END IF;
		-- Check if transaction_no is null
		IF v_transaction_no IS NULL THEN
			RAISE e_transaction_no_null;
		END IF;

		dbms_output.put_line('Transaction type: ' || v_transaction_type);

		-- Check if transaction_type is invalid
		IF v_transaction_type NOT IN (c_credit, c_debit) THEN
			v_error_msg := 'Invalid transaction type';
			RAISE_APPLICATION_ERROR(-20002, v_error_msg);
		END IF;

		
		
		
		-- Get the default account type for the current account_no
		SELECT default_trans_type
		INTO v_default_trans_type
		FROM account_type
		WHERE account_type_code = (SELECT account_type_code 
								FROM account 
								WHERE account_no = v_account_no);

		
		
		

		
		--EXCEPTION 1
		BEGIN
		
		-- check if a row from the same transaction already exists
		SELECT count(*)
		INTO v_row_exists
		FROM transaction_history
		WHERE transaction_no = v_transaction_no;

		
		
		if (v_row_exists = 0) THEN
			-- Insert into transaction_history 
			INSERT INTO transaction_history (transaction_no, transaction_date, description)
			VALUES (v_transaction_no, v_transaction_date, v_description);
		END IF;

		EXCEPTION
			WHEN OTHERS THEN
				DBMS_OUTPUT.PUT_LINE('exception 1 ' || SQLERRM);
		END;

		-- Insert into transaction_detail
		INSERT INTO transaction_detail (account_no, transaction_no, transaction_type, transaction_amount)
		VALUES (v_account_no, v_transaction_no, v_transaction_type, v_transaction_amount);
		
	-- Update account balance based on transaction type
		
		SELECT Account_balance
		INTO v_account_balance
		FROM ACCOUNT
		WHERE Account_no = v_account_no;

		IF v_default_trans_type = v_transaction_type THEN
			v_account_balance := v_account_balance + v_transaction_amount;
		ELSE 
			v_account_balance := v_account_balance - v_transaction_amount;
		END IF;
		
		UPDATE account
		SET account_balance = v_account_balance
		WHERE account_no = v_account_no;

		DBMS_OUTPUT.PUT_LINE('Account balance: ' || v_account_balance);
		
		-- Delete transaction from load table once it has been processed
		DELETE FROM new_transactions
		WHERE transaction_no = v_transaction_no;

		
		
	END LOOP;
	COMMIT;
	EXCEPTION
	WHEN e_transaction_no_null THEN
		v_error_msg := 'Error, transaction number is null.';
		DBMS_OUTPUT.PUT_LINE('Error, transaction number is null.');
		DBMS_OUTPUT.PUT_LINE('Error, transaction number is null.' || ' ' || v_description);	
		INSERT INTO wkis_error_log 
		VALUES (v_transaction_no, v_transaction_date, v_description, v_error_msg);	
		COMMIT;
	--TRANSACTION NEGATIVE
	WHEN e_transaction_amount_negative THEN
		v_error_msg := 'Error, transaction amount is negative.';
		DBMS_OUTPUT.PUT_LINE('Error, transaction amount is negative.');
		INSERT INTO wkis_error_log 
		VALUES (v_transaction_no, v_transaction_date, v_description, v_error_msg);	
		COMMIT;  	
	WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('Unexpected Error: outer block ' || SQLERRM);

    ROLLBACK;

END;
/