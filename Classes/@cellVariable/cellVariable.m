classdef cellVariable
    %CELLVARIABLE Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        dimension
        meshsize
        value
        cellsize
        Old = [];
    end
    
    methods
        function cv = cellVariable(meshVar, cellval)
            if nargin>0
                cv.dimension = meshVar.dimension;
                cv.meshsize = meshVar.numberofcells;
                cv.cellsize = meshVar.cellsize;
                cv.value = cellval.*ones(meshVar.numberofcells);
            end
        end
    end    
end

