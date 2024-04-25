CREATE TABLE IF NOT EXISTS CUSTOMER(
    CUS_NUM INT AUTO_INCREMENT NOT NULL PRIMARY KEY,
    CUS_FNAME VARCHAR(15),
    CUS_LNAME VARCHAR(20),
    CUS_EMAIL VARCHAR(50),
    CUS_PHONE_NUM VARCHAR(10),
    CUS_ADDRESS VARCHAR(50),
    CUS_CITY VARCHAR(15),
    CUS_ZIP_CODE VARCHAR(5),
    CUS_STATE CHAR(2)
);

CREATE TABLE IF NOT EXISTS POTENTIAL_CUSTOMER(
    POT_CUS_NUM INT AUTO_INCREMENT NOT NULL PRIMARY KEY,
    CUS_NUM INT REFERENCES CUSTOMER(CUS_NUM),
    POT_CUS_FNAME VARCHAR(15),
    POT_CUS_LNAME VARCHAR(20),
    POT_CUS_EMAIL VARCHAR(50),
    POT_CUS_PHONE_NUM VARCHAR(10)
);

CREATE TABLE IF NOT EXISTS JOB(
    JOB_NUM INT AUTO_INCREMENT NOT NULL PRIMARY KEY,
    START_DATE DATE NOT NULL,
    END_DATE DATE,
    JOB_NAME VARCHAR(20),
    JOB_TYPE CHAR(1) NOT NULL CHECK(JOB_TYPE = 'D' OR JOB_TYPE = 'F' OR JOB_TYPE = 'I' )
);

CREATE TABLE IF NOT EXISTS DESIGN(
    JOB_NUM INT NOT NULL PRIMARY KEY REFERENCES JOB(JOB_NUM),
    NUM_OF_DESIGNS INT,
    IS_COMMERCIAL BOOLEAN
);

CREATE TABLE IF NOT EXISTS FABRICATION(
    JOB_NUM INT NOT NULL PRIMARY KEY REFERENCES JOB(JOB_NUM),
    NUM_OF_CUTS INT,
    IS_CUSTOM BOOLEAN,
    DAYS_STORED INT
);

CREATE TABLE IF NOT EXISTS INSTALLATION(
    JOB_NUM INT NOT NULL PRIMARY KEY REFERENCES JOB(JOB_NUM),
    NET_WEIGHT_TONS NUMERIC(8,2),
    IS_VERTICAL BOOLEAN,
    SURFACE_AREA_FT_2 FLOAT
);

CREATE TABLE IF NOT EXISTS SUPPLIER(
    SUPPLIER_NUM INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    COUNTRY_IMPORT VARCHAR(15),
    SUPPLIER_NAME VARCHAR(30)
);

CREATE TABLE IF NOT EXISTS INVENTORY(
    STONE_NUM INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    JOB_NUM INT REFERENCES JOB(JOB_NUM),
    SUPPLIER_NUM INT NOT NULL REFERENCES SUPPLIER(SUPPLIER_NUM),
    STONE_TYPE VARCHAR(10) NOT NULL,
    STONE_QUALITY TINYINT NOT NULL CHECK(
        STONE_QUALITY = 1 OR
        STONE_QUALITY = 2 OR
        STONE_QUALITY = 3
        ),
    STONE_SURFACE_AREA FLOAT NOT NULL,
    STONE_WEIGHT FLOAT NOT NULL
);

CREATE TABLE EMPLOYEE(
    EMP_NUM INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    EMP_FNAME VARCHAR(15),
    EMP_LNAME VARCHAR(20),
    EMP_EMAIL VARCHAR(50),
    EMP_PHONE_NUM VARCHAR(10),
    EMP_ADDRESS VARCHAR(50),
    EMP_CITY VARCHAR(15),
    EMP_ZIP_CODE VARCHAR(5),
    EMP_STATE CHAR(2),
    EMP_START_DATE DATE,
    EMP_SALARY INT
);

CREATE TABLE IF NOT EXISTS CERTIFICATION(
    CERT_NUM INT AUTO_INCREMENT PRIMARY KEY NOT NULL,
    ISSUER VARCHAR(30),
    CERT_NAME VARCHAR(20)
);

CREATE TABLE IF NOT EXISTS MACHINE(
    MACH_NUM INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    CERT_NUM INT REFERENCES CERTIFICATION(CERT_NUM),
    JOB_NUM INT REFERENCES JOB(JOB_NUM),
    MACH_DESC TEXT,
    MACH_NAME VARCHAR(20)
);

CREATE TABLE IF NOT EXISTS INVOICE(
    CUS_NUM INT NOT NULL PRIMARY KEY REFERENCES CUSTOMER(CUS_NUM),
    JOB_NUM INT NOT NULL PRIMARY KEY REFERENCES JOB(JOB_NUM),
    NET_SALES_PRICE FLOAT,
    REFERRAL_DISCOUNT INT,
    GROSS_PRICE FLOAT,
    DATA_OF_PURCHASE DATE NOT NULL
);

CREATE TABLE IF NOT EXISTS EMP_TO_CERT(
    EMP_NUM INT NOT NULL PRIMARY KEY REFERENCES EMPLOYEE(EMP_NUM),
    CERT_NUM INT NOT NULL PRIMARY KEY REFERENCES CERTIFICATION(CERT_NUM),
    DATE_ISSUES DATE,
    DATE_EXP DATE,
    VERSION_NUM VARCHAR(30)
);

