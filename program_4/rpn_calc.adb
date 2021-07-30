with ada.text_io; use ada.text_io;
with ada.integer_text_io; use ada.integer_text_io;
with ada.strings.fixed; use ada.strings.fixed;
with ada.exceptions; use ada.exceptions;
with bignumpkg.signed; use bignumpkg.signed;
with stackpkg;

procedure rpn_calc is
   op_chars      : constant string := "+-*Ppq";

   type operator is (add, sub, mul, print, pop);
   gen_exception : exception;

   package signed_bignum_stack is new stackpkg (100, signed_bignum);
   use signed_bignum_stack;


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
		 push (left, s);
		 raise stack_empty with "Error: Stack is empty";
      end if;
   end get_operands;


   procedure calculate (op : in operator; s : in out stack) is
      left, right, ans : signed_bignum;
   begin
      get_operands (left, right, s);

      if op = add then
         ans := left + right;
      elsif op = sub then
         ans := right - left;
      elsif op = mul then
         ans := left * right;
      end if;

      push (ans, s);
   end calculate;


   procedure perform_operation (op : in operator; s : in out stack) is
   begin
      case op is
         when sub | add | mul =>
            calculate (op, s);
         when print =>
            put (top (s));
            new_line;
         when pop =>
            pop (s);
      end case;
   end perform_operation;


   procedure get (op : out operator) is
      c : character;
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
            raise gen_exception with "Invalid operator: " & c;
      end case;
   end get;


   function is_operator
     (c : in character) return boolean is
     (index (op_chars, "" & c) > 0);


   function is_number
     (c : in character) return boolean is
     (c in '0' .. '9' or c = '_');


   procedure handle_other is
      c : character;
   begin
      get (c);
      if c /= ' ' then
         raise gen_exception with "Invalid input: " & c;
      end if;
   end handle_other;


   procedure handle_number (s : out stack) is
      bn : signed_bignum;
   begin
      get (bn);
      push (bn, s);
   end handle_number;

   procedure handle_operator (s : out stack) is
      op : operator;
   begin
      get (op);
      perform_operation (op, s);
   end handle_operator;


   procedure process_input (c : in character; s : in out stack) is
   begin
      if is_number (c) then
         handle_number (s);
      elsif is_operator (c) then
         handle_operator (s);
      else
         handle_other;
      end if;

   exception
      when e : stack_empty | signed_bignumoverflow | gen_exception =>
         put_line (exception_message(e));
   end process_input;


   procedure input_loop (s : in out stack) is
      c : character;    -- next character of input
      nl     : boolean;      -- was a newline recieved
   begin
      loop
         -- grab the next character
         look_ahead (c, nl);
         exit when c = 'q';

         if nl or c = '#' then
            skip_line;
         else
            -- send the character for processing
            process_input (c, s);
         end if;

      end loop;
   end input_loop;

   -- entry point
   numstack : stack;
begin
   input_loop (numstack);
end rpn_calc;
