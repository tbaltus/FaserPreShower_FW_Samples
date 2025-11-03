----------------------------------------------------------------------------------
-- Company.......: Université de Genève - DPNC
-- Author........: Terry Baltus
-- File..........: FPS_SC_SPI.vhd
-- Description...: SPI driver Prod ASIC
-- Project Name..: FaserPreShower
-- Created.......: Jun 29, 2022
-- Version.......: -
--
-- Revision History:
-- Oct 05, 2022: file creation
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.Numeric_STD.all;
use work.FPS_SlowControl.all;

-- ENTITY ----------------------------------------------------
-- FPS_SC_SPI: SPI (Serial Peripheral Interface) controller for communication with an ASIC.
-- This entity handles the communication protocol, managing the signals clock (x_clk_SPI), chip select (x_CS),
-- and data output (x_mosi) based on the feeder interface (x_start, x_ack, x_reg).
-- It includes state management and timing control to ensure correct data transmission.

-- Required components inside the entity :
-- FPS_SC_PRESCALER -> f(x_pulse) = f(x_clk)/x_prescaler (each x_pulse toggles x_spi_clk) (@50 MHz -> f(x_spi_clk) = 8.33 MHz)

entity FPS_SC_SPI is
	Generic(
		x_reset_active : std_logic := '0');
	Port (
		x_nreset	: in  std_logic;
		x_clk 		: in  std_logic;

		--Feeder interface---------
		x_start 	: in  std_logic; --must be valid until ack
		x_ack 		: out std_logic; --Valid for one clock cycle when done
		x_reg 		: in  std_logic_vector(19 downto 0); --must remain unchanged until ack
		
		--ASIC interface-----------
		x_clk_SPI 	: out std_logic;
   		x_CS 		: out std_logic;
   		x_mosi 		: out std_logic);
end FPS_SC_SPI;	

-- ARCHITECTURE  ---------------------------------------------
Architecture rtl of FPS_SC_SPI is
-- Constants -------------------------------------------------

	constant C_PRESCALER : integer := 3;
		
-- Types -----------------------------------------------------	
	
	type type_state is (IDLE, CLK0, CLK1, CS0, ACK);
	subtype cnt_type is integer range 0 to 20;

-- aliases----------------------------------------------------
-- Signals ---------------------------------------------------
	
	signal sl_int_pulse : std_logic;
	
	signal sl_int_state	 : type_state;
	signal sl_next_state : type_state;

	signal sl_int_count  : cnt_type := 20;
	signal sl_next_count : cnt_type;

-- Components ------------------------------------------------

begin
	-------------------------------------------------------------------------------
	-- components instanciation
	-------------------------------------------------------------------------------

	C_FPS_SC_PRESCALER : FPS_SC_PRESCALER
	generic map(
		x_reset_active 	=> x_reset_active,
		x_prescaler 	=> C_PRESCALER)
	port map (
		x_nreset => x_nreset,
		x_clk 	 => x_clk,
		x_pulse  => sl_int_pulse); --sl_int_pulse is one at every edge (falling and rising) of x_clk_spi

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
		sl_next_state 	<= sl_int_state;
		sl_next_count	<= sl_int_count;

		case(sl_int_state) is
			when IDLE =>
				sl_next_count <= 20;
				if(x_start = '1' and sl_int_pulse = '1') then
					sl_next_state 	<= CLK0;
				end if;

			when CLK0 =>
				if(sl_int_pulse = '1') then
					sl_next_state <= CLK1;
				end if;

			when CLK1 =>
				if(sl_int_pulse = '1') then
					if(sl_int_count = 0) then
						sl_next_state <= CS0;
					else
						sl_next_count <= sl_int_count - 1;
						sl_next_state <= CLK0;
					end if;
				end if;

			when CS0 =>
				if(sl_int_pulse = '1') then
					sl_next_state <= ACK;
				end if;

			when ACK => 
				sl_next_state <= IDLE;

		end case;
	end process;

	-------------------------------------------------------------------------------
	-- CLOCK process --------------------------------------------------------------
	p_clk : process (x_clk, x_nreset)
	begin
		if(x_nreset = x_reset_active) then
			sl_int_state <= IDLE;
			sl_int_count <= 20;
		elsif (x_clk'event and x_clk = '1') then
			sl_int_state <= sl_next_state;
			sl_int_count <= sl_next_count;
		end if;
	end process;
	
	-------------------------------------------------------------------------------
	-- OUTPUTS --------------------------------------------------------------------
	-------------------------------------------------------------------------------

	x_clk_SPI 	<= '1' when (sl_int_state = CLK1) else '0';
	x_mosi		<= '0' when (sl_int_state = IDLE or sl_int_state = CS0 or sl_int_state = ACK or sl_int_count = 0) else x_reg(sl_int_count - 1);
	x_CS 		<= '1' when (sl_int_state = IDLE or sl_int_state = ACK) else '0';
	x_ack 		<= '1' when (sl_int_state = ACK) else '0';

end rtl;