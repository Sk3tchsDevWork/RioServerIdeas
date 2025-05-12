CREATE TABLE IF NOT EXISTS `player_reputation` (
  `citizenid` VARCHAR(64) NOT NULL,
  `reputation` INT DEFAULT 0,
  PRIMARY KEY (`citizenid`)
);