-- Name: Joshua Early
-- Date: March 23, 2018
-- Course: ITEC 320-01 - Procedural Analysis and Design
-- calcpkg.adb - package body
with ada.text_io, ada.integer_text_io, stackpkg, ada.unchecked_conversion;
with ada.characters.handling;
use ada.characters.handling;
use ada.text_io, ada.integer_text_io;
----------------------------------------------------------
-- Purpose: calcpkg body for calcpkg.ads implementation
-- Parameters: n/a
-- Precondition: calcpkg.ads spec is complete.
-- Postcondition: defines the body for calcpkg spec.
----------------------------------------------------------
package body calcpkg is

package operand_stacks is new stackpkg(size => 100, itemtype => integer);
package operator_stacks is new stackpkg (size => 100, itemtype => character);
use operand_stacks, operator_stacks;

operand_stack: operand_stacks.stack;
operator_stack: operator_stacks.stack;

procedure calc_get (calc : out calculation) is
	c,j: character; -- look_ahead character and character for element
	i: integer; -- standard integer input
	e: element; -- element to add to the calculation record
  end_line: boolean; -- detects the end-of-line state
	exp_int: boolean := true; -- marker for next expected input
	exp_op: boolean := false; -- marker for next expected input
begin
	calc.length := 0;
loop
	loop
		look_ahead (c, end_line);
		if end_line then
			skip_line;
		else
			exit when end_line;
			exit when c not in ' ' | ASCII.HT;
			get (c); -- consume the empty spaces
		end if;
	end loop;
look_ahead (c, end_line);
if c in '(' then
	exp_int := false;
	exp_op := true;
end if;
if end_line then
	skip_line;
	elsif exp_int then
		ada.integer_text_io.get(i); -- get the next integer value from input
		calc.length := calc.length + 1; -- incrementing the length of the calc
		e.int_element := i; -- adding the value of i to the element
		e.op_element := ' '; -- setting the operator value to empty marker
		calc.calc_element(calc.length) := e;
		exp_int := false;
		exp_op := true;
	else
		ada.text_io.get(j); -- get the next character value from input
		if j = '*' then -- checking if the operator is a '**' for exponentiation
			look_ahead(c, end_line);
			if c = '*' then
				get(c); -- throw away the second asterisk
				j := '^'; -- '^' used to represent exponentiation on the stack
			end if;
		end if;

		calc.length := calc.length + 1; -- incrementing the length of the calc
		e.op_element := j; -- adding the value of j to the element
		calc.calc_element(calc.length) := e;

		if j in ')' then
			exp_int := false; -- change to expected input state, when input is ')'
			exp_op := true;   -- to catch operators that immediately follow
		else
			exp_int := true;
			exp_op := false;
		end if;
	end if;
exit when j = '='; -- end the input for the calulation
end loop;
end calc_get;

procedure calc_put (calc: calculation; result: integer) is
begin
for i in 1..calc.length loop -- loop through all calulation elements
	if calc.calc_element(i).op_element = ' ' then
		if calc.calc_element(i+1).op_element = ')' then
			put(calc.calc_element(i).int_element, width => 0);
		else
			put(calc.calc_element(i).int_element, width => 0);
			put(" ");
		end if;
	elsif calc.calc_element(i).op_element = '('
	OR calc.calc_element(i+1).op_element = ')' then
		put(calc.calc_element(i).op_element);
	elsif calc.calc_element(i).op_element = '^' then
		put("** "); -- output to indicate exponentiation, rather than the actual
	else          -- stack symbol '^'
		put(calc.calc_element(i).op_element);
		put(" ");
	end if;
end loop;

put(result, width => 0); -- print out the top of the operand stack after
                         -- the calculation has been computed
end calc_put;

----------------------------------------------------------
-- Purpose: Pulls a pair of operands and an operator from
-- the operand_stack and operator_stack.
-- Parameters: n/a
-- Precondition: stacks are not empty or full.
-- Postcondition: calculations are prcessed and result is added
-- to the top of the operand_stack
----------------------------------------------------------
procedure compute is
	left : integer; -- left operand for individual operations
	right : integer; -- right operand for individual operations
	operator : character; -- operator for computation
