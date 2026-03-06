## Sonnylike-RPG
Designing a Turn-based RPG from scratch, using Godot. This game takes inspiration from series of flash games that I've played in my youth, namely Legend of the Void and Sonny. General passion project. Name WIP.

# Purpose
This project while being made for personal fulfillment, it also serves as a means to practice personal project ownership, as well as system designing.
With this project, I seek to develop the kind of skills that would be helpful for succeeding as a developer and Software Engineer.

---

## Game Play
The game revolves around skill based combat, where characters has a selection of abilities at their disposal to use in combat. The player has a team of characters they control by strategically selecting and using skills. The gameplay flow works by a selected turn order (determined by the speed stat, the turn order goes from highest speed to lowest regardless of team), where a character selects a skill on their turn and potential target(s) to use the skill on. 

The game currently works in a single battle instance, where the goal of the battle is for the player to defeat all exisiting enemy units before the player's units die. Last team standing wins. 

## Combat Flow:
Battle Start
     ↓
Load Level Data
     ↓
Initialize Entities
     ↓
Determine Turn Order
     ↓
Execute Turn
     ↓
Apply Status Effects
     ↓
Update Durations
     ↓
Next Turn

---

## Design Philosophy
For this game, I am looking to design the game in such a way it can be as modular as possible.
Particularly, I am designing in it such a way so that I can write the code to allow myself to create any feasible skill you can realistically think of.

---

## Engineering Concepts Demonstrated

- Object-Oriented Design
- Separation of Concerns
- Data-Driven Architecture
- Explicit State Management
- Modular System Design
- Extensible Gameplay Systems

---

## Features
Current the game has:
-CombatManager: A singleton class that tracks the battle state, managing the character's stats (adding/subtracting values), turn order, skill activation, and more!

-Level loading feature: Level resource files contain the necessary information to populate the CombatManger, including entity stats, skills, sprites, and the background scene. This provides me a reusable script to set up the battle instance with various variables I can tweak in these files. 

-Status Effects: Skills can apply status effects. Status effects can generally be either buffs or debuffs. Instances of status effects are tracked by the CombatManager. The CombatManager uses a singleton script that serves as a database for the IDs and associated scripts for the behavior of any given status. Status have a turn duration, and applies its effects at the start or end of a character's turn, depending on the listed behavior. At the end of the character's turn, the duration is decremented and drops off after the duration is 0. Status effects include stat modifers (+/- a particular stat), damage over time, stuns (prevents a character from acting on their turn), etc.

-UI: On the player's turn for one of their units, the player can select a skill from the skill bar and select the target. The arrow above a character represents the applicable target(s). The turn ring (ring below the character; at this time represented with a simple square) shows the current character taking a turn. Enemies will automatically select a random skill and target on their turn. The UI is a constant WIP!

---

## Development Roadmap (No Particular Order)
-Proper character sprites
-Anamation! 
-Flesh out skills and statuses. The design implementation is there, but add an array of skills and respective statuses.
-Character Progression: allow your units to level up and improve their stats and unlock new skills!
-Flesh out enemy AI: currently the AI selects a random skill and target. Add a script to make the enemy strategically use skills in a "smart" way. Potentially scaled off of a difficulty feature?
-Campaign: Create a sequence of playable levels (battles), instead of the single battle. Will have to transfer character progession between levels. Potential story and lore.

...And more!

---

## License
None! This is a personal project made using Godot for fun and developing professional skills. All assets used in the game are either default free assests given in Godot, or either designed by me or uses free assets available online. I ask if you wish to use any of the code that you ask for permission, or seek collaboration with me. You can find my avaiable contact information on my github profile.
