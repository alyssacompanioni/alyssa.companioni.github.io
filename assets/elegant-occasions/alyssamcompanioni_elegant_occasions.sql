-- *************************************************************
-- This script  creates the EOWA (Elegant Occasions with Alyssa)
-- database for DBA 120 with John Locklear
-- Spring 2025
-- *************************************************************

-- create the database
DROP DATABASE IF EXISTS alyssamcompanioni_eowa;
CREATE DATABASE alyssamcompanioni_eowa;

-- select the database
USE alyssamcompanioni_eowa;

-- create the tables
CREATE TABLE employees (
  employee_id     INT             PRIMARY KEY       AUTO_INCREMENT,
  first_name      VARCHAR(50)     NOT NULL,
  last_name       VARCHAR(50)     NOT NULL,
  address1        VARCHAR(50)     NOT NULL,
  address2        VARCHAR(50),
  city            VARCHAR(50)     NOT NULL,
  state           CHAR(2)         NOT NULL,
  zip             VARCHAR(12)     NOT NULL,
  phone           VARCHAR(20)     NOT NULL,
  email           VARCHAR(50)     NOT NULL          UNIQUE
);

CREATE TABLE service_types (
  service_id        INT           PRIMARY KEY       AUTO_INCREMENT,
  service_name      VARCHAR(50)   NOT NULL          UNIQUE,
  service_description             VARCHAR(255)
);

CREATE TABLE employee_services (
  employee_id       INT           NOT NULL,
  service_id        INT           NOT NULL,
  years_experience  INT,
  CONSTRAINT employee_services_pk 
    PRIMARY KEY (employee_id, service_id),
  CONSTRAINT employee_services_fk_employees
    FOREIGN KEY (employee_id)
    REFERENCES employees (employee_id),
  CONSTRAINT employee_services_fk_service_types
    FOREIGN KEY (service_id)
    REFERENCES service_types (service_id)
);


CREATE TABLE clients (
  client_id       INT             PRIMARY KEY       AUTO_INCREMENT,
  first_name      VARCHAR(50)     NOT NULL,
  last_name       VARCHAR(50)     NOT NULL,
  address1        VARCHAR(50)     NOT NULL,
  address2        VARCHAR(50),
  city            VARCHAR(50)     NOT NULL,
  state           VARCHAR(2)      NOT NULL,
  zip             VARCHAR(12)     NOT NULL,
  phone           VARCHAR(20)     NOT NULL,
  email           VARCHAR(50)     NOT NULL          UNIQUE
);

CREATE TABLE appointments (
  client_id       INT             NOT NULL,
  employee_id     INT             NOT NULL,
  start_time      DATETIME        NOT NULL,
  end_time        DATETIME        NOT NULL,
  service_to_plan INT             NOT NULL, 
  CONSTRAINT appointments_pk
    PRIMARY KEY (client_id, employee_id),
  CONSTRAINT appointments_fk_clients
    FOREIGN KEY (client_id)
    REFERENCES clients (client_id),
  CONSTRAINT appointments_fk_employees
    FOREIGN KEY (employee_id)
    REFERENCES employees (employee_id),
  CONSTRAINT appointments_fk_service_types
    FOREIGN KEY (service_to_plan)
    REFERENCES service_types (service_id)
);

CREATE TABLE vendors (
  vendor_id       INT             PRIMARY KEY       AUTO_INCREMENT,
  service_id      INT             NOT NULL,
  vendor_name     VARCHAR(50)     NOT NULL          UNIQUE,
  address1        VARCHAR(50)     NOT NULL,
  address2        VARCHAR(50),
  city            VARCHAR(50)     NOT NULL,
  state           CHAR(2)         NOT NULL,
  zip             VARCHAR(12)     NOT NULL,
  phone           VARCHAR(20)     NOT NULL,
  email           VARCHAR(50)     NOT NULL,
  price           DECIMAL(9,2),
  CONSTRAINT vendors_fk_service_types
    FOREIGN KEY (service_id)
    REFERENCES service_types (service_id)
);

CREATE TABLE venues (
  venue_id        INT             PRIMARY KEY         AUTO_INCREMENT,
  venue_name      VARCHAR(50)     NOT NULL            UNIQUE,
  address1        VARCHAR(50)     NOT NULL,
  address2        VARCHAR(50),
  city            VARCHAR(50)     NOT NULL,
  state           CHAR(2)         NOT NULL,
  zip             VARCHAR(12)     NOT NULL,
  phone           VARCHAR(20)     NOT NULL,
  email           VARCHAR(50)     NOT NULL,
  capacity        INT             NOT NULL,
  price           DECIMAL(9,2)    NOT NULL
);

