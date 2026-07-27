# Lanterndeep — design notes

Design and balance notes for the game. The whole thing is `index.html` at the repository
root — open it in a browser, or build the desktop app with `desktop/build/`.

## Premise
Your grandfather **Elias Kane** sank the shaft alone in 1974, went down one morning
and never came back up. The bank wants the note paid and all the family owns is that
hole in the hill. You take his lantern and his pick.

## The one resource: energy
There is **no health and no death**. The lantern runs on energy and the energy runs out.

- Energy drains constantly (faster the deeper you are).
- Ore, oil flasks (+28s), chests (+35s), soup (+40s) and layer gates (+25%) top it up.
- **Hazards cost energy, not life**: lava −18s, gas −20s, boulder −14s, your own
  dynamite −20s, long falls −4s per block over five.
- At zero energy the rope hauls you up automatically — **you keep everything you mined**.
  The Spirit Lantern skill lets you keep mining for a few seconds past zero.

## Creatures are thieves, not killers
Rock Worms, Cave Bats and the Ancient Warden do not hurt you — they **grab your ore
and run for it**.

- A worm takes 12% of your carried ore, a bat 8%, the Warden 30%.
- The thief flees for six seconds. **Kill it and the ore comes straight back** (plus the
  Thief Taker bonus and its normal drop). Let it escape and the ore is gone.
- Getting robbed also breaks your combo — the real sting.
- The Ore Satchel skill reduces how much they can take; the chest "theft ward" buff
  blocks theft entirely for 14 seconds.

## Scaling
The whole DOM interface lives inside a fixed **design-resolution layer (1240×780)** that is
scaled to the real window with a single transform (1× up to 2.4×). At 1920×1080 the UI renders
at 1.38×, at 1440p at 1.85× — so nothing looks tiny on a big monitor, and percentages, centring
and anchoring all keep working. The Delve tab is a two-column layout on wide screens.

## Look
- **Type**: condensed industrial display face (Bahnschrift / Franklin Gothic) for headings, numbers
  and buttons; humanist sans for body; Georgia italic for the journal and story lines.
- **Palette**: lantern amber as the anchor, with cave teal, relic violet and rose as secondary
  accents so panels are not all one hue. A live `--layer` accent recolours the HUD, depth readout
  and panel edges as you descend.
- **Layer identity**: every layer now has a saturated palette of its own — green earth, grey
  stonebed, violet crystal hollow, green fungal forest, blue frostrift, hot emberwell, ancient
  violet ruins, near-black rock bottom. The fog, the ambient wash and the crust gates are all
  tinted to match, so depth reads at a glance.
- **Menus** run on a three-band parallax mine that slowly crossfades through the layer palettes,
  with glowing ore seams, a swinging lantern wash and drifting dust.
- **Panels** are carved-stone cards with accent edges, top highlights and heavy shadows;
  the journal is inverted to warm parchment with ink-brown serif text.

## Feel
- **Walking is continuous**: linear interpolation with seamless step chaining — constant
  207 px/s, no stutter at tile boundaries, legs cycle on their own clock.
- **The pickaxe is a separate rotating sprite**: it aims at whatever you are mining, winds
  up and snaps forward every swing, with a motion trail and a spark arc on impact.
- **Aiming is directional**: the cursor only gives a direction — the game casts a ray from
  the miner and targets the first breakable block in that direction, so you can mine
  comfortably while running. Creatures under the cursor take priority.

## Controls
| Key | Action |
|-----|--------|
| **Mouse** | Point in a direction — the first block that way gets mined (range ~3.2 tiles) |
| **Right click** | Drop dynamite |
| **A / D** | Walk — single-block steps are climbed automatically |
| **W / Space** | Jump; chimney-climb when both sides are walls |
| **S** | Climb down |
| **H** soup · **Q** haul up · **Esc** pause · **M** mute · **F11** fullscreen |

## Layers
| # | Layer | Depth | Ores |
|---|-------|-------|------|
| 1 | Green Earth | 0-24 m | Coal, Copper |
| 2 | Stonebed | 24-60 m | Iron, Silver |
| 3 | Crystal Hollow | 60-120 m | Amethyst, Gold |
| 4 | Fungal Forest | 120-200 m | Spore Crystal, Emerald |
| 5 | The Frostrift | 200-300 m | Ice Diamond, Platinum |
| 6 | Emberwell | 300-430 m | Obsidian, Ruby |
| 7 | Ancient Ruins | 430-600 m | Mithril, Ancient Tablet |
| 8 | Rock Bottom | 600 m+ | Starstone, Voidstone |

Every layer starts behind a **crust gate**; breaking through refills the lantern and pays
a milestone bonus the first time.

## Systems
- Swing-based mining with combo tiers (5/10/18/30/45 → up to ×2.2 value, faster swings),
  **Frenzy** at 25 combo.
- Dynamite, chests, geodes, oil flasks, powder veins, hidden rooms.
- **Contracts**: three per delve, paid at the end, rerollable in the cabin.
- **8 ancient relics** with permanent passives · **12 journal pages** · **14 achievements**.
- **The Heart** at 1000 m — the ending.

## Skill tree — 19 nodes / 96 levels
BASICS: Keen Edge, Padded Vest (hazard drain), Wide Lantern
CRAFT: Ore Eye, Quick Feet, Lantern Cell (max energy), Soft Landing
MASTERY: Rhythm, Master Strike, Ore Satchel (theft resist), Deep Pocket, Thief Taker
DEPTHS: Helper Drone, Lucky Pick, Thermal Shield, Powderman
ANCIENT: Elevator, Ancient Lore, Spirit Lantern

## Balance (bot simulation)
First delve ~75 m · the tree fills in ~16 delves · relics and journal pages spread over
~20 delves · the 1000 m ending needs full gear.

## Technical
Single HTML + Canvas file (~150 KB), zero dependencies. Procedural pixel-art textures,
WebAudio synthesis, procedural music. Save in `localStorage` (`lanterndeep_v1`; older
saves migrate automatically).

Tested with: syntax checks, 46,000-step random-input fuzzing (0 errors), movement unit
tests, a dedicated energy/theft test (hazard drain, robbery, recovery on kill, auto-haul),
a UI smoke test over every screen, screenshot verification and a 16-delve progression run.
