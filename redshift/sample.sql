CREATE TABLE sample
(
    id INT PRIMARY KEY,
    name VARCHAR(100),
    age INT,
    email VARCHAR(100),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    is_active BOOLEAN DEFAULT TRUE
);
