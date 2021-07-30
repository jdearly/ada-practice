-- Name: Joshua Early
-- Date: March 23, 2018
-- Course: ITEC 320-01 - Procedural Analysis and Design
-- do_calcs.adb - main driver

-- Purpose: This program implements a simple calulator using stacks and records.
-- The program reads from standard input and adds operands and operators to
-- their respective stacks. All operations are done using integers, no floating
-- point operations.
-- The program calulates by order of precedence and left-to-right.
-- All input is assumed to be valid.
-- Sample input:
-- 2+3*5=
-- 2 * 3 + 5=
-- 2 - 4 * 2 ** 3 =
-- 10+3*5=
-- -2 + -2 =
-- 2 + (3 + 4) *5 =
-- -2--3=
-- (1+2) * (3 * (5 + 5) + (6 * 7)) * 7  =
-- Output:
-- 2 + 3 * 5 = 25
-- 2 + 3 * 5 = 17
-- 2 * 3 + 5 = 11
-- 2 * 3 + 5 = 11
-- 2 - 4 * 2 ** 3 = -64
-- 2 - 4 * 2 ** 3 = -30
-- 10 + 3 * 5 = 65
-- 10 + 3 * 5 = 25
-- -2 + -2 = -4
-- -2 + -2 = -4
-- 2 + (3 + 4) * 5 = 45
-- 2 + (3 + 4) * 5 = 37
-- -2 - -3 = 1
-- -2 - -3 = 1
-- (1 + 2) * (3 * (5 + 5) + (6 * 7)) * 7 = 1512
-- (1 + 2) * (3 * (5 + 5) + (6 * 7)) * 7 = 1512

with ada.text_io, ada.integer_text_io;
use ada.text_io, ada.integer_text_io;
with calcpkg; use calcpkg;

procedure do_calcs is
  c: calculation;
begin
  while not end_of_file loop
      calc_get(c);
      calc_put(c, left_to_right(c));
      calc_put(c, op_precedence(c));
  end loop;
end do_calcs;
