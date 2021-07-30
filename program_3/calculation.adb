with Ada.Text_IO, Ada.Integer_Text_IO, StackPkg, WordPkg;
use Ada.Text_IO, Ada.Integer_Text_IO;
      procedure Calculation is
          type Operators is ('+', '-', '/', '*', '(', '=', ' ');
          package OperatorsIO is new Ada.Text_IO.Enumeration_IO(Operators);
          package Operand_Stacks is new StackPkg(Size => 100, ItemType => Integer);
          package Operator_Stacks is new StackPkg (Size => 100, ItemType => Operators);
          use Operand_Stacks, Operator_Stacks;
          use WordPkg;

          Operand_Stack  : Operand_Stacks.Stack;
          Operator_Stack : Operator_Stacks.Stack;

          Operator    : Operators;
          Operand     : Integer;
          End_Line    : Boolean;
          Got_Operand : Boolean := False;

          procedure Apply is
              Left, Right : Integer;
              Operator    : Operators;
          begin
              Right := Top (Operand_Stack);
              Pop (Operand_Stack);
              Left := Top (Operand_Stack);
              Pop (Operand_Stack);
              Operator := Top (Operator_Stack);
              Pop (Operator_Stack);

              case Operator is
                  when '+' => Push (Left + Right, Operand_Stack);
                  when '-' => Push (Left - Right, Operand_Stack);
                  when '*' => Push (Left * Right, Operand_Stack);
                  when '/' => Push (Left / Right, Operand_Stack);
                  --when "**" => Push (Left ** Right, Operand_Stack);
                  when others => raise Program_Error;
              end case;
          end Apply;

          function Prio (Operator : Character) return Natural is
          begin
              case Operator is
                  when '+' | '-' => return 1;
                  when '*' | '/' => return 2;
                  when '=' | '(' => return 0;
                  when others => raise Program_Error;
              end case;
          end Prio;

          Syntax_Error : exception;



      begin                                       -- main program
          Push ('=', Operator_Stack);
          --Put ("Enter an expression: ");
          loop
              -- Get next non-space character
              loop
                Look_Ahead (Operator, End_Line);
                  exit when End_Line or Operator /= ' ';
                  Get (Operator);                 -- got a space, so skip it
              end loop;

              -- Exit main loop at end of line
              exit when End_Line;

              -- Process operator or operand
              if Operator in '1'..'9' then        -- it's an operand
                  if Got_Operand then             -- can't have an operand
                      Put ("Missing operator");   -- immediately after another
                      exit;
                  end if;
                  Get (Operand);                  -- read the operand
                  Push (Operand, Operand_Stack);
                  Got_Operand := True;            -- record we've got an operand
              else                                -- it's not an operand
                  Got_Operand := False;           -- so record the fact
                  exit when Operator = '.';       -- exit at end of expr.
                  Get (Operator);                 -- else read the operator
                  case Operator is                -- and apply it
                      when '+' | '-' | '*' | '/' =>
                          while Prio(Operator) <= Prio(Top(Operator_Stack)) loop
                              Apply;
                          end loop;
                          Push (Operator, Operator_Stack);

                      when '(' =>              -- stack left parenthesis
                          Push (Operator, Operator_Stack);
                    when ')' =>              -- unwind stack back to '('
                          while Prio(Top(Operator_Stack)) > Prio('(') loop
                              Apply;
                          end loop;
                          Operator := Top(Operator_Stack);
                          Pop (Operator_Stack);
                          if Operator /= '(' then
                              Put ("Missing left parenthesis");
                              raise Syntax_Error;
                          end if;

                      when others =>
                          Put ("Invalid operator '");
                          Put (Operator);
                          Put ("'");
                          raise Syntax_Error;
                  end case;
              end if;
          end loop;

          -- Apply remaining operators from stack
          while Prio(Top(Operator_Stack)) > Prio('=') loop
              Apply;
          end loop;

          -- Display result or report error
          if Top(Operator_Stack) = '=' then
              Put (Top(Operand_Stack), Width => 1);
              New_Line;
          else
              Put ("Missing right parenthesis");
              raise Syntax_Error;
          end if;
      exception
          when Syntax_Error =>
              Put_Line (" -- program terminated.");
      end Calculation;
