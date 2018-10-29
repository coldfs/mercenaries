--green  109929330
--blue - 110029222
--Plants List - for avoiding if nesessery


PlantsList={}
PlantsList[110020967]=1 -- Red Mushroom
PlantsList[109922154]=1 -- Possible green plant?

function IsPlant(id)
    if (PlantsList[id]~=nil) then
        return 1
    end
    return 0
end
