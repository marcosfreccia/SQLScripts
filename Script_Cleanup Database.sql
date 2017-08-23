USE DropObjects
--USE master

SET NOCOUNT ON
DECLARE @Statement NVARCHAR(MAX)

CREATE TABLE #QueryList
    (
      SQLStatement VARCHAR(MAX) ,
      Executed BIT ,
      ObjectPriority TINYINT
    )


DECLARE @ObjectPriorities TABLE
    (
      ObjectName NVARCHAR(500) ,
      ObjectType CHAR(2) ,
      ObjectPriority TINYINT
    )

INSERT  INTO @ObjectPriorities
        ( ObjectName ,
          ObjectType ,
          ObjectPriority
        )
        SELECT  name ,
                type ,
                ObjectPriority = CASE WHEN type = 'F' THEN 1
                                      WHEN type = 'IF' THEN 2
                                      WHEN type = 'P' THEN 3
                                      WHEN type = 'FN' THEN 4
                                      WHEN type = 'V' THEN 5
                                      WHEN type = 'U' THEN 6
                                 END
        FROM    sys.objects
        WHERE   type NOT IN ( 'S', 'IT', 'SQ', 'PK' )

INSERT  INTO #QueryList
        ( SQLStatement ,
          Executed ,
          ObjectPriority 
        )
        SELECT  SQLStatement = CASE WHEN ObjectPriority = 1
                                    THEN 'ALTER TABLE ' + TABLE_SCHEMA + '.'
                                         + TABLE_NAME + ' DROP CONSTRAINT '
                                         + QUOTENAME(ObjectName)
                                    WHEN ObjectPriority = 2
                                    THEN 'DROP FUNCTION '
                                         + QUOTENAME(ObjectName)
                                    WHEN ObjectPriority = 3
                                    THEN 'DROP PROCEDURE '
                                         + QUOTENAME(ObjectName)
                                    WHEN ObjectPriority = 4
                                    THEN 'DROP FUNCTION '
                                         + QUOTENAME(ObjectName)
                                    WHEN ObjectPriority = 5
                                    THEN 'DROP VIEW ' + QUOTENAME(ObjectName)
                                    WHEN ObjectPriority = 6
                                    THEN 'DROP TABLE ' + QUOTENAME(ObjectName)
                               END ,
                0 AS Executed ,
                ObjectPriority
        FROM    @ObjectPriorities AS obj
                LEFT JOIN INFORMATION_SCHEMA.CONSTRAINT_TABLE_USAGE AS Const ON obj.ObjectName = Const.CONSTRAINT_NAME
        ORDER BY ObjectPriority ASC

WHILE ( SELECT  COUNT(*)
        FROM    #QueryList
        WHERE   Executed = 0
      ) > 0 
    BEGIN
        SELECT TOP 1
                @statement = SQLStatement
        FROM    #QueryList
        WHERE   Executed = 0
        ORDER BY ObjectPriority ASC

        EXECUTE sp_Executesql @statement
        
		UPDATE  #QueryList
        SET     Executed = 1
        WHERE   @statement = SQLStatement
    END

SELECT  SQLStatement, QueryExecuted = 
		CASE
		WHEN Executed = 0 THEN 'NO'
		ELSE 'YES'
		END      
FROM    #QueryList
ORDER BY ObjectPriority

SET NOCOUNT OFF
DROP TABLE #QueryList
