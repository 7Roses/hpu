--vlag
local d = false;--true;
--imports:
local component = require("component");

-- helper functions
local betweenStartAndEnd = function(minima,actual,maxima)
	--print(" actual >= minima", actual,minima,actual>=minima);
	--print(" actual < maxima", actual,minima,actual<maxima);
	return actual>=minima and actual < maxima;
end

local function has_value (tab, val)
    for index, value in ipairs(tab) do
        if value == val then
            return index;
        end
    end
    return nil;
end

local hpu = {};
hpu.version = 0.3;
hpu.holograms={};
hpu.palette = {};-- the global color palette, entries will be changed by: a bind comand or by the setPaletteColor function.
hpu.bind = function(comp,x,y,z,palette)
	local colorpalette = palette or {1}; -- if none are set, the first in the whole palette is used.
  if (comp.maxDepth()== 1.0) then 
	print("WARNING!, only 1 of the palette can be used, this hologram doesn't support any more.");
	colorpalette = {palette[1] or {1}}
  end
  hpu.holograms[comp.address] = {h=comp,x=x-1,z=z-1,y=y-1,palette=colorpalette};
  print("added an hologram with cordinates: ",x,y,z);
  print("calculated maximums would be: ",x+47,z+47,y+31);
  print("color depth:" .. comp.maxDepth());
  
  for k,v in pairs(colorpalette) do
	hpu.palette[v] = comp.getPaletteColor(k);
	print("configured color: " .. hpu.palette[v] .." with index: "..v);
  end
end