CREATE TABLE events (                              
  event_id        INT             PRIMARY KEY       AUTO_INCREMENT,
  event_type      ENUM('wedding', 'reception', 'dress rehearsal')     NOT NULL,
  event_date      DATE            NOT NULL,
  start_time      TIME            NOT NULL,
  end_time        TIME            NOT NULL,
  guest_count     INT             NOT NULL,
  venue_id        INT,
  dress_code      ENUM('white tie', 'black tie', 'black tie optional', 'semi-formal', 'casual'),
  CONSTRAINT events_fk_venues
    FOREIGN KEY (venue_id)                         
    REFERENCES venues (venue_id)
);

CREATE TABLE event_clients (                         
  event_id        INT             NOT NULL,
  client_id       INT             NOT NULL,
  role            VARCHAR(20)     NOT NULL,
  CONSTRAINT event_clients_pk
    PRIMARY KEY (event_id, client_id),
  CONSTRAINT event_clients_fk_clients
    FOREIGN KEY (client_id)                        
    REFERENCES clients (client_id),
  CONSTRAINT event_clients_fk_events
    FOREIGN KEY (event_id)                          
    REFERENCES events (event_id),
  CONSTRAINT one_wedding_role_per_client
    UNIQUE (client_id, role)
);

CREATE TABLE event_vendors (                         
  event_id        INT             NOT NULL,
  vendor_id       INT             NOT NULL,
  CONSTRAINT event_vendors_pk
    PRIMARY KEY (event_id, vendor_id),
  CONSTRAINT event_vendors_fk_vendors
    FOREIGN KEY (vendor_id)                         
    REFERENCES vendors (vendor_id),
  CONSTRAINT event_vendors_fk_events
    FOREIGN KEY (event_id)                          
    REFERENCES events (event_id)
);

CREATE TABLE venue_availability (
  availability_id     INT         PRIMARY KEY         AUTO_INCREMENT,
  venue_id            INT         NOT NULL,
  availability_date   DATE        NOT NULL,
  start_time          TIME        NOT NULL,
  end_time            TIME        NOT NULL,
  is_available        BOOLEAN     DEFAULT TRUE,
  event_id            INT         UNIQUE,                           
  CONSTRAINT venue_availability_fk_venues
    FOREIGN KEY (venue_id)                          
    REFERENCES venues (venue_id),
  CONSTRAINT venue_availability_fk_events
    FOREIGN KEY (event_id)                         
    REFERENCES events (event_id)
);

-- insert basic sample data
INSERT INTO venues (venue_id, venue_name, address1, address2, city, state, zip, phone, email, capacity, price)
VALUES
(DEFAULT, 'Biltmore Estate', '1 Lodge St', NULL, 'Asheville', 'NC', '28803', '(828) 225-1660', 'info@biltmore.com', 400, 10000.00),
(DEFAULT, 'Homewood', '19 Zillicoa St', NULL, 'Asheville', 'NC', '28801', '(828) 232-9900', 'info@mybelovedhomewood.com', 150, 5000.00),
(DEFAULT, 'The North Carolina Arboretum', '100 Frederick Law Olmsted Way', NULL, 'Asheville', 'NC', '28806', '(828) 665-2492', 'events@ncarboretum.org', 150, 750.00),
(DEFAULT, 'Highland Brewing Company', '12 Old Charlotte Hwy, Suite 200', NULL, 'Asheville', 'NC', '28803', '(828) 299-3370', 'events@highlandbrewing.com', 250, 4000.00),
(DEFAULT, 'The Sanctuary at Fiddlehead', '212 Fiddlehead Ln', NULL, 'Asheville', 'NC', '28790', 'N/A', 'info@thesanctuaryatfiddlehead.com', 150, 4550.00),
(DEFAULT, 'Capital Club of Asheville', '82 Patton Ave', NULL, 'Asheville', 'NC', '28801', '(828) 398-5055', 'info@capitalclubavl.com', 175, 4500.00),
(DEFAULT, 'Haiku I Do', '26 Sweeten Creek Rd', NULL, 'Asheville', 'NC', '28803', '(828) 505-1963', 'info@haikui-do.com', 150, 3700.00),
(DEFAULT, 'Weaver House', '56 N Main St', NULL, 'Weaverville', 'NC', '28787', '(828) 484-1299', 'info@weaverhousenc.com', 200, 5000.00),
(DEFAULT, 'The Event Space at Hi-Wire Brewing', '2B Huntsman Pl', NULL, 'Asheville', 'NC', '28803', '(828) 738-2448', 'events@hiwirebrewing.com', 200, 4000.00),
(DEFAULT, 'Douglas Ellington House', '583 Chunns Cove Rd', NULL, 'Asheville', 'NC', '28805', 'N/A', 'info@douglasellingtonhouse.com', 125, 3500.00),
(DEFAULT, 'The Venue', '21 N Market St', '', 'Asheville', 'NC', '28801', '(828) 252-1101', 'info@thevenueasheville.com', 250, 6000.00);

