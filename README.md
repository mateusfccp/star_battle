# Star Battle

A Dart/Flutter implementation of Star Battle.

![Sample](https://github.com/user-attachments/assets/526f7e71-9b55-4d8a-91c5-8c7696d161fa)

There are currently three packages in this repository.

## `star_battle`

The core of the game. Contains the game logic and is agnostic to any UI, so
it can be used to implement the game with any Dart UI package.

## `star_battle_app`

A Flutter UI built on top of `star_battle` that allows one to play the game
on Android, iOS, Windows, Linux and macOS.

Currently, it was only tested on macOS, but compiling to all targets should have
zero or low cost.

## `star_battle_file`

A specification and implementation of a file format that (kind of) effieciently
encodes Star Battle boards.
