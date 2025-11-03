library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.Numeric_STD.all;

-- ENTITY ----------------------------------------------------

entity FPS_SC_PRESCALER_tb is
end FPS_SC_PRESCALER_tb;

-- ARCHITECTURE  ---------------------------------------------
Architecture rtl of FPS_SC_PRESCALER_tb is
-- Constants -------------------------------------------------
	
	constant PRESCALER : integer := 3;

-- Types -----------------------------------------------------

-- aliases----------------------------------------------------
	
-- Signals ---------------------------------------------------

	signal x_nreset : std_logic;
	signal x_clk 	: std_logic;
	signal x_pulse	: std_logic;

----------------------------------------------
-- Procedure
	
-- Components ------------------------------------------------

	component FPS_SC_PRESCALER is
		Generic (x_reset_active : std_logic := '0';
				 x_prescaler : integer);
		Port 	(x_nreset 	: in std_logic;
				 x_clk	 	: in std_logic;
				 x_pulse 	: out std_logic);
	end component;

begin
	-------------------------------------------------------------------------------
	-- components instanciation
	-------------------------------------------------------------------------------

	FPS_SC_PRESCALER_DUT : FPS_SC_PRESCALER
	generic map(x_reset_active => '0',
				x_prescaler => PRESCALER)
	port map(x_nreset 	=> x_nreset,
			 x_clk 		=> x_clk,
			 x_pulse 	=> x_pulse);

	-------------------------------------------------------------------------------
	-- COMBINATORIAL --------------------------------------------------------------
	-------------------------------------------------------------------------------
	-------------------------------------------------------------------------------
	-- PROCESS --------------------------------------------------------------------
	-------------------------------------------------------------------------------

	p_clk : process  --50MHz
	begin
		x_clk <= '1';
		wait for 10 ns;
		x_clk <= '0';
		wait for 10 ns;
	end process;

	p_testbench : PROCESS
	begin
		x_nreset <= '0';
		wait for 40 ns;
		x_nreset <= '1';
		----------------------------------------------------
		report "TEST SUCCESSFULL ... " & time'image(now);
		---------------------------------------------------
		wait; -- will wait forever
	end process;

end rtl;