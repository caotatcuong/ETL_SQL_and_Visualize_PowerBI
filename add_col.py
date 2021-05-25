import glob

files = glob.glob("*sales.csv")

from csv import writer
from csv import reader
for i in range(len(files)):
    with open(files[i], 'r') as read_obj:
        csv_reader = reader(read_obj)
        listrow = [row for row in csv_reader]
    with open(files[i], 'w', newline='') as write_obj:
        csv_writer = writer(write_obj)
        for row in listrow:
            if row[0]=='Product name':
                row.append('Year')
                csv_writer.writerow(row)
            else:
                row.append(files[i][0:4])
                csv_writer.writerow(row)


            