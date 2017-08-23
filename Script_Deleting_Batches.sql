USE DatabaseName
go
DECLARE @start INT
DECLARE @batches INT
DECLARE @RecoveryModel VARCHAR(25)
declare @StartTime datetime
declare @EndTime datetime

SET @StartTime = GETDATE()

SET @start = 1
SET @batches = 10000


WHILE ( @start > 0 )
    BEGIN

        DELETE TOP ( @batches )
        FROM    TableName
        SET @start = @@ROWCOUNT

                CHECKPOINT;
                PRINT 'CHECKPOINT EXECUTED!!'
    END
    SET @EndTime = GETDATE()

select DATEDIFF(SS,@StartTime,@EndTime)
