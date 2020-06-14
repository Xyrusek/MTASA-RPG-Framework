local mysqlHandler = nil
local tablePrefix = ""
local mysqlData = {
  login = "root",
  host = "localhost",
  password = "",
	database = "mrf"
}

addEvent("onDatabaseConnected", false)

local function mysql_connect( )
  mysqlHandler = dbConnect( "mysql", "dbname="..mysqlData.database..";host="..mysqlData.host, mysqlData.login, mysqlData.password, "share=1" )
  if mysqlHandler then
    outputDebugString( "[db:mysql_connect()] polaczono z baza danych!" )
    triggerEvent("onDatabaseConnected", root)
    query( "SET NAMES utf8;" )
    setTimer(query,1000*60*2,0,'SET NAMES utf8;') -- mysql gubi się po jakimś czasie
  else
    outputDebugString( "[db:mysql_connect()] brak polaczenia z baza danych. Nastepna proba za 10 sekund" )
    setTimer( mysql_connect, 10000, 1 )
    return false
  end
  return true
end

function getTablePrefix()
  return tablePrefix
end

addEventHandler( "onResourceStart", resourceRoot, function( )
  tablePrefix = get("tablePrefix")
  mysqlHandler = nil
  mysql_connect( )
end )

function query( ... )
  if not isElement( mysqlHandler ) then
    mysql_connect( ) -- autoreconnect
    return
  end

  local safeString=dbPrepareString( mysqlHandler, ... )
	if safeString then
    local query = dbQuery( mysqlHandler, safeString )
    local result, rows, last_insert_id = dbPoll( query, -1 )
    if not result then 
      outputDebugString( "[db:query()]: skrypt: "..getResourceName(sourceResource)..", blad w zapytaniu: ".. select( 1, ... ), 1 )
      return false
    end 
    return result, last_insert_id, rows
  else 
		return false
	end
	return false
end

function getHandler( )
  if not isElement( mysqlHandler ) then
    mysql_connect( ) -- autoreconnect
  end
  
  return mysqlHandler
end

function queryFree( ... )
  if not isElement( mysqlHandler ) then
    mysql_connect( ) -- autoreconnect
    return
  end
  
  local safeString = dbPrepareString( mysqlHandler, ... )
  if safeString then
    local query = dbExec( mysqlHandler, safeString )
    return query
	else 
		return false
	end
	return false
end

function queryAsync( trigger, args, ... )
  if not isElement( mysqlHandler ) then
    mysql_connect( ) -- autoreconnect
    return
  end

  local safeString = dbPrepareString( mysqlHandler, ... )
	if safeString then
		local function callback( query, ...)
      local args = { ... }
      local triggerName = args[1] 
      table.remove( args, 1 ) -- nie przekazujemy nazwy triggera 
      
      local result = dbPoll( query, 0 )
      triggerEvent( triggerName, root, result, unpack( args ) )     
    end
    dbQuery( callback, { trigger, unpack( args ) }, mysqlHandler, safeString )
  end
  return true          
end