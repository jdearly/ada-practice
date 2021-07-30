-- Name: Joshua Early
-- Date: March 23, 2018
-- Course: ITEC 320-01 - Procedural Analysis and Design
-- calcpkg.ads - package spec

package calcpkg is

   type element is limited private; -- record type for each element
   type calculation is limited private;
        -- get standard input and produce a calculation
   procedure calc_get (calc : out calculation);
        -- print the calculation and result
   procedure calc_put (calc : calculation; result: integer);
        -- compute the result for operator precedence
   function op_precedence(c: calculation) return integer;
        -- compute the result for left-to-right
   function left_to_right(c: calculation) return integer;

private

    max_calc_size: constant natural := 100;

    type ele_array is array(1..max_calc_size) of element;

    type element is record
        int_element: integer;
        op_element: character := ' ';
    end record;

    type calculation is record
        length: natural := 0;
        calc_element: ele_array;
    end record;
end calcpkg;