INSERT INTO employees (first_name, last_name, address1, address2, city, state, zip, phone, email)
VALUES
('Emily', 'Waters', '123 Magnolia Ave', 'Apt 2B', 'Asheville', 'NC', '28801', '(828) 555-0192', 'emily.waters@everafterevents.com'),
('Daniel', 'Reed', '456 Willow St', NULL, 'Asheville', 'NC', '28806', '(828) 555-0143', 'daniel.reed@everafterevents.com'),
('Anthony', 'Sepielli', '789 Laurel Dr', NULL, 'Asheville', 'NC', '28803', '(828) 555-0164', 'sophia.nguyen@everafterevents.com'),
('Marcus', 'Lopez', '321 Sycamore Ln', NULL, 'Weaverville', 'NC', '28787', '(828) 555-0178', 'marcus.lopez@everafterevents.com'),
('Isabella', 'King', '654 Dogwood Rd', 'Suite 1', 'Asheville', 'NC', '28805', '(828) 555-0139', 'isabella.king@everafterevents.com'),
('Jasmine', 'Patel', '812 Birch Blvd', NULL, 'Asheville', 'NC', '28804', '(828) 555-0185', 'jasmine.patel@everafterevents.com'),
('Owen', 'Brooks', '145 Cedar Creek Ln', 'Unit C', 'Arden', 'NC', '28704', '(828) 555-0127', 'owen.brooks@everafterevents.com'),
('Chloe', 'Ramirez', '275 Hawthorne Ave', NULL, 'Asheville', 'NC', '28801', '(828) 555-0150', 'chloe.ramirez@everafterevents.com');

INSERT INTO service_types (service_name, service_description)
VALUES
('venue', 'Booking and coordination of ceremony and reception locations'),
('catering', 'Food and beverage services for the wedding event'),
('floristry', 'Design and arrangement of wedding floral décor and bouquets'),
('photography', 'Professional photography services for the wedding'),
('entertainment', 'Live music, DJs, or other entertainment providers'),
('tux rentals', 'Rental services for tuxedos and formal-wear for the groom and groomsmen'),
('dress rentals', 'Rental services for bridal gowns and bridesmaids’ dresses'),
('bar', 'Bar setup and beverage service, including bartenders'),
('wedding cake', 'Custom cake design and baking for the wedding'),
('aesthetician', 'Makeup, hair, and beauty services for the wedding party');

INSERT INTO employee_services (employee_id, service_id, years_experience)
VALUES
-- Emily Waters
(1, 1, 7),  -- venue
(1, 2, 5),  -- catering
(1, 4, 4),  -- photography
-- Daniel Reed
(2, 2, 6),  -- catering
(2, 8, 4),  -- bar
(2, 9, 3),  -- wedding cake
-- Anthony Sepielli
(3, 5, 5),  -- entertainment
(3, 4, 6),  -- photography
(3, 1, 3),  -- venue
(3, 8, 4),  -- bar
-- Marcus Lopez
(4, 6, 4),  -- tux rentals
(4, 7, 4),  -- dress rentals
(4, 2, 3),  -- catering
-- Isabella King
(5, 3, 8),  -- floristry
(5, 10, 4), -- aesthetician
(5, 6, 4),  -- tux rentals
(5, 7, 4),  -- dress rentals
(5, 2, 3),  -- catering
-- Jasmine Patel
(6, 3, 7),  -- floristry
(6, 7, 2),  -- dress rentals
(6, 10, 5), -- aesthetician
-- Owen Brooks
(7, 5, 6),  -- entertainment
(7, 8, 3),  -- bar
-- Chloe Ramirez
(8, 1, 4),  -- venue
(8, 4, 3),  -- photography
(8, 9, 2);  -- wedding cake

