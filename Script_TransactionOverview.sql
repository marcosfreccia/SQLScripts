SELECT  st.session_id ,
		ISNULL(DB_NAME(dt.database_id),dt.database_id) AS DatabaseName,
        st.is_user_transaction ,
        dt.transaction_id ,
        name AS statementtype ,
		st.enlist_count,
        dt.database_transaction_begin_time ,
        database_transaction_type = CASE WHEN database_transaction_type = 1
                                         THEN 'Read/write transaction'
                                         WHEN database_transaction_type = 2
                                         THEN 'Read-only transaction'
                                         WHEN database_transaction_type = 3
                                         THEN 'System transaction'
                                    END ,
        database_transaction_state = CASE WHEN database_transaction_state = 1
                                          THEN 'The transaction has not been initialized.'
                                          WHEN database_transaction_state = 3
                                          THEN 'The transaction has been initialized but has not generated any log records.'
                                          WHEN database_transaction_state = 4
                                          THEN 'The transaction has generated log records.'
                                          WHEN database_transaction_state = 5
                                          THEN 'The transaction has been prepared.'
                                          WHEN database_transaction_state = 10
                                          THEN 'The transaction has been committed.'
                                          WHEN database_transaction_state = 11
                                          THEN 'The transaction has been rolled back.'
                                          WHEN database_transaction_state = 12
                                          THEN 'The transaction is being committed. In this state the log record is being generated, but it has not been materialized or persisted.'
                                     END ,
        database_transaction_log_bytes_used ,
        database_transaction_log_bytes_reserved ,
        database_transaction_begin_lsn ,
        database_transaction_commit_lsn ,
        login_time ,
        host_name ,
        program_name ,
        client_interface_name ,
        login_name ,
        text,
		GETDATE() AS DateCollected
FROM    sys.dm_tran_database_transactions (NOLOCK) AS dt
        LEFT JOIN sys.dm_tran_active_transactions (NOLOCK) AS at ON dt.transaction_id = at.transaction_id
        LEFT JOIN sys.dm_tran_session_transactions (NOLOCK) AS st ON at.transaction_id = st.transaction_id
        JOIN sys.dm_exec_sessions (NOLOCK) AS es ON st.session_id = es.session_id
        LEFT JOIN sys.dm_exec_requests (NOLOCK) AS req ON req.session_id = es.session_id
        CROSS APPLY sys.dm_exec_sql_text(req.plan_handle)
		WHERE req.session_id <> @@SPID
		AND dt.database_transaction_begin_time IS NOT NULL