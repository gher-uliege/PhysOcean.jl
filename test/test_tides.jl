using PhysOcean
using Test

semimajor,  eccentricity, inclication, phase = ap2ep(1.39, -20, 1.12, 10)

@test semimajor ≈  1.72725444147619
@test eccentricity ≈  0.260909679343247
@test inclication ≈  37.9460337000640 atol=1e-9
@test phase ≈  351.499847005578

amplitude_u = 1.3
amplitude_v = 1.12
phase_u = 190
phase_v = 350

semimajor,  eccentricity, inclication, phase = ap2ep(amplitude_u,phase_u,amplitude_v,phase_v)

@test (amplitude_u * cosd(phase-phase_u))^2 + (amplitude_v * cosd(phase-phase_v))^2 ≈ semimajor^2

semiminor = semimajor * eccentricity
@test (amplitude_u * cosd(phase-phase_u+90))^2 + (amplitude_v * cosd(phase-phase_v+90))^2 ≈ semiminor^2

@test semimajor ≈  1.69044952262127
@test eccentricity ≈  0.174264387982538
@test inclication ≈  139.522457812211
@test phase ≈  1.54109835450289


amplitude_u2,phase_u2,amplitude_v2,phase_v2 = ep2ap(semimajor, eccentricity, inclication, phase)

@test amplitude_u ≈ amplitude_u2
@test amplitude_v ≈ amplitude_v2
@test phase_u     ≈ phase_u2
@test phase_v     ≈ phase_v2
