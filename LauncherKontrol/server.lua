local kontrolAdresi = 'https://yalc.in/fivem_launcher/kontrol.php'
local guncellemeAdresi = 'https://yalc.in/fivem_launcher/guncelle.php'

local function OnPlayerConnecting(name, setKickReason, deferrals)
	deferrals.defer()
    deferrals.update('Girişiniz kontrol ediliyor...')
	
	local identifiers = GetPlayerIdentifiers(source)
	local hex
	
	for _, v in pairs(identifiers) do
        if string.find(v, "steam") then
            hex = v
            break
        end
    end
	
	if hex == nil then
		deferrals.done('Sunucumuza girmek için Steam açmalısınız!')
	end
	
	PerformHttpRequest(kontrolAdresi..'?steamid='..hex, function(err, text, headers) 
		if text == "-2" then
			deferrals.done('Sunucumuzda yasaklısınız.')
		elseif text == "-1" then
			deferrals.done('Şu anda oyundasınız, tekrar giriş yapamazsınız.')
		elseif text == "0" then
			deferrals.done('Sunucumuza girebilmek için launcher çalıştırmalısınız.')
		elseif text == "1" then
			PerformHttpRequest(guncellemeAdresi..'?steamid='..hex..'&durum=-1', function(err, text, headers) end, 'GET', '', { ["Content-Type"] = 'application/json' })
			deferrals.done()
		else
			deferrals.done('Whiteliste ekli değilsiniz.')
		end
	end, 'GET', '', { ["Content-Type"] = 'application/json' })
end

local function OnPlayerDrop(name)
	local identifiers = GetPlayerIdentifiers(source)
	local hex
	
	for _, v in pairs(identifiers) do
        if string.find(v, "steam") then
            hex = v
            break
        end
    end
	
	PerformHttpRequest(guncellemeAdresi..'?steamid='..hex..'&durum=0', function(err, text, headers) end, 'GET', '', { ["Content-Type"] = 'application/json' }) 	
end

AddEventHandler("playerConnecting", OnPlayerConnecting)
AddEventHandler("playerDropped", OnPlayerDrop)

RegisterServerEvent('LauncherKontrol:checkPlayer')
AddEventHandler('LauncherKontrol:checkPlayer', function(playerId)
	if source ~= nil then
		local identifiers = GetPlayerIdentifiers(source)
		local hex
		
		for _, v in pairs(identifiers) do
			if string.find(v, "steam") then
				hex = v
				break
			end
		end
		
		PerformHttpRequest(kontrolAdresi..'?steamid='..hex, function(err, text, headers) 
			if text == "-2" then
				DropPlayer(source, 'Sunucumuzda yasaklısınız.')
			elseif text == "-1" then
			elseif text == "0" then
				DropPlayer(source, 'Sunucumuza girebilmek için launcher çalıştırmalısınız.')
			elseif text == "1" then
				DropPlayer(source, 'Launcher kapatılmış.')
			else
				DropPlayer(source, 'Whiteliste ekli değilsiniz.')
			end
		end, 'GET', '', { ["Content-Type"] = 'application/json' })
	end
end)