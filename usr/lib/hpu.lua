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

local hpu = {};

hpu.holograms={};



hpu.bind = function(comp,x,y,z)
  table.insert(hpu.holograms,{h=comp,x=x-1,z=z-1,y=y-1});
  print("added an hologram with cordinates: ",x,y,z);
  print("calculated maximums would be: ",x+47,z+47,y+31);
end

hpu.clear = function()
	for k, h in pairs(hpu.holograms) do
		h.h.clear();
	end
end;


hpu.set = function(x,y,z,value)
	local x0,y0,z0 = x-1,y-1,z-1;
	for k, h in pairs(hpu.holograms) do
	  if (
		betweenStartAndEnd(h.x,x0,h.x+48)
		and betweenStartAndEnd(h.z,z0,h.z+48)
		and betweenStartAndEnd(h.y,y0,h.y+32)
	  ) then
	    local lx,ly,lz = (x0%48)+1, (y0 % 32) + 1, (z0%48)+1;
		if d then print(x,x0,lx);print(y,y0,ly);print(z,z0,lz);end;
		if d then print(h.h.address);end;
	    return h.h.set(lx,ly,lz,value);
	  end
	end
end;

hpu.get = function(x,y,z)
  local x0,y0,z0 = x-1,y-1,z-1;
  for k, h in pairs(hpu.holograms) do
	  if (
		betweenStartAndEnd(h.x,x0,h.x+48)
		and betweenStartAndEnd(h.z,z0,h.z+48)
		and betweenStartAndEnd(h.y,y0,h.y+32)
	  ) then
	    local lx,ly,lz = (x0%48)+1, (y0 % 32)+1, (z0%48)+1;
	    return h.h.get(lx,ly,lz);
	  end
	end
  return nil,"no hologram configured for this range";
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
	local function fill_(r) 
		print("later callback");
		for j=1,maxY,r do --y
			for t=1,maxZ,r do --z
				for i=1,maxX,r do --x
					hpu.set(i,j,t,1);
				end
			end
		end 
	end;
	local function fill(r)
		local t = thread.create( function() fill_(r) end ):detach();
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