INSERT INTO clients (first_name, last_name, address1, address2, city, state, zip, phone, email)
VALUES
('Rachel', 'Garzarelli', '120 Cedar Hill Rd', NULL, 'Asheville', 'NC', '28801', '(828) 555-2101', 'rachel.garzarelli@gmail.com'),
('Lena', 'Garzarelli', '120 Cedar Hill Rd', NULL, 'Asheville', 'NC', '28801', '(828) 555-2102', 'lena.garzarelli@yahoo.com'),
('Hanna', 'Kirby', '233 Beechwood Ave', 'Apt 4B', 'Asheville', 'NC', '28803', '(828) 555-2103', 'hanna.kirby@outlook.com'),
('Emily', 'Burdette', '98 Riverbend Dr', NULL, 'Weaverville', 'NC', '28787', '(828) 555-2104', 'emily.burdette@gmail.com'),
('Sue', 'Kirby', '233 Beechwood Ave', 'Apt 4B', 'Asheville', 'NC', '28803', '(828) 555-2105', 'sue.kirby@yahoo.com'),
('Ryan', 'Franklin', '14 Chestnut St', NULL, 'Asheville', 'NC', '28806', '(828) 555-2106', 'ryan.franklin@outlook.com'),
('Tanya', 'Franklin', '14 Chestnut St', NULL, 'Asheville', 'NC', '28806', '(828) 555-2107', 'tanya.franklin@gmail.com'),
('Patricia', 'Galbani', '312 Willow Ln', NULL, 'Asheville', 'NC', '28804', '(828) 555-2108', 'patricia.galbani@yahoo.com'),
('Jon', 'Wilson', '488 Highland Blvd', NULL, 'Arden', 'NC', '28704', '(828) 555-2109', 'jon.wilson@outlook.com'),
('Maddie', 'Blankenship', '215 Blue Ridge Pkwy', NULL, 'Candler', 'NC', '28715', '(828) 555-2110', 'maddie.blankenship@gmail.com'),
('Erin', 'Blankenship', '215 Blue Ridge Pkwy', NULL, 'Candler', 'NC', '28715', '(828) 555-2111', 'erin.blankenship@yahoo.com'),
('Kenny', 'Hsu', '79 Maple Crest Dr', NULL, 'Asheville', 'NC', '28805', '(828) 555-2112', 'kenny.hsu@outlook.com'),
('Ben', 'Bradshaw', '303 Oak Hollow Rd', NULL, 'Asheville', 'NC', '28803', '(828) 555-2113', 'ben.bradshaw@gmail.com'),
('Megan', 'Fox', '110 Ivy Glen Ln', NULL, 'Asheville', 'NC', '28801', '(828) 555-2114', 'megan.fox@yahoo.com'),
('Matt', 'Harris', '400 Laurel Ridge Dr', NULL, 'Weaverville', 'NC', '28787', '(828) 555-2115', 'matt.harris@outlook.com'),
('Annika', 'Crutchfield', '52 Pine Meadow Ct', NULL, 'Asheville', 'NC', '28806', '(828) 555-2116', 'annika.crutchfield@gmail.com'),
('Alec', 'Codeman', '620 Sunset View Dr', NULL, 'Asheville', 'NC', '28805', '(828) 555-2117', 'alec.codeman@yahoo.com');

-- appointments for May 10th, 2025
INSERT INTO appointments (client_id, employee_id, start_time, end_time, service_to_plan)
VALUES
-- Client 1 (Rachel Garzarelli) with Employee 1 (Emily Waters) (Venue)
(1, 1, '2025-05-10 09:00:00', '2025-05-10 10:00:00', 1),
-- Client 1 (Rachel Garzarelli) with Employee 2 (Daniel Reed) (Catering) 
(1, 2, '2025-05-10 10:30:00', '2025-05-10 11:30:00', 2),
-- Client 2 (Lena Garzarelli) with Employee 1 (Emily Waters) (Photography) 
(2, 1, '2025-05-10 11:00:00', '2025-05-10 12:00:00', 4),
-- Client 3 (Hanna Kirby) with Employee 3 (Anthony Sepielli) (Bar)
(3, 3, '2025-05-10 09:00:00', '2025-05-10 10:00:00', 8),
-- Client 3 (Hanna Kirby) with Employee 4 (Marcus Lopez) about (Dress Rentals)
(3, 4, '2025-05-10 10:30:00', '2025-05-10 11:30:00', 7),
-- Client 4 (Emily Burdette) with Employee 8 (Chloe Ramirez) (Wedding Cake) 
(4, 8, '2025-05-10 12:00:00', '2025-05-10 13:00:00', 9),
-- Client 2 (Lena Garzarelli) with Employee 2 (Daniel Reed) (Wedding Cake)
(2, 2, '2025-05-10 13:30:00', '2025-05-10 14:30:00', 9),
-- Client 5 (Sue Kirby) with Employee 6 (Jasmine Patel) (Floristry)
(5, 6, '2025-05-10 14:30:00', '2025-05-10 15:30:00', 3),
-- Client 5 (Sue Kirby) with Employee 3 (Anthony Sepielli) (Entertainment)
(5, 3, '2025-05-10 16:00:00', '2025-05-10 17:00:00', 5);

