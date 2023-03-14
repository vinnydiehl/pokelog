# PokéLog ![CodeQL](https://www.github.com/vinnydiehl/pokelog/workflows/CodeQL/badge.svg) [![CircleCI](https://circleci.com/gh/vinnydiehl/pokelog/tree/trunk.svg?style=shield)](https://app.circleci.com/pipelines/github/vinnydiehl/pokelog/?branch=trunk)

http://www.pokelog.net/

EV tracker for hardcore Pokémon enthusaists.

### What is EV Training?

EVs, or Effort Values, are a hidden stat that can be increased through battling
wild Pokémon. Each Pokémon species gives a certain amount of EVs in a specific
stat when defeated. For example, defeating a Pidgey will give 1 EV for Speed.
A Pokémon can have a maximum of 255 EVs in one stat, and a maximum of 510 EVs
across all stats. 4 EVs translates to 1 extra stat point.

EV training is the practice of strategically battling specific Pokémon in order
to increase the EVs of your Pokémon in a specific stat. This can be accelerated
by using items such as the Power Weight, which will gives extra HP EVs.

With discipline you can enhance the stats of your Pokémon beyond the normal
level-up process, allowing you to create a Pokémon that is tailored to your
specific needs.

### So what is this website?

PokéLog aims to remove some of the mystery behind EV training for newer
players, and make the process of tracking progress across a team (or teams)
less of a pain for experienced players.

Create entries in the app (we call them
trainees) for each Pokémon that you wish to train, and load them all into your
party (keeping in mind that EVs are applied to every Pokémon that gains EXP
after a battle, even if they were never sent out). From this page you are able
to search for Pokémon as you encounter them, see what EVs they yield, and click
on them to apply those EVs to your trainees.

### Report a Bug

Please don't hesitate to report any bugs, issues or general jank that you
encounter on the [issues page](https://github.com/vinnydiehl/pokelog/issues).
Please keep issues separated as they are tied into the development history of
the software; if you have multiple bugs that you wish to report, open separate
issues for each one so that they may be addressed and referenced individually.

### Contributing

PokéLog is built on Rails 7. If you are interested in helping out with the
project, feel free to check out
[my ever-growing TODO list](https://github.com/vinnydiehl/pokelog/issues) and
pick something that interests you. If you have a new idea, please open a ticket
and we can discuss it.

See
[`CONTRIBUTING.md`](https://github.com/vinnydiehl/pokelog/blob/trunk/CONTRIBUTING.md)
for more information on getting a development environment set up.

### So PokéLog is open source?

Not quite. PokéLog has a [fair-code](https://faircode.io/) distribution model,
where its source code will always be available, and you're welcome to fork and
contribute, and even run your own copy locally, but you are restricted from using
the software commercially. See
[`LICENSE.md`](https://github.com/vinnydiehl/pokelog/blob/trunk/LICENSE.md)
for all the fine print.
