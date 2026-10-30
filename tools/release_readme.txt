Heavy Aircraft Hangar for Nuclear Option, version {VERSION}
https://github.com/IornMan1213/NO-HeavyHangar

INSTALL
1. You need BepInEx 5 and Blueprinter 2.1.1 or newer.
2. Delete any older Heavy Hangar_*.nobp and HeavyHangar.dll first.
3. Make a folder Nuclear Option/BepInEx/plugins/HeavyHangar/ and put everything from this zip in it.
   (Mod managers that use NOMNOM, such as NOMM, do this for you.)
Every player in a multiplayer game needs the same version.

WHAT IT DOES
- When a mission starts, the host puts a heavy hangar against a taxiway at each land airbase with a runway of
  1,800 m or more. Aircraft wider than 44 m or taller than 9 m spawn from it.
- Airbases without one spawn oversize aircraft just outside a stock hangar's door.
- It's also in the mission editor as "Heavy Aircraft Hangar".

SETTINGS: BepInEx/config/com.ironman1213.heavyhangar.cfg
  Placement.AutoPlace        place hangars automatically (host only)
  Placement.MinRunwayLength  shortest runway that gets one, metres (host only)
  Routing.OversizeSpan / OversizeHeight   what counts as oversize, metres

Licence: MIT (LICENSE.txt). Nuclear Option is (c) Shockfront Studios; this is an unofficial fan mod.
Bugs and feedback: https://github.com/IornMan1213/NO-HeavyHangar/issues
