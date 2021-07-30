-- Name: Joshua Early
-- Date: March 20, 2017

-- Purpose: This program determines if a line of input is a pal
--  as is, with letters converted to uppercase, or not a pal.
-- Input is read in as standard input from a text file, one pal
--  string per line.

with ada.text_io; use ada.text_io;
with ada.integer_text_io; use ada.integer_text_io;
with ada.characters.handling; use ada.characters.handling;

procedure pal_finder is

function is_pal (s: string; len: natural) return boolean is
pal: boolean;
count: natural := len;
begin
if (s="" OR len=0) then
pal := true;
else
for i in 1 .. count loop
	if s(i) = s(count) then
	pal := true;
	count := count-1;
	else 
	pal := false;
	exit;
	end if;
end loop;
end if;
return pal;
end is_pal;

function remove_nl (s: string; len: natural) return boolean is
only_letters: string(1..72);
new_len: integer := 0;
count: natural := 0;
begin
	for i in 1 .. len loop
		if (is_letter(s(i))) then
			new_len := new_len+1;
			only_letters(new_len) := s(i);
		else
			count := count+1;
		end if;
	end loop;
	if (is_pal(only_letters,new_len)) then
		put_line("String: " &'"'&s&'"');
		put_line("Palindrome when non-letters are removed."); 
		put("Characters removed: ");
		put(count,0);
		new_line; new_line;
	end if;
return is_pal(only_letters,new_len);
end remove_nl;

function convert_uppercase (s: string; len: natural) return string is
t: string(1..len);
begin
	for i in 1 .. len loop
		t(i) := to_upper(s(i));
	end loop;
return t(1..len);
end convert_uppercase;

function rnl_and_convert (s: string; len: natural) return boolean is
only_letters: string(1..72);
new_len: integer := 0;
count: natural := 0;
begin
	for i in 1 .. len loop
		if (is_letter(s(i))) then
			new_len := new_len+1;
			only_letters(new_len) := s(i);
		else
			count := count+1;
		end if;
	end loop;
		
	if (is_pal(convert_uppercase(only_letters,new_len),new_len)) then
		put_line("String: " &'"'&s&'"');
		put_line("Palindrome when non-letters are removed and converted to upper case.");
		put("Characters removed: ");
		put(count,0);
		new_line; new_line;
	end if;
return (is_pal(convert_uppercase(only_letters,new_len),new_len));
end rnl_and_convert;

procedure process_input is
t: string(1..72);
len: natural;
status: boolean;
begin
while (not end_of_file) loop
	--len := 0;
	get_line(t, len);
	declare
	temp: string(1..len) := t(1..len);
	begin
	--s_only_letters := remove_nl(t,len);	
	if (is_pal(temp,len)) then
	put_line("String: " &'"'&temp&'"');
	put_line("Palindrome as entered."); new_line;
	elsif (remove_nl(temp,len)) then
		status := true;
	elsif (is_pal(convert_uppercase(temp,len),len)) then
	put_line("String: " &'"'&temp&'"');
	put_line("Palindrome when converted to upper case."); new_line;
	elsif (rnl_and_convert(temp,len)) then
		status:=true;
	else
	put_line("String: " &'"'&temp&'"');
	put_line("Not a pal."); new_line;
	end if;
	end;
end loop;	
end process_input;

begin
process_input;
end pal_finder;
