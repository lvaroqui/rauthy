ALTER TABLE user_attr_config ADD
    user_editable BOOLEAN NOT NULL DEFAULT FALSE,
    is_email BOOLEAN NOT NULL DEFAULT FALSE;

ALTER TABLE clients
    ADD cust_email_mapping TEXT
        REFERENCES user_attr_config
            ON UPDATE ON DELETE CASCADE;