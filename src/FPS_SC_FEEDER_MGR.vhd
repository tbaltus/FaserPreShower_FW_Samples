----------------------------------------------------------------------------------
-- Company.......: Université de Genève - DPNC
-- Author........: Terry Baltus
-- File..........: FPS_SC_FEEDER_MGR.vhd
-- Description...: Individual management of feeder
-- Project Name..: FaserPreShower
-- Created.......: Aug 18, 2023
-- Version.......: -
--
-- Revision History:
-- Aug 18, 2023: file creation
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.Numeric_STD.all;

-- ENTITY ----------------------------------------------------
-- FPS_SC_FEEDER_MGR: Manages the interaction between the feeder, wrapper, and GUI interfaces.
-- It controls the feeder's start, acknowledges completion, handles errors, and communicates status codes.

entity FPS_SC_FEEDER_MGR is
	Generic(
		x_reset_active : std_logic := '0');
	Port (
		x_nreset	: in  std_logic;
		x_clk 		: in  std_logic;

		--Feeder interface---------
		x_start 	: out  std_logic; --must be valid until ack
		x_ack 		: in std_logic;   --Valid for one clock cycle when feeder done
		x_err 		: in std_logic;   --Valid for one clock cycle if error when feeder done
		
		--Wrapper interface-----------
		x_req 		: in std_logic;
   		en 			: in std_logic; --Connected to to x_param_out(module#)

		--FPS_SC_GUI_MGMT interface-----------
   		x_code 		: out std_logic_vector(1 downto 0));
end FPS_SC_FEEDER_MGR;	

-- ARCHITECTURE  ---------------------------------------------
Architecture rtl of FPS_SC_FEEDER_MGR is
-- Constants -------------------------------------------------
		
-- Types -----------------------------------------------------	
	
	type type_state is (IDLE, START);

-- aliases----------------------------------------------------
-- Signals ---------------------------------------------------
	
	signal sl_int_state  : type_state;
	signal sl_next_state : type_state;

	signal sl_int_code  : std_logic_vector(1 downto 0);
	signal sl_next_code : std_logic_vector(1 downto 0);

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

		sl_next_state 	<= sl_int_state;
		sl_next_code	<= sl_int_code;

		case(sl_int_state) is
			when IDLE =>
				if(x_req = '0') then
					sl_next_code <= "00";
				elsif(en = '1' and sl_int_code = "00") then
					sl_next_state <= START;
				end if;

			when START => 
				if(x_ack = '1') then
					if(x_err = '1') then
						sl_next_code <= "01";
						sl_next_state <= IDLE;
					else
						sl_next_code <= "10";
						sl_next_state <= IDLE;
					end if;
				end if;
		end case;

	end process;

	-------------------------------------------------------------------------------
	-- CLOCK process --------------------------------------------------------------
	p_clk : process (x_clk, x_nreset)
	begin
		if(x_nreset = x_reset_active) then
			sl_int_state 	<= IDLE;
			sl_int_code		<= (others => '0');
		elsif (x_clk'event and x_clk = '1') then
			sl_int_state 	<= sl_next_state;
			sl_int_code		<= sl_next_code;
		end if;
	end process;
	
	-------------------------------------------------------------------------------
	-- OUTPUTS --------------------------------------------------------------------
	-------------------------------------------------------------------------------

	x_start <= '1' when sl_int_state = START else '0';
	x_code 	<= sl_int_code;


end rtl;