-- appointments for May 12th, 2025
INSERT INTO appointments (client_id, employee_id, start_time, end_time, service_to_plan)
VALUES
-- Client 3 (Hanna Kirby) with Employee 1 (Emily Waters) (Photography)
(3, 1, '2025-05-12 09:00:00', '2025-05-12 10:00:00', 4),
-- Client 14 (Megan Fox) with Employee 2 (Daniel Reed) (Catering)
(14, 2, '2025-05-12 09:00:00', '2025-05-12 10:00:00', 2),
-- Client 13 (Ben Bradshaw) with Employee 3 (Anthony Sepielli) (Photography)
(13, 3, '2025-05-12 09:00:00', '2025-05-12 10:00:00', 4),
-- Client 6 (Ryan Franklin) with Employee 4 (Marcus Lopez) (Tux Rentals)
(6, 4, '2025-05-12 09:00:00', '2025-05-12 10:00:00', 6),
-- Client 5 (Sue Kirby) with Employee 5 (Isabella King) (Catering)
(5, 5, '2025-05-12 09:00:00', '2025-05-12 10:00:00', 2),
-- Client 4 (Emily Burdette) with Employee 6 (Jasmine Patel) (Aesthetician)
(4, 6, '2025-05-12 09:00:00', '2025-05-12 10:00:00', 10),
--  Client 9 (Jon Wilson) with Owen Brooks (Entertainment)
(9, 7, '2025-05-12 09:00:00', '2025-05-12 10:00:00', 5),
-- Client 8 (Patricia Galbani) with Chloe Ramirez (Wedding Cake)
(8, 8, '2025-05-12 09:00:00', '2025-05-12 10:00:00', 9),
-- Add another round starting at 10:30 AM (30-minute buffer)
-- Client 9 (Jon Wilson) with Employee 1 (Emily Waters) (Photography)
(9, 1, '2025-05-12 10:30:00', '2025-05-12 11:30:00', 4),
-- Client 11 (Erin Blankenship) with Employee 2 (Daniel Reed) (Wedding Cake)
(11, 2, '2025-05-12 10:30:00', '2025-05-12 11:30:00', 9),
-- Client 10 (Maddie Blankenship) with Employee 3 (Anthony Sepielli) (Bar)
(10, 3, '2025-05-12 10:30:00', '2025-05-12 11:30:00', 8),
-- Client 12 (Kenny Hsu) with Employee 4 (Marcus Lopez) (Tux Rentals)
(12, 4, '2025-05-12 10:30:00', '2025-05-12 11:30:00', 6),
-- Client 13 (Ben Bradshaw) with Employee 5 (Isabella King) (Tux Rentals)
(13, 5, '2025-05-12 10:30:00', '2025-05-12 11:30:00', 6),
-- Client 14 (Megan Fox) with Employee 6 (Jasmine Patel) (Floristry)
(14, 6, '2025-05-12 10:30:00', '2025-05-12 11:30:00', 3),
-- Client 15 (Matt Harris) with Employee 7 (Owen Brooks) (Entertainment)
(15, 7, '2025-05-12 10:30:00', '2025-05-12 11:30:00', 5),
-- Client 16 (Annika Crutchfield) with Employee 8 (Chloe Ramirez) (Photography)
(16, 8, '2025-05-12 10:30:00', '2025-05-12 11:30:00', 4); 

INSERT INTO events (event_id, event_type, event_date, start_time, end_time, guest_count, venue_id, dress_code)
VALUES
-- Rachel's wedding
(DEFAULT, 'wedding', '2025-06-15', '16:00:00', '22:00:00', 120, 1, NULL), 
-- Patto's wedding
(DEFAULT, 'wedding', '2025-07-10', '15:00:00', '21:00:00', 80, NULL, NULL),
-- Maddie's wedding 
(DEFAULT, 'wedding', '2025-08-03', '17:30:00', '23:30:00', 150, 3, 'white tie'),
-- Hanna's wedding 
(DEFAULT, 'wedding', '2025-09-01', '14:00:00', '20:00:00', 200, NULL, 'casual'), 
-- Annika's wedding
(DEFAULT, 'wedding', '2025-10-18', '16:30:00', '22:30:00', 60, 2, 'black tie optional'),
-- Ben's wedding 
(DEFAULT, 'wedding', '2025-10-18', '14:00:00', '18:00:00', 100, NULL, 'semi-formal'),
-- Ben's reception
(DEFAULT, 'reception', '2025-10-18', '19:00:00', '23:30:00', 80, NULL, 'casual'),
-- Hanna's reception
(DEFAULT, 'reception', '2025-09-01', '20:00:01', '23:30:00', 200, NULL, 'casual'),
-- Random test reception
(DEFAULT, 'reception', '2025-09-01', '15:00:00', '17:00:00', 100, NULL, NULL);   

