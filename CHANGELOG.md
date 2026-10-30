# Changelog

## Unreleased
- Needs Blueprinter 2.1.1 (built with Blueprinter Editor 0.1.1, which pairs with 2.1.1's material texture fix).
- The build stops on Unity compile errors and builder failures even when Unity exits normally.

## 0.2.0
- **Automatic hangars now sit against a taxiway.** They used to go on grass 70 m or more from the runway, so big
  aircraft couldn't get from the apron to the runway. Now the apron meets one of the airbase's taxiways, level with
  it, with the door facing it; sites nearest a runway end come first, so heavy aircraft get the whole runway.
- The apron's front edge has a sloped lip, so there's no step down onto the taxiway.
- Hangars stay clear of every runway's strip and approach.
- Oversize aircraft spawned outside a stock hangar no longer land on an aircraft, vehicle or building already
  there; they use the next clear spot.
- The plugin builds on Linux without extra settings; build scripts work on Linux and Windows.
- Checked in game: placed against taxiways at Boscali North, the naval base and the city airbase; a B-52 taxis
  from the hangar onto the taxiway on paving all the way.

## 0.1.0
First release.
- Heavy Aircraft Hangar (`hangar_heavy`): 114 x 78 m building with an 84 x 17 m door (six telescoping leaves), lit at night,
  with an apron and taxi line. Damageable, repairable and capturable like the stock hangars.
- Plugin: places one beside the longest runway (1,800 m or more) of each land airbase at mission start, on a flat, clear site
  joined to the runway; routes aircraft wider than 44 m or taller than 9 m to it; spawns oversize aircraft outside the door
  of a stock hangar when a base has no heavy hangar. All configurable.
- Checked in game: placed at Boscali North, the naval base and the city airbase.
