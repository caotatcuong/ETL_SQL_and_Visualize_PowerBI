cmd /c python add_col.py
cmd /c for /r %%i in (*sales.csv) do bcp Sales_staging in %%i -S talent5.database.windows.net -d talentdb -U talent5_0828452340 -P Abcd#12345 -F 1 -t "," -c
cmd /c bcp Quantity in ./Quantity_data.csv -S talent5.database.windows.net -d talentdb -U talent5_0828452340 -P Abcd#12345 -F 1 -t "," -c
cmd /c sqlcmd.exe -S talent5.database.windows.net -d talentdb -U talent5_0828452340 -P Abcd#12345 -I -Q "EXEC sp_TransformData;"
cmd /c sqlcmd.exe -S talent5.database.windows.net -d talentdb -U talent5_0828452340 -P Abcd#12345 -I -Q "EXEC sp_IntegrateData;"
cmd /c pause