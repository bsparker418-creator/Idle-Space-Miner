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
- [ ] Mining rule (see decision 1)
- [ ] Sector progress bar
- [ ] Warp gate opens when the grid is clear and moves you to the next sector
- [ ] Each sector is tougher (for example +25% HP) and pays more

**Done when:** tap, earn, clear, move on.

### 3. Mechs and merging
- [ ] Mech scene that sits on a cleared tile and fires at adjacent blocks once per second
- [ ] Damage = `10 × 2.15^(tier − 1)`
- [ ] "Deploy mech" button with a rising cost
- [ ] Drag a mech onto one of the same tier to merge; drag to move

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

1. **Mining rule:** tap any block, or only exposed blocks (top row or next to cleared space)? Leaning: exposed only.
2. **Where mechs live:** on the grid (as in the README) or in a separate bay? Leaning: on the grid.
3. **Art:** placeholder squares until Milestone 7, or a free pack (Kenney.nl) earlier? Leaning: placeholders until Milestone 3 is fun.
