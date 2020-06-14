local accountByUID = {}

function getAccountIdByLogin(login)
  local result = exports.db:queryTable("select id from %s where lower(login) = ? limit 1", "accounts", string.lower(login))
  if(result and #result > 0)then
    return result[1].id
  end
  return false
end

function getAccountInfo(id, column)
  -- @TODO dodać prawdziwe filtrowanie po kolumnie
  local result = exports.db:queryTable("select * from %s where id = ? limit 1", "accounts", id)
  if(not result or #result == 0)then
    return false
  end
  if(column)then
    return result[1][column]
  else
    return result[1]
  end
end

function getLastAccountId()
  local result = exports.db:queryTable("SELECT max(id) as id FROM %s limit 1", "accounts")
  if(result and #result > 0)then
    return result[1].id
  end
  return false
end

function accountLoginExists(login)
  return type(getAccountIdByLogin(login)) == "number"
end

function accountIdExists(id)
  return type(getAccountLoginById(id)) == "string"
end

function getAccountLoginById(id)
  return getAccountInfo(id, "login")
end

function registerAccount(login, password)
  if(not login or not password)then
    return false
  end

  if(accountLoginExists(login))then
    return false
  end

  local hashedPassword = passwordHash(password,"bcrypt",{})
  exports.db:queryTableFree("insert into %s (login, password)values(?,?)","accounts", login, hashedPassword)
  return getLastAccountId();
end

function verifyAccountPassword(accountId, password)
  local hashedPassword = getAccountInfo(accountId,"password")
  if(not hashedPassword)then
    return false
  end
  return passwordVerify(password, hashedPassword)
end

function getAccountData(thePlayer, key)
  local uid = getPlayerUID(thePlayer)
  if(not uid)then
    return;
  end

  local result = exports.db:queryTable("select value from %s where id = ? and valuekey = ? limit 1", "accountsDatas", uid, key)
  if(result and #result > 0)then
    return fromJSON(result[1].value)
  end
  return nil;
end

function hasElementData(thePlayer, key)
  local uid = getPlayerUID(thePlayer)
  if(not uid)then
    return;
  end

  local result = exports.db:queryTable("select 1 from %s where uid = ? and valuekey = ? limit 1", "accountsDatas", uid, key)
  return (result and #result == 1)
end

function setAccountData(thePlayer, key, value)
  local uid = getPlayerUID(thePlayer)
  if(not uid)then
    return;
  end

  local value = toJSON(value);
  if(hasElementData(uid, key))then
    exports.db:queryTableFree("update %s set value = ? where uid = ? and valuekey = ? limit 1", "accountsDatas", value, uid, key)
  else
    exports.db:queryTableFree("insert into %s (uid, valuekey, value)values(?,?,?)", "accountsDatas", uid, key, value)
  end
  return true
end

function savePlayer(thePlayer)
  local uid = getPlayerUID(thePlayer)
  if(not uid)then
    return;
  end
  local totalTimePlayed = getAccountData(thePlayer, "timePlayed") or 0
  
  local loginTick = getElementData(thePlayer, "loginTick") or getTickCount()
  local timePlayed = getTickCount() - loginTick
  
  totalTimePlayed = totalTimePlayed + timePlayed
  setAccountData(thePlayer, "timePlayed", totalTimePlayed)
  return true
end

function isAccountInUse(id)
  return accountByUID[id] and true or false
end

function getPlayerByUID(id)
  return accountByUID[id] or false
end

function isPlayerLoggedIn(thePlayer)
  return getElementData(thePlayer, "loggedIn")
end

function getPlayerUID(thePlayer)
  if(type(thePlayer) == "number")then
    return thePlayer;
  else
    return getElementData(thePlayer, "uid") or false
  end
end

function logoutPlayer(thePlayer)
  local uid = getPlayerUID(thePlayer)
  if(not uid)then
    return;
  end

  savePlayer(thePlayer);
  accountByUID[uid] = nil
  updateAccountLastInfo(id, thePlayer)
  removeElementData(thePlayer, "uid")
  setElementData(thePlayer, "loggedIn", false)
  removeElementData(thePlayer, "loginTick")
  triggerEvent("onPlayerLoggedOut", thePlayer, id)
end

function onLoggedPlayerQuit(quitType, reason, responsibleElement)
  logoutPlayer(source)
end

function updateAccountLastInfo(id, thePlayer)
  local serial = getPlayerSerial(thePlayer)
  local ip = getPlayerIP(thePlayer)
  exports.db:queryTableFree("update %s set lastSerial = ?, lastIp = ?, lastUsed = now()", "accounts", serial, ip)
  return true
end

function loginPlayer(id, thePlayer)
  if(not id)then
    return false
  end
  if(not isElement(thePlayer) or getElementType(thePlayer) ~= "player")then
    return false
  end
  if(isAccountInUse(id))then
    return false
  end
  if(isPlayerLoggedIn(thePlayer))then
    return false
  end
  if(not accountIdExists(id))then
    return false
  end
  accountByUID[id] = thePlayer
  setElementData(thePlayer, "uid", id)
  setElementData(thePlayer, "loggedIn", true)
  setElementData(thePlayer, "loginTick", getTickCount())
  addEventHandler("onPlayerQuit", thePlayer, onLoggedPlayerQuit)
  updateAccountLastInfo(id, thePlayer)
  triggerEvent("onPlayerLoggedIn", thePlayer, id)
  return true
end

addEventHandler("onResourceStop", resourceRoot, function()
  for i,v in pairs(accountByUID)do
    logoutPlayer(v)
  end
end)
