# Custom Void Client
A custom hacked client for Void Realms

### Improving this because I'm bored


## Contents
* Toggleable godmode
  * Prevents projectile damage
  * Prevents tile damage ex: lava tiles
  * Does NOT protect against bombs ex: medusa bombs
* Toggle Kill Aura 
  * Soon to add
* Toggeable Stacked Shots
  * its set at 5 and is non changeable unless you edit the client
* Toggleable msm (Move Speed Multiplier)
  * /msm <number bewteen 1.0 and 2.0>
  * 1.0 is normal speed, 2.0 is double
* Toggleable range boost
  * increases projectile range by 1 second
* No Debuffs
  * No confuse
  * No stunned/dazed
  * No blink, drunk, darkness, hallucination
* No sink
  * disables slowness from sink tiles ex: water tiles, lava, quick sand in tomb etc
* No cooldowns
  * disables ability cooldowns
* Projectile no-clip
  * walls are over rated
* Toggleable display hub
  * displays godmode, range, msm, stacked shots
* Mscale
  * /mscale <1.0 - 3.0>
* Disable Players
  * You can disable players in the experimental options tab (BETA)

## Screen Shot
![alt text](https://github.com/dAtiuyy/VOID/blob/master/Hacks.PNG)
## Download Link
[Client Download](https://github.com/dAtiuyy/VOID/blob/master/CustomVoidClient.swf "Hacked Client")


✓  WebMain.as (Added loader to bypass protection, loads Alvina.swf if there's one in same folder as swf)

✓  PlayGameCommand.as (Custom reconnect delay)

✓  IdleWatcher.as (Remove afk kick)

✓  Player.as (speed/dexhack, stacked shots, ability cooldown, and manaless abil toggles, tp bypass, changeable ArcGap)

✓  MapUserInput.as (Add new buttons for toggles)

✓  Parameters.as (Added new parameters in setDefaults so hack settings save after closing game)

✓  Options.as (Added hacks to options)

✓  Map.as (Allow teleporting on every map)

✓  Gamesprite.as (changed initialize function so spawner tp button cycle resets every map)

✓  GameServerConnectionConcrete.as (Godmode/tile godmode, toggle consumable cooldown, use loader to bypass protection, onValidate function)

✓  ParseChatMessageCommand.as (Where I added commands)

✓  TradeButton.as (Remove trade delay)

✓  Projectile.as (Add killaura with toggle)

✓  GameObject.as (Anti-debuffs)
