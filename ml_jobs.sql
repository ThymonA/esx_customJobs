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