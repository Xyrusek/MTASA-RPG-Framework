local tables = {
  ["accounts"] = [[
    CREATE TABLE IF NOT EXISTS `%s` (
      `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
      `login` varchar(32) COLLATE utf8_polish_ci NOT NULL,
      `password` varchar(60) COLLATE utf8_polish_ci NOT NULL,
      `serial` varchar(32) COLLATE utf8_polish_ci DEFAULT NULL COMMENT 'serial rejestracji',
      `lastSerial` varchar(32) COLLATE utf8_polish_ci DEFAULT NULL COMMENT 'ostatni serial',
      `ip` varchar(22) COLLATE utf8_polish_ci DEFAULT NULL COMMENT 'ip rejestracji',
      `lastIp` varchar(22) DEFAULT NULL COMMENT 'ostatnie ip',
      `registerTs` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'data rejestracji',
      `lastUsed` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'data ostatniego logowania',
      PRIMARY KEY (`id`)
     ) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8 COLLATE=utf8_polish_ci
  ]],
  ["accountsDatas"] = [[
    CREATE TABLE IF NOT EXISTS `%s` (
      `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
      `uid` int(11) NOT NULL COMMENT 'id konta',
      `valuekey` varchar(128) COLLATE utf8_polish_ci NOT NULL COMMENT 'klucz',
      `value` text COLLATE utf8_polish_ci NOT NULL COMMENT 'wartosc',
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