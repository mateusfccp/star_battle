# Star Battle

A Dart/Flutter implementation of Star Battle.

![Sample](https://github.com/user-attachments/assets/a103c2b2-30ab-42c0-9341-379c997c1085)

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
