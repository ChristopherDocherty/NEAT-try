memList[1] = 0x0460
memList[2] = 0x04A0
memList[3] = 0x0461
memList[4] = 0x04A1
memList[5] = 0x047D
memlist[6] = 0x04BD
memList[7] = 0x047C
memList[8] = 0x04BC
memList[9] = 0x047B
memList[10] = 0x04BB



function getInputs(memList,times,power2,root2)

    local inputs = {}
    for i = 1,#memList do
		--Trying to nromalize over 1 so that weight mutations have a greater effect
        inputs[i] = memory.readbyte(memList[i])/128 - 1

    end

    if power2 == True then
        local currentSize = #inputs
        for i = 1,#memList do
        inputs[currentSize+i] = 2* inputs[i]^2 /(256^2) - 1
        end
    end

    if power2 == True then
        local currentSize = #inputs
        for i = 1,#memList do
        inputs[currentSize+i] = 2* inputs[i]^(0.5) /(256^(0.5) - 1
        end
    end

    if times == true then
        local currentSize = #inputs
        for i = 2,#memList/2 do
            inputs[currentSize + (i-1)] = 2* (memList[1] * memList[i])/(256^2) - 1
        end
    end

end


console.writeline(memory.readbyte(memList[1]))
