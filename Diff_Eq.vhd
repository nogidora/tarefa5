-- differential equation solver using 2 stage pipeline and
-- unlimited resources;
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Diff_Eq is
   port(
         x, u, y, dx, a : in  integer;
         clock          : in  std_logic;
         load           : in  std_logic;
         y_final        : out integer
      );
end entity Diff_Eq;



architecture arq_Diff_Eq of Diff_Eq is
---------------------
-----COMPONENTS------
---------------------
	component somador_m_bits is
		GENERIC (Z : integer := 16);
		port (
				a, b        : in  std_logic_vector(Z-1 downto 0);
				c0, clock   : in  std_logic;
				s           : out std_logic_vector(Z-1 downto 0);
				cout, overf : out std_logic
			 );
	end component;
--
	component Mult_Sequencial
		GENERIC (N : integer := 16; -- tamanho do produto
				 M : integer := 8);
		port (
			MD, MR        : in std_logic_vector(M-1 downto 0);
			clock         : in std_logic;
			load          : in std_logic;
			cout, overf   : out std_logic;
			Produto_final : out std_logic_vector(N-1 downto 0));

	end component;

--------------------
------SIGNALS-------
--------------------
	signal s_x : std_logic_vector (7 downto 0);
	signal s_u : integer;
	signal s_y : integer;
	
	signal contador : integer;

	signal s_S1 : 

	signal s_x1, s_u1, s_y1 : integer; -- temporarios do process

-------------------
-------ARCH--------
-------------------
begin
	process (clock, load) 
	begin
		if (clock'event AND clock = '1' AND load = '1') then
			s_x <= x;
			s_y <= y;
			s_u <= u;
			if (contador < a) then
			
			--           S1	
			-- s_x1 <= x + dx;


			s_x1 <= s_S1;
			--             S2                     S3
			-- s_u1 <= s_u - (3 * s_x * s_u * dx) - (3 * s_y * dx);  2 somas
			---->       A  -          B          -       C;
			 
			----> A = s_u;
		
			--           M1  s_B    M2     						
			----> B = (3 * dx * s_x * s_u ) 3 mults;
			---->      [B1]   *   [B2]
			
			--
			
			--           M1   M4        
			----> C = (3 * dx * s_y) 2 mults;
			---->       [C1]  *  dx
			
			
			s_u1 <= s_S3;

			--             S4    M5
			-- s_y1 <= s_y + s_u * dx; 
			---->              [B2]
			
			s_y1 <= s_S4;
				
			s_x <= s_x1;
			s_u <= s_u1;
			s_y <= s_y1;
		
			contador <= contador + 1;
			end if;
		end if;
 
	end process;

-------------------
-----PORTMAPS------
-------------------
	-- s_x1 <= x + dx;
	S1: somador_m_bits port map(
								s_x,
								dx,
								'0',
								clock,
								s_x1,
								open,
								open

	);
	
	-- s_u1 <= s_u - (3 * s_x * s_u * dx)
	S2: somador_m_bits port map(
								s_u,  -- A = s_u
								s_B,
								'0',
								clock,
								s_S2,
								open,
								open

	);
	
	-- s_S3 = (s_S2 - (3 * s_y * dx)
	--                      C
	S3: somador_m_bits port map(
								s_S2, 
								s_C,
								'0',
								clock,
								s_S3,
								open,
								open

	);
	
	-- s_y1 = s_y + s_M5
	S4: somador_m_bits port map(
						s_y, 
						s_M5,
						'0',
						clock,
						s_S4,
						open,
						open

);
	



	-- 3 * dx 
	M1: Mult_Sequencial port map(
							"00000101", dx ,
							clock,
							load,
							open,
							open,
							s_M1
							);
	
	-- s_u * dx
	M2: Mult_Sequencial port map(
							s_x, s_u,
							clock,
							load,
							open,
							open,
							s_M2
							);
	-- M3 = M1 * M2
	M3: Mult_Sequencial port map(
							s_M1, s_M2,
							clock,
							load,
							open,
							open,
							s_B
							);

    -- s_C = s_M1 * s_y
	M4: Mult_Sequencial port map(
							s_M1, s_y,
							clock,
							load,
							open,
							open,
							s_C
							);
				
	-- s_u * dx
	M5: Mult_Sequencial port map(
		s_u, dx,
		clock,
		load,
		open,
		open,
		s_M5
		);
				
	y_final <= s_y;
	
end architecture arq_Diff_Eq;