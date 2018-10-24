--гриб
--свинья
--гриб
--пень
--гриб
--свинья
--свинья
--дерево
--свинья
--хорен
--свинья
--свинья
--
--
--
--
--трава


--Plants List - for avoiding if nesessery

function IsPlant(id)
    if (PlantsList[id]~=nil) then
        return 1
    end
    return 0
end

PlantsList={}
PlantsList[110020967]=1 -- Red Mushroom
PlantsList[109922154]=1 -- Possible green plant?