-- wedding clients
INSERT INTO event_clients (event_id, client_id, role)
VALUES
(1, 1, 'bride'),            -- Rachel Garzarelli
(1, 2, 'sister of bride'),  -- Lena Garzarelli
(2, 8, 'bride'),            -- Patricia Galbani
(2, 9, 'groom'),            -- Jon Wilson
(2, 12, 'best man'),        -- Kenny Hsu
(3, 10, 'bride'),           -- Maddie Blankenship
(3, 11, 'sister of bride'), -- Erin Blankenship
(3, 15, 'groom'),           -- Matt Harris
(4, 3, 'bride'),            -- Hanna Kirby
(4, 4, 'maid of honor'),    -- Emily Burdette
(4, 5, 'mother of bride'),  -- Sue Kirby
(4, 6, 'groom'),            -- Ryan Franklin
(4, 7, 'mother of groom'),  -- Tanya Franklin
(5, 16, 'bride'),           -- Annika Crutchfield
(5, 17, 'groom'),           -- Alec Codeman
(6, 13, 'groom'),           -- Ben Bradshaw
(6, 14, 'bride');           -- Megan Fox

-- reception_clients
INSERT INTO event_clients (event_id, client_id, role)
VALUES
(7, 13, 'groom'),           -- Ben Bradshaw
(7, 14, 'bride'),           -- Megan Fox
(8, 3, 'bride'),            -- Hanna Kirby
(8, 4, 'maid of honor'),    -- Emily Burdette
(8, 5, 'mother of bride'),  -- Sue Kirby
(8, 6, 'groom'),            -- Ryan Franklin
(8, 7, 'mother of groom');  -- Tanya Franklin

INSERT INTO venue_availability (availability_id, venue_id, availability_date, start_time, end_time, is_available, event_id) 
VALUES
-- Rachel's wedding
(DEFAULT, 1, '2025-06-15', '16:00:00', '22:00:00', FALSE, 1), 
-- Maddie's wedding   
(DEFAULT, 3, '2025-08-03', '17:30:00', '23:30:00', FALSE, 3), 
-- Annika's wedding   
(DEFAULT, 2, '2025-10-18', '16:30:00', '22:30:00', FALSE, 5);    

