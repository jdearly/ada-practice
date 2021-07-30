-- This is the interface for the BigNum abstract data type, which supports
-- arithmetic with VERY LARGE natural values.  The operations provided
-- work as one would expect for natural numbers.

package BigNumPkg is
   type BigNum is private;

   Zero : constant BigNum;
   One  : constant BigNum;

   First : constant BigNum;
   Last  : constant BigNum;

   BigNumOverFlow : exception;

   function toString (X : BigNum) return String;

   function "<" (X, Y : BigNum) return Boolean;
   function ">" (X, Y : BigNum) return Boolean;
   function "<=" (X, Y : BigNum) return Boolean;
   function ">=" (X, Y : BigNum) return Boolean;

   function "+" (X, Y : BigNum) return BigNum;
   function "*" (X, Y : BigNum) return BigNum;

   procedure plus_ov
     (X, Y     :     BigNum;
      Result   : out BigNum;
      Overflow : out Boolean);

   procedure Get (Item : out BigNum);
   procedure Put (Item : BigNum; Width : Natural := 1);
private
   Size : constant Positive := 50;
   type BigNum is array (0 .. Size - 1) of Integer;

   Zero : constant BigNum := (others => 0);
   One  : constant BigNum := (Size - 1 => 1, others => 0);

   --  Only valid for base 10
   First : constant BigNum := (others => 0);
   Last  : constant BigNum := (others => 9);
end BigNumPkg;
