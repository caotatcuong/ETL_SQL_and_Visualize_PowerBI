ALTER PROC sp_IntegrateData
AS
BEGIN
	/*Add column Quantity into Sales table*/
	IF COL_LENGTH('Sales','Quantity') IS NULL
	BEGIN
		ALTER TABLE Sales
		ADD [Quantity] int;
	END;

	/*Update column Quantity into Sales*/
	MERGE Sales AS mrg

	USING (
	SELECT s.[Product name], s.Latitude, s.Longitude, s.[Customer ID], s.[Post code], s.[Date], s.[Sales], sum(q.Quantity) AS Quantity 
	FROM Sales AS s
	LEFT JOIN Quantity AS q ON s.[Product name] = q.[Product name]  and s.Latitude = q.Latitude and s.Longitude = q.Longitude
		and s.[Customer ID] = q.[Customer ID] and s.[Post code] = q.[Post code] and s.[Date] = CAST('1 -' + q.[Date] AS datetime) 
	GROUP BY s.[Product name], s.Latitude, s.Longitude, s.[Customer ID], s.[Post code], s.[Date], s.[Sales]
	) AS emp

	ON mrg.[Product name] = emp.[Product name]  and mrg.Latitude = emp.Latitude and mrg.Longitude = emp.Longitude
		and mrg.[Customer ID] = emp.[Customer ID] and mrg.[Post code] = emp.[Post code] and mrg.[Date] = emp.[Date] and mrg.[Sales] = emp.[Sales]

	WHEN MATCHED THEN UPDATE SET mrg.Quantity = emp.Quantity 

	WHEN NOT MATCHED THEN
	INSERT VALUES(emp.[Product name], emp.Latitude, emp.Longitude, emp.[Customer ID], emp.[Post code], emp.[Date], emp.[Sales], emp.Quantity);

	DELETE FROM Quantity
END;

EXEC sp_IntegrateData;