INSERT INTO vendors (service_id, vendor_name, address1, address2, city, state, zip, phone, email, price)
VALUES
-- Catering
(2, 'White Wine and Butter', '123 Gourmet St', NULL, 'Asheville', 'NC', '28801', '(828) 555-1001', 'contact@whitewineandbutter.com', 5000.00),
(2, 'Homegrown Catering', '456 Local Ave', NULL, 'Asheville', 'NC', '28801', '(828) 555-1002', 'info@homegrowncatering.com', 4500.00),
(2, 'Mountain Harvest Kitchen', '789 Rustic Way', NULL, 'Weaverville', 'NC', '28787', '(828) 555-1003', 'events@mountainharvest.com', 4800.00),
-- Floristry
(3, 'Flora', '789 Bloom Rd', NULL, 'Asheville', 'NC', '28801', '(828) 555-2001', 'hello@floraflowers.com', 3000.00),
(3, 'StarGazers Designs', '321 Petal Ln', NULL, 'Asheville', 'NC', '28801', '(828) 555-2002', 'contact@stargazersdesigns.com', 2800.00),
(3, 'Wildflower Boutique', '404 Valley Bloom Blvd', NULL, 'Asheville', 'NC', '28803', '(828) 555-2003', 'studio@wildfloweravl.com', 3200.00),
-- Photography
(4, 'Amber Hatley Photography', '654 Lens Blvd', 'Suite 5', 'Asheville', 'NC', '28801', '(828) 555-3001', 'amber@amberhatley.com', 4000.00),
(4, 'Light Shifter Studios', '987 Snapshot Dr', NULL, 'Asheville', 'NC', '28801', '(828) 555-3002', 'info@lightshifterstudios.com', 3800.00),
(4, 'Blue Ridge Pixels', '122 Shutter St', NULL, 'Asheville', 'NC', '28806', '(828) 555-3003', 'brpixels@outlook.com', 3500.00),
-- Entertainment
(5, 'DJ Poundcake', '159 Beat St', NULL, 'Asheville', 'NC', '28801', '(828) 555-4001', 'dj@poundcakeentertainment.com', 2500.00),
(5, 'The Royal Suits', '753 Harmony Ave', NULL, 'Asheville', 'NC', '28801', '(828) 555-4002', 'booking@theroyalsuits.com', 2700.00),
(5, 'Soundscape AVL', '230 Rhythm Blvd', NULL, 'Asheville', 'NC', '28804', '(828) 555-4003', 'soundscape@musicavl.com', 2600.00),
-- Tux Rentals
(6, 'Asheville Tuxedo Co.', '852 Formal Way', NULL, 'Asheville', 'NC', '28801', '(828) 555-5001', 'rentals@ashevilletux.com', 150.00),
(6, 'Black Tie Rentals', '369 Suit Blvd', NULL, 'Asheville', 'NC', '28801', '(828) 555-5002', 'info@blacktierentals.com', 160.00),
(6, 'Formalwear of Asheville', '712 Button St', NULL, 'Asheville', 'NC', '28801', '(828) 555-5003', 'support@formalavl.com', 140.00),
-- Dress Rentals
(7, 'Meadowbrooke Bridal', '147 Gown St', NULL, 'Asheville', 'NC', '28801', '(828) 555-6001', 'contact@meadowbrookebridal.com', 500.00),
(7, 'Candler Budget Bridal', '258 Elegance Rd', NULL, 'Candler', 'NC', '28715', '(828) 555-6002', 'info@candlerbridal.com', 450.00),
(7, 'Velvet Veil Boutique', '341 Silk Ave', NULL, 'Asheville', 'NC', '28803', '(828) 555-6003', 'hello@velvetveil.com', 475.00),
-- Bar Services
(8, 'Mix Masters Mobile Bar', '900 Spirits Rd', NULL, 'Asheville', 'NC', '28801', '(828) 555-7001', 'events@mixmastersbar.com', 2200.00),
(8, 'Craft Cocktails Co.', '810 Highball Ln', NULL, 'Asheville', 'NC', '28801', '(828) 555-7002', 'booking@craftcocktailsco.com', 2100.00),
-- Wedding Cakes
(9, 'Sweet Elegance Bakery', '123 Sugar Blvd', NULL, 'Asheville', 'NC', '28801', '(828) 555-8001', 'order@sweetelegance.com', 950.00),
(9, 'Buttercream Dreams', '675 Dessert Dr', NULL, 'Asheville', 'NC', '28801', '(828) 555-8002', 'cakes@buttercreamdreams.com', 875.00),
-- Aesthetician
(10, 'Glow & Grace', '412 Spa Way', NULL, 'Asheville', 'NC', '28801', '(828) 555-9001', 'glow@graceaesthetics.com', 300.00),
(10, 'Radiance Asheville', '688 Beauty Ln', NULL, 'Asheville', 'NC', '28803', '(828) 555-9002', 'appointments@radianceavl.com', 320.00);

-- Based on previous appointments
INSERT INTO event_vendors (event_id, vendor_id)
VALUES
-- Rachel's Wedding, Homegrown Catering (Catering)
(1, 2),
-- Rachel's Wedding, Blue Ridge Pixels (Photography)
(1, 9),
-- Rachel's Wedding, Buttercream Dreams (Wedding Cake)
(1, 22),
-- Patto's Wedding, Sweet Elegance Baker (Wedding Cake)
(2, 21),
-- Patto's Wedding, Soundscape AVL (Entertainment)
(2, 12),
-- Patto's Wedding, Light Shifter Studios (Photography)
(2, 8),
-- Patto's Wedding, Asheville Tuxedo Co. (Tux Rentals)
(2, 13),
-- Maddie's Wedding, Buttercream Dreams (Wedding Cake)
(3, 22),
-- Maddie's Wedding, Craft Cocktails Co. (Bar)
(3, 20),
-- Maddie's Wedding, The Royal Suits (Entertainment)
(3, 11), 
-- Hanna's Wedding, Mix Masters Mobile Bar (Bar)
(4, 19),
-- Hanna's Wedding, Candler Budget Bridal (Dress Rentals)
(4, 17),
-- Hanna's Wedding, Buttercream Dreams (Wedding Cake)
(4, 22),
-- Hanna's Wedding, StarGazers Designs (Floristry)
(4, 5),
-- Hanna's Wedding, DJ Poundcake (Entertainment)
(4, 10), 
-- Hanna's Wedding, Blue Ridge Pixels (Photography)
(4, 9), 
-- Hanna's Wedding, Asheville Tuxedo Co. (Tux Rentals)
(4, 13),
-- Hanna's Wedding, Mountain Harvest Kitchen (Catering)
(4, 3), 
-- Hanna's Wedding, Glow & Grace (Aesthetician)
(4, 23), 
-- Annika's Wedding, Amber Hatley Photography (Photography)
(5, 7);

