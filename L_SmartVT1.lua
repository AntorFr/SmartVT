        local SWP_SID =		"urn:upnp-org:serviceId:SwitchPower1"
		local DOOR_SID =	"urn:micasaverde-com:serviceId:SecuritySensor1"

		-- Fonction permettant de surveiller les variables presentes dans "inhibit Sensors"
		function register_watch(Sensors)
			for index = 1, #Sensors, 1 do
                local device = math.abs(Sensors[index])
				local type_device = luup.devices[device].device_type -- On determine le SID en fonction de l'ID.
				if type_device == DOOR_DID or type_device == MOTI_DID then -- En fonction du SID, on determine la variable a lire.
					luup.variable_watch("watch_callback", DOOR_SID, "Tripped", device)
				elseif type_device == BIN_DID then
					luup.variable_watch("watch_callback", SWP_SID, "Status", device)
				end
			end
            return true
		end
        
        function Consigne(data)
            if data.EnergyModeStatus == "EnergySavingsMode" then
                return data.coolSp
            else
                return data.heatSp
            end
        end
        
        function AvgTemperature(t,TimeSecu)
            local sum = 0
            local count= 0
            local temp = {}
            if TimeSecu == nil or tonumber(TimeSecu) == nil then
                TimeSecu = 0
            end

            -- BatteryDate ("urn:micasaverde-com:serviceId:HaDevice1")

            for k,id in pairs(t) do
                
                local invert = false
                if (0 > id) then
                    id = 0 - id
                    invert = true
                end
                
                local temp, time = luup.variable_get(TEMP_SID, "CurrentTemperature", id)                
                temp = tonumber(temp)
                
                local BatDate = luup.variable_get(HAD_SID, "BatteryDate", id)
                local MasterId = luup.devices[id].device_num_parent

                if tonumber(MasterId) ~= nil and BatDate == nil then
                    BatDate = luup.variable_get(HAD_SID, "BatteryDate", MasterId)
                end
                
                if (temp ~= nil) then
                    if (TimeSecu == 0) or (os.time()-time <= TimeSecu) then
                        sum = sum + temp
                        count = count + 1
                    elseif BatDate ~= nil and (os.time()-BatDate <= (TimeSecu * 4)) then
                        sum = sum + temp
                        count = count + 1
                    elseif invert then -- désactivation sécurité
                        sum = sum + temp
                        count = count + 1
                    else
                        -- Attention, la sonde n'a pas prise en compte
                    end
                end
            end
        
            if count > 0 then
                return round((sum / count),1)
            else
                return false
            end
        
        end
        
        
        function SetTargetTable(target,t)
            for k,id in pairs(t) do
                local devicetype = luup.devices[id].device_type
                if (devicetype == BIN_DID) then
                    heaterStatus = luup.variable_get(SWP_SID, "Status", id) -- On recupere la variable du module
                    if heaterStatus ~= target then
                        luup.call_action(SWP_SID, "SetTarget", { newTargetValue= target }, id)
                    end
                elseif (devicetype == VSW_DID) then
                    heaterStatus = luup.variable_get(VSW_SID, "Status", id) -- On recupere la variable du module
                    if heaterStatus ~= target then
                        luup.call_action(VSW_SID, "SetTarget", { newTargetValue= target }, id)
                    end
                elseif (devicetype == PIL_DID) or (devicetype == DIM_DID)  then
                    target = tostring(tonumber(target) * 100)
                    heaterStatus = luup.variable_get(DIM_SID, "LoadLevelStatus", id) -- On recupere la variable du plugin pilotwire Antor
                    if heaterStatus ~= target then -- Si la variable du plugin pilotwire Antor est different du Target, on envoie la commande
                        luup.call_action(DIM_SID, "SetLoadLevelTarget", { newLoadlevelTarget= target}, id)
                    end
                elseif (devicetype == HEAT_DID) then
                    heaterStatus = luup.variable_get(HVUOM_SID, "ModeStatus", id) -- On recupere la variable du module
                    if target == "1" and heaterStatus ~= "HeatOn"  then -- Si la variable du plugin pilotwire Antor est different du Target, on envoie la commande
                        luup.call_action(HVUOM_SID, "SetModeTarget", { NewModeTarget= "HeatOn" }, id)
                    elseif target == "0" and heaterStatus ~= "Off"  then
                        luup.call_action(HVUOM_SID, "SetModeTarget", { NewModeTarget= "Off" }, id)
                    end
                end
            end
        end
		
		function readVariableOrInit(lul_device, devicetype, name, defaultValue)
            local var = luup.variable_get(devicetype,name, lul_device)
            if (var == nil) then
                var = defaultValue
                luup.variable_set(devicetype,name,var,lul_device)
            end
            return var
        end

        function fromListOfNumbers(t)
            return table.concat(t, ",")
        end
        
        function toListOfNumbers(s)
            t = {}
            for v in string.gmatch(s, "(-?[0-9\.]+)") do
                table.insert(t, tonumber(v))
            end
            return t
        end

        function tableMean( t )
            local sum = 0
            local count= 0
        
            for k,v in pairs(t) do
                if type(v) == 'number' then
                sum = sum + v
                count = count + 1
                end
            end
        
            return round((sum / count),1)
        end

        function round(num, idp)
            local mult = 10^(idp or 0)
            return math.floor(num * mult + 0.5) / mult
        end


    function GetTime(TimeStamp,Sec)
        
        local dr = os.date("*t",TimeStamp) -- Referece date
        local newSec = os.time({year=dr.year, month=dr.month, day=dr.day, hour=dr.hour, min=dr.min, sec=(dr.sec+Sec)})
        
        return newSec
    end
    
    function debuglog(log)
        if debug then
            luup.log( "SmartVT : " .. log)
        end
    end
