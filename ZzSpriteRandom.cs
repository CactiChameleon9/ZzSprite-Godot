using Godot;
using System;

public class ZzSpriteRandom : Node
{
	
	public Int32 generate_seed(Int32 random_seed){
		random_seed ^= random_seed << 13;
//		GD.Print(random_seed);
		random_seed ^= random_seed >> 17;
//		GD.Print(random_seed);
		random_seed ^= random_seed << 5;
		return random_seed;
		
	}
	
}
