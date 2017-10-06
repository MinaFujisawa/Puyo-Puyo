# Puyo Puyo

# What is Puyo Puyo?
Puyo Puyo is a series of tile-matching video games.

# Rule
Puyo(in my app : 💙) fall from the top of the screen in pairs.
The piece can be moved,rotated and dropped by prompting the user. The piece falls until it reaches another Puyo or the bottom of the screen.
In my game, user can decide the position first, then drop them.

![drop](https://github.com/MinaFujisawa/PuyoPuyo/blob/master/screenshots/drop.png)

When four or more Puyo of the same color line up adjacent to each other, they disappear. Puyo connect horizontally or vertically. This is called Popping.

A Chain is made when falling Puyo cause a new group of Puyo to Pop, making a chain reaction.
![drop](https://github.com/MinaFujisawa/PuyoPuyo/blob/master/screenshots/chain.png)

Ref:
https://en.wikipedia.org/wiki/Puyo_Puyo#Gameplay

# Scoring
The scoring is based on the formula, which consists of follows:
- Number of puyo cleared in the chain
- How many puyo are in the group
- Number of chain reaction

In a nutshell, the more you chain and the bigger the amount you clear per chain, the higher the score gets.

![drop](https://github.com/MinaFujisawa/PuyoPuyo/blob/master/screenshots/score.png)

More detail about scoring:
https://puyonexus.com/wiki/Scoring#Group_Bonus



