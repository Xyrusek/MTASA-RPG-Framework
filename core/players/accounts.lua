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
