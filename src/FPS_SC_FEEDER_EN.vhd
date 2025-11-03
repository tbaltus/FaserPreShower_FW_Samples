----------------------------------------------------------------------------------
-- Company.......: Université de Genève - DPNC
-- Author........: Terry Baltus
-- File..........: FPS_SC_FEEDER_EN.vhd
-- Description...: Entity that enables the feeder according to the user input
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
use work.TOP_FASER_pkg.all;

--  Entity: FPS_SC_FEEDER_EN
--  Description: 
--    The FPS_SC_FEEDER_EN is responsible for managing the communication between 
--    multiple feeder managers (FPS_SC_FEEDER_MGR) and a code manager (FPS_SC_CODE_MGR).
--    It handles the feeder request, acknowledgment, error signals, and coordinates 
--    the enabling and communication signals to/from the feeder and code manager 
--    modules, enabling efficient control and error handling for multiple feeder units.

entity FPS_SC_FEEDER_EN is
	Generic(
		x_reset_active : std_logic := '0');
	Port (
		x_nreset	: in  std_logic;
		x_clk 		: in  std_logic;

		--Interface with feeders---------
		x_feeder_req : out std_logic_vector(5 downto 0);
		x_feeder_ack : in  std_logic_vector(5 downto 0);
		x_feeder_err : in  std_logic_vector(5 downto 0);

		--Wrapper interface
		x_req 		: in  std_logic;
		x_ack 		: out std_logic;
		x_err 		: out std_logic;
		en 			: in  std_logic_vector(5 downto 0)); -- connected to x_param_out(5 downto 0)
end FPS_SC_FEEDER_EN;	

-- ARCHITECTURE  ---------------------------------------------
Architecture rtl of FPS_SC_FEEDER_EN is
-- Constants -------------------------------------------------
		
-- Types -----------------------------------------------------	
	type t_int_code is array (0 to c_module_nb - 1) of std_logic_vector(1 downto 0);

-- aliases----------------------------------------------------
-- Signals ---------------------------------------------------

	signal sl_int_code : t_int_code;

-- Components ------------------------------------------------

	component FPS_SC_FEEDER_MGR is
		Generic(
			x_reset_active : std_logic := '0');
		Port (
			x_nreset	: in  std_logic;
			x_clk 		: in  std_logic;

			--Feeder interface---------
			x_start 	: out std_logic; --must be valid until ack
			x_ack 		: in std_logic;   --Valid for one clock cycle when feeder done
			x_err 		: in std_logic;   --Valid for one clock cycle if error when feeder done
			
			--Wrapper interface-----------
			x_req 		: in std_logic;
	   		en 			: in std_logic;

			--FPS_SC_GUI_MGMT interface-----------
	   		x_code 		: out std_logic_vector(1 downto 0));
	end component;	

	component FPS_SC_CODE_MGR is
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
	end component;

begin
	-------------------------------------------------------------------------------
	-- components instanciation
	-------------------------------------------------------------------------------

	GEN_FPS_SC_FEEDER_MGR: for i in 0 to 5 generate
	C_FPS_SC_FEEDER_MGR : FPS_SC_FEEDER_MGR
	generic map(
		x_reset_active 	=> x_reset_active)
	port map (
		x_nreset 	=> x_nreset,
		x_clk  		=> x_clk,
		x_start 	=> x_feeder_req(i),
		x_ack 		=> x_feeder_ack(i),
		x_err 		=> x_feeder_err(i),
		x_req 		=> x_req,
		en 			=> en(i),
		x_code 		=> sl_int_code(i));
	end generate GEN_FPS_SC_FEEDER_MGR;


	C_FPS_SC_CODE_MGR : FPS_SC_CODE_MGR
	generic map(
		x_reset_active 	=> x_reset_active)
	port map (
		x_nreset	=> x_nreset,
		x_clk 		=> x_clk,
		x_code_0 	=> sl_int_code(0),
		x_code_1 	=> sl_int_code(1),
		x_code_2 	=> sl_int_code(2),
		x_code_3 	=> sl_int_code(3),
		x_code_4 	=> sl_int_code(4),
		x_code_5 	=> sl_int_code(5),
		x_req 		=> x_req,
		x_ack 		=> x_ack,
		x_err 		=> x_err,
		en 			=> en);

	-------------------------------------------------------------------------------
	-- COMBINATORIAL --------------------------------------------------------------
	-------------------------------------------------------------------------------
	-------------------------------------------------------------------------------
	-- PROCESS --------------------------------------------------------------------
	-------------------------------------------------------------------------------
	-------------------------------------------------------------------------------
	-- COMBINATORIAL process ------------------------------------------------------

	-------------------------------------------------------------------------------
	-- CLOCK process --------------------------------------------------------------
	
	-------------------------------------------------------------------------------
	-- OUTPUTS --------------------------------------------------------------------
	-------------------------------------------------------------------------------

end rtl;