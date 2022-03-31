## ZzSprite-Godot
A port of ZzSprite (A Tiny Sprite Generator) by Frank Force to Godot

### Details
- Requires Mono Version of Godot due to the requirement for 32bit Integers (for the ZzSpriteRandom.cs)
- Seeds for the usual ZzSprite aren't the same due to the same 32bit Integer requirement (mutations and color adjust the seed by huge amounts, so values vary due to gdscipt 64bit intergers)
- Only the main ZzSprite script is ported, none of the settings or options. (same things still possible, just with editing the parameters for the ZzSprite function)


### Acknowledgments 
Many thanks to [Frank Force (aka KilledByAPixel)](https://github.com/KilledByAPixel) for his [original code (MIT)](https://github.com/KilledByAPixel/ZzSprite)
