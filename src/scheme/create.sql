DO $$
    BEGIN
        IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'gender_') then
            CREATE TYPE gender_ AS ENUM ('MALE', 'FEMALE', 'OTHER');
        END IF;
    END $$;

CREATE TABLE IF NOT EXISTS profession(
                                         id SERIAL PRIMARY KEY,
                                         name VARCHAR(100) NOT NULL,
                                        
                                        CONSTRAINT profession_unique
                                           UNIQUE (name)
);

CREATE TABLE IF NOT EXISTS responsibility(
                                             id SERIAL PRIMARY KEY,
                                             name VARCHAR(100) NOT NULL,
                                             description TEXT,

                                            CONSTRAINT responsibility_unique
                                                UNIQUE (name)
);

CREATE TABLE IF NOT EXISTS profession_responsibility(
                                                        profession_id INT NOT NULL,
                                                        responsibility_id INT NOT NULL,

                                                        CONSTRAINT profession_responsibility_pk
                                                            PRIMARY KEY (profession_id, responsibility_id),
                                                        CONSTRAINT profession_id_fk
                                                            FOREIGN KEY (profession_id) REFERENCES profession(id)
                                                                ON UPDATE CASCADE
                                                                ON DELETE CASCADE,
                                                        CONSTRAINT location_id_fk
                                                            FOREIGN KEY (responsibility_id) REFERENCES responsibility(id)
                                                                ON UPDATE CASCADE
                                                                ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS location(
                                       id SERIAL PRIMARY KEY,
                                       name VARCHAR(255) NOT NULL,
                                       latitude DECIMAL(10, 8) NOT NULL,
                                       longitude DECIMAL (10, 8) NOT NULL,

                                       CONSTRAINT location_unique
                                           UNIQUE (name, latitude, longitude)
);

CREATE TABLE IF NOT EXISTS ship(
                                   id SERIAL PRIMARY KEY,
                                   name VARCHAR(100) NOT NULL,
                                   manufacture_year DATE
);

CREATE TABLE IF NOT EXISTS sailor(
                                     id SERIAL PRIMARY KEY,
                                     first_name VARCHAR(50) NOT NULL,
                                     last_name VARCHAR(50),
                                     gender gender_ NOT NULL,
                                     profession_id INT NOT NULL,
                                     location_id INT NOT NULL

                                         CONSTRAINT first_name_is_correct
                                             CHECK (first_name ~ '/^[A-Za-z]+([\ A-Za-z]+)*/'),
                                     CONSTRAINT last_name_is_correct
                                         CHECK (last_name IS NULL OR last_name ~ '/^[A-Za-z]+([\ A-Za-z]+)*/'),
                                     CONSTRAINT profession_id_fk
                                         FOREIGN KEY (profession_id) REFERENCES profession(id)
                                             ON UPDATE CASCADE
                                             ON DELETE CASCADE,
                                     CONSTRAINT location_id_fk
                                         FOREIGN KEY (location_id) REFERENCES location(id)
                                             ON UPDATE CASCADE
                                             ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS action(
                                     id SERIAL PRIMARY KEY,
                                     name VARCHAR(50) NOT NULL,
                                     description TEXT,
                                     start_time TIMESTAMP,
                                     duration INTERVAL,
                                     sailor_id INT NOT NULL,

                                     CONSTRAINT sailor_id_fk
                                         FOREIGN KEY (sailor_id) REFERENCES sailor(id)
                                             ON UPDATE CASCADE
                                             ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS ship_component(
                                             id SERIAL PRIMARY KEY,
                                             name VARCHAR(100) NOT NULL,
                                             serial_number VARCHAR(50) NOT NULL,
                                             ship_id INT NOT NULL,

                                             CONSTRAINT serial_number_unique
                                                 UNIQUE (serial_number),
                                             CONSTRAINT ship_id_fk
                                                 FOREIGN KEY (ship_id) REFERENCES ship(id)
                                                     ON UPDATE CASCADE
                                                     ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS ship_component_measurement(
                                                         name VARCHAR(50) NOT NULL,
                                                         result REAL NOT NULL,
                                                         unit VARCHAR(25) NOT NULL,
                                                         sailor_id INT NOT NULL,
                                                         ship_component_id INT NOT NULL,

                                                         CONSTRAINT sailor_id_fk
                                                             FOREIGN KEY (sailor_id) REFERENCES sailor(id)
                                                                 ON UPDATE CASCADE
                                                                 ON DELETE CASCADE,
                                                         CONSTRAINT ship_component_id_fk
                                                             FOREIGN KEY (ship_component_id) REFERENCES ship_component(id)
                                                                 ON UPDATE CASCADE
                                                                 ON DELETE CASCADE
);

CREATE INDEX ship_component_id_sailor_id ON ship_component_measurement(ship_component_id, sailor_id);