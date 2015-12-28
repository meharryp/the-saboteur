# How to create new games
1. Create a new lua file and call it whatever you want.
2. Add properties like so: 
```
GAME.Name = "My cool game" -- The name of your game
GAME.Desc = "Hello, world!" -- A short description to tell people how to play it
GAME.Time = 60 -- The amount of time, in seconds, people have before the game ends
```
3. Create a new function named `GAME.Start` and place the logic of your game in there. Any hooks, timers or entities you create will be automagically removed so don't worry about them. When you want a team to win call Saboteur.GameEnd( TEAM_SABOTEUR ) or TEAM_PLAYERS. The function is shared so make sure you have the appropriate checks so the client doesn't see anything.
4. (optional) When a game runs out of time the saboteur is automatically chosen as the winner. If you have other logic that will determine who wins or not create a function named `GAME.OnEnd`. Instead of calling Saboteur.GameEnd, just return the enum of the team that should win.