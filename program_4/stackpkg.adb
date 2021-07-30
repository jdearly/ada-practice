-- Name: Joshua Early
-- Date: March 23, 2018
-- Course: ITEC 320-01 - Procedural Analysis and Design
-- stackpkg.adb - package body

package body stackpkg is
      -- Determine if stack is full
    function isfull (s : stack) return boolean is
  	begin
  		return s.top = size;
  	end isfull;
      -- Determine if stack is empty or full
  	function isempty (s : stack) return boolean is
  	begin
  		return s.top = 0;
  	end isempty;
      -- push element onto the stack
  	procedure push (item : itemtype; s : in out stack) is
  	begin
  		if isfull (s) then
  			raise stack_full;
  		else
  			s.top := s.top + 1;
  			s.elements(s.top) := item;
  		end if;
  	end push;
      -- remove element from the top of the stack
  	procedure pop (s : in out stack) is
  	begin
  		if isfull (s) then
  			raise stack_full;
  		else
  			s.top := s.top - 1;
  		end if;
  	end pop;
        -- determine the top element on the stack
  	function top (s : in stack) return itemtype is
  	begin
  	if isempty (s) then
  			raise stack_empty;
  		else
  			return s.elements(s.top);
  		end if;
  	end top;

end stackpkg;
