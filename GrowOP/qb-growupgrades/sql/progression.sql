CREATE TABLE IF NOT EXISTS `player_drug_progress` (
  `citizenid` VARCHAR(64) NOT NULL,
  `weed` INT DEFAULT 0,
  `mushroom` INT DEFAULT 0,
  `coca` INT DEFAULT 0,
  PRIMARY KEY (`citizenid`)
);