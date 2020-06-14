local tables = {
  ["accounts"] = [[
    CREATE TABLE IF NOT EXISTS `%s` (
    `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
    `login` varchar(32) COLLATE utf8_polish_ci NOT NULL,
    `password` varchar(60) COLLATE utf8_polish_ci NOT NULL,
    `serial` varchar(32) COLLATE utf8_polish_ci NOT NULL COMMENT 'serial rejestracji',
    `lastSerial` varchar(32) COLLATE utf8_polish_ci NOT NULL COMMENT 'ostatni serial',
    `ip` varchar(22) COLLATE utf8_polish_ci NOT NULL COMMENT 'ip rejestracji',
    `lastIp` int(11) NOT NULL COMMENT 'ostatnie ip',
    `registerTs` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'data rejestracji',
    `lastUsed` timestamp NOT NULL DEFAULT '0000-00-00 00:00:00' COMMENT 'data ostatniego logowania',
    PRIMARY KEY (`id`)
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_polish_ci
  ]]
}

function initializeTables()
  for tableName,sql in pairs(tables)do
    queryFree(string.format(sql, getTablePrefix()..tableName));
  end
end
addEventHandler("onDatabaseConnected", root, initializeTables)