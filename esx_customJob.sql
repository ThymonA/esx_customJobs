CREATE TABLE `job_account` (
	`id` INT(11) NOT NULL AUTO_INCREMENT,
	`job` VARCHAR(100) NOT NULL,
    `account` VARCHAR(100) NOT NULL,
	`money` INT(11) NOT NULL DEFAULT 0,
	`label` VARCHAR(100) DEFAULT NULL,

	PRIMARY KEY (`id`),
	UNIQUE INDEX `index_job_account_job_account` (`job`, `account`),
	INDEX `index_job_account_account` (`account`)
);

CREATE TABLE `job_safe` (
	`id` INT(11) NOT NULL AUTO_INCREMENT,
	`job` VARCHAR(100) NOT NULL,
    `item` VARCHAR(100) NOT NULL,
	`count` INT(11) NOT NULL DEFAULT 0,
	`label` VARCHAR(100) DEFAULT NULL,

	PRIMARY KEY (`id`),
	UNIQUE INDEX `index_job_safe_job_item` (`job`, `item`),
	INDEX `index_job_safe_item` (`item`)
);

CREATE TABLE `job_weapon` (
	`id` INT(11) NOT NULL AUTO_INCREMENT,
	`job` VARCHAR(100) NOT NULL,
    `weapon` VARCHAR(100) NOT NULL,
	`count` INT(11) NOT NULL DEFAULT 0,
	`label` VARCHAR(100) DEFAULT NULL,

	PRIMARY KEY (`id`),
	UNIQUE INDEX `index_job_weapon_job_item` (`job`, `weapon`),
	INDEX `index_job_weapon_item` (`weapon`)
);