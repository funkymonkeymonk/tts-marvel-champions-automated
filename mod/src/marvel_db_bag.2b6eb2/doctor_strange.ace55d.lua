-- TODO: this type of function passing is feeling sloppy. I need to figure out how to create a helper to import
local getFromBag = function(params)
    return getObjectFromGUID("330ff1").call("getFromBag", params)
end
positioning = {
    -- Return position "position" in "object"'s frame of reference
    -- (most likely the only function you want to directly access)
    LocalPos = function(self, object, position)
        local rot = object.getRotation()
        local lPos = { position[1], position[2], position[3] }

        -- Z-X-Y extrinsic
        local zRot = self.RotMatrix('z', rot['z'])
        lPos = self.RotateVector(zRot, lPos)
        local xRot = self.RotMatrix('x', rot['x'])
        lPos = self.RotateVector(xRot, lPos)
        local yRot = self.RotMatrix('y', rot['y'])
        lPos = self.RotateVector(yRot, lPos)

        return positioning.Vect_Sum(lPos, object.getPosition())
    end,

    -- Build rotation matrix
    -- 1st table = 1st row, 2nd table = 2nd row etc
    RotMatrix = function(axis, angDeg)
        local ang = math.rad(angDeg)
        local cs = math.cos
        local sn = math.sin

        if axis == 'x' then
            return {
                { 1, 0, 0 },
                { 0, cs(ang), -1 * sn(ang) },
                { 0, sn(ang), cs(ang) }
            }
        elseif axis == 'y' then
            return {
                { cs(ang), 0, sn(ang) },
                { 0, 1, 0 },
                { -1 * sn(ang), 0, cs(ang) }
            }
        elseif axis == 'z' then
            return {
                { cs(ang), -1 * sn(ang), 0 },
                { sn(ang), cs(ang), 0 },
                { 0, 0, 1 }
            }
        end
    end,

    -- Apply given rotation matrix on given vector
    -- (multiply matrix and column vector)
    RotateVector = function(rotMat, vect)
        local out = { 0, 0, 0 }
        for i = 1, 3, 1 do
            for j = 1, 3, 1 do
                out[i] = out[i] + rotMat[i][j] * vect[j]
            end
        end
        return out
    end,

    -- Sum of two vectors (of any size)
    Vect_Sum = function(vec1, vec2)
        local out = {}
        local k = 1
        while vec1[k] ~= nil and vec2[k] ~= nil do
            out[k] = vec1[k] + vec2[k]
            k = k + 1
        end
        return out
    end
}

function setup()
    local specialOffset = { -2, 1, -7 }
    local specialParams = {
        position = positioning:LocalPos(self, specialOffset)
    }

    getFromBag({
        searchBy = "name",
        searchTerm = "Invocation",
        params = specialParams,
        guid = self.getGUID()
    })
end

