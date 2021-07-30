-- Name: Joshua Early
-- Date: April 10, 2018
-- bignumpkg-sgned.adb - package body

with ada.text_io; use ada.text_io;
with ada.integer_text_io; use ada.integer_text_io;

----------------------------------------------------------
-- Purpose: bignumpkg-signed.adb body for bignumpkg-signed.ads implementation
-- Parameters: n/a
-- Precondition: bignumpkg-signed.ads spec is complete.
-- Postcondition: defines the body for bignumpkg-signed spec.
----------------------------------------------------------
package body bignumpkg.signed is

  ----------------------------------------------------------
  -- Purpose: To determine if a signed_bignum is a negative.
  -- Parameters: x: signed_bignum to test for negativity
  -- Precondition: n/a
  -- Postcondition: Returns true if given signed_bignum is
  -- a negative, false otherwise
  ----------------------------------------------------------
   function is_neg(x : signed_bignum) return boolean is
     status: boolean := false; -- track negative or not
   begin
     if (bignum (x) >= bignum (minus_one)) then
       status := true;
     end if;
     return status;
   end is_neg;

   ----------------------------------------------------------
   -- Purpose: Convert signed_bignum to a string.
   -- Parameters: x: signed_bignum to convert
   -- Precondition: n/a
   -- Postcondition: Returns a string representing a
   -- signed_bignum
   ----------------------------------------------------------
   function tostring (x : signed_bignum) return string is
   begin
      if is_neg (x) then
         if x = first then
            return '-' & bignumpkg.tostring (bignum (x));
         else
            return '-' & bignumpkg.tostring (bignum (abs_val (x)));
         end if;
      else
         return bignumpkg.tostring (bignum (x));
      end if;
   end tostring;

   -----------------------------------------------------------
   -- Purpose: Operator to compare signed_bignums
   -- Parameters: x, y: signed_bignums to compare
   -- Precondition: n/a
   -- Postcondition: Returns comparison result
   ----------------------------------------------------------
   function "<" (x, y : signed_bignum) return boolean is
   begin

	  if is_neg (x) and (not is_neg (y)) then
         return true;

	  elsif (not is_neg (x)) and is_neg (y) then
         return false;

	  elsif is_neg (x) and is_neg (y) then
         return bignum (x) > bignum (y); -- find smallest

	  -- if both are positive, use bignum "<"
	  else
         return bignum (x) < bignum (y);
    end if;
   end "<";

   -----------------------------------------------------------
   -- Purpose: Operator to compare signed_bignums
   -- Parameters: x, y: signed_bignums to compare
   -- Precondition: n/a
   -- Postcondition: Returns comparison result
   -- (next three functions)
   ----------------------------------------------------------
   function ">" (x, y : signed_bignum) return boolean is
     (not (x < y or x = y));

   function "<=" (x, y : signed_bignum) return boolean is
     (x < y or x = y);

   function ">=" (x, y : signed_bignum) return boolean is
     (x > y or x = y);

   -----------------------------------------------------------
   -- Purpose: To generate the 9's complement of a signed_bignum
   -- Parameters: x: signed_bignum to convert
   -- Precondition: n/a
   -- Postcondition: Returns the 9's complement of the given
   -- signed_bignum
   ----------------------------------------------------------
   function nines_complement (x : signed_bignum) return signed_bignum is
      nine_comp_result : signed_bignum; -- value to return
   begin
      for i in reverse 0 .. size - 1 loop
         nine_comp_result (i) := 9 - x (i);
      end loop;
      return nine_comp_result + one;
   end nines_complement;

   ----------------------------------------------------------
   -- Purpose: To generate the negative of a number
   -- Parameters: x: signed_bignum to convert
   -- Precondition: n/a
   -- Postcondition: Returns the negative of input number
   ----------------------------------------------------------
   function negate (x : signed_bignum) return signed_bignum is
     result: signed_bignum;
   begin
     result := nines_complement (x);
     return result;
   end negate;

   ----------------------------------------------------------
   -- Purpose: Generate the absolute value of a signed_bignum
   -- Parameters: x: signed_bignum
   -- Precondition: n/a
   -- Postcondition: Returns the absolute value of x
   ----------------------------------------------------------
   function abs_val (x : signed_bignum) return signed_bignum is
       result: signed_bignum;
   begin
     if is_neg (x) then
         result := negate (x);
     else
         result := x;
     end if;
   return result;
   end abs_val;

   ----------------------------------------------------------
   -- Purpose: Add two signed_bignums
   -- Parameters: x, y: signed_bignums to add together
   -- Precondition: n/a
   -- Postcondition: Returns the result of x + y
   ----------------------------------------------------------
   function "+" (x, y : signed_bignum) return signed_bignum is
      overflow : boolean; -- status of overflow
      result   : signed_bignum; -- result of x + y
   begin
      plus_ov (bignum (x), bignum (y), bignum (result), overflow);
      return result;
   end "+";

   ----------------------------------------------------------
   -- Purpose: Subtract two signed_bignums
   -- Parameters: x, y: signed_bignums to calculate difference
   -- Precondition: n/a
   -- Postcondition: Returns the reuslt of x - y
   ----------------------------------------------------------
   function "-" (x, y : signed_bignum) return signed_bignum is
     result: signed_bignum;
   begin
     result := x + negate (y);
     return result;
   end "-";

   ----------------------------------------------------------
   -- Purpose: Multiply two signed_bignums
   -- Parameters: x, y: signed_bignums to use for the calculation
   -- Precondition: n/a
   -- Postcondition: Returns the result of x * y
   ----------------------------------------------------------
   function "*" (x, y : signed_bignum) return signed_bignum is
      result   : signed_bignum; -- result of x * y
      negative : boolean := is_neg (x) /= is_neg (y);
   begin

      result := signed_bignum (bignum (abs_val (x)) * bignum (abs_val (y)));

      -- check for overflow
      if bignum (result) > bignum (first) or
         (result = first and not negative)
      then
         raise signed_bignumoverflow;
      end if;

      if negative and result /= first then
         return negate (result);
      else
         return result;
      end if;


   exception
      when others =>
         raise signed_bignumoverflow with
           "Result too large.";
   end "*";

   ----------------------------------------------------------
   -- Purpose: Prints signed_bignum
   -- Parameters: item, width: signed_bignum to print and
   -- the character width (padding)
   -- Precondition: n/a
   -- Postcondition: Output the signed_bignum
   ----------------------------------------------------------
   procedure put (item : signed_bignum; width : natural := 1) is
   begin
      if is_neg (item) then
         ada.text_io.put ('-');
         put (bignum (abs_val (item)), width);
      else
         put (bignum (item), width);
      end if;
   end put;

   ----------------------------------------------------------
   -- Purpose: To get characters from standard input
   -- Parameters: item: signed_bignum
   -- Precondition: input is valid
   -- Postcondition: Gets a signed_bignum from standard input
   ----------------------------------------------------------
   procedure get (item : out signed_bignum) is
      c   : character;
      eol  : boolean;
      negative : boolean := false;
   begin

      loop
         if end_of_file then
            raise data_error;
         elsif end_of_line then
            skip_line;
         else
            look_ahead (c, eol);
            exit when c in '0' .. '9' or else c = '_';
            get (c);
            if c /= ' ' and c /= ASCII.HT and c /= '0' then
               raise data_error;
            end if;
         end if;
      end loop;

      if c = '_' then
         get (c);
         negative := true;
      end if;

      get (bignum (item));

      -- check for input overflow
      if (is_neg (item) and item /= first) or
        (item = first and not negative) then
         raise signed_bignumoverflow;
      end if;

      if negative and item /= first then
         item := negate (item);
      end if;
   end get;

end bignumpkg.signed;
