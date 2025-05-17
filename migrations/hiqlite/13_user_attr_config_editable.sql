ALTER TABLE user_attr_config ADD
    user_editable INTEGER NOT NULL DEFAULT 0;

ALTER TABLE user_attr_config ADD
    is_email INTEGER NOT NULL DEFAULT 0;

ALTER TABLE clients
    ADD cust_email_mapping TEXT
        REFERENCES user_attr_config
            ON UPDATE CASCADE ON DELETE CASCADE;