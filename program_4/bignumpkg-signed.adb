with ada.text_io;         use ada.text_io;
with ada.integer_text_io; use ada.integer_text_io;

package body bignumpkg.signed is
   ----------------------------------------------------------
   -- purpose: determine if the signed_bignum is negative.
   -- parameters: x: signed_bignum to test.
   ----------------------------------------------------------
   function is_negative(x : signed_bignum) return boolean is
     (bignum (x) >= bignum (first));

   ----------------------------------------------------------
   -- purpose: convert a signed_bignum into a string.
   -- parameters: x: signed_bignum to convert.
   ----------------------------------------------------------
   function tostring (x : signed_bignum) return string is
   begin
      if is_negative (x) then
         if x = first then
            return '-' & bignumpkg.tostring (bignum (x));
         else
            return '-' & bignumpkg.tostring (bignum (abs_val (x)));
         end if;
      else
         return bignumpkg.tostring (bignum (x));
      end if;
   end tostring;

   ----------------------------------------------------------
   -- purpose: special operator to compare signed_bignums
   -- parameters: x,y: signed_bignums to compare
   ----------------------------------------------------------
   function "<" (x, y : signed_bignum) return boolean is
   begin
      -- left is not negative, right is negative
	  if is_negative (x) and (not is_negative (y)) then
         return true;

	  -- left is negative, right is not
	  elsif (not is_negative (x)) and is_negative (y) then
         return false;

	  -- both are negative, figure out which one is less negative
	  elsif is_negative (x) and is_negative (y) then
         return bignum (x) > bignum (y);

	  -- both are positive, normal comparison
	  else
         return bignum (x) < bignum (y);
      end if;
   end "<";

   ----------------------------------------------------------
   -- purpose: special operator to compare signed_bignums
   -- parameters: x,y: signed_bignums to compare
   ----------------------------------------------------------
   function ">" (x, y : signed_bignum) return boolean is
     (not (x < y or x = y));

   ----------------------------------------------------------
   -- purpose: special operator to compare signed_bignums
   -- parameters: x,y: signed_bignums to compare
   ----------------------------------------------------------
   function "<=" (x, y : signed_bignum) return boolean is
     (x < y or x = y);

   ----------------------------------------------------------
   -- purpose: special operator to compare signed_bignums
   -- parameters: x,y: signed_bignums to compare
   ----------------------------------------------------------
   function ">=" (x, y : signed_bignum) return boolean is
     (x > y or x = y);

   ----------------------------------------------------------
   -- purpose: compute the 9's complement for a signed_bignum.
   -- parameters: x: signed_bignums to compute the 9's complement for.
   ----------------------------------------------------------
   function nines_comp (x : signed_bignum) return signed_bignum is
      y : signed_bignum;
   begin
   	  -- invert each digit
      for i in reverse 0 .. size - 1 loop
         y (i) := 9 - x (i);
      end loop;

	 -- must add 1 to the result for 9's complement
      return y + one;
   end nines_comp;

   ----------------------------------------------------------
   -- purpose: return negative value of a signed_bignum
   -- parameters: x: signed_bignum to negate.
   -- exceptions: smallest negative value cannot be negated.
   ----------------------------------------------------------
   function negate (x : signed_bignum) return signed_bignum is
     (if x = first then raise signed_bignumoverflow
      else nines_comp (x) );

   ----------------------------------------------------------
   -- purpose: return absolute value of a signed_bignum
   -- parameters: x: signed_bignum to get the abs of.
   -- exceptions: absolute value of the smallest negative cannot
   --    be represented.
   ----------------------------------------------------------
   function abs_val (x : signed_bignum) return signed_bignum is
     (if is_negative (x) then negate (x) else x);

   ----------------------------------------------------------
   -- purpose: add two signed_bignums
   -- parameters: x,y: signed_bignums to add
   ----------------------------------------------------------
   function "+" (x, y : signed_bignum) return signed_bignum is
      overflow : boolean;
      result   : signed_bignum;
      sum      : signed_bignum;
   begin
      -- do a standard addition, allowing overflow
      plus_ov (bignum (x), bignum (y), bignum (result), overflow);

	  -- detect overflow via incorrect sign of result
     if is_negative(x) = is_negative(y) then
       result := nines_comp(result);
     end if;
    --   -- then
      --    raise signed_bignumoverflow;
      -- end if;

      return result;
   end "+";

   ----------------------------------------------------------
   -- purpose: subtract two signed_bignums, x-y
   -- parameters: x,y: signed_bignums to subtract
   ----------------------------------------------------------
   function "-" (x, y : signed_bignum) return signed_bignum is
     ((nines_comp(x + negate (y))));

   ----------------------------------------------------------
   -- purpose: multiply two signed_bignums
   -- parameters: x,y: signed_bignums to multiply
   ----------------------------------------------------------
   function "*" (x, y : signed_bignum) return signed_bignum is
      result   : signed_bignum;
      negative : boolean := is_negative (x) /= is_negative (y);
   begin
      -- handle some special cases
      if x = zero or y = zero then
         return zero;
      elsif x = one then
         return y;
      elsif y = one then
         return x;
      end if;

      -- do a full multiply based on positive values of both numbers
      result := signed_bignum (bignum (abs_val (x)) * bignum (abs_val (y)));

      -- detect overflows
      if bignum (result) > bignum (first) or
         (result = first and not negative)
      then
         raise signed_bignumoverflow;
      end if;

      -- return the value
      if negative and result /= first then
         return negate (result);
      else
         return result;
      end if;


   exception
      when others =>
         raise signed_bignumoverflow with
           "result for signed_bignum multiply needs more digits.";
   end "*";

   ----------------------------------------------------------
   -- purpose: writes a signed_bignum to the output, padding with
   --    leading spaces if the width given is larger than the length
   --    of the number (leading zeros are not printed).
   -- parameters: item: signed_bignum to print
   --            width: amount of padding
   ----------------------------------------------------------
   procedure put (item : signed_bignum; width : natural := 1) is
   begin
      if is_negative (item) then
         ada.text_io.put ('-');
         if item = first then
            put (bignum (item), width);
         else
            put (bignum (abs_val (item)), width);
         end if;

      else
         put (bignum (item), width);
      end if;
   end put;

   ----------------------------------------------------------
   -- purpose: get reads positive and negative numbers
   --    negative numbers are preceded by a minus sign (ie '_').
   -- parameters: item: signed_bignum to store input in.
   ----------------------------------------------------------
   procedure get (item : out signed_bignum) is
      c   : character;
      lineend  : boolean;
      negative : boolean := false;
   begin
      -- skip leading whitespace
      loop
         if end_of_file then
            raise data_error;
         elsif end_of_line then
            skip_line;
         else
            look_ahead (c, lineend);

            -- exit if find a digit or minus symbol
            exit when c in '0' .. '9' or else c = '_';

            get (c);
            if c /= ' ' and c /= ascii.ht and c /= '0' then
               raise data_error;
            end if;
         end if;
      end loop;

      -- check for negative symbol
      if c = '_' then
         get (c);
         negative := true;
      end if;

      -- get the bignum
      get (bignum (item));

      -- handle user putting in a number too large that it overflows
      if (is_negative (item) and item /= first) or
        (item = first and not negative) then
         raise signed_bignumoverflow;
      end if;

      -- negate the number is needed
      if negative and item /= first then
         item := negate (item);
      end if;
   end get;

end bignumpkg.signed;
