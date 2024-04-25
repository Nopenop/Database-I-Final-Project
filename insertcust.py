import mariadb
import sys
import csv
import random
import string

try:
    conn = mariadb.connect(
        user="ncampise2655",
        password='Bz@"69pope$',
        host="10.200.208.126",
        port=3306,
        database="ncampise2655_db_finalproject"
    )
except mariadb.Error as e:
    print(f"error conneting to MariaDB platform: {e}")
    sys.exit(1)

cur = conn.cursor()


def makeCustomers():
    with open('customer.csv',newline='') as csvfile:
        csv_data = csv.DictReader(csvfile)
        for row in csv_data:
            cur.execute(
                f"INSERT INTO CUSTOMER(CUS_FNAME,\
                    CUS_LNAME,\
                    CUS_EMAIL, CUS_PHONE_NUM,\
                    CUS_ADDRESS,CUS_ZIP_CODE, CUS_CITY\
                    , CUS_STATE)\
                    VALUES(\"{row['fname']}\",\
                    \"{row['lname']}\",\
                    \"{row['email']}\",\
                    \"{str(row['phone_number'])}\",\
                    \"{row['address']}\",\
                    \"{row['zip']}\",\
                    \"{row['city']}\",\'FL\')")

def makePotCustomers():
    pass
    with open('pot_customer.csv',newline='') as csvfile:
        csv_data = csv.DictReader(csvfile)
        i = 0
        for row in csv_data:
            i+=1
            cur.execute(
                f"INSERT INTO POTENTIAL_CUSTOMER(POT_CUS_FNAME,POT_CUS_LNAME, POT_CUS_EMAIL, POT_CUS_PHONE_NUM,CUS_NUM)\
                    VALUES(\"{row['fname']}\",\
                    \"{row['lname']}\",\
                    \"{row['email']}\",\
                    \"{str(row['phone_number'])}\",\
                        \"{str(random.randrange(1,201))}\")")
            if i > 45:
                break

def makeEmployees():
    pass
    with open('employee.csv',newline='') as csvfile:
        csv_data = csv.DictReader(csvfile)
        for row in csv_data:
            cur.execute(
                f"INSERT INTO EMPLOYEE(EMP_FNAME,\
                    EMP_LNAME,\
                    EMP_EMAIL, EMP_PHONE_NUM,\
                    EMP_ADDRESS,EMP_ZIP_CODE\
                    ,EMP_START_DATE\
                        ,EMP_CITY, EMP_STATE, EMP_SALARY )\
                    VALUES(\"{row['fname']}\",\
                    \"{row['lname']}\",\
                    \"{row['email']}\",\
                    \"{str(row['phone_number'])}\",\
                    \"{row['address']}\",\
                    \"{row['zip']}\",\
                    \"{str(random.randint(1999, 2024))}-{str(random.randint(1,12)).rjust(2,'0')}-{str(random.randint(1,30)).rjust(2,'0')}\",\
                    \"{row['city']}\",\'FL\', \"{str(random.randrange(40000,80000))}\");")



def makeCertifications():
    for i in range(10):
        iss = ''.join(random.choices(string.ascii_uppercase +
                             string.digits, k=random.randint(7,28)))
        name = ''.join(random.choices(string.ascii_uppercase +
                             string.digits, k=random.randint(7,19)))
        cur.execute(f"INSERT INTO CERTIFICATION(ISSUER, CERT_NAME) VALUES(\
                    \"{iss}\",\
                    \"{name}\")")
makeCertifications()
def makeInventory():
    stoneTypes = ["GRANITE", "OBSIDIAN", "GABBRO", "DIABASE", "SLATE", "MARBLE", "GNEISS", "QUARTZITE", "LIMESTONE","SANDSTONE"]
    for i in range(120):
        cur.execute(f"INSERT INTO INVENTORY(JOB_NUM, SUPPLIER_NUM, STONE_TYPE, STONE_QUALITY, STONE_SURFACE_AREA, STONE_WEIGHT) VALUES(\
                    \"{str(random.randint(1,150))}\",\
                    \"{str(random.randint(1,4))}\",\
                    \"{stoneTypes[random.randint(0,len(stoneTypes)-1)]}\",\
                    \"{str(random.randint(1,3))}\",\
                    \"{str(random.randint(100,500))}\",\
                    \"{str(random.randint(1,10))}\")\
                    ")
    pass
def makeJobs():
        for i in range(150):
            year = random.randint(1999, 2024)
            month = random.randint(1,12)
            day = random.randint(1,30)
            startdate = f"{str(year)}-{str(month).rjust(2,'0')}-{str(day).rjust(2,'0')}"
            vals = [0,0,0,1,1]
            endDay = vals[random.randint(0,4)] * random.randint(4,10) + day
            endmonth = month
            endyear = year
            if (endDay > 30):
                endDay = endDay%27
                endmonth += 1
            if(endmonth > 12):
                endmonth = endmonth%12
                endyear += 1
            enddate = f"{str(endyear)}-{str(endmonth).rjust(2,'0')}-{str(endDay).rjust(2,'0')}"
            res = ''.join(random.choices(string.ascii_uppercase +
                             string.digits, k=random.randint(7,19)))
            types = ['D','F','I']
            type_of_job = types[random.randint(0,2)]

            cur.execute(
                f"INSERT INTO JOB(START_DATE, END_DATE, JOB_NAME, JOB_TYPE) VALUES(\
                    \"{startdate}\",\
                    \"{enddate}\",\
                    \"{res}\",\
                    \"{type_of_job}\"\
                )"
                )
            
