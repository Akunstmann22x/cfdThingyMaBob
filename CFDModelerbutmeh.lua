-- Configuration for simulation
local geometry = workspace.Geometry -- Your geometry, litterally name it geometry
local airflowDirection = Vector3.new(1, 0, 0) -- Airflow direction, im so crap with setting up the vector 3 to get it to work, but this of all things did it
local airflowSpeed = 20 -- Airflow speed (studs/second, kept low for laminar flow)
local airDensity = 1.225 -- Air density (kg/m^3), cause intro to aerodynamics told me so
local simulationDuration = 5 -- Simulation duration (seconds), anything greater and computer will explode
local streamlineStep = 0.05 -- Time step for particle movement (seconds), see above :D

-- Particle and streamline controls
local particleSize = 0.5 -- Size of visualization particles
local streamlineDensity = 20 -- Number of streamlines (per side of the geometry)
local boundaryLayerHeight = 10 -- Approximate height of the boundary layer, THIS I NEED TO WORK ON, I DIDNT FEEL LIKE DOING THE CONTROL VOLUME METHOD BUT, i know

-- Coefficients for aerodynamic forces
local CL = 1.0 -- Lift coefficient, next step is to dynamicall change this
local CD = 0.1 -- Drag coefficient, see above



--The below was quite litterally designed just because of the CFD meme of but the pretty colors. 
-- Function to map velocity to a color (velocity contours)
local function mapVelocityToColor(velocityMagnitude, maxVelocity)
	local normalizedVelocity = math.clamp(velocityMagnitude / maxVelocity, 0, 1)
	local r = normalizedVelocity -- Red for high velocity
	local g = 0 -- No green
	local b = 1 - normalizedVelocity -- Blue for low velocity
	return Color3.new(r, g, b)
end

-- Function to calculate velocity profile (Couette flow approximation), i know coutte flow aint really realistic but, im a simplification connoisour 
local function calculateVelocityProfile(distanceFromSurface, boundaryHeight)
	return math.clamp((distanceFromSurface / boundaryHeight) * airflowSpeed, 0, airflowSpeed)
end

-- Function to calculate lift and drag forces, aerodynamics 101
local function calculateLiftAndDrag(velocityMagnitude)
	local dynamicPressure = 0.5 * airDensity * velocityMagnitude^2
	local lift = dynamicPressure * CL
	local drag = dynamicPressure * CD
	return lift, drag
end

-- Function to create a visualization particle
--I love seeding
local function createParticle(position, color)
	local particle = Instance.new("Part")
	particle.Size = Vector3.new(particleSize, particleSize, particleSize)
	particle.Shape = Enum.PartType.Ball
	particle.Anchored = true
	particle.CanCollide = false
	particle.Material = Enum.Material.Neon
	particle.Color = color
	particle.Position = position
	particle.Parent = workspace
end

-- Function to generate initial starting points for streamlines
--Getting this to offset properly had me one second away from throwing my computer out the window
local function generateStreamlineStartPoints(geometry, density, AoA)
	local size = geometry.Size
	local cframe = geometry.CFrame
	local points = {}

	for i = 1, density do
		for j = 1, density do
			local offsetY = -size.Y / 2 + (size.Y / (density - 1)) * (i - 1)
			local offsetZ = -size.Z / 2 + (size.Z / (density - 1)) * (j - 1)
			local localOffset = Vector3.new(-size.X / 2 - 5, offsetY, offsetZ)
			local startPoint = cframe:PointToWorldSpace(localOffset) 
			table.insert(points, startPoint)
		end
	end

	return points
end

-- Function to simulate particles along streamlines (laminar flow only)
local function simulateStreamline(startPoint, AoA)
	local position = startPoint
	local path = {}
	local totalLift = 0
	local totalDrag = 0

	for t = 0, simulationDuration, streamlineStep do
		-- Distance from the geometry surface
		local distanceFromSurface = math.abs(position.Y - geometry.Position.Y)
		local velocityMagnitude = calculateVelocityProfile(distanceFromSurface, boundaryLayerHeight)
		-- Apply airflow direction and AoA adjustment
		local velocityDirection = airflowDirection * math.cos(math.rad(AoA)) + Vector3.new(0, math.sin(math.rad(AoA)), 0)
		local velocity = velocityDirection.Unit * velocityMagnitude
		-- Update position
		position = position + velocity * streamlineStep
		table.insert(path, {position = position, velocity = velocity, velocityMagnitude = velocityMagnitude})
		-- Calculate forces
		local lift, drag = calculateLiftAndDrag(velocityMagnitude)
		totalLift = totalLift + lift
		totalDrag = totalDrag + drag
	end

	return path, totalLift, totalDrag
end

-- Function to visualize streamlines
local function displayStreamline(path, maxVelocity)
	for _, point in ipairs(path) do
		local velocityMagnitude = point.velocityMagnitude
		local color = mapVelocityToColor(velocityMagnitude, maxVelocity)
		createParticle(point.position, color)
	end
end

-- Function to calculate the angle of attack (AoA)
local function calculateAoA()
	local modelForward = geometry.CFrame.LookVector
	local dotProduct = modelForward:Dot(airflowDirection)
	-- Handle edge cases where AoA would become NaN, cause this shafted me the first time
	if dotProduct >= 1 then
		return 0 -- Perfectly aligned with airflow :D
	elseif dotProduct <= -1 then
		return 180 -- Perfectly reversed to airflow :()
	end

	-- Otherwise, calculate the AoA normally
	return math.acos(dotProduct) * (180 / math.pi)
end

-- Main function to run the simulation
local function runSimulation()
	-- Calculate the angle of attack
	local AoA = calculateAoA()
	print("Angle of Attack (AoA): " .. AoA .. "�")
	-- Generate streamline start points
	local startPoints = generateStreamlineStartPoints(geometry, streamlineDensity, AoA)
	-- Initialize total forces
	local totalLift = 0
	local totalDrag = 0

	-- Simulate and visualize streamlines
	for _, startPoint in ipairs(startPoints) do
		local path, streamlineLift, streamlineDrag = simulateStreamline(startPoint, AoA)
		displayStreamline(path, airflowSpeed)
		-- Accumulate forces
		totalLift = totalLift + streamlineLift
		totalDrag = totalDrag + streamlineDrag
	end

	-- Print total forces
	print("Total Lift: " .. totalLift .. " N")
	print("Total Drag: " .. totalDrag .. " N")
end

-- Run the simulation
runSimulation()
