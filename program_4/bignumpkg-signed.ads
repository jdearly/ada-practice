--  Package for Signed Bignums

package BigNumPkg.Signed is

   type Signed_BigNum is new BigNum;

   first : constant Signed_BigNum;
   last : constant Signed_BigNum;

   Minus_One : constant Signed_BigNum;
   Zero : constant Signed_BigNum := Signed_BigNum (BigNumPkg.Zero);
   One  : constant Signed_BigNum := Signed_BigNum (BigNumPkg.One);

   Signed_BigNumOverFlow : exception;

   --  Removes leading zeros
   function toString (X : Signed_BigNum) return String;

   function "<" (X, Y : Signed_BigNum) return Boolean;
   function ">" (X, Y : Signed_BigNum) return Boolean;
   function "<=" (X, Y : Signed_BigNum) return Boolean;
   function ">=" (X, Y : Signed_BigNum) return Boolean;

   --  Returns the negative of X
   --  N.B. the smallest negative cannot be negated
   function negate (X : Signed_BigNum) return Signed_BigNum;

   --  Return absolute value of X
   --  N.B. absolute value of the smallest negative cannot be represented
   function abs_val (X : Signed_BigNum) return Signed_BigNum;

   function "+" (X, Y : Signed_BigNum) return Signed_BigNum;
   function "-" (X, Y : Signed_BigNum) return Signed_BigNum;
   function "*" (X, Y : Signed_BigNum) return Signed_BigNum;

   procedure Put (Item : Signed_BigNum; Width : Natural := 1);

   --  Get reads positive and negative numbers
   --  Negative numbers are preceded by a minus sign (ie '-')
   procedure Get (Item : out Signed_BigNum);

private
   -- minus_one : constant Signed_BigNum := (others => 9);
   --
   -- --  Only valid for base 10
   -- first : constant Signed_BigNum := (0 => 5, others => 0);
   -- last  : constant Signed_BigNum := (0 => 4, others => 9);
minus_one : Constant Signed_Bignum := (0 => 5, size - 1 => 1, others => 0);

--  Only valid for base 10
first : Constant Signed_Bignum := (others => 9);
last : Constant Signed_Bignum := (0 => 4, others => 9);
end BigNumPkg.Signed;
