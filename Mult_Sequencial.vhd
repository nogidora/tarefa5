library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Mult_Sequencial is  -- pode mudar com o port generic
    GENERIC (N : integer := 16; -- tamanho do produto
			 M : integer := 8);
	 
	 port (
		 	 MD, MR        : in std_logic_vector(M-1 downto 0);
			 clock         : in std_logic;
			 load          : in std_logic;
        	 cout, overf   : out std_logic;
			 Produto_final : out std_logic_vector(N-1 downto 0));

end Mult_Sequencial;

architecture arq_Mult_Sequencial of Mult_Sequencial is
	component somador_m_bits is
		GENERIC (M : integer := 8);
		port (
				a, b        : in std_logic_vector(M-1 downto 0);
				c0, clock   : in std_logic;
				s           : out std_logic_vector(M-1 downto 0);
				cout, overf : out std_logic);
	end component;
	
	signal sinal_PR    : std_logic_vector(N-1 downto 0);
	signal sinal_PP    : std_logic_vector(M-1 downto 0);
	signal sinal_P     : std_logic_vector(M-1 downto 0);	
	signal sinal_soma  : std_logic_vector(M-1 downto 0);
	signal sinal_count : integer := 0;
	signal sinal_sel   : std_logic;
	
begin
	sinal_sel <= sinal_PR(0);
	
	with sinal_sel select
	sinal_PP <= "00000000" when '0',
                       MD when '1';
							
							
	sinal_P <= sinal_PR(N-1 downto 8); 
	
   process (clock, load)
   begin
		if(clock'event AND clock = '1') then
		    if(sinal_count < 8 AND load = '0') then   -- se passar de 8 ciclos nao entra de novo no shift	
			    sinal_PR <= sinal_soma(7) & sinal_soma(7 downto 0) & sinal_PR(7 downto 1); -- realiza oo shift da multiplicacao
				 sinal_count <= sinal_count + 1;         -- conta quantos ciclos se passam
			
			elsif(load = '1') then
				sinal_PR <= "00000000" & MR;
				sinal_count <= 0;
			end if;
		end if;
	end process;
	
	Somador: somador_m_bits port map (sinal_PP,
												sinal_P,
												'0',
											   clock,
												sinal_soma,
												open,
												open); -- passo open pq o cout e overflow nao sao usados neste modul, entao evitamos a criacao de sinais desnecessarios
	
	Produto_final <= sinal_PR when sinal_count = 8 else (others => '0');
end arq_Mult_Sequencial;
