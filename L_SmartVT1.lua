        local SWP_SID =		"urn:upnp-org:serviceId:SwitchPower1"
		local DOOR_SID =	"urn:micasaverde-com:serviceId:SecuritySensor1"

		-- Fonction permettant de surveiller les variables presentes dans "inhibit Sensors"
		function register_watch(Sensors)
			for index = 1, #Sensors, 1 do
                local device = Sensors[index]
                
                if (0 > device) then
                    device = 0 - device
                end

				local type_device = luup.devices[device].device_type -- On determine le SID en fonction de l'ID.
				
				if type_device == DOOR_DID then -- En fonction du SID, on determine la variable a lire. A ameliorer peut etre.
					luup.variable_watch("watch_callback", DOOR_SID, "Tripped", device)
				elseif type_device == BIN_DID then
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
