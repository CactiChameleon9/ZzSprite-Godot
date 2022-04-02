using Godot;
using System;

public class ZzSpriteLibs : Node
{
	
	public Int32 generate_seed(Int32 random_seed){
		random_seed ^= random_seed << 13;
		random_seed ^= (Int32)((uint)random_seed >> 17);
		random_seed ^= random_seed << 5;
		return random_seed;
		
	}
	
	public Int32 add_int32(Int32 num1, Int32 num2, Int32 num3){
		return num1 + num2 + num3;
	}
	
}
