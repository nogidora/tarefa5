library ieee;
use ieee.std_logic_1164.ALL;
use ieee.numeric_std.all;

entity somador_m_bits is
    GENERIC (Z : integer := 8); --pode mudar com port generic
	 
	 port (a, b        : in std_logic_vector(Z-1 downto 0);
			 c0, clock   : in std_logic;
			 s           : out std_logic_vector(Z-1 downto 0);
          cout, overf : out std_logic);
end somador_m_bits;

architecture arq_somador_m_bits OF somador_m_bits is

	component somadorbit is
		port (
             a, b, cin : in std_logic;
	         clock     : in std_logic;
			 s, cout   : out std_logic);
	end component;

	signal sinal_cin : std_logic_vector(Z downto 0);
	signal b_xor_c0: std_logic_vector(Z-1 downto 0);
begin
	G1  : FOR i IN 0 TO (Z-1) GENERATE
	b_xor_c0(i) <= b(i) XOR c0;
	SOM : somadorbit port map (a(i),
                              b_xor_c0(i),--(b(i) XOR c0),
                              sinal_cin(i),
                              clock,
                              s(i),
                              sinal_cin(i+1));
		  end GENERATE;
	
	process(clock)
	begin
		if(clock'event AND clock ='1') then
			sinal_cin(0) <= c0;
			cout         <= sinal_cin(Z-1);
			overf        <= sinal_cin(Z-1) XOR sinal_cin(Z-2); -- a partir dos 2 bits mais significativos verifica o overfow
		end if;
	end process;
end arq_somador_m_bits;