CREATE TABLE JOB_TO_EMP(
    JOB_NUM INT NOT NULL PRIMARY KEY REFERENCES JOB(JOB_NUM),
    EMP_NUM INT NOT NULL PRIMARY KEY REFERENCES EMPLOYEE(EMP_NUM),
    HOURS_PER_WEEK INT
);

DELIMITER //
    CREATE PROCEDURE invoice_design_job(cus_num INT, job_num INT)
    BEGIN
        SELECT DESIGN.NUM_OF_DESIGNS INTO @nod FROM DESIGN WHERE DESIGN.JOB_NUM = job_num;
        SELECT DESIGN.IS_COMMERCIAL INTO @ic FROM DESIGN WHERE DESIGN.JOB_NUM = job_num;
        UPDATE INVOICE
            SET INVOICE.NET_SALES_PRICE = @nod * 200 + @ic * 1000
            WHERE (INVOICE.JOB_NUM = job_num AND INVOICE.CUS_NUM = cus_num);
        SELECT COUNT(*) INTO @referalls FROM POTENTIAL_CUSTOMER WHERE POTENTIAL_CUSTOMER.CUS_NUM = cus_num;
        UPDATE INVOICE
            SET INVOICE.REFERRAL_DISCOUNT = @referalls * 50
            WHERE (INVOICE.JOB_NUM = job_num AND INVOICE.CUS_NUM = cus_num);
        UPDATE INVOICE
            SET INVOICE.GROSS_PRICE = INVOICE.NET_SALES_PRICE - INVOICE.REFERRAL_DISCOUNT
            WHERE (INVOICE.JOB_NUM = job_num AND INVOICE.CUS_NUM = cus_num);
    END;//

DELIMITER ;

DELIMITER //
    CREATE PROCEDURE invoice_fabrication_job(cus_num INT, job_num INT)
    BEGIN
        SELECT FABRICATION.NUM_OF_CUTS INTO @noc FROM FABRICATION WHERE FABRICATION.JOB_NUM = job_num;
        SELECT FABRICATION.IS_CUSTOM INTO @ic FROM FABRICATION WHERE FABRICATION.JOB_NUM = job_num;
        SELECT FABRICATION.DAYS_STORED INTO @ds FROM FABRICATION WHERE FABRICATION.JOB_NUM = job_num;
        UPDATE INVOICE
            SET INVOICE.NET_SALES_PRICE = @noc * 75 + @ic*2000 + @ds * 200
            WHERE (INVOICE.JOB_NUM = job_num AND INVOICE.CUS_NUM = cus_num);
        SELECT COUNT(*) INTO @referalls FROM POTENTIAL_CUSTOMER WHERE POTENTIAL_CUSTOMER.CUS_NUM = cus_num;
        UPDATE INVOICE
            SET INVOICE.REFERRAL_DISCOUNT = @referalls * 50
            WHERE (INVOICE.JOB_NUM = job_num AND INVOICE.CUS_NUM = cus_num);
        UPDATE INVOICE
            SET INVOICE.GROSS_PRICE = INVOICE.NET_SALES_PRICE - INVOICE.REFERRAL_DISCOUNT
            WHERE (INVOICE.JOB_NUM = job_num AND INVOICE.CUS_NUM = cus_num);
    END;//

DELIMITER ;

DELIMITER //
    CREATE PROCEDURE invoice_installation_job(cus_num INT, job_num INT)
    BEGIN
        SELECT NET_WEIGHT_TONS INTO @nwt FROM INSTALLATION WHERE INSTALLATION.JOB_NUM = job_num;
        SELECT IS_VERTICAL INTO @iv FROM INSTALLATION WHERE INSTALLATION.JOB_NUM = job_num;
        SELECT SURFACE_AREA_FT_2 INTO @saf2 FROM INSTALLATION WHERE INSTALLATION.JOB_NUM = job_num;
        UPDATE INVOICE
            SET INVOICE.NET_SALES_PRICE = @nwt * 1000 + @iv * 2000 + @saf2 * 50
            WHERE (INVOICE.JOB_NUM = job_num AND INVOICE.CUS_NUM = cus_num);
        SELECT COUNT(*) INTO @referalls FROM POTENTIAL_CUSTOMER WHERE POTENTIAL_CUSTOMER.CUS_NUM = cus_num;
        UPDATE INVOICE
            SET INVOICE.REFERRAL_DISCOUNT = @referalls * 50
            WHERE (INVOICE.JOB_NUM = job_num AND INVOICE.CUS_NUM = cus_num);
        UPDATE INVOICE
            SET INVOICE.GROSS_PRICE = INVOICE.NET_SALES_PRICE - INVOICE.REFERRAL_DISCOUNT
            WHERE (INVOICE.JOB_NUM = job_num AND INVOICE.CUS_NUM = cus_num);
    END;//

DELIMITER ;
DROP PROCEDURE add_invoice_instance;
DELIMITER //
    CREATE PROCEDURE add_invoice_instance(cus_num INT, job_num INT, date DATE)
    BEGIN
        INSERT INTO INVOICE(CUS_NUM, JOB_NUM, DATE_OF_PURCHASE) VALUES (cus_num, job_num, date);
        SELECT JOB.JOB_TYPE INTO @type FROM JOB WHERE job_num = JOB.JOB_NUM;
        IF @type = 'D' THEN
            CALL invoice_design_job(cus_num, job_num);
        ELSEIF @type = 'F' THEN
            CALL invoice_fabrication_job(cus_num, job_num);
        ELSE
            CALL invoice_installation_job(cus_num, job_num);
        end if;
    END;//

DELIMITER ;
DESCRIBE CERTIFICATION;

SELECT * FROM SUPPLIER;

SELECT * FROM MACHINE;