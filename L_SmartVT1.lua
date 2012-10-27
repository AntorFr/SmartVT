--  START COMMUN FUNCTION
        
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
--  END COMMUN FUNCTION