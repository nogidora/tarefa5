library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity somadorbit is
	port (
		   a, b, cin : in std_logic;
	      clock     : in std_logic;
		   s         : out std_logic;
			cout      : out std_logic
			);
end somadorbit;

architecture arq_somadorbit of somadorbit is
begin
	cout <= (a and b) OR (a and cin) OR (b and cin);
	s    <= (a XOR b XOR cin);
end arq_somadorbit;