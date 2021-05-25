CREATE PROC sp_TransformData
AS
BEGIN
	DECLARE @cols AS NVARCHAR(MAX);
	DECLARE @query AS NVARCHAR(MAX);

	/*Get date cols in Sales_staging*/
	SELECT @cols = STUFF((SELECT distinct ',' +
							QUOTENAME(column_name)
						  FROM information_schema.columns
						  WHERE table_name = 'Sales_staging'
							AND COLUMN_NAME <> 'Product name' 
							AND COLUMN_NAME <> 'Latitude'
							AND COLUMN_NAME <> 'Longitude'
							AND COLUMN_NAME <> 'Customer ID'
							AND COLUMN_NAME <> 'Post code'
							AND COLUMN_NAME <> 'Year'
						  FOR XML PATH(''), TYPE
						 ).value('.', 'NVARCHAR(MAX)') 
							, 1, 1, '');
	/*Unpivot table*/
	SELECT @query = N'
	INSERT INTO SALES([Product name], [Latitude], [Longitude], [Customer ID], [Post code], [Date], [Sales])
	SELECT [Product name], [Latitude], [Longitude], [Customer ID], [Post code], CAST(''1-'' + Date  + [Year] AS datetime), [Sales]
	FROM Sales_staging
	UNPIVOT([Sales] FOR [Date] IN (' + @cols + ')) AS UnPVT
	WHERE [Post code] <> ''0'';';

	EXEC sp_executesql  @query;

	/*Get error rows*/
	SELECT @query = N'
	INSERT INTO ERRORS_LOG([Time import], [Product name], [Latitude], [Longitude], [Customer ID], [Post code], [Date], [Sales], [Error name])
	SELECT  getdate(), [Product name], [Latitude], [Longitude], [Customer ID], [Post code], CAST(''1-'' + Date  + [Year] AS datetime), [Sales], ''Post code = 0''
	FROM Sales_staging
	UNPIVOT([Sales] FOR [Date] IN (' + @cols + ')) AS UnPVT
	WHERE [Post code] = ''0'';';

	EXEC sp_executesql  @query;

	DELETE FROM Sales_staging;
END;

EXEC sp_TransformData;


