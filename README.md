# Blaster-Gun-System

A modular **Roblox (Luau)** blaster/laser gun system built for **server-authoritative** combat with **smooth client VFX/SFX**. Drop it into your game with minimal wiring and clear extension points for new weapons, fire modes, and effects.

> Design doc: **Blaster System 1.0 – User Guide** > [https://docs.google.com/document/d/1UDMj3X-n-5f8cBDXlzjcDagfvXyZwlQ5yAwH1ZCq_D8/edit?usp=sharing](https://docs.google.com/document/d/1UDMj3X-n-5f8cBDXlzjcDagfvXyZwlQ5yAwH1ZCq_D8/edit?usp=sharing)

---

## Features

- **Server-authoritative hits** (raycast or hitscan checks on the server)
- **Config-driven stats** (damage, fire rate, mag size, reload time, spread/bloom, range)
- **Fire modes**: Semi-auto and Full-auto (Burst-fire ready via config)
- **Client polish**: muzzle flash, tracers/impact FX, crosshair, UI feedback, sounds
- **Anti-exploit defaults**: server validates shots, ranges, and cadence
- **Extensible modules**: add weapons or swap behaviors without touching core code

---

## Repository Layout

```
/client/          # Local input, camera/ADS, VFX/SFX, UI, crosshair
/shared/          # Shared config/constants/types (used by client & server)
README.md
```

> Move modules to your preferred locations (e.g., `ReplicatedStorage`, `ServerScriptService`, `StarterPlayerScripts`) and update require paths.

---

## Quick Start (Roblox Studio)

1. **Import modules** into your place.

   - `shared/` → `ReplicatedStorage/Blaster/Shared`
   - `client/` → `StarterPlayerScripts/BlasterClient`

2. **Create or import a Tool** (weapon) and place in `StarterPack`.

   - Include a handle and a `Muzzle` attachment for FX.

3. **Create Remotes** (if your version uses them) under `ReplicatedStorage/Blaster/Remotes`

   - Example names: `Fire`, `Reload`, `HitConfirm`.

4. **Configure a weapon** (see example below).
5. **Play-test**: click/tap to fire; **R** to reload; hold to auto-fire if enabled.

---

## Configuration (Example)

> Keep the server as the source of truth; the client reads a strict subset for UI.

```lua
-- ReplicatedStorage/Blaster/Shared/BlasterConfig.lua
return {
  Weapons = {
    BlasterRifle = {
      Damage = 18,                 -- per shot
      HeadshotMultiplier = 1.5,    -- optional
      FireMode = "Auto",           -- "Semi" | "Auto" | "Burst"
      RPS = 8,                     -- rounds per second
      MagazineSize = 30,
      ReloadTime = 2.0,            -- seconds
      Range = 300,                 -- studs
      Penetration = 0,             -- studs; 0 = disabled
      Spread = {
        Hipfire = 1.5,             -- degrees
        ADS = 0.5,
        BloomPerShot = 0.15,       -- added spread each shot (decays)
        BloomDecay = 2.0           -- degrees/sec decay toward base
      },
      Recoil = {
        Vertical = 0.6,
        Horizontal = 0.25,
        Recovery = 8.0             -- how quickly aim returns
      },
      FX = {
        MuzzleAttachmentName = "Muzzle",
        UseTracer = true,
        ImpactSpark = "BlasterImpact",
        Sound_Fire = "BlasterFire",
        Sound_Reload = "Reload",
      }
    }
  }
}
```

---

## How It Works (High Level)

**Input & client feel (`/client`)**

- Reads input, performs **local aim/raycast preview** for responsive crosshair and VFX.
- Sends minimal **fire requests** (time, muzzle CFrame, direction) to the server.
- Plays local **muzzle flash / sound / tracer**; reconciles on server confirmation.

**Validation & damage (server)**

- Server **re-casts** using authoritative data and validates cadence, range, and hit parts.
- Applies damage (with optional headshot multiplier) and triggers **impact FX** to nearby clients.
- Enforces **magazine** and **reload** rules; rejects out-of-cadence spam.

**Replication**

- Server broadcasts **hit confirmations** and FX triggers; clients play synced effects.

---

## Suggested Folder Conventions

```
ReplicatedStorage/
  Blaster/
    Shared/          # Config, constants, raycast helpers, types
    Remotes/         # RemoteEvent(s): Fire, Reload, HitConfirm, etc.
ServerScriptService/
  BlasterServer/     # Validation, damage, replication
StarterPlayerScripts/
  BlasterClient/     # Input, ADS/camera helpers, crosshair UI, client FX
StarterPack/
  BlasterRifle (Tool)/  # Model + attachments (Muzzle, etc.)
```

---

## Extending

- **Burst fire**: add `BurstCount` and per-burst cadence limits.
- **Overheating**: track heat, add cooldown lockout + UI warning.
- **Projectile mode**: swap raycast for physical projectiles or use **FastCast**.
- **Attachments**: scopes (ADS FOV), silencers (audio/flash), barrels (spread/recoil).
- **Ammo types**: AP (penetration), stun (status), explosive (AOE).
- **Lag compensation**: server rewinds to client fire time within a safe window.

---

## Anti-Exploit Notes

- Never trust client damage or range; **re-compute** server-side.
- **Rate-limit** by last server-accepted shot time per weapon.
- Clamp **direction** to a cone around camera/aim to prevent extreme vectors.
- Replicate **FX + confirmations** only; never raw damage numbers to other clients.

---

## Performance Tips

- Use `RaycastParams` with collision groups; ignore cosmetics.
- Batch impact FX if many hits occur in a short window.
- Reuse attachments/emitters; pool tracers if using beams.

---

## Design Doc

Goals, constraints, and UX guidelines:
**Blaster System 1.0 – User Guide**
[https://docs.google.com/document/d/1UDMj3X-n-5f8cBDXlzjcDagfvXyZwlQ5yAwH1ZCq_D8/edit?usp=sharing](https://docs.google.com/document/d/1UDMj3X-n-5f8cBDXlzjcDagfvXyZwlQ5yAwH1ZCq_D8/edit?usp=sharing)

---

## Roadmap (Suggested)

- Hit markers and damage numbers (client-side; server confirms)
- ADS sway and weapon bob
- Melee bash and quick-swap
- Per-weapon animation sets (equip, reload, inspect)
- Unit tests for cadence, reload, and validation

---

## License

Add your preferred license (e.g., MIT).

## Credits

Built by **Reuvi**. Thanks to the Roblox dev community for best practices on server-authoritative gunplay.
