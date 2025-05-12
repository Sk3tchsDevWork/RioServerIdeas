-- Table for tracking player drug progress
CREATE TABLE IF NOT EXISTS player_drug_progress (
    id INT AUTO_INCREMENT PRIMARY KEY,
    citizenid VARCHAR(50) NOT NULL UNIQUE,
    weed INT DEFAULT 0,
    mushroom INT DEFAULT 0,
    coca INT DEFAULT 0
);

-- Table for tracking heat levels
CREATE TABLE IF NOT EXISTS player_heat (
    id INT AUTO_INCREMENT PRIMARY KEY,
    citizenid VARCHAR(50) NOT NULL UNIQUE,
    heat INT DEFAULT 0,
    last_crop TIMESTAMP NULL DEFAULT NULL,
    last_known_coords JSON DEFAULT NULL
);

-- Table for tracking planted crops
CREATE TABLE IF NOT EXISTS bunker_plants (
    id INT AUTO_INCREMENT PRIMARY KEY,
    coords JSON NOT NULL,
    upgrades JSON DEFAULT NULL,
    owner VARCHAR(50) NOT NULL,
    plantedAt INT NOT NULL,
    stage VARCHAR(20) DEFAULT 'small',
    watered BOOLEAN DEFAULT FALSE,
    cropType VARCHAR(50) NOT NULL
);