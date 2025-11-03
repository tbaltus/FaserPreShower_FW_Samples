library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.Numeric_STD.all;

-- ENTITY ----------------------------------------------------
-- FPS_SC_PRESCALER: A prescaler module that generates a pulse output based on a configurable prescaler value. 
-- It counts clock cycles and outputs a pulse signal when the count reaches the preset threshold.
-- A pulse (1 clock cycle width) will be asserted every x_prescaler clock cycles.
-- f(x_pulse) = f(x_clk)/x_prescaler

entity FPS_SC_PRESCALER is
	Generic (
		x_reset_active : std_logic := '0';
		x_prescaler : integer);
	Port (
		x_nreset 	: in std_logic;
		x_clk	 	: in std_logic;

		--FPS_SC_SPI interface-----
		x_pulse 	: out std_logic);
end FPS_SC_PRESCALER;

-- ARCHITECTURE  ---------------------------------------------
Architecture rtl of FPS_SC_PRESCALER is

-- Constants -------------------------------------------------
-- Types -----------------------------------------------------		
-- aliases----------------------------------------------------
-- Signals ---------------------------------------------------

	signal sl_int_count, sl_next_count : integer := 0;

-- Components ------------------------------------------------

begin
	-------------------------------------------------------------------------------
	-- components instanciation
	-------------------------------------------------------------------------------
	-------------------------------------------------------------------------------
	-- COMBINATORIAL --------------------------------------------------------------
	-------------------------------------------------------------------------------
	-------------------------------------------------------------------------------
	-- PROCESS --------------------------------------------------------------------
	-------------------------------------------------------------------------------
	-------------------------------------------------------------------------------
	-- COMBINATORIAL process ------------------------------------------------------
	p_state : process(all)
	begin
		sl_next_count <= sl_int_count;

		if(sl_int_count = x_prescaler - 1) then
			sl_next_count <= 0;
		else
			sl_next_count <= sl_int_count + 1;
		end if;
	end process;

	-------------------------------------------------------------------------------
	-- CLOCK process --------------------------------------------------------------
	p_clk : process (x_clk, x_nreset)
	begin
		if(x_nreset = x_reset_active) then
			sl_int_count <= 0;
		elsif(x_clk'event and x_clk = '1') then
			sl_int_count <= sl_next_count;
		end if;
	end process;
	
	-------------------------------------------------------------------------------
	-- OUTPUTS --------------------------------------------------------------------
	-------------------------------------------------------------------------------

	x_pulse <= '1' when (sl_int_count = x_prescaler - 1) else '0';

end rtl;