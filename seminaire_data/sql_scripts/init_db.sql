CREATE SCHEMA EFF_CUSTOMER;
CREATE SCHEMA EFF_WORKING;
CREATE SCHEMA EFF_DATAINTERN;
CREATE SCHEMA EFF_AUDIT;

-- ========================
-- ENUMS
-- ========================
CREATE TYPE intervention_status AS ENUM ('en_cours', 'a_faire', 'fait');
CREATE TYPE user_role AS ENUM ('admin', 'technician', 'gestionnaire');

-- ========================
-- USERS / PERSONNEL
-- ========================
CREATE TABLE EFF_DATAINTERN.LU_User (
                         main_user_id SERIAL PRIMARY KEY,
                         mailing_user VARCHAR(255) UNIQUE NOT NULL,
                         is_internal_user BOOLEAN DEFAULT FALSE,
                         created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                         password_hash VARCHAR(255),
                         last_connection_at TIMESTAMP
);

CREATE TABLE EFF_DATAINTERN.LU_Personnel (
                              user_id SERIAL PRIMARY KEY,
                              main_user_id INT UNIQUE REFERENCES EFF_DATAINTERN.LU_User(main_user_id) ON DELETE CASCADE,
                              role user_role,
                              name VARCHAR(100),
                              surname VARCHAR(100),
                              is_active BOOLEAN DEFAULT TRUE,
                              created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ========================
-- CUSTOMERS / SITES
-- ========================
CREATE TABLE EFF_CUSTOMER.LU_Customer (
                             client_id SERIAL PRIMARY KEY,
                             main_user_id INT UNIQUE REFERENCES EFF_DATAINTERN.LU_User(main_user_id) ON DELETE CASCADE,
                             company_name VARCHAR(255),
                             contact_name VARCHAR(255),
                             phone VARCHAR(50),
                             created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                             updated_at TIMESTAMP
);

CREATE TABLE EFF_CUSTOMER.LU_Site_Address (
                                 site_id SERIAL PRIMARY KEY,
                                 client_id INT REFERENCES EFF_CUSTOMER.LU_Customer(client_id) ON DELETE CASCADE,
                                 address VARCHAR(255),
                                 city VARCHAR(100),
                                 access_codes VARCHAR(255),
                                 created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                                 updated_at TIMESTAMP
);

-- ========================
-- INTERVENTIONS
-- ========================
CREATE TABLE EFF_WORKING.F_Intervention (
                                intervention_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
                                client_id INT REFERENCES EFF_CUSTOMER.LU_Customer(client_id) ON DELETE CASCADE,
                                site_id INT REFERENCES EFF_CUSTOMER.LU_Site_Address(site_id) ON DELETE CASCADE,
                                technician_id INT REFERENCES EFF_DATAINTERN.LU_Personnel(user_id),
                                gestionnaire_id INT REFERENCES EFF_DATAINTERN.LU_Personnel(user_id),
                                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                                scheduled_date TIMESTAMP,
                                realized_date TIMESTAMP,
                                intervention_type VARCHAR(100),
                                status intervention_status DEFAULT 'a_faire',
                                priority_level INT DEFAULT 1
);

CREATE TABLE EFF_CUSTOMER.F_Notation (
                            rating_id SERIAL PRIMARY KEY,
                            intervention_id UUID UNIQUE REFERENCES EFF_WORKING.F_Intervention(intervention_id) ON DELETE CASCADE,
                            score INT,
                            comment TEXT,
                            rated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE EFF_DATAINTERN.F_Skill (
                         technician_id INT PRIMARY KEY REFERENCES EFF_DATAINTERN.LU_Personnel(user_id) ON DELETE CASCADE,
                         elec BOOLEAN DEFAULT FALSE,
                         informatic BOOLEAN DEFAULT FALSE,
                         system BOOLEAN DEFAULT FALSE,
                         network BOOLEAN DEFAULT FALSE,
                         security BOOLEAN DEFAULT FALSE,
                         other BOOLEAN DEFAULT FALSE
);

-- ========================
-- LOGS
-- ========================
CREATE TABLE EFF_AUDIT.F_Auth_Logs (
                             auth_logs_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
                             user_id INT REFERENCES EFF_DATAINTERN.LU_User(main_user_id),
                             created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                             token_authentification TEXT,
                             ip_client VARCHAR(50),
                             is_connection_successful BOOLEAN
);

CREATE TABLE EFF_AUDIT.F_Action_Logs (
                               action_logs_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
                               action_made TEXT,
                               script_name VARCHAR(64),
                               executor_id INT REFERENCES EFF_DATAINTERN.LU_User(main_user_id),
                               executed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
