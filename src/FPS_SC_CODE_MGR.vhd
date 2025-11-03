----------------------------------------------------------------------------------
-- Company.......: Université de Genève - DPNC
-- Author........: Terry Baltus
-- File..........: FPS_SC_CODE_MGR.vhd
-- Description...: Code manager
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
-- Entity FPS_SC_CODE_MGR: Manages the interaction between feeder managers and wrapper interface.
-- It processes requests, validates codes, and provides acknowledgment and error signals.
-- The entity uses a state machine to handle different states: IDLE, ACK, and ACK_ERR.

entity FPS_SC_CODE_MGR is
	Generic(
		x_reset_active : std_logic := '0');
	Port (
		x_nreset	: in  std_logic;
		x_clk 		: in  std_logic;

		--Interface with feeder managers---------
		x_code_0 	: in  std_logic_vector(1 downto 0);
		x_code_1 	: in  std_logic_vector(1 downto 0);
		x_code_2 	: in  std_logic_vector(1 downto 0);
		x_code_3 	: in  std_logic_vector(1 downto 0);
		x_code_4 	: in  std_logic_vector(1 downto 0);
		x_code_5 	: in  std_logic_vector(1 downto 0);

		--Wrapper interface
		x_req 		: in std_logic;
		x_ack 		: out std_logic;
		x_err 		: out std_logic;
		en 			: in std_logic_vector(5 downto 0));
end FPS_SC_CODE_MGR;	

-- ARCHITECTURE  ---------------------------------------------
Architecture rtl of FPS_SC_CODE_MGR is
-- Constants -------------------------------------------------
		
-- Types -----------------------------------------------------	
	
	type type_state is (IDLE, ACK, ACK_ERR);

-- aliases----------------------------------------------------
-- Signals ---------------------------------------------------
	
	signal sl_int_state  : type_state;
	signal sl_next_state : type_state;

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

		case(sl_int_state) is
			when IDLE =>
				if (x_req = '1') then
					if (not((en(0) = '1' and x_code_0 = "00") or
							(en(1) = '1' and x_code_1 = "00") or
							(en(2) = '1' and x_code_2 = "00") or
							(en(3) = '1' and x_code_3 = "00") or
							(en(4) = '1' and x_code_4 = "00") or
							(en(5) = '1' and x_code_5 = "00"))) then
						if (x_code_0 = "01" or 
							x_code_1 = "01" or 
							x_code_2 = "01" or 
							x_code_3 = "01" or 
							x_code_4 = "01" or
							x_code_5 = "01") then 
							sl_next_state <= ACK_ERR;
						else
							sl_next_state <= ACK;
						end if ;
					end if ;
				end if ;

			when ACK => 
				sl_next_state <= IDLE;

			when ACK_ERR => 
				sl_next_state <= IDLE;
		end case;

	end process;

	-------------------------------------------------------------------------------
	-- CLOCK process --------------------------------------------------------------
	p_clk : process (x_clk, x_nreset)
	begin
		if(x_nreset = x_reset_active) then
			sl_int_state 	<= IDLE;
		elsif (x_clk'event and x_clk = '1') then
			sl_int_state 	<= sl_next_state;
		end if;
	end process;
	
	-------------------------------------------------------------------------------
	-- OUTPUTS --------------------------------------------------------------------
	-------------------------------------------------------------------------------

	x_ack <= '1' when (sl_int_state = ACK or sl_int_state = ACK_ERR) else '0';
	x_err <= '1' when sl_int_state = ACK_ERR else '0';

end rtl;