        local SWP_SID =		"urn:upnp-org:serviceId:SwitchPower1"
		local DOOR_SID =	"urn:micasaverde-com:serviceId:SecuritySensor1"

		-- Fonction permettant de surveiller les variables presentes dans "inhibit Sensors"
		function register_watch(data)
            -- Gestion des capteurs
            --if (Inibitors(data)) then
             --   luup.variable_set (HVOS_SID, "ModeState", "Idle", lul_device)
            --    luup.log("Inibitor detecte : arret du chauffage")
            --    SetTargetTable("0",data.heaters,data.heaterMode)
			--	luup.call_timer("updateStatus", 1, interval, "", tostring(lul_device))
			--end		
			for index = 1, #data.inhibitSensors, 1 do
                local device = data.inhibitSensors[index]
				local type_device = luup.devices[device].device_type -- On determine le SID en fonction de l'ID.
				
				if (0 > device) then
                    device = 0 - device
                end
				
				if type_device == DOOR_DT then -- En fonction du SID, on determine la variable a lire. A ameliorer peut etre.
					luup.variable_watch("watch_callback", DOOR_SID, "Tripped", device)
				elseif type_device == SWP_DT then
					luup.variable_watch("watch_callback", SWP_SID, "Status", device)
				end
			end
            return true
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
            for v in string.gmatch(s, "(-?[0-9]+)") do
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
