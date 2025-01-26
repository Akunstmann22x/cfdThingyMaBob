# cfdThingyMaBob

I was bored and was like screw it why not try to see my best attempt at a CFD model for Roblox.

Open source anybody that feels like adding to it, go for it!

Math and logic behind it, some parts I know the math behind but had co-pilot write it cause it was a tad beyond me:

Used a basic navier stoke cancelling method to get a coutte flow, which might not be a realistic approximation but it seemed to get fairly good results.

This is for a low reynolds/possible transition number approach "Re < 4000".

Have the velocity of the boundry layer described as v(y) = y/h *vinf, where vinf is the free stream velocity, h is the boundry layer height which was approximated
cause i didnt feel like doing the control volume double integral at 2 am, and y is the distance from the surface. 

Streamlines represent the path that fluid particles follow as they flow around the geometry. The script generates particles upstream and simulates their movement based on the local velocity field.
The particles' movement is calculated by integrating their velocity over time:
x(t+Δt)=x(t)+v(t)⋅Δt

Visualization: The particles are color-coded based on their velocity magnitude, creating velocity contours: Blue: Low velocity (near the surface or recirculation zones). Red: High velocity (away from the surface, in the freestream).



 The angle of attack ( 𝛼) measures the orientation of the geometry relative to the airflow direction. It's calculated using the dot product between: The forward vector of the geometry (f). The airflow direction vector (v ∞ ). 𝛼 = arccos ⁡ ( 𝑓 ⋅ 𝑣 ∞ ) ⋅ 180 𝜋 α=arccos(f⋅v ∞ ​ )⋅ π 180 ​ Special cases handle perfectly aligned or reversed airflow: 𝑓 ⋅ 𝑣 ∞ = 1 f⋅v ∞ ​ =1: AoA = 0° (aligned with airflow). 𝑓 ⋅ 𝑣 ∞ = − 1 f⋅v ∞ ​ =−1: AoA = 180° (reversed to airflow).


Lift and drag is calcuted using the basic equation you can find on NASA's website, but obviously multiplied by the sin of alpha. Also Cl Cd was approximated, if anybody wants to 
add an official cl solver go for it, thats for a later problem. 

The particle motion is computed using Euler integration, a simple numerical method

Its opensource, so here is the basics, have fun!