\# 🚀 Idle Space Miner



An idle merge-mining game built for Android in \*\*Godot 4\*\*, inspired by the core loop of \*Gold and Goblins\* with a futuristic sci-fi aesthetic. 



Command excavation mechs, trigger explosive chain reactions through volatile asteroid crusts, deploy automated carrier drones, and strip-mine cosmic sectors across deep space.



\---



\## 🌌 Game Overview



Players oversee mining operations across rotating sci-fi sectors—from mineral-rich asteroid belts and derelict dreadnoughts to cybernetic data vaults. 



\* \*\*Clear the Sector:\*\* Carve through obstacle tiles with health pools, armor plating, and explosive cores to reach and power up the Warp Gate.

\* \*\*Merge to Upgrade:\*\* Deploy humanoid mechs onto the grid and merge identical units (1 + 1) to exponentially amplify laser mining DPS.

\* \*\*Rent Specialized Mechs:\*\* Spend earned sector points to contract high-tier specialized units for limited windows (1 to 12 hours).

\* \*\*Automated Logistics:\*\* Repair and upgrade extraction refineries to deploy carrier drones that haul plasma scrap back to the mothership.

\* \*\*Low-Pressure Idle:\*\* Designed as a relaxing offline-friendly experience—your mechs keep chipping away even while you are away.



\---



\## 🛠️ Features \& Pillars



\### 1. Dynamic Grid \& Hazards

\* \*\*Destructible Terrain:\*\* Multiple block classes (Asteroid Crust, Titanium Bulkheads, Cyber Vaults).

\* \*\*Volatile Cores:\*\* Mining through unstable plasma blocks causes cascading explosions that damage neighboring tiles.

\* \*\*Aura Hazards:\*\* Localized EMP pylons and radiation pockets that reduce mining efficiency until dismantled.



\### 2. Mech Engine \& Merging

\* \*\*Humanoid Miner Mechs:\*\* Tactically position units on adjacent tiles to melt through blocks.

\* \*\*Non-Linear Damage Scaling:\*\* Higher tiers reward greater efficiency:

&#x20; $$\\text{Damage} = \\text{Base Damage} \\times 2.15^{(\\text{Tier} - 1)}$$

\* \*\*Time-Leased Contracts:\*\* Specialized heavy-duty mechs leased with Unix timestamp-backed expiration timers (safe against app closing).



\### 3. Drone Logistics (Passive Income)

\* Uncover hidden refinery nodes on the sector grid.

\* Upgrade drone speed, cargo capacity, and refinery output to build an automated scrap supply chain.



\---



\## 📂 Project Structure



```text

Idle-Space-Miner/

├── project.godot               # Engine configuration \& autoload registry

├── scenes/

│   ├── main.tscn               # Core game loop \& sector viewport

│   └── block.tscn              # Destructible tile scene

├── scripts/

│   ├── autoload/

│   │   └── game\_events.gd      # Global decoupled signal bus

│   ├── data/

│   │   └── block\_data.gd       # Custom Resource definitions for tiles

│   └── grid/

│       ├── block.gd            # Tile damage, UI, and death handling

│       └── grid\_manager.gd     # Grid generation and hazard chain-reactions

└── assets/                     # Sprites, UI icons, and audio

