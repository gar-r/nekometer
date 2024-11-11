BaseMeterMock = {}

function BaseMeterMock:new()
    return {
        recordedData = {},
        RecordData = function(self, data)
            table.insert(self.recordedData, data)
        end,
    }
end