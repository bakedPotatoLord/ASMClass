/*
Josiah Hamm @bakedpotatoLord
CSC2025X01 Computr Arch/Assembly Language
9/5/2024
Uses C# and the .NET 6.0 Framework
Takes an input of binary, hex, or integer type and displays the value in binary, hex, and decimal
*/

using System;
using System.Collections.Generic;
using System.Numerics;

class Program {

		// Hexadecimal to Integer conversion dictionary
		static Dictionary<char, int> HexToInt = new Dictionary<char, int> {
				{'0', 0}, {'1', 1}, {'2', 2}, {'3', 3}, {'4', 4},
				{'5', 5}, {'6', 6}, {'7', 7}, {'8', 8}, {'9', 9},
				{'A', 10}, {'B', 11}, {'C', 12}, {'D', 13}, {'E', 14}, {'F', 15}
		};

		// Decimal to Integer conversion dictionary
		static Dictionary<char, int> DecToInt = new Dictionary<char, int> {
				{'0', 0}, {'1', 1}, {'2', 2}, {'3', 3}, {'4', 4}, {'5', 5},
				{'6', 6}, {'7', 7}, {'8', 8}, {'9', 9}
		};

		// Integer to Hexadecimal string conversion array
		static String[] intToHex = {"0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "A", "B", "C", "D", "E", "F"};

		/*
		Function: Menu
		Inputs: None
		Outputs: None (Displays text to the console)
		Memory Usage: Minimal (Used to display instructions)
		Description: 
				This function displays a menu for the user to choose the type of input (binary, hex, integer, or quit).
		*/
		static void Menu(){
				Console.WriteLine("Chose an Input Type:");
				Console.WriteLine("(b)\t16-bit Binary value");
				Console.WriteLine("(h)\t32-bit Hexadecimal value");
				Console.WriteLine("(i)\tInteger value");
				Console.WriteLine("(q)\tQuit");
		}

		/*
		Function: DisplayValues
		Inputs: BigInteger intValue - A large integer value to be converted and displayed
		Outputs: None (Displays the binary, hexadecimal, and integer representations)
		Memory Usage: Uses temporary variables for binary and hexadecimal conversion.
		Description: 
				Converts the provided integer into binary and hexadecimal strings and displays them along with the original integer.
		*/
		static void DisplayValues(BigInteger intValue){

				// Convert integer to binary
				BigInteger intValueCopy = intValue;
				string binaryValue = "";
				while(intValueCopy > 0){
						binaryValue = intValueCopy % 2 + binaryValue;  // Append remainder to form binary
						intValueCopy /= 2;  // Integer division to continue binary conversion
				}

				// Convert integer to hexadecimal
				BigInteger intValueCopy2 = intValue;
				string hexValue = "";
				while(intValueCopy2 > 0){
						hexValue = intToHex[(int)intValueCopy2 % 16] + hexValue;  // Use modulus to get hex digit
						intValueCopy2 /= 16;  // Integer division to continue hex conversion
				}

				// Display the converted values
				Console.WriteLine("\n------------------------------------");
				Console.WriteLine("Integer value: " + intValue);
				Console.WriteLine("Binary value: " + binaryValue);
				Console.WriteLine("Hexadecimal value: " + hexValue);
				Console.WriteLine("------------------------------------\n");
		}

		/*
		Function: Main
		Inputs: string[] args - Command line arguments (not used in this program)
		Outputs: None
		Memory Usage: Uses memory for input handling, conversion, and temporary storage.
		Description: 
				Main loop that accepts user input and processes it based on the input type (binary, hex, or integer).
				Calls the appropriate conversion methods and displays the result.
		*/
		public static void Main (string[] args) {
				while(true){  // Infinite loop until user chooses to quit
						Menu();  // Display menu options
						string input = Console.ReadLine();  // Get user choice

						if(input == "q"){  // Quit option
								Console.WriteLine("Thanks for using this program!");
								break;
						} else if(input == "b"){  // Binary input option
								Console.WriteLine("Enter a 16-bit binary value:");
								String binaryString = Console.ReadLine();
								BigInteger binaryValue = 0;
								while(binaryString.Length > 0){  // Convert binary string to integer
										binaryValue *= 2;  // Multiply by 2 (shifting left)
										if(binaryString[0] == '1'){
												binaryValue += 1;  // Add 1 if the current binary digit is 1
										}
										binaryString = binaryString.Substring(1);  // Move to the next digit
								}
								DisplayValues(binaryValue);  // Display the converted values
						} else if(input == "h"){  // Hexadecimal input option
								Console.WriteLine("Enter a Hex value:");
								String hexString = Console.ReadLine();
								BigInteger hexValue = 0;
								while(hexString.Length > 0){  // Convert hex string to integer
										hexValue *= 16;  // Multiply by 16 (shift by hex base)
										hexValue += HexToInt[hexString[0]];  // Add corresponding integer value
										hexString = hexString.Substring(1);  // Move to the next digit
								}
								DisplayValues(hexValue);  // Display the converted values
						} else if(input == "i"){  // Integer input option
								Console.WriteLine("Enter a decimal integer value:");
								String intString = Console.ReadLine();
								BigInteger intValue = 0;
								while(intString.Length > 0){  // Convert decimal string to integer
										intValue *= 10;  // Multiply by 10 (shift left by decimal base)
										intValue += DecToInt[intString[0]];  // Add corresponding integer value
										intString = intString.Substring(1);  // Move to the next digit
								}
								DisplayValues(intValue);  // Display the converted values
						} else {  // Invalid input
								Console.WriteLine("Invalid input, try again\n");
						}
				}
		}
}
