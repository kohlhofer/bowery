--- Springs
-- a spring physics based voltage follower
-- input 1+2: voltages that outs 1/2 and 2/4 will follow.
-- output 1/2 will follow input 1 
-- output 3/4 will follow input 2 (the first pair is more volatile)
-- For best results don't attentuate the input but the outputs. Bigger or faster changes put more energy into the system and create more pronounced effects. Try using a quantizer to drive two related melodies.



-- settings
scale = false -- outputs are continous (not quantized). Try {0,2,3,5,7,9,10} instead.
rate = 0.05 -- sets the refresh rate for the springs' state calculation. This has a drastic effect and is callibrate to the default set of variables for the springs.

function init()
    -- initialize the 4 springs with dedicated settings for gravity, spring constant, mass, and dampening
    springA = Spring:new(0,0.5,2,0.92)
    springB = Spring:new(0,0.01,5,0.97)
    springC = Spring:new(0,0.7,1,0.90)
    springD = Spring:new(0,0.03,5,0.92)

    -- configure the 4 outputs
    for i = 1, 4 do
      if scale then 
        -- if a scale is set up in settings it is used here
        output[i].scale(scale)
      else 
        -- otherwise the output is slewed to be continuous
        output[i].slew  = rate
      end
    end

    -- kick of the spring update cycle at the given rate
    metro[1].event = updateSprings
    metro[1].time  = rate
    metro[1]:start()
end

function updateSprings() 
    -- update the spring pairs A/B and C/D based on input 1 and 2 using the built in method
    -- Tip: try passing in one springs endpoint (e.g. springA.ps) as anbother springs target
    springA:calculate(input[1].volts)
    springB:calculate(input[1].volts)
    springC:calculate(input[2].volts)
    springD:calculate(input[2].volts)

    -- update the outputs based on the updated springs' states. They all will evetually catch up with the input voltages.
    -- Please note: If you set gravity to something other than 0 than springs will set in a "stretched state which means the voltage will never quite reach the input voltage.
    output[1].volts = springA.ps 
    output[2].volts = springB.ps 
    output[3].volts = springC.ps 
    output[4].volts = springD.ps 
end



-- defining the spring object

Spring = {}

function Spring:new(g,K,M,D)             
-- a = postion of anchor
-- f = force = f=-ky
-- g = gravity (if not 0 the output will be offset from the input and never catch up)
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


function Spring:calculate(target)
  --  method to calculate the spring's state with physics!
  self.a = target or input[1].volts
  self.f = -self.K * ( self.ps - self.a )     -- f=-ky
  self.as = self.f / self.M + self.M * self.g -- Set the acceleration based on force, f=ma == a=f/m
  self.vs = self.D * (self.vs + self.as);     -- Set the velocity
  self.ps = self.ps + self.vs                 -- Updated endpoint 
end