begin
	right := top (operand_stack);
	pop (operand_stack);
	left := top (operand_stack);
	pop (operand_stack);
	operator := top (operator_stack);
	pop (operator_stack);

	if operator = '+' then
		push (left + right, operand_stack);
	elsif operator = '-' then
		push (left - right, operand_stack);
	elsif operator = '*' then
		push (left * right, operand_stack);
	elsif operator = '/' then
		push (left / right, operand_stack);
	elsif operator = '^' then
		if right < 0 then -- can't have decimal result from negative exponent
			push(0, operand_stack);
		else
			push (left ** right, operand_stack);
		end if;
	else raise program_error; -- for catching invalid operators on the stack
	end if;
end compute;
	----------------------------------------------------------
	-- Purpose: Assigns a priority value to each of the valid
	-- operators.
	-- evaluate precedence.
	-- Parameters: c: character
	-- Precondition: c is a valid operator
	-- Postcondition: returns the op_priority value for each operator
	----------------------------------------------------------
	function op_priority (c : character) return natural is
	begin
		case c is
			when '+' | '-' => return 1;
			when '*' | '/' => return 2;
			when '^' 			 => return 3;
			when '=' | '(' => return 0;
			when others => return 4;
		end case;
	end op_priority;
	syntax_error : exception;

	----------------------------------------------------------
	-- Purpose: Processes a given calculation using operator
	-- precedence. Elements are read from the calcluation and
	-- then pushed to a stack.
	-- Parameters: c: calculation
	-- Precondition: c is a valid calculation record
	-- Postcondition: Returns the remaining value after all operations
	-- have been completed
	----------------------------------------------------------
function op_precedence(c: calculation) return integer is
	operator : character; -- holds current operator from the calculation
	operand : integer; -- holds current operand to push to stack
begin
	push ('=', operator_stack);
	for i in 1..c.length loop
		if c.calc_element(i).op_element = ' ' then
			operand := c.calc_element(i).int_element;
			push (operand, operand_stack);
		else
			operator := c.calc_element(i).op_element;
			case operator is
				when '+' | '-' | '*' | '/' | '^' =>
					while op_priority(operator) <= op_priority(top(operator_stack)) loop
						compute;
					end loop;
					push (operator, operator_stack);
				when '(' =>
					push (operator, operator_stack);
				when ')' =>
					while op_priority(top(operator_stack)) > op_priority('(') loop
						compute; -- process back to the opening paren
					end loop;
					operator := top(operator_stack);
					pop (operator_stack); -- remove the left '(' from the stack
					if operator /= '(' then
						put ("Invalid input.");
						raise syntax_error;
					end if;
				when '=' => exit;
				when others =>
					put ("Invalid input.");
					raise syntax_error; -- catches invalid operators
			end case;
		end if;
	end loop;

	while op_priority(top(operator_stack)) > op_priority('=') loop
		compute; -- compute any remaining values on the stacks
	end loop;
	new_line;
	return top(operand_stack); -- return the op_precedence result
end op_precedence;

----------------------------------------------------------
-- Purpose: Processes a given calculation from left-to-right.
-- Elements are read from the calculation and pushed to a stack.
-- Parameters: c: calculation
-- Precondition: c is a valid calculation record
-- Postcondition: Returns the remaining value after all operations
-- have been completed
----------------------------------------------------------
function left_to_right (c: calculation) return integer is
	operator : character; -- holds current operator from the calculation
	operand : integer; -- holds current operand to push to stack
begin
	push ('=', operator_stack);
	for i in 1..c.length loop
		if c.calc_element(i).op_element = ' ' then
			operand := c.calc_element(i).int_element;
			push (operand, operand_stack);
		else
			operator := c.calc_element(i).op_element;
			case operator is
				when '+' | '-' | '*' | '/' | '^' => -- compute all with same priority
					while op_priority(top(operator_stack)) > op_priority('=') loop
						compute;
					end loop;
					push (operator, operator_stack);
				when '(' => -- parens handled the same as with op_precedence
					push (operator, operator_stack);
				when ')' =>
					while op_priority(top(operator_stack)) > op_priority('(') loop
						compute;
					end loop;
					operator := top(operator_stack);
					pop (operator_stack); -- remove the left '(' from the stack
					if operator /= '(' then
						put ("Invalid input.");
						raise syntax_error;
					end if;
				when '=' => exit;
				when others =>
					put ("Invalid input.");
					raise syntax_error;
			end case;
		end if;
	end loop;

	while op_priority(top(operator_stack)) > op_priority('=') loop
		compute; -- compute any remaining values on the stacks
	end loop;
	new_line;
	return top(operand_stack); -- return the left_to_right result
end left_to_right;
end calcpkg;