--[[ use this if you set the colors befor binding to the hpu, but don't want to use the hpu.setPaletteColor, or want to be save that all the colors are set right.]]
hpu.initColors = function()
	for k, h in pairs(hpu.holograms) do
	  
		if hpu.debug then 
			print(value);
		end;
		local found = has_value(h.palette,value)
		if found ~=nil then
			h.h.setPaletteColor(found,hpu.palette[value]);
		end
	end
end;

hpu.setPaletteColor = function(index, value)
	hpu.palette[index] = value;
	hpu.initColors();
end;
hpu.getPaletteColor = function(index)
	return hpu.palette[index];
end;


hpu.clear = function()
	for k, h in pairs(hpu.holograms) do
		h.h.clear();
	end
end;

hpu.setModeMultiColor = function(multiColorEnabled)
	if multiColorEnabled then
		hpu.multiColor = true;
	else
		hpu.multiColor = false;
	end;
end;
-- default we set it to nonmuulticolored
hpu.setModeMultiColor(false);


hpu.set = function(x,y,z,value)
	local x0,y0,z0 = x-1,y-1,z-1;
	for k, h in pairs(hpu.holograms) do
	  if (
		betweenStartAndEnd(h.x,x0,h.x+48)
		and betweenStartAndEnd(h.z,z0,h.z+48)
		and betweenStartAndEnd(h.y,y0,h.y+32)
	  ) then
	    local lx,ly,lz = (x0%48)+1, (y0 % 32) + 1, (z0%48)+1;
		if hpu.multiColor or not value or value==0 then h.h.set(lx,ly,lz,false) end; -- on multicolor the color needs to be deleted first.
		if hpu.debug then 
			print(value);
		end;
		local found = has_value(h.palette,value)
		if found ~=nil then
			if hpu.debug then print("found it at index:"..found) end;
			h.h.set(lx,ly,lz,found);
		end
	  end
	end
end;

hpu.get = function(x,y,z)
  local x0,y0,z0 = x-1,y-1,z-1;
  local result = {};
  for k, h in pairs(hpu.holograms) do
	  if (
		betweenStartAndEnd(h.x,x0,h.x+48)
		and betweenStartAndEnd(h.z,z0,h.z+48)
		and betweenStartAndEnd(h.y,y0,h.y+32)
	  ) then
	    local lx,ly,lz = (x0%48)+1, (y0 % 32)+1, (z0%48)+1;
	    local res = h.h.get(lx,ly,lz);
		if res then table.insert(result,res); end
	  end
	end
  return res,"no hologram configured for this range";
end;

hpu.fill = function(x,z,minY,maxY,value)
	checkArg(1,x,"number");
	checkArg(2,z,"number");
	checkArg(3,minY,"number","nil");
	checkArg(4,maxY,"number");
	checkArg(5,value,"number","boolean");
		
	-- two ways possible:
	---- easy -> just loop over them and use the 'set' function
	---- hard -> find out on what holograms you need to set what fill command, and then call them with calculated values.
	
	-- first version will contain the easy one :)
	for t=minY or 1,maxY+1,1 do
		hpu.set(x,t,z,value);
	end;
end;

hpu.copy = function(x,z,sx,sz,tx,tz)
	for ix = 0, sx, 1 do
		local lx = x + ix;
		local lz = z; -- reset it to the original z
		for iz = 0, sz, 1 do
			-- actual translation/copy of the column.
		end
	end
end
--[[
copy(x:number, z:number, sx:number, sz:number, tx:number, tz:number)
Copies an area of columns by the specified translation.
getScale():number
Returns the current render scale of the hologram.
setScale(value:number)
Set the render scale. A larger scale consumes more energy. The minimum scale is 0.33, where the hologram will fit in a single block space, the maximum scale is 3, where the hologram will take up a 9x6x9 block space.
getTranslation:number, number, number Return the current translation offset.
setTranslation(x:number, y:number, z:number) Set the translation vector. The hologram display will be offset by this vector from its normal location. The maximum allowable translation is a function of tier. Units are the hologram's size, so the distance translated increases and decreases with scale as well.
maxDepth():number
The color depth supported by the hologram.
getPaletteColor(index:number):number
Get the color defined for the specified value.
setPaletteColor(index:number, value:number):number

--]]
local getMaxima = function()
	local maxX,maxZ,maxY = 0,0,0;
	for k, h in pairs(hpu.holograms) do
	  if(h.x+48>maxX) then maxX = h.x+48 end;
	  if(h.z+48>maxZ) then maxZ = h.z+48 end;
	  if(h.y+48>maxY) then maxY = h.y+48 end;
	end
	return {maxX=maxX,maxY=maxY,maxZ=maxZ};
end
hpu.diagnostic = function()
	local thread = require("thread");
	local maxima = getMaxima();
	local maxX,maxZ,maxY = maxima.maxX,maxima.maxZ,maxima.maxY;
	
	-- fill the screen with dots r voxels apart. this will run on a timer to give faster command back to the program (while executed when possible.)
	local function fill_(r,value) 
		print("fill thread for color: "..value);
		for j=1,maxY,r do --y
			for t=1,maxZ,r do --z
				for i=1,maxX,r do --x
					hpu.set(i,j,t,value);
				end
			end
		end 
	end;
	local function fill(r,value)
		local t = thread.create( function() fill_(r,value) end ):detach();
	end;
	local check = function(holo,actual,full)
	  if (holo.get(actual.x,actual.y,actual.z)~= 1) then
		print("ERROR on local ",actual.x,actual.y,actual.z," for hologram with address: ",holo.address);
		return false;
	  end
	  if(hpu.get(full.x,full.y,full.z)~= 1) then
	    print("error on hpu get for adress:",full.x,full.y,full.z,"and address:",holo.address);
		return false;
	  end
	  return true;
	end;
	local function testHOLO(hRecord)
	  local h = hRecord.h;
	  local tests = {};
	  table.insert(tests,{local_={x=1,y=1,z=1},full={x=hRecord.x+1,y=1,z=hRecord.z+1}});
	  table.insert(tests,{local_={x=48,y=1,z=1},full={x=hRecord.x+48,y=1,z=hRecord.z+1}});
	  table.insert(tests,{local_={x=1,y=32,z=1},full={x=hRecord.x+1,y=32,z=hRecord.z+1}});
	  table.insert(tests,{local_={x=48,y=32,z=1},full={x=hRecord.x+48,y=32,z=hRecord.z+1}});
	  table.insert(tests,{local_={x=1,y=1,z=48},full={x=hRecord.x+1,y=1,z=hRecord.z+48}});
	  table.insert(tests,{local_={x=48,y=1,z=48},full={x=hRecord.x+48,y=1,z=hRecord.z+48}});
	  table.insert(tests,{local_={x=1,y=32,z=48},full={x=hRecord.x+1,y=32,z=hRecord.z+48}});
	  table.insert(tests,{local_={x=48,y=32,z=48},full={x=hRecord.x+48,y=32,z=hRecord.z+48}});
	  print("selftest for hologram with address: "..h.address);
	  for t,test in pairs(tests) do
		hpu.set(test.full.x,test.full.y,test.full.z,true);
		local message = check(h,test.local_,test.full) and "test "..t.." passed" or "test "..t.." failed";
		print(message);
	  end
	end
	local function selfTest()
		--for each hologram try to set a field through hpu, and then check through the component if the location was set.
		for v,k in pairs(hpu.holograms) do
			testHOLO(k);
		end
		hpu.clear();
	end
	return {xMax=maxX,zMax=maxZ,yMax=maxY,fill=fill,bounds=bounds,selfTest=selfTest}
end

return hpu;