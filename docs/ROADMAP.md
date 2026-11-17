# Idle Space Miner Roadmap

The plan for turning the current prototype into a playable idle game. Each milestone ends with something you can run and play.

## Where it started (Nov 2026)

**Working**
- Random 7×9 grid of three block types (Asteroid Crust, Titanium Bulkhead, Unstable Core)
- HP number and bar on every block, red flash on hit
- Unstable Cores explode and can set off other cores in a chain
- `GameEvents` signal bus

**Missing**
- Scrap is announced but nothing keeps a total
- Nothing to spend scrap on
- No goal: clearing the grid does nothing
- No save, so no idle progress
- Block stats are hard-coded and Data Vault never spawns

## Milestones

### 1. Foundation
- [x] Confirm tapping damages blocks
- [x] `GameState` autoload that owns scrap, sector number, and so on
- [x] On-screen scrap counter
- [x] Block types as `.tres` resources, editable in the inspector
- [x] `.gitattributes` to settle line endings

**Done when:** you tap blocks and watch scrap go up.

### 2. Core loop
- [x] Mining rule: only exposed blocks (top row, or next to a cleared cell) can be tapped; buried blocks are dimmed. Explosions still hit buried blocks.
- [x] Sector progress bar
- [x] Warp gate button appears when the grid is clear; it pays a clear bonus (200 × 1.2^(sector − 1)) and moves you to the next sector
- [x] Each sector has +25% block HP and explosion damage, and +20% scrap drops (constants in `game_state.gd`)

**Done when:** tap, earn, clear, move on.

### 3. Mechs and merging
- [x] Direction flipped: you dig **upward** from a launch pad under the grid. The bottom row starts exposed; the warp gate sits at the top and powers up once every block is cleared.
- [x] Mechs stand on the launch pad (7 slots, which is also the mech limit) or on any cleared cell, and fire once per second at a neighbouring block (up first, then left, right, down)
- [x] Damage = `10 × 2.15^(tier − 1)`
- [x] "Deploy mech" button; cost = `50 × 1.35^(mechs bought)`. New games start with one free T1 mech.
- [x] Drag to move; drop on the same tier to merge, on a different tier to swap. Mechs return to the pad at each new sector.

**Done when:** you plan where mechs go, merge them, and watch them work. This is the point where it becomes playable.

### 4. Idle
- [ ] Autosave to `user://save.json`, and save when the app closes
- [ ] Store the time you leave; grant capped offline earnings (about 8 hours)
- [ ] "Welcome back, you earned X" popup

**Done when:** progress survives closing the app.

### 5. Variety
- [ ] Data Vault blocks: very high HP, big payout
- [ ] EMP pylons that slow nearby mechs until destroyed
- [ ] Two or three sector themes with different colours and block mixes

### 6. Drones and leased mechs
- [ ] Hidden refinery tiles that send drones for passive scrap
- [ ] Lease high-tier mechs with sector points; lease timers use real clock time so closing the app can't cheat them

### 7. Polish and Android
- [ ] Art, sound, screen shake, particles
- [ ] Balance pass: a spreadsheet of costs against damage
- [ ] Android export settings and testing on a real phone

## Open decisions

1. ~~**Mining rule:**~~ Decided: exposed only.
2. ~~**Where mechs live:**~~ Decided: on the grid, deployed from a launch pad under it.
3. **Art:** placeholder squares until Milestone 7, or a free pack (Kenney.nl) earlier? Leaning: placeholders until Milestone 3 is fun.
