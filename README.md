# Prerequisites
You will need the [experimental version of UE4SS] (https://github.com/UE4SS-RE/RE-UE4SS/releases/tag/experimental-latest)

# WorldMapStuff.lua
Currently set to automatically shuffle maps on entering the world map. 

**Excluded maps: Spring Meadows, Monoco's Station**

Set portal_shuffle_seed to nil if you want random portals every time.

Endless Tower is excluded by default but can be changed by setting shuffle_et to true.

Painting Workshop is included by default but can be changed by setting shuffle_workshop to true.

Gestral Beaches are included by default but can be changed by setting shuffle_beaches to true.

Portals will keep their vanilla sizes by default  (The Monolith portal is always huge). Can be changed by setting funny_portals to false.

Weird flavour text to replace level names so you don't know which map you'll be getting until you load in is enabled by default. Can be disabled by setting random_names to false.

# Encounter.lua
## Encounter Scaling
Enemy encounter scaling to highest level character in your party is enabled by default. Set scale_to_party to false if you'd prefer encounters having their default vanilla levels.

scale_down_only will only affect enemies with a higher level than you. Encounters with a vanilla level below yours will be unaffected.

scale_up_only will only affect enemies with a lower level than you. Encounters with a vanilla level above yours will be unaffected.

Turn both scale_down_only and scale_up_only if you'd like enemies to always scale to your party level.

factor is how many times your highest character level to scale the encounter to. Default is at 1.1x your highest character level. 

## Enemy Randomiser
Enemy randomiser proof of concept is off by default. Turn randomise_every_encounter to true to enable.
the other settings are kinda self explanatory
