with StackPkg;
with Ada.Text_IO;
use Ada.Text_IO;
with Ada.Integer_Text_IO;
use Ada.Integer_Text_IO;

procedure stack_test is
   package IntStack is new StackPkg(10, Integer);
   use IntStack;


   myStack : IntStack;
   temp    : Integer;

begin
   Put_Line("Pushing 10");
   push( 10, myStack);

   Put_Line( "Pushing 11" );
   Push( 11, myStack);

   Put("Top: ");
   temp := myStack.top;
   Put_Line( temp );
   New_Line;

   Put_Line("Popping...");
   pop(myStack);

   Put("Top: ");
   temp := myStack.top;
   Put_Line( temp );
   New_Line;

   Put_Line("Popping...");
   pop(myStack);

   begin
      Put("Top: ");
      temp := myStack.top;
      Put_Line( temp );
      New_Line;
   exception
      when Stack_Empty=>
         Put_Line("Caught Stack Empty correctly...");
   end;

   begin
      Put_Line("Popping...");
      pop(myStack);
   exception
      when Stack_Empty=>
         Put_Line("Caught Stack Empty correctly...");
   end;


end stack_test;
