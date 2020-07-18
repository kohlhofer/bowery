--- Springs
-- a spring physics based voltage follower
-- input 1: target voltage
-- input 2: update clock

scale = {0,2,3,5,7,9,10}

function init() input[2].mode('change',1.0,0.1,'rising') -- input 2 is expecting a clock signal
    springA = Spring:new(0,0.5,1,0.95)
    springB = Spring:new(0,0.05,2,0.5)
    output[1].scale(scale)
    output[2].scale(scale)
    output[3].scale(scale)
    metro[1].event = updateSprings
    metro[1].time  = 0.05
    metro[1]:start()
end

input[2].change = function(state)
    -- output[1].volts = math.random() * 10 - 5
    target = input[1].volts
    output[1].volts = target 
    output[2].volts = springA.ps 
    output[3].volts = springB.ps 
end

function updateSprings() 
    springA:calculate()
    springB:calculate()
end



-- spring object

Spring = {}

function Spring:new(g,K,M,D)             
-- a = postion of anchor
-- f = force = f=-ky
-- g = gravity
-- as = acceleration, f=ma == a=f/m
-- vs = velocity
-- ps = position of spring end
-- K = spring constant
-- M = Mass
-- D = Dampening 

  newObj = {a = 0, f = 0, g = g, as = 0, vs = 0, ps = 0, K = K, M = M, D = D }
  setmetatable(newObj, self)
  self.__index = self
  return newObj
end


function Spring:calculate()
  --  physics!
  self.a = input[1].volts
  self.f = -self.K * ( self.ps - self.a ) -- f=-ky
  self.as = self.f / self.M + self.M * self.g          -- Set the acceleration, f=ma == a=f/m
  self.vs = self.D * (self.vs + self.as);  -- Set the velocity
  self.ps = self.ps + self.vs        -- Updated endpoint position
  print(self.a - self.ps)
end