def makeSubJobs():
    cur.execute("SELECT JOB_NUM, JOB_TYPE FROM JOB")
    rows = cur.fetchall()
    for row in rows:
        job_num = row[0]
        type_of_job = row[1]
        if type_of_job == 'I':
                    cur.execute(
                    f"INSERT INTO INSTALLATION(JOB_NUM, NET_WEIGHT_TONS, IS_VERTICAL, SURFACE_AREA_FT_2) VALUES(\
                        \"{str(job_num)}\",\
                        \"{str(random.randint(1,10))}.{str(random.randint(0,9))}\",\
                        \"{str(random.randint(0,1))}\",\
                        \"{str(random.randint(300,1500))}.{str(random.randint(0,9))}\"\
                    )"
                    )
        elif type_of_job == 'D':
            cur.execute(
            f"INSERT INTO DESIGN(JOB_NUM, NUM_OF_DESIGNS, IS_COMMERCIAL) VALUES(\
                \"{str(job_num)}\",\
                \"{str(random.randint(1,10))}\",\
                \"{str(random.randint(0,1))}\"\
            )"
            )
        else:
            cur.execute(
            f"INSERT INTO FABRICATION(JOB_NUM, NUM_OF_CUTS, IS_CUSTOM, DAYS_STORED) VALUES(\
                \"{str(job_num)}\",\
                \"{str(random.randint(10,100))}\",\
                \"{str(random.randint(0,1))}\",\
                \"{str(random.randint(0,7))}\"\
            )"
            )

def makeInvoices():
    
    for i in range(100):
        year = random.randint(1999, 2024)
        month = random.randint(1,12)
        day = random.randint(1,28)
        cur.execute(
            f"CALL add_invoice_instance(\
                \"{str(random.randint(1,200))}\",\
                \"{str(random.randint(1,150))}\",\
                \"{str(year)}-{str(month).rjust(2,'0')}-{str(day).rjust(2,'0')}\"\
                )"
        )

def connectJobToEmp():
    for i in range(50):
        cur.execute(
            f"INSERT INTO JOB_TO_EMP(JOB_NUM, EMP_NUM, HOURS_PER_WEEK) VALUES(\
                \"{str(random.randint(1,150))}\",\
                \"{str(random.randint(1,36))}\",\
                \"{str(random.randint(5,10))}\"\
                )"
        )

def connectCertToEmp():
    for i in range(19):
        year = random.randint(1999, 2024)
        month = random.randint(1,12)
        day = random.randint(1,30)
        startdate = f"{str(year)}-{str(month).rjust(2,'0')}-{str(day).rjust(2,'0')}"
        vals = [0,0,0,1,1]
        endDay = vals[random.randint(0,4)] * random.randint(4,10) + day
        endmonth = month
        endyear = year
        if (endDay > 30):
                endDay = endDay%30
                endmonth += 1
        if(endmonth > 12):
            endmonth = endmonth%12
            endyear += 1
        enddate = f"{str(endyear)}-{str(endmonth).rjust(2,'0')}-{str(endDay).rjust(2,'0')}"
        res = ''.join(random.choices(string.ascii_uppercase +
                             string.digits, k=random.randint(7,19)))
        cur.execute(
            f"INSERT INTO EMP_TO_CERT(EMP_NUM, CERT_NUM, DATE_ISSUES, DATE_EXP, VERSION_NUM) VALUES(\
                \"{str(random.randint(1,36))}\",\
                \"{str(random.randint(1,10))}\",\
                \"{startdate}\",\
                \"{enddate}\",\
                \"{random.randint(1,10)}\"\
                )"
        )

def makeMachine():
    for i in range(23):
        year = random.randint(1999, 2024)
        month = random.randint(1,12)
        day = random.randint(1,30)
        startdate = f"{str(year)}-{str(month).rjust(2,'0')}-{str(day).rjust(2,'0')}"
        res = ''.join(random.choices(string.ascii_uppercase +
                             string.digits, k=random.randint(7,19)))
        ser = ''.join(random.choices(string.ascii_uppercase +
                             string.digits, k=random.randint(30,50)))
        cur.execute(
                f"INSERT INTO MACHINE( CERT_NUM, JOB_NUM, MACH_DESC, MACH_NAME) VALUES(\
                    \"{str(random.randint(1,10))}\",\
                    \"{str(random.randint(1,150))}\",\
                    \"{ser}\",\
                    \"{res}\"\
                    )"
            )
    


# makeCustomers()
# makePotCustomers()
# makeCertifications()
# makeEmployees()
# makeJobs()
# makeSubJobs()
# makeSuppliers()
# makeInventory()
# makeCertifications()
# makeInvoices()
# makeMachine()
# connectCertToEmp()
connectJobToEmp()
conn.commit()
cur.close()
print("done")


