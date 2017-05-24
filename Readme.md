<center>
<img src="https://cloud.githubusercontent.com/assets/1666014/26267105/0169f088-3cf1-11e7-93e9-2d0d0169eacc.png" width="48">
</center>

# A back-end platform for games.

* **Self-hosted**. You have full control of the system. That makes it cheaper and a lot easier to modify.
* **Scalable**. It's designed to handle high load, because each node can be scaled horizontally. 
* **Unified**. Each service follow standards so service behaviour is predictable and making a new one is easy.
* **Environmental**. You can have a set of completely different environments that never interact each other.
* **Universal**. It can handle any type of games, even a different games at the same time.
* **A platform**. Not just a complete solution, it's a platform. You can easily create a new component that meets your exact requirements.

# Runtimes
It also comes with game client runtimes for various programming languages for quick start. They allow to interact with services and handle most of core tasks under the hood.
* [Java](https://github.com/anthill-platform/anthill-runtime-java/)
* [Unity](https://github.com/anthill-platform/anthill-runtime-unity/)
* [C++](https://github.com/anthill-platform/anthill-runtime-cpp/)

# Core services
| Service | Description |
|-------------------------------------------------------------------------|--------------------------------------------------------------------------------------------------|
| [environment](https://github.com/anthill-platform/anthill-environment/) | Define a set of environments and dynamically assign each game version to any of those |
| [discovery](https://github.com/anthill-platform/anthill-discovery/) | Discover each service location dynamically by it's ID |
| [login](https://github.com/anthill-platform/anthill-login/) | Solves authentication. Login using any kind of credential (like google or facebook), or your own |
| [profile](https://github.com/anthill-platform/anthill-profile/) | Manages user profiles. Just a plain JSON object, completely defined by a game |
| [social](https://github.com/anthill-platform/anthill-social/) | Social interactions (social network's friend list etc) |
| [config](https://github.com/anthill-platform/anthill-config/) | Delivers dynamic configuration to the user using handy schema editor |
| [leaderboard](https://github.com/anthill-platform/anthill-leaderboard/) | Competes users around by anything |
| [exec](https://github.com/anthill-platform/anthill-exec/) | Server-side game-depended javascript code execution (validation and so on) |
| [common](https://github.com/anthill-platform/anthill-common/) | A shared library with common functionality for each service |
| [admin](https://github.com/anthill-platform/anthill-admin/) | Internal service, allows to manage every service across the environment using web browser |
| [dlc](https://github.com/anthill-platform/anthill-dlc/) | Downloadable content delivery service |
| [game](https://github.com/anthill-platform/anthill-game/) | Matchmaking service, allows to start any game server to a server side, and match users around it |
| [message](https://github.com/anthill-platform/anthill-message/) | Delivers messages from anything to anything, realtime |
| [store](https://github.com/anthill-platform/anthill-store/) | Monetization service |
| [promo](https://github.com/anthill-platform/anthill-promo/) | Promo codes service |