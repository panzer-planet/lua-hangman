--[[Hangman in Lua
copyright 2013 Werner Roets

You may use this file under the terms of the GNU General Public License v3
which can be found here http://www.gnu.org/copyleft/gpl.html
Redistributions of files must retain the above copyright notice.
]]
require "posix"

help = [[
Hangman in Lua
copyright 2013 Werner Roets

You may use this file under the terms of the GNU General Public License v3
which can be found here http://www.gnu.org/copyleft/gpl.html
Redistributions of files must retain the above copyright notice.

usage:
	hangman [ h|a|d [ w|x ][l] [<lives>] <answer>|<dictionary_file> ]
parameters:
	1; options
	2-n: answer to guess or dictionary file
options:
	h:
		Display this help message.
	a:
		Specify your word or phrase to guess as the next parameters
		e.g
			hangman a guess this dude
	d:
		Specify a dictionary file as the second parameter.
		A dictionary is newline seperated plain text file of words or
		phrases.
		e.g
			hangman d dictionary.txt
	l<lives>:
		Number of lives before you loose.
		e.g
			hangman al 5 guess me
	w|x:
		Specify windows or unix for screen clearing.
		e.g
			hangman aw guessme
		or
			hangman ax guessme

]]

--The word or phrase to guess
guess = "aphantasia"
--guesses remaining before you loose
lives_left = 5

options = {}
-- COMMAND LINE ARGS

if #arg > 0 then
	--we have some stuff to handle
	local answer_index = 2

	if string.find(arg[1],"w") then
		options["os"] = "win"
	elseif string.find(arg[1],"x") then
		options["os"] = "unix"
	else
		options["os"] = "?"
	end

	--Non default number of lives
	if string.find(arg[1],"l") then
		answer_index = 3
		if type(arg[2]) == "number" then
			lives_left = arg[2]
		else
			print("Invalid argument for lives. Defaulting to " .. lives_left)
		end
	end

	--Answer by dictionary file
	if string.find(arg[1],"d") then
		if not arg[answer_index] then
			print "Please specify a dictionary as the second argument.\n Do 'hangman.lua h for more help."
			os.exit(0)
		else
			options["dictionary"] = io.open(arg[2],"r")
			if options["dictionary"] == nil then
				print "The file you specified as a dictionary is invalid"
				os.exit(0)
			end
		end
	--Answer by command line argument
	elseif string.find(arg[1],"a") then
		if not arg[answer_index] then
			print "Please specify an answer to guess.\ne.g lua hangman.lua a guess this"
		else
			--there may be n arguments to handle as the answer to guess
			local n = #arg
			local g = ""
			local sep = ""
				for i = answer_index, n do
					g = g .. sep .. arg[i]
					sep = " "
				end
			--Set the word or phrase to guess
			guess = g
		end
	end
end


-- INITIALISE


so_far = {}
local sep = "_"
for i = 1, string.len(guess), 1 do
	local n = string.sub(guess,i,i)
	
	if n == " "	then
		so_far[i] = " "
	else
		so_far[i] = sep
		
	end
	sep = ",_"
end

alphabet = {}

for i = 97, 97+25 do
	alphabet[string.char(i)] = string.char(i)
end

selection = ""

function clear_screen()
	if options["os"] == "win" then
		os.execute("cls")
	elseif options["os"] == "unix" then
		os.execute("clear")
	else
		return--no screen clearing as we can't determine os
	end
end
-- INTRO
clear_screen()
print "Welcome to Hangman\n"

-- FUNCTIONS
function guess_the_answer(g)
	if string.lower(g) == string.lower(guess) then return true end
	print ("Nope! " .. g .. " is not the answer")
	lives_left = lives_left - 1
	return false
end

function present_alphabet()
	print ""
	for i = 97, 97+25 do
		io.write(alphabet[string.char(i)] .. " ")
		local j = i - 96
		if j % 10 == 0 then print "" end
	end
	print "\n"
end

function check_has_won()
	for i = 1, #so_far, 1 do
		if so_far[i] == "_" or so_far[i] == ",_" then
			return false
		end
	end
	return true
end

function choose_letter(c)
	if c ~= " " then
		alphabet[c] = " "
		local flag = false
		for i = 1, string.len(guess) do
			local n = string.sub(guess,i,i)
			if n == c then
				flag = true
				so_far[i] = c
			end
		end
		if flag == false then lives_left = lives_left - 1 end

	else
		print ("Already tried " .. c)
	end
end
--does lua have indexOf(string)?
--can rewrite this func
--[[ string.find doesnt return the position
	of every occurance of a character or pattern ]]

function show_so_far()
	for i = 1, #so_far do
		io.write(so_far[i])
	end
	print ""

end

-- GAME LOOP
while selection ~= "!q" and lives_left > 0 do
	print ("You have " .. lives_left .. " lives left")
	io.write("Your guess so far: ")
	show_so_far()
	print "Type a letter or guess the answer. type !q to quit"
	--present alphabet
	present_alphabet()
	selection = io.read()
	
	if selection == "!q" then
		break
	elseif string.len(selection) > 1 then
	 	--guess answer
		if guess_the_answer(selection) then
			--you win
			io.write("Yes the answer was '" .. guess .. "'\n")
			print "You win"
			break
		end
	elseif string.len(selection) == 1 then
		choose_letter(selection)
		if check_has_won() then print "You win" break end
	else
		print "Please type something before pressing enter"
	end
	clear_screen()
end
print(lives_left .. " lives left")
if selection ~= "!q" and lives_left == 0 then print("You Lose! The word was "..guess) ; end


