library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Diff_Eq is
   port(
         x, u, y, dx : in  std_logic_vector (7 downto 0);
		 a           : in  std_logic_vector (7 downto 0);
         x_out, u_out, y_out : out std_logic_vector (7 downto 0);
	     S1_out, S2_out, S3_out, S4_out : out std_logic_vector (7 downto 0); 
	     A_OUT, B_OUT, C_OUT, BNEG_OUT, CNEG_OUT : out std_logic_vector (7 downto 0);
		 M1_OUT, M2_OUT, M3_OUT, M4_OUT, M5_OUT : out std_logic_vector (15 downto 0);
         clock       : in  std_logic;
         load        : in  std_logic;
         y_final     : out std_logic_vector (7 downto 0)
      );
end entity Diff_Eq;



architecture arq_Diff_Eq of Diff_Eq is
---------------------
-----COMPONENTS------
---------------------
	component somador_m_bits is
		GENERIC (Z : integer := 8);
		port (
				a, b        : in  std_logic_vector(Z-1 downto 0);
				c0, clock   : in  std_logic;
				s           : out std_logic_vector(Z-1 downto 0);
				cout, overf : out std_logic
			 );
	end component;
--
	component Mult_Booth is -- MUDAR PARA BOOTH
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
	signal s_u : std_logic_vector (7 downto 0);
	signal s_y : std_logic_vector (7 downto 0);

	signal s_S1 : std_logic_vector (7 downto 0); -- soma1, soma2, etc...
	signal s_S2 : std_logic_vector (7 downto 0);
	signal s_S3 : std_logic_vector (7 downto 0);
	signal s_S4 : std_logic_vector (7 downto 0);

	signal s_A  : std_logic_vector (15 downto 0);
	signal s_B  : std_logic_vector (15 downto 0); -- sao de 16 bits pq contém produtos com multiplicador
	signal s_C  : std_logic_vector (15 downto 0);

	

	signal Bnegado : std_logic_vector (7 downto 0);
	signal Cnegado : std_logic_vector (7 downto 0);	
	
	signal s_M1 : std_logic_vector (15 downto 0); -- mult1, mult2, etc...
	signal s_M2 : std_logic_vector (15 downto 0);
	signal s_M3 : std_logic_vector (15 downto 0);
	signal s_M4 : std_logic_vector (15 downto 0);
	signal s_M5 : std_logic_vector (15 downto 0); -- 16 bits pq multiplicou 
	

	signal s_x1, s_u1, s_y1 : std_logic_vector (7 downto 0); -- temporarios do process

-------------------
-------ARCH--------
-------------------
begin
	process (clock, load, s_x) 
	begin
		if (clock'event AND clock = '1' AND load = '1') then
			s_x <= x;  -- so carrega no primeiro ciclo
			s_y <= y;
			s_u <= u;
            
		else 	
			if (rising_edge(clock)  AND (s_x < a)) then				
			    Bnegado <= not(s_B (7 downto 0));
                Cnegado <= not(s_C (7 downto 0));
				

                s_x1 <= s_S1 (7 downto 0);
			    s_u1 <= s_S3 (7 downto 0);
				s_y1 <= s_S4 (7 downto 0);
						
				--- para debugar	
				
				S1_out <= s_S1;
				S2_out <= s_S2;
				S3_out <= s_S3;
			    S4_out <= s_S4;
				
                
				B_OUT  <= s_B (7 downto 0);
				BNEG_OUT <= Bnegado (7 downto 0);
				
				C_OUT <= s_C(7 downto 0);
				CNEG_OUT <= Cnegado (7 downto 0);
			
				M1_OUT <= s_M1;
				M2_OUT <= s_M2;
				M3_OUT <= s_M3;
				M4_OUT <= s_M4;
				M5_OUT <= s_M5;
	
			-------
				s_x <= s_x1;
				s_u <= s_u1;
				s_y <= s_y1;				
				y_final <= s_y (7 downto 0);
                
                x_out <= s_x;
				y_out <= s_y;
			    u_out <= s_u;
				
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
								s_S1,
								open,
								open

	);
	
	-- s_S2 <= s_u - (3 * s_x * s_u * dx)
	--          A  -           B
	S2: somador_m_bits port map(
								s_u,
								Bnegado,
								'1',
								clock,
								s_S2,
								open,
								open

	);
	
	-- s_S3 = s_S2 - (3 * s_y * dx)
	--                      C
	S3: somador_m_bits port map(
								s_S2, 
								Cnegado,
								'1',
								clock,
								s_S3,
								open,
								open

	);
	
	-- s_y1 = s_y + s_M5
	S4: somador_m_bits port map(
						s_y (7 downto 0), 
						s_M5(7 downto 0),
						'0',
						clock,
						s_S4,
						open,
						open

);
	

	-- 3 * dx 
	M1: Mult_Booth port map(
							"00000011", dx(7 downto 0),
							clock,
							load,
							open,
							open,
							s_M1
							);
	
	-- s_u * s_x
	M2: Mult_Booth port map(
							s_x(7 downto 0), s_u (7 downto 0),
							clock,
							load,
							open,
							open,
							s_M2
							);
							
	-- s_B = M3 = M1 * M2
	M3: Mult_Booth port map(
							s_M1(7 downto 0), s_M2(7 downto 0),
							clock,
							load,
							open,
							open,
							s_B
							);

    -- s_C = s_M1 * s_y
	M4: Mult_Booth port map(
							s_M1(7 downto 0), s_y (7 downto 0),
							clock,
							load,
							open,
							open,
							s_C
							);
				
	-- s_u * dx
	M5: Mult_Booth port map(
								s_u(7 downto 0), dx(7 downto 0),
								clock,
								load,
								open,
								open,
								s_M5
		);
				
	
	
end architecture arq_Diff_Eq;


	--           S1	
			-- s_x1 <= x + dx;

			--             S2                     S3
			-- s_u1 <= s_u - (3 * s_x * s_u * dx) - (3 * s_y * dx);  2 somas
			---->       A  -          B          -       C;
			 
			----> A = s_u;
		
			--            M1      M2     						
			----> B = (3 * dx * s_x * s_u ) 3 mults;
			---->      [s_M1]   *   [s_M2]
			
			--
			
			--           M1   M4        
			----> C = (3 * dx * s_y) 2 mults;
			---->       [s_M1]  *  dx
			
			
			--             S4    M5
			-- s_y1 <= s_y + s_u * dx; 
			---->              [s_M2]