-- Procedures and views
-- Finds available venues for a given date and guest count.
DROP PROCEDURE IF EXISTS FindAvailableVenues;
DELIMITER //
CREATE PROCEDURE FindAvailableVenues(
  IN search_date DATE,
  IN start_time TIME,
  IN end_time TIME,
  IN guest_count INT
)
BEGIN
  SELECT v.venue_id, v.venue_name, v.capacity, v.price
  FROM venues v
  WHERE v.capacity >= guest_count
  AND NOT EXISTS (
    SELECT 1 FROM venue_availability va
    WHERE va.venue_id = v.venue_id
    AND va.availability_date = search_date
    AND va.is_available = FALSE
    AND (
      (va.start_time <= end_time AND va.end_time >= start_time)
    )
  )
  ORDER BY v.price;
END//
DELIMITER ;

-- Calculates the total cost of services for a wedding.
DROP PROCEDURE IF EXISTS calculateEventCost;
DELIMITER //
CREATE PROCEDURE calculateEventCost(
  IN event_id INT
)
BEGIN
  DECLARE total_event_cost DECIMAL(9,2);

  SELECT SUM(price)
  INTO total_event_cost
  FROM ( 
    SELECT ev.vendor_id, v.price
    FROM event_vendors ev
      JOIN vendors v
      ON ev.vendor_id = v.vendor_id
    WHERE ev.event_id = event_id
  ) t;

  SELECT CONCAT('$', total_event_cost) AS 'Total Event Cost:';
END //
DELIMITER ;

-- Displays upcoming appointments for the week
CREATE OR REPLACE VIEW view_appointments AS 
  SELECT CONCAT(c.first_name, ' ', c.last_name) as client, 
      CONCAT(e.first_name, ' ', e.last_name) as employee,
      a.start_time,
      a.end_time,
      st.service_name AS service
  FROM appointments a
    JOIN employees e
    ON a.employee_id = e.employee_id
    JOIN clients c 
    ON a.client_id = c.client_id
    JOIN service_types st
    ON a.service_to_plan = st.service_id 
  WHERE a.start_time < DATE_ADD(NOW(), INTERVAL 7 DAY);

-- Displays clients, their roles, and the events that they're in
CREATE OR REPLACE VIEW clients_per_event AS
  SELECT CONCAT(c.first_name, ' ', c.last_name) AS client,
  ec.role AS client_role,
  e.event_id AS event_id,
  e.event_type
  FROM event_clients ec
    JOIN clients c 
    ON ec.client_id = c.client_id
    JOIN events e 
    ON ec.event_id = e.event_id;

-- Sets venue_id for an event
DROP PROCEDURE IF EXISTS set_venue_id;
DELIMITER //
CREATE PROCEDURE set_venue_id(
  IN p_event_id INT,
  IN p_venue_id INT
)
BEGIN
  DECLARE guest_count_var INT;
  DECLARE capacity_var INT;
  DECLARE is_available_var BOOLEAN;
  DECLARE event_date_var DATE;
  DECLARE start_time_var TIME;
  DECLARE end_time_var TIME;

  SELECT guest_count, event_date, start_time, end_time
  INTO guest_count_var, event_date_var, start_time_var, end_time_var
  FROM events
  WHERE event_id = p_event_id;

  SELECT capacity
  INTO capacity_var
  FROM venues
  WHERE venue_id = p_venue_id;

  SELECT COUNT(*) = 0
  INTO is_available_var
  FROM venue_availability
  WHERE venue_id = p_venue_id
    AND availability_date = event_date_var
    AND is_available = FALSE
    AND (
      start_time <= end_time_var AND
      end_time >= start_time_var
    );

  IF is_available_var = FALSE THEN
    SELECT 'There is an availability conflict with this venue.';
  ELSEIF (guest_count_var <= capacity_var AND is_available_var) THEN
    UPDATE events
    SET venue_id = p_venue_id
    WHERE event_id = p_event_id;
    INSERT INTO venue_availability
    VALUES(DEFAULT, p_venue_id, event_date_var, start_time_var, end_time_var, FALSE, p_event_id);    
    SELECT 'The venue has been updated for this event.';
  ELSE 
    SELECT "The guest count for this event exceeds the venue's capacity.";
  END IF;
END //
