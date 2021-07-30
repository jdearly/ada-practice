-- Name: Joshua Early
-- Date: April 10, 2018
-- rpn_calc.adb - client body

with ada.text_io; use ada.text_io;
with ada.integer_text_io; use ada.integer_text_io;
with ada.strings.fixed; use ada.strings.fixed;
with ada.exceptions; use ada.exceptions;
with bignumpkg.signed; use bignumpkg.signed;
with stackpkg;

procedure rpn_calc is

   type operator is (add, sub, mul, print, pop); -- enum for operators
   gen_exception : exception;

   -- signed_bignum stack
   package sbn_stack is new stackpkg (100, signed_bignum);
   use sbn_stack;

   ----------------------------------------------------------
   -- Purpose: Pull two operands off of the stack
   -- Parameters: left, right: signed_bignums to get from the stack
   -- Precondition: the stack is not empty
   -- Postcondition: Returns left and right operands
   ----------------------------------------------------------
   procedure get_operands (left, right : out signed_bignum; s : in out stack) is
   begin
      if not isempty (s)then
         left := top (s);
         pop (s);
      else
         raise stack_empty with "Error: Stack is empty";
      end if;

      if not isempty (s) then
         right := top (s);
         pop (s);
      else
		      push (left, s); -- if no second operator
		      raise stack_empty with "Error: Stack is empty";
      end if;
   end get_operands;

   ----------------------------------------------------------
   -- Purpose: Performs calcluation based on the operator provided
   -- Parameters: op, s: operator to use for calculation and the stack
   -- to get values from
   -- Precondition: Stack is not empty
   -- Postcondition: Pushes the result of the calculation back onto
   -- the stack
   ----------------------------------------------------------
   procedure calc (op : in operator; s : in out stack) is
      result, left, right : signed_bignum; -- operands for operation
   begin
      get_operands (left, right, s);
      if op = add then
         result := left + right;
      elsif op = sub then
         result := right - left;
      elsif op = mul then
         result := left * right;
      end if;
      push (result, s);
   end calc;

   ----------------------------------------------------------
   -- Purpose: Handle operation provided
   -- Parameters: op, s: operator provided by user and stack to
   -- push/pop values
   -- Precondition: stack is not empty
   -- Postcondition: Returns new stack
   ----------------------------------------------------------
   procedure operation (op : in operator; s : in out stack) is
   begin
      case op is
         when sub | add | mul =>
            calc (op, s);
         when print =>
            put (top (s));
            new_line;
         when pop =>
            pop (s);
      end case;
   end operation;

   ----------------------------------------------------------
   -- Purpose: Gets an operator from input and assigns enum value
   -- Parameters: op: operator
   -- Precondition: n/a
   -- Postcondition: Returns the operator enum value
   ----------------------------------------------------------
   procedure get (op : out operator) is
      c : character; -- input operator
   begin
      get (c);
      case c is
         when '-' =>
            op := sub;
         when '+' =>
            op := add;
         when '*' =>
            op := mul;
         when 'p' =>
            op := print;
         when 'P' =>
            op := pop;
         when others =>
            raise gen_exception with "Invalid input: " & c;
      end case;
   end get;

   ----------------------------------------------------------
   -- Purpose: Checks if input is one of the valid input operators
   -- Parameters: c: character to compare
   -- Precondition: n/a
   -- Postcondition: Returns true of the input character is a valid
   -- operator, false otherwise
   ----------------------------------------------------------
   function is_op (c : in character) return boolean is
     op: boolean := false; -- track if c is an operator
   begin
     if (index ("+-*Ppq", "" & c) > 0) then
       op := true;
     end if;
     return op;
   end is_op;

   ----------------------------------------------------------
   -- Purpose: Checks if input is a number
   -- Parameters: c: character to compare to valid integer values
   -- Precondition: n/a
   -- Postcondition: Returns true if c is a number, false otherwise
   ----------------------------------------------------------
   function is_num (c : in character) return boolean is
     num: boolean := false; -- track if c is a number (integer)
   begin
     if (c in '0' .. '9' or c = '_') then
       num := true;
     end if;
     return num;
   end is_num;

   ----------------------------------------------------------
   -- Purpose: Helper procedure to consume white space
   -- Parameters: n/a
   -- Precondition: n/a
   -- Postcondition: Consumes whitespace, moves input marker to
   --next character
   ----------------------------------------------------------
   procedure skip_white_space is
      c : character; -- character to be consumed
   begin
      get (c);
      if c /= ' ' then
         raise gen_exception with "Invalid input: " & c;
      end if;
   end skip_white_space;

   ----------------------------------------------------------
   -- Purpose: Main loop to capture user input
   -- Parameters: s: stack to use for operands and operators
   -- Precondition: n/a
   -- Postcondition: Loops until user input is the character 'q'
   ----------------------------------------------------------
   procedure process_input (s : in out stack) is
      c: character; -- standard input character
      end_of_line: boolean; -- checks if a newline is reached
      sbn: signed_bignum; -- signed_bignum to push to stack
      op: operator; -- operator for operation procedure
   begin
      loop
         look_ahead (c, end_of_line);
         exit when c = 'q';

         if end_of_line then
            skip_line;
         else
            if is_num (c) then
              get (sbn);
              push (sbn, s);
            elsif is_op (c) then
              get (op);
              operation (op, s);
            else
              skip_white_space;
            end if;
         end if;
      end loop;
   end process_input;

   s: stack;
begin
   process_input (s);
end rpn_calc;
