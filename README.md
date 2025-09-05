# Various-Projects
Various different projects I've worked on that aren't part of a series

MSBT Name Generator
Usage:
.\MsbtNameGenerator.ps1 -name "[insertnames]" -startat [Where do your custom skins start?] -internalname "[How the game refers to that character]"

Explaination:
-name: The names you're looking to add to your MSBT. EX: "Kirby, Pikachu, Perfect Cell"
-startat: Where your modified skin slots start. For example, if you've left the first skin as default and modified the others, you would type in 1
-internalname: The internal name of the character. Some of these are self explanatory (Marios is just mario), but others are more of a pain to figure out. EX: Kazuya's is demon. You can find your internal name through here: https://gamebanana.com/tools/16906

Example:

Let's say you have three skins you want added to the MSBT. They are numbers 3, 4, and 5. They're also over Kazuya. To do this, this is how we'd invoke our script.

EX Input:
.\MsbtNameGenerator.ps1 -name "kirby, pikachu, perfect cell" -startat 3 -internalname "demon"

EX Output:

```        <entry label="nam_char1_03_demon">
                <text>Kirby</text>
        </entry>
        <entry label="nam_char1_04_demon">
                <text>Pikachu</text>
        </entry>
        <entry label="nam_char1_05_demon">
                <text>Perfect Cell</text>
        </entry>
        <entry label="nam_char2_03_demon">
                <text>KIRBY</text>
        </entry>
        <entry label="nam_char2_04_demon">
                <text>PIKACHU</text>
        </entry>
        <entry label="nam_char2_05_demon">
                <text>PERFECT CELL</text>
        </entry>

These can now be copy and pasted into whatever template you'd prefer. I'd recommend this one, especially if you're trying to modify almost every skin in the game like I have: https://gamebanana.com/tools/8100

That's about it